import json
import os
import sys
import re
import questionary
from questionary import Choice, Separator
from prompt_toolkit import Application
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.layout.containers import Window, HSplit
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.layout.layout import Layout
from prompt_toolkit.formatted_text import HTML
from prompt_toolkit.styles import Style

# 配置路径
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RULES_DIR = os.path.join(BASE_DIR, 'rules')
OUTPUT_FILE = os.path.join(BASE_DIR, 'rule.md')

class Color:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_header(text):
    print(f"\n{Color.HEADER}{Color.BOLD}=== {text} ==={Color.ENDC}")

def print_info(text):
    print(f"{Color.CYAN}{text}{Color.ENDC}")

def print_success(text):
    print(f"{Color.GREEN}{text}{Color.ENDC}")

def load_rules():
    """加载所有规则文件"""
    rules = []
    if not os.path.exists(RULES_DIR):
        print(f"{Color.FAIL}Rules directory not found: {RULES_DIR}{Color.ENDC}")
        return rules
    
    files = sorted([f for f in os.listdir(RULES_DIR) if f.endswith('.json')])
    for f in files:
        try:
            with open(os.path.join(RULES_DIR, f), 'r', encoding='utf-8') as fp:
                rule_data = json.load(fp)
                # 简单的校验
                if 'id' not in rule_data or 'options' not in rule_data:
                    print(f"{Color.WARNING}Skipping invalid rule file: {f}{Color.ENDC}")
                    continue
                rules.append(rule_data)
        except Exception as e:
            print(f"{Color.FAIL}Error loading {f}: {e}{Color.ENDC}")
    return rules

def process_inputs(option):
    """处理选项中的自定义输入变量"""
    content = option.get('content', '')
    inputs = option.get('inputs', [])
    
    if not inputs:
        return content
    
    print_info(f"  > 需要配置详细信息 ({option.get('label')}):")
    replacements = {}
    for inp in inputs:
        key = inp.get('key')
        prompt_text = inp.get('prompt', key)
        default_val = inp.get('default', '')
        
        # 使用 questionary 获取输入
        value = questionary.text(
            f"    {prompt_text}:", 
            default=default_val
        ).ask()
        
        if value is None: # 用户取消
            sys.exit(0)
            
        replacements[key] = value.strip()
        
    # 执行替换
    try:
        # 使用 format 进行替换，允许 content 中包含 {key}
        # 为了防止 content 中有其他花括号（如代码块），我们需要小心
        # 这里简单起见，我们假设 content 中的花括号都是变量，或者用户需要转义
        # 更稳健的做法是使用正则替换
        for key, val in replacements.items():
            pattern = r'\{' + re.escape(key) + r'\}'
            content = re.sub(pattern, str(val), content)
    except Exception as e:
        print(f"{Color.WARNING}  Template rendering warning: {e}{Color.ENDC}")
        
    return content

