#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SubAgent Creator Script
用于创建子智能体配置文件并维护索引
"""

import os
import argparse
import sys
import re
from datetime import datetime

# 获取当前脚本目录
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))


def find_project_root(current_dir):
    """
    查找项目根目录
    向上查找直到找到包含 .git 或其他标识的目录
    """
    search_dir = current_dir
    for _ in range(10):  # 最多向上查找10层
        # 检查是否存在常见的项目根目录标识
        if os.path.exists(os.path.join(search_dir, '.git')) or \
           os.path.exists(os.path.join(search_dir, 'package.json')) or \
           os.path.exists(os.path.join(search_dir, 'README.md')):
            return search_dir
        
        parent = os.path.dirname(search_dir)
        if parent == search_dir:  # 到达文件系统根目录
            break
        search_dir = parent
    
    # 如果没找到，返回当前工作目录
    return os.getcwd()


def get_subagents_master_dir(project_root):
    """
    获取 subagents-master 目录路径
    """
    return os.path.join(project_root, "subagents-master")


def create_subagent_directory(subagents_dir, name):
    """
    创建子智能体目录
    """
    subagent_path = os.path.join(subagents_dir, name)
    
    if os.path.exists(subagent_path):
        print(f"警告: 子智能体目录 '{name}' 已存在，将更新配置文件")
    else:
        os.makedirs(subagent_path, exist_ok=True)
        print(f"已创建子智能体目录: {subagent_path}")
    
    return subagent_path


def generate_subagent_md(subagent_path, name, description, scene_prompt, tools, mcp, knowledge_base):
    """
    生成 subagent.md 配置文件
    """
    md_path = os.path.join(subagent_path, "subagent.md")
    
    # 格式化工具列表
    tools_content = ""
    if tools:
        tools_list = [t.strip() for t in tools.split(',') if t.strip()]
        tools_content = "\n".join([f"- {tool}" for tool in tools_list])
    else:
        tools_content = "<!-- 暂无配置 -->"
    
    # 格式化 MCP 列表
    mcp_content = ""
    if mcp:
        mcp_list = [m.strip() for m in mcp.split(',') if m.strip()]
        mcp_content = "\n".join([f"- {m}" for m in mcp_list])
    else:
        mcp_content = "<!-- 暂无配置 -->"
    
    # 格式化知识库列表
    kb_content = ""
    if knowledge_base:
        kb_list = [k.strip() for k in knowledge_base.split(',') if k.strip()]
        kb_content = "\n".join([f"- {kb}" for kb in kb_list])
    else:
        kb_content = "<!-- 暂无配置 -->"
    
    content = f"""# {name}

<!-- 子智能体名称：用于标识该智能体的唯一名称 -->

## 描述

<!-- 描述：简要说明该子智能体的用途和功能 -->

{description}

## 场景提示词

<!-- 场景提示词：设置智能体的角色定位和行为指令，智能体将根据这些预设指令更准确地理解开发需求，并以设定的方式协助完成开发任务 -->

{scene_prompt}

## 工具

<!-- 工具：配置该智能体可使用的工具名称列表（多个工具用英文逗号分隔） -->

{tools_content}

## MCP

<!-- MCP：配置该智能体使用的 MCP Server 名称列表（多个用英文逗号分隔） -->

{mcp_content}

## 知识库

<!-- 知识库：配置该智能体关联的知识库名称列表（多个用英文逗号分隔） -->

{kb_content}
"""
    
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"已生成配置文件: {md_path}")
    return md_path


def update_index(subagents_dir, name, description):
    """
    更新子智能体索引文件
    """
    index_path = os.path.join(subagents_dir, "INDEX.md")
    
    # 如果索引文件不存在，创建新的
    if not os.path.exists(index_path):
        content = f"""# 子智能体索引

<!-- 本文件自动维护，记录所有已创建的子智能体 -->

| 名称 | 描述 | 创建时间 |
|------|------|----------|
| [{name}](./{name}/subagent.md) | {description} | {datetime.now().strftime('%Y-%m-%d')} |
"""
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"已创建索引文件: {index_path}")
        return
    
    # 读取现有索引
    with open(index_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否已存在该子智能体
    pattern = re.compile(f"\\| \\[{re.escape(name)}\\]")
    
    new_row = f"| [{name}](./{name}/subagent.md) | {description} | {datetime.now().strftime('%Y-%m-%d')} |"
    
    if pattern.search(content):
        # 更新现有行
        print(f"更新索引中 '{name}' 的记录...")
        content = re.sub(
            f"\\| \\[{re.escape(name)}\\]\\([^)]+\\) \\| .* \\| .* \\|",
            new_row,
            content
        )
    else:
        # 添加新行
        print(f"在索引中添加 '{name}' 的记录...")
        lines = content.split('\n')
        
        # 找到表格的最后一行
        last_table_row_index = -1
        for i, line in enumerate(lines):
            if line.strip().startswith('|') and not line.strip().startswith('| 名称') and not line.strip().startswith('|---'):
                last_table_row_index = i
        
        if last_table_row_index != -1:
            lines.insert(last_table_row_index + 1, new_row)
            content = '\n'.join(lines)
        else:
            # 如果没找到表格行，在文件末尾添加
            content += f"\n{new_row}"
    
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"已更新索引文件: {index_path}")


def main():
    parser = argparse.ArgumentParser(description="创建子智能体配置文件")
    parser.add_argument("--name", required=True, help="子智能体名称")
    parser.add_argument("--description", required=True, help="子智能体描述")
    parser.add_argument("--scene-prompt", required=True, help="场景提示词")
    parser.add_argument("--tools", default="", help="工具列表（逗号分隔）")
    parser.add_argument("--mcp", default="", help="MCP 列表（逗号分隔）")
    parser.add_argument("--knowledge-base", default="", help="知识库列表（逗号分隔）")
    parser.add_argument("--project-root", default="", help="项目根目录（可选，默认自动检测）")
    
    args = parser.parse_args()
    
    # 确定项目根目录
    if args.project_root:
        project_root = os.path.abspath(args.project_root)
    else:
        project_root = find_project_root(CURRENT_DIR)
    
    print(f"项目根目录: {project_root}")
    
    # 获取 subagents-master 目录
    subagents_dir = get_subagents_master_dir(project_root)
    
    # 确保 subagents-master 目录存在
    if not os.path.exists(subagents_dir):
        os.makedirs(subagents_dir, exist_ok=True)
        print(f"已创建 subagents-master 目录: {subagents_dir}")
    
    # 创建子智能体目录
    subagent_path = create_subagent_directory(subagents_dir, args.name)
    
    # 生成 subagent.md
    generate_subagent_md(
        subagent_path,
        args.name,
        args.description,
        args.scene_prompt,
        args.tools,
        args.mcp,
        args.knowledge_base
    )
    
    # 更新索引
    update_index(subagents_dir, args.name, args.description)
    
    print(f"\n✅ 子智能体 '{args.name}' 创建成功！")
    print(f"   配置文件: {os.path.join(subagent_path, 'subagent.md')}")


if __name__ == "__main__":
    main()
