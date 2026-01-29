#!/usr/bin/env python3
"""
Git Diff Statistics Tool

用于分析 git diff 输出并生成结构化的变更统计信息。
"""

import subprocess
import sys
import argparse
from collections import defaultdict


def run_git_diff(target="HEAD"):
    """执行 git diff 命令并返回输出"""
    try:
        result = subprocess.run(
            ["git", "diff", target, "--stat", "--numstat"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running git diff: {e.stderr}", file=sys.stderr)
        sys.exit(1)


def get_diff_files(target="HEAD"):
    """获取变更文件列表及其统计"""
    try:
        # 获取文件名和状态
        name_status = subprocess.run(
            ["git", "diff", target, "--name-status"],
            capture_output=True,
            text=True,
            check=True
        )
        
        # 获取详细统计
        numstat = subprocess.run(
            ["git", "diff", target, "--numstat"],
            capture_output=True,
            text=True,
            check=True
        )
        
        return name_status.stdout, numstat.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}", file=sys.stderr)
        sys.exit(1)


def parse_diff_stats(name_status_output, numstat_output):
    """解析 diff 统计信息"""
    files = {
        'added': [],
        'modified': [],
        'deleted': [],
        'renamed': []
    }
    
    stats = {}
    
    # 解析 numstat 获取行数统计
    for line in numstat_output.strip().split('\n'):
        if not line:
            continue
        parts = line.split('\t')
        if len(parts) >= 3:
            added = parts[0] if parts[0] != '-' else '0'
            deleted = parts[1] if parts[1] != '-' else '0'
            filename = parts[2]
            stats[filename] = {
                'added': int(added) if added.isdigit() else 0,
                'deleted': int(deleted) if deleted.isdigit() else 0
            }
    
    # 解析 name-status 获取文件状态
    for line in name_status_output.strip().split('\n'):
        if not line:
            continue
        parts = line.split('\t')
        if len(parts) >= 2:
            status = parts[0][0]  # 取第一个字符
            filename = parts[-1]  # 文件名
            
            file_stats = stats.get(filename, {'added': 0, 'deleted': 0})
            
            if status == 'A':
                files['added'].append({
                    'name': filename,
                    'stats': file_stats
                })
            elif status == 'M':
                files['modified'].append({
                    'name': filename,
                    'stats': file_stats
                })
            elif status == 'D':
                files['deleted'].append({
                    'name': filename,
                    'stats': file_stats
                })
            elif status == 'R':
                files['renamed'].append({
                    'name': filename,
                    'stats': file_stats
                })
    
    return files


def print_summary(files):
    """打印变更摘要"""
    total_added = sum(f['stats']['added'] for category in files.values() for f in category)
    total_deleted = sum(f['stats']['deleted'] for category in files.values() for f in category)
    
    print("=" * 60)
    print("📁 Git Diff 变更统计")
    print("=" * 60)
    print()
    print(f"├── 新增文件: {len(files['added'])} 个")
    print(f"├── 修改文件: {len(files['modified'])} 个")
    print(f"├── 删除文件: {len(files['deleted'])} 个")
    print(f"├── 重命名文件: {len(files['renamed'])} 个")
    print(f"└── 总变更行数: +{total_added} / -{total_deleted}")
    print()
    
    if files['added']:
        print("📄 新增文件:")
        for f in files['added']:
            print(f"   [新增] {f['name']} (+{f['stats']['added']})")
        print()
    
    if files['modified']:
        print("📝 修改文件:")
        for f in files['modified']:
            print(f"   [修改] {f['name']} (+{f['stats']['added']}/-{f['stats']['deleted']})")
        print()
    
    if files['deleted']:
        print("🗑️ 删除文件:")
        for f in files['deleted']:
            print(f"   [删除] {f['name']} (-{f['stats']['deleted']})")
        print()
    
    if files['renamed']:
        print("📋 重命名文件:")
        for f in files['renamed']:
            print(f"   [重命名] {f['name']}")
        print()
    
    print("=" * 60)
    
    # 返回统计数据
    return {
        'total_files': len(files['added']) + len(files['modified']) + len(files['deleted']) + len(files['renamed']),
        'added_files': len(files['added']),
        'modified_files': len(files['modified']),
        'deleted_files': len(files['deleted']),
        'renamed_files': len(files['renamed']),
        'total_lines_added': total_added,
        'total_lines_deleted': total_deleted
    }


def main():
    parser = argparse.ArgumentParser(
        description='分析 git diff 并生成变更统计'
    )
    parser.add_argument(
        '--target',
        default='HEAD',
        help='Diff 目标 (默认: HEAD)'
    )
    parser.add_argument(
        '--json',
        action='store_true',
        help='以 JSON 格式输出'
    )
    
    args = parser.parse_args()
    
    name_status, numstat = get_diff_files(args.target)
    
    if not name_status.strip() and not numstat.strip():
        print("没有发现未提交的变更。")
        print("提示: 使用 --target <commit> 来比较指定的提交。")
        return
    
    files = parse_diff_stats(name_status, numstat)
    
    if args.json:
        import json
        result = {
            'files': files,
            'summary': {
                'added_files': len(files['added']),
                'modified_files': len(files['modified']),
                'deleted_files': len(files['deleted']),
                'renamed_files': len(files['renamed'])
            }
        }
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print_summary(files)


if __name__ == '__main__':
    main()