def custom_select(title, options, multi=False):
    """
    自定义选择器，支持 'd' 查看详情，'e' 编辑内容
    """
    selected_indices = set()
    current_index = 0
    
    # 过滤掉 Separator，只保留真实选项
    real_options = [opt for opt in options if not isinstance(opt, Separator)]
    
    # 映射回原始 options 列表中的索引，用于显示 Separator
    # 这里简化处理，只显示真实选项列表
    
    kb = KeyBindings()

    @kb.add('c-c')
    def exit_(event):
        event.app.exit(result=None)

    @kb.add('up')
    def up(event):
        nonlocal current_index
        current_index = (current_index - 1) % len(real_options)

    @kb.add('down')
    def down(event):
        nonlocal current_index
        current_index = (current_index + 1) % len(real_options)

    if multi:
        @kb.add('space')
        def toggle(event):
            if current_index in selected_indices:
                selected_indices.remove(current_index)
            else:
                selected_indices.add(current_index)
    
    @kb.add('enter')
    def enter(event):
        if not multi:
            selected_indices.add(current_index)
        event.app.exit(result=list(selected_indices))

    @kb.add('d')
    def show_detail(event):
        opt = real_options[current_index]
        # 假设 value 是 dict，包含 description
        # 如果 value 是 CUSTOM_TOKEN 或 SKIP_TOKEN，可能没有 description
        value = opt.value
        desc = ""
        if isinstance(value, dict):
            desc = value.get('description', 'No description available.')
            content = value.get('content', '')
            if content:
                desc += f"\n\nContent Preview:\n{content[:200]}..."
        elif value == "___CUSTOM___":
            desc = "手动输入自定义规则内容。"
        elif value == "___SKIP___":
            desc = "跳过当前规则配置。"
        
        # 清屏并打印详情，然后重新绘制
        # 由于 prompt_toolkit 是全屏应用模式（这里 full_screen=False），
        # 直接 print 会破坏布局。
        # 我们可以在下方显示详情区域，或者弹窗。
        # 简单起见，我们更新一个状态变量，让 get_text 渲染详情
        nonlocal detail_msg
        detail_msg = desc

    @kb.add('e')
    def edit_content(event):
        opt = real_options[current_index]
        value = opt.value
        if isinstance(value, dict):
            # 退出当前 app，进入编辑模式
            # 但这里比较麻烦，因为 app.run() 是阻塞的。
            # 我们可以先 exit，返回一个特殊信号，让外层处理编辑，然后再回来？
            # 或者使用 suspend_to_background (复杂)
            # 简单方案：标记编辑状态，退出 app，在外层处理完后再重新进入 custom_select
            # 但这样会丢失当前的选择状态（除非传入）
            event.app.exit(result=('EDIT', current_index))
        else:
            nonlocal detail_msg
            detail_msg = "此选项不支持编辑 (仅预定义规则内容可编辑)"

    detail_msg = None

    def get_text():
        text = []
        text.append(('', f'{title}\n'))
        
        for i, opt in enumerate(real_options):
            prefix = "  "
            if multi:
                prefix = "[x] " if i in selected_indices else "[ ] "
            
            style = ''
            if i == current_index:
                style = 'class:selected'
                prefix = "> " + prefix
            else:
                prefix = "  " + prefix

            text.append((style, f'{prefix}{opt.title}\n'))
            
        text.append(('', '\n[d]详情 [e]编辑 [Enter]确认'))
        if multi:
            text.append(('', ' [Space]选择'))
        
        if detail_msg:
            text.append(('class:detail', f'\n\n--- Detail ---\n{detail_msg}'))
            
        return text

    layout = Layout(HSplit([Window(content=FormattedTextControl(text=get_text))]))
    style = Style.from_dict({
        'selected': 'fg:cyan bold',
        'detail': 'fg:yellow',
    })
    
    app = Application(layout=layout, key_bindings=kb, full_screen=False, style=style)
    return app.run()

