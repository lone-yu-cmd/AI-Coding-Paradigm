# Git Hook 机制

> 本文档详细说明 Git Hook 如何触发文档自动维护流程。

---

## 概述

Git Hook 是 AI Context Sync 框架的自动触发层，通过 pre-commit 钩子在代码提交前自动分析变更并更新文档。

### 核心职责

- 检测代码变更
- 调用 doc-maintainer 分析
- 自动将文档更新包含在同一 commit

---

## Pre-commit 脚本设计

### 完整脚本

```bash
#!/bin/bash
# 文件路径: .git/hooks/pre-commit
# 权限: chmod +x .git/hooks/pre-commit

# ===== AI Context 自动维护 Hook =====

# 配置
AI_CONTEXT_DIR="docs/AI_CONTEXT"
DOC_MAINTAINER_SCRIPT="scripts/doc_maintainer.py"

# 检测是否有代码变更（排除文档变更）
CODE_CHANGES=$(git diff --cached --name-only | grep -v "^${AI_CONTEXT_DIR}/" | grep -v "_AI_CONTEXT.md$")

if [ -z "$CODE_CHANGES" ]; then
    echo "ℹ️  [AI-Context] 仅文档变更，跳过文档维护"
    exit 0
fi

echo "🔍 [AI-Context] 检测到代码变更，分析文档更新需求..."

# 检查 doc-maintainer 脚本是否存在
if [ ! -f "$DOC_MAINTAINER_SCRIPT" ]; then
    echo "⚠️  [AI-Context] doc-maintainer 脚本不存在，跳过自动维护"
    exit 0
fi

# 调用 doc-maintainer
if python3 "$DOC_MAINTAINER_SCRIPT"; then
    # 检查是否有文档更新
    DOC_CHANGES=$(git diff "${AI_CONTEXT_DIR}/" 2>/dev/null)
    MODULE_DOC_CHANGES=$(find . -name "_AI_CONTEXT.md" -exec git diff {} \; 2>/dev/null)
    
    if [ -n "$DOC_CHANGES" ] || [ -n "$MODULE_DOC_CHANGES" ]; then
        echo "✅ [AI-Context] 文档已更新，自动添加到本次提交"
        git add "${AI_CONTEXT_DIR}/"
        find . -name "_AI_CONTEXT.md" -exec git add {} \;
    else
        echo "ℹ️  [AI-Context] 文档无需更新"
    fi
else
    echo "⚠️  [AI-Context] 文档更新失败，但不阻断提交"
    echo "    建议稍后手动检查文档同步"
fi

exit 0
```

---

## 工作流程

```
用户执行 git commit
        ↓
pre-commit hook 触发
        ↓
检测是否有代码变更（排除文档）
        ↓
    ┌───┴───┐
    │       │
  有变更   无变更
    │       │
    ↓       └─→ 跳过，继续 commit
调用 doc-maintainer
        ↓
分析 git diff HEAD
        ↓
AI 判断是否需要更新文档
        ↓
    ┌───┴───┐
    │       │
  需要     不需要
    │       │
    ↓       └─→ 记录日志，继续 commit
更新相关 .md 文件
        ↓
git add 更新的文档
        ↓
继续 commit 流程
```

---

## 错误处理策略

### 核心原则

**非侵入性**：文档更新失败不应阻断正常的代码提交流程。

### 错误处理代码

```bash
# 如果 doc-maintainer 失败
if ! python3 "$DOC_MAINTAINER_SCRIPT"; then
    echo "⚠️  文档更新失败，但不阻断提交"
    echo "    建议稍后手动检查文档同步"
    exit 0  # 不阻断提交
fi
```

### 常见错误场景

| 错误场景 | 处理方式 |
|---------|---------|
| doc-maintainer 脚本不存在 | 警告并跳过，继续提交 |
| Python 环境问题 | 警告并跳过，继续提交 |
| AI 服务不可用 | 警告并跳过，继续提交 |
| 文件写入权限问题 | 警告并跳过，继续提交 |

---

## 安装与配置

### 安装命令

```bash
# 创建 hook 文件
cat > .git/hooks/pre-commit << 'EOF'
# [粘贴上面的脚本内容]
EOF

# 添加执行权限
chmod +x .git/hooks/pre-commit

# 验证安装
ls -la .git/hooks/pre-commit
```

### 验证安装

```bash
# 检查 hooks 目录
ls -la .git/hooks/

# 检查脚本权限
file .git/hooks/pre-commit

# 测试执行
.git/hooks/pre-commit
```

---

## 技术约束

| 约束项 | 要求 |
|-------|------|
| 执行时间 | < 5 秒 |
| 跨平台 | macOS / Linux / Windows |
| 依赖 | Python 3.6+，仅标准库 |
| 原子性 | 文档更新与代码在同一 commit |
| 可选性 | 可通过配置禁用 |

---

## 配置选项

通过环境变量或配置文件控制 Hook 行为：

```bash
# 环境变量方式
export AI_CONTEXT_SKIP=1  # 跳过本次文档更新
git commit -m "紧急修复"

# 配置文件方式 (.ai-context.yml)
doc_maintainer:
  enabled: false  # 临时禁用
```

---

## 相关文档

- [doc-maintainer 设计](./002-doc-maintainer设计.md) - AI 驱动的文档维护逻辑
- [增量更新策略](./003-增量更新策略.md) - 如何进行增量文档更新
