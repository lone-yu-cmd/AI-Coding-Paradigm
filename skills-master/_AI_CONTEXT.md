# Skills Master 模块

> 技能管理系统的核心模块，提供技能模板的安装、更新和列表功能。
> 文档大小限制：< 10KB

---

## 模块职责（Responsibility）

<!-- AUTO_SYNC_START -->

### 核心职责

Skills Master 是 Skill 生态系统的包管理器，负责管理和分发标准技能模板库。它提供了一套标准化的技能模板，可以快速部署到任何项目中。

### 模块边界

- **负责**：
  - 维护 13 个标准技能模板库
  - 提供技能安装、列表查询功能
  - 管理技能模板的目录结构和文件组织
  - 作为元技能（Meta-Skill）协调其他技能的安装

- **不负责**：
  - 技能的具体业务逻辑实现（由各技能模板自身负责）
  - 技能的运行时执行（由 IDE/AI 负责）
  - 用户项目的代码修改（由具体技能负责）
  - 技能模板的创建（由 `skill-creator` 技能负责）

<!-- AUTO_SYNC_END -->

---

## 文件结构（File Structure）

<!-- AUTO_SYNC_START -->

```
skills-master/
├── SKILL.md                          # 技能管理器主入口，定义元技能
├── scripts/                          # 安装脚本目录
│   └── install.py                    # Python 安装脚本（2.28 KB）
└── assets/                           # 资源目录
    └── skill-templates/              # 标准技能模板库（13个）
        ├── add-in-skills-master/     # 添加/更新技能到库
        ├── context-ai-sync/          # AI 上下文文档系统
        ├── auto-committer/           # 自动化 Git 提交
        ├── context-code-explainer/           # 代码分析报告生成
        ├── git-diff-requirement/     # 需求匹配分析
        ├── context-aware-coding/     # 上下文感知编码
        ├── git-diff-requirement/     # Git Diff 需求分析
        ├── playwright-analyze-page/  # 页面结构分析
        ├── context-project-analyzer/         # 项目分析器

        ├── skill-creator/            # 技能创建器
        └── subagent-creator/         # 子智能体创建器
```

### 文件说明

| 文件 | 职责 | 重要程度 |
|-----|-----|---------|
| `SKILL.md` | 定义 skills-master 元技能，列出所有可用技能模板和使用说明 | ⭐⭐⭐ |
| `scripts/install.py` | Python 安装脚本，实现技能模板的复制和部署逻辑 | ⭐⭐⭐ |
| `assets/skill-templates/` | 存储所有标准技能模板，每个子目录是一个完整的技能 | ⭐⭐⭐ |

<!-- AUTO_SYNC_END -->

---

## 关键接口（Key Interfaces）

<!-- AUTO_SYNC_START -->

### 命令行接口

```bash
# 列出所有可用的技能模板
python3 skills/skills-master/scripts/install.py --list

# 安装指定技能
python3 skills/skills-master/scripts/install.py --name <skill-name>

# 安装所有技能
python3 skills/skills-master/scripts/install.py --all
```

### 主要函数/方法

| 名称 | 参数 | 返回值 | 说明 |
|-----|-----|-------|-----|
| `install_skill(skill_name)` | `skill_name: str` | `bool` | 从模板目录复制技能到目标位置 |
| `list_templates()` | 无 | `list[str]` | 列出所有可用的技能模板名称 |

<!-- AUTO_SYNC_END -->

---

## 依赖关系（Dependencies）

<!-- AUTO_SYNC_START -->

### 内部依赖（本项目模块）

| 依赖模块 | 用途 | 关键接口 |
|---------|-----|---------|
| 无 | skills-master 是独立模块，不依赖其他项目模块 | - |

### 外部依赖（第三方库）

| 依赖名称 | 版本 | 用途 |
|---------|-----|-----|
| Python | 3.6+ | 运行安装脚本 |
| `os` | 标准库 | 文件路径操作 |
| `shutil` | 标准库 | 目录复制 |
| `argparse` | 标准库 | 命令行参数解析 |

### 被依赖情况

本模块被以下模块依赖：
- 所有技能模板（安装时依赖）
- `skill-creator`（创建新技能后需要添加到 skills-master）
- `add-in-skills-master`（更新技能模板库）

<!-- AUTO_SYNC_END -->

---

## 常见操作指南（Common Operations）

<!-- MANUAL_START -->

### 如何查看可用技能

```bash
# 切换到技能目录的上级目录
cd /path/to/your/project/.codebuddy

# 列出所有可用技能模板
python3 skills/skills-master/scripts/install.py --list
```

### 如何安装单个技能

```bash
# 示例：安装 auto-committer 技能
python3 skills/skills-master/scripts/install.py --name auto-committer

# 安装后，建议运行 skill-creator 更新 README 索引
```

### 如何安装所有技能

```bash
# 一次性安装所有 13 个标准技能
python3 skills/skills-master/scripts/install.py --all
```

### 如何添加新技能到模板库