def process_rule(rule):
    """处理单个规则"""
    print_header(rule.get('title', 'Unknown Rule'))
    description = rule.get('description', '')
    if description:
        print(f"{Color.CYAN}{description}{Color.ENDC}")
    
    options = rule.get('options', [])
    if not options:
        return ""

    rule_type = rule.get('type', 'single_select')
    # 强制允许跳过，不再依赖配置文件中的 allow_skip
    allow_skip = True 
    
    SKIP_TOKEN = "___SKIP___"
    CUSTOM_TOKEN = "___CUSTOM___"

    # 构建 Choices
    choices = []
    for opt in options:
        choices.append(Choice(
            title=f"{opt.get('label')}",
            value=opt
        ))
    
    # 添加自定义选项
    # choices.append(Separator()) # custom_select 暂不支持 Separator 显示，先忽略
    choices.append(Choice(title="自定义内容 (手动输入)", value=CUSTOM_TOKEN))

    if allow_skip:
        # choices.append(Separator())
        choices.append(Choice(title="跳过此规则", value=SKIP_TOKEN))

    selected_opts = []
    
    while True:
        # 使用自定义选择器
        result = custom_select(
            "请选择 (上下键移动):", 
            choices, 
            multi=(rule_type == 'multi_select')
        )
        
        if result is None: # Cancelled
            sys.exit(0)
            
        if isinstance(result, tuple) and result[0] == 'EDIT':
            # 进入编辑模式
            idx = result[1]
            opt_to_edit = choices[idx].value
            # 使用 questionary.text 编辑内容
            new_content = questionary.text(
                f"编辑 '{opt_to_edit.get('label')}' 的内容 (按 Enter 保存):",
                default=opt_to_edit.get('content', ''),
                multiline=False
            ).ask()
            
            if new_content is not None:
                opt_to_edit['content'] = new_content
                print_success("内容已更新")
            continue # 重新进入选择界面
            
        # 正常返回结果 (indices list)
        selected_indices = result
        
        # 转换索引为选项值
        answer_values = [choices[i].value for i in selected_indices]
        
        if rule_type == 'multi_select':
            if SKIP_TOKEN in answer_values:
                selected_opts = []
            else:
                selected_opts = answer_values
        else:
            # 单选
            if not answer_values: # 没选
                 # 如果是单选且没选，可能需要提示？或者默认跳过？
                 # 这里假设必须选一个，或者选跳过
                 # 但 custom_select 允许不选直接回车（如果 current_index 没加进去）
                 # 修正 custom_select 逻辑：单选回车时默认选中当前
                 pass
            
            if SKIP_TOKEN in answer_values:
                selected_opts = []
            elif answer_values:
                selected_opts = [answer_values[0]]
            else:
                selected_opts = [] # Should not happen if logic is correct
        
        break

    # 处理选中的内容
    selected_contents = []
    for opt in selected_opts:
        if opt == CUSTOM_TOKEN:
            custom_content = questionary.text("请输入自定义内容 (支持 Markdown):").ask()
            if custom_content:
                print_success("已添加自定义内容")
                selected_contents.append(custom_content)
        elif opt and opt != SKIP_TOKEN: # 过滤掉 None 和 SKIP_TOKEN
            print_success(f"已选择: {opt.get('label')}")
            content = process_inputs(opt)
            selected_contents.append(content)

    if not selected_contents:
        return ""

    # 添加规则标题
    rule_title = rule.get('title')
    if rule_title:
        return f"## {rule_title}\n" + "\n\n".join(selected_contents)

    return "\n\n".join(selected_contents)

def main():
    print_header("Rule Master - AI Coding 规范生成器")
    print_info("将引导您生成项目的 rule.md 文件...")
    
    rules = load_rules()
    if not rules:
        print(f"{Color.FAIL}没有找到规则定义文件。请检查 rules/ 目录。{Color.ENDC}")
        return

    final_content = []
    
    # 添加文件头
    final_content.append("# Project Rules\n")
    final_content.append("> Generated by Rule Master\n")

    for rule in rules:
        content = process_rule(rule)
        if content:
            final_content.append(content)
            print_success("规则已添加。")
        else:
            print_info("规则已跳过。")

    # 自定义规则交互
    print_header("自定义规则")
    while questionary.confirm("是否添加自定义规则?", default=False).ask():
        title = questionary.text("请输入规则标题 (例如: 'My Custom Rule'):").ask()
        if not title:
            continue
        
        content = questionary.text("请输入规则内容 (支持 Markdown):").ask()
        if not content:
            continue
            
        final_content.append(f"## {title}\n\n{content}")
        print_success(f"已添加自定义规则: {title}")

    # 写入文件
    try:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write("\n".join(final_content))
        print_header("生成完成")
        print_success(f"文件已生成: {OUTPUT_FILE}")
    except Exception as e:
        print(f"{Color.FAIL}写入文件失败: {e}{Color.ENDC}")

if __name__ == '__main__':
    main()