# Update Skills Master

快速从 GitHub 远程仓库拉取并更新本地 `skills-master` 目录。

## 快速开始

```bash
# 使用默认配置更新（从 lone-yu-cmd/AI-Coding-Paradigm 仓库）
# 脚本会自动检测 skills-master 位置（update-skills-master 的同级目录）
python3 scripts/update_skills_master.py

# 从自定义仓库更新
python3 scripts/update_skills_master.py --repo https://github.com/username/repo.git

# 从不同分支更新
python3 scripts/update_skills_master.py --branch main
```

## 功能特性

- ✅ **稀疏检出** - 只拉取 `skills-master` 目录，无需克隆整个仓库
- ✅ **自动备份** - 替换前自动创建备份
- ✅ **安全回滚** - 更新失败时自动恢复备份
- ✅ **灵活配置** - 支持自定义仓库、分支和目标目录
- ✅ **智能路径检测** - 自动定位 skills-master（本技能的同级目录）
- ✅ **通用兼容** - 适用于任何 skills 环境（CodeBuddy、独立项目等）

## 主要参数

| 参数 | 默认值 | 说明 |
|-----|--------|------|
| `--repo` | `https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git` | GitHub 仓库 URL |
| `--branch` | `master` | 拉取的分支名 |
| `--sparse-path` | `skills-master` | 仓库中要检出的路径 |
| `--target` | 自动检测 | 本地目标目录（自动检测为本技能的同级目录） |
| `--no-backup` | `False` | 跳过备份（不推荐） |

## 工作原理

此技能使用 Git 稀疏检出（sparse checkout）功能：

1. **自动路径检测** - 找到本技能的位置，定位到同级的 skills-master 目录
2. 初始化临时 Git 仓库
3. 添加远程仓库
4. 启用稀疏检出
5. 配置只检出 `skills-master` 目录
6. 拉取指定分支
7. 替换本地目录
8. 清理临时文件

**优势**：
- 比克隆整个仓库快得多
- 节省磁盘空间
- 减少网络带宽消耗
- 只下载需要的内容
- 通用于各种项目结构

## 使用示例

### 示例 1：标准更新

```bash
python3 scripts/update_skills_master.py
```

### 示例 2：从公司 Fork 更新

```bash
python3 scripts/update_skills_master.py \
  --repo https://github.com/company/skills-fork.git \
  --branch develop
```

### 示例 3：更新到自定义目录

```bash
python3 scripts/update_skills_master.py \
  --target ./shared-skills
```

## 注意事项

⚠️ **警告**：此操作会覆盖本地的 `skills-master` 目录中的所有更改。

- 默认会创建备份，可以在更新失败时恢复
- 验证更新成功后可以删除备份
- 如需保留本地修改，请在更新前手动备份重要文件

## 故障排除

### Git 未安装

如果看到 "Git is not installed" 错误：

- macOS: `brew install git`
- Linux: `sudo apt-get install git`
- Windows: 从 https://git-scm.com/ 下载

### 网络连接失败

如果无法连接到 GitHub：

1. 检查网络连接
2. 验证仓库 URL 是否正确
3. 检查是否能访问 GitHub

### 权限被拒绝

如果遇到权限错误：

1. 检查目标目录的写权限
2. 尝试使用 sudo（不推荐）
3. 使用 `--target` 指定其他目录

## 详细文档

查看 `SKILL.md` 获取完整的使用说明和技术细节。