1. 使用 `add-in-skills-master` 技能
2. 提供技能的完整目录路径
3. 技能会被复制到 `assets/skill-templates/` 目录
4. 更新 `SKILL.md` 中的技能列表

### 注意事项

- ⚠️ **路径要求**：必须在 skills 目录的上级目录运行安装命令
- ⚠️ **重复安装**：如果技能已存在，脚本会跳过安装并显示警告
- ⚠️ **更新索引**：安装新技能后，建议运行 `skill-creator` 更新项目 README
- ⚠️ **模板完整性**：每个技能模板必须包含 `SKILL.md` 文件

<!-- MANUAL_END -->

---

## 标准技能模板列表（Skill Templates）

<!-- MANUAL_START -->

### 技能分类

#### 🛠️ 开发工具类
- **auto-committer**: 自动化 Git 提交，生成规范的提交信息
- **context-code-explainer**: 生成结构化的代码分析报告
- **git-diff-requirement**: 分析代码变更与需求匹配度，检测缺陷
- **git-diff-requirement**: 分析代码变更是否符合需求

#### 📝 文档管理类
- **context-ai-sync**: AI 上下文文档系统，自动同步项目文档
- **context-aware-coding**: 管理 `AI_README.md`，实施上下文优先架构
- **context-project-analyzer**: 为新/遗留项目生成引导文档


#### 🏗️ 架构设计类
- **skill-creator**: 创建新技能并维护索引
- **subagent-creator**: 生成子智能体配置文档

#### 🔧 工具集成类
- **playwright-analyze-page**: 连接 Chrome 浏览器分析页面结构
- **add-in-skills-master**: 添加/更新技能模板到库

### 技能使用频率

| 频率 | 技能列表 |
|-----|---------|
| 高频 | `auto-committer`, `git-diff-requirement`, `context-ai-sync` |
| 中频 | `git-diff-requirement`, `context-code-explainer`, `context-requirements-analysis` |
| 低频 | `context-project-analyzer`, `skill-creator`, `subagent-creator` |
| 按需 | `playwright-analyze-page`, `add-in-skills-master` |

<!-- MANUAL_END -->

---

## 代码示例（Code Examples）

<!-- MANUAL_START -->

### 基本用法：列出和安装技能

```bash
# 1. 进入项目的 .codebuddy 目录
cd /path/to/your/project/.codebuddy

# 2. 查看可用技能
python3 skills/skills-master/scripts/install.py --list

# 输出示例：
# Available Skill Templates:
# - add-in-skills-master
# - context-ai-sync
# - auto-committer
# ...

# 3. 安装特定技能
python3 skills/skills-master/scripts/install.py --name context-ai-sync

# 输出示例：
# Successfully installed skill: context-ai-sync
```

### 高级用法：批量安装和验证

```bash
# 1. 安装所有技能
python3 skills/skills-master/scripts/install.py --all

# 2. 验证安装结果
ls -la skills/

# 3. 检查特定技能的 SKILL.md
cat skills/auto-committer/SKILL.md
```

### Python 脚本集成示例

```python
import subprocess
import os

def install_skill_programmatically(skill_name):
    """通过 Python 代码安装技能"""
    script_path = "skills/skills-master/scripts/install.py"
    
    result = subprocess.run(
        ["python3", script_path, "--name", skill_name],
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        print(f"✅ {skill_name} installed successfully")
    else:
        print(f"❌ Failed to install {skill_name}: {result.stderr}")
    
    return result.returncode == 0

# 使用示例
install_skill_programmatically("auto-committer")
```

<!-- MANUAL_END -->

---

## 已知问题与限制（Known Issues & Limitations）

<!-- MANUAL_START -->

### 当前限制

- **路径依赖**：安装脚本假设在 `skills/` 目录的上级运行，路径计算依赖目录结构
- **覆盖保护**：如果技能已存在，脚本会跳过安装，不支持强制覆盖或版本更新
- **无版本管理**：不支持技能模板的版本控制和升级检查
- **单向操作**：只支持安装，不支持卸载或回滚
- **依赖检查**：不检查技能之间的依赖关系

### 待改进项

- [ ] 添加 `--force` 参数支持强制覆盖现有技能
- [ ] 实现技能版本管理和升级机制
- [ ] 添加技能卸载功能
- [ ] 支持从远程仓库拉取最新模板
- [ ] 添加技能依赖关系检查和自动安装
- [ ] 改进路径检测，支持更灵活的目录结构

<!-- MANUAL_END -->

---

## 变更历史（Change History）

<!-- AUTO_SYNC_START -->

| 日期 | 变更类型 | 说明 |
|-----|---------|-----|
| 2026-02-04 | 文档创建 | 初始化 _AI_CONTEXT.md 文档 |

<!-- AUTO_SYNC_END -->

---

> 📅 本文档由 AI Context Sync Skill 生成  
> 🔄 AUTO_SYNC 区域会在代码变更时自动更新  
> ✏️ MANUAL 区域供人工编辑，不会被自动覆盖
