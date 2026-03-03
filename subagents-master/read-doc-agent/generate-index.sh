#!/bin/bash
# generate-index.sh
# 扫描指定文档目录，生成结构化索引文件供 read-doc subagent 使用
#
# 用法: ./generate-index.sh <docs_dir> [output_file]
#   docs_dir:    要扫描的文档目录（必填）
#   output_file: 索引输出路径（默认: <docs_dir>/.doc-index.md）
#
# 约定:
#   - 索引文件固定名称: .doc-index.md
#   - 默认生成在文档目录根部
#   - 使用 <!-- DOC-INDEX-START --> / <!-- DOC-INDEX-END --> 标记
#     方便嵌入 CODEBUDDY.md 时做区域替换

set -euo pipefail

DOCS_DIR="${1:?用法: $0 <docs_dir> [output_file]}"
# 去掉末尾斜杠
DOCS_DIR="${DOCS_DIR%/}"
OUTPUT_FILE="${2:-.doc-index.md}"

# 确保文档目录存在
if [ ! -d "$DOCS_DIR" ]; then
  echo "错误: 目录不存在: $DOCS_DIR" >&2
  exit 1
fi

generate_index() {
  echo "<!-- DOC-INDEX-START -->"
  echo "# 文档索引"
  echo ""
  echo "- 生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- 文档目录: \`$DOCS_DIR\`"
  echo "- 索引文件: \`$OUTPUT_FILE\`"
  echo ""
  echo "## 目录"
  echo ""

  local count=0

  # 递归查找所有 .md 文件（排除索引自身和隐藏文件），按路径排序
  while IFS= read -r -d '' file; do
    # 跳过索引文件自身
    local basename_file
    basename_file=$(basename "$file")
    if [ "$basename_file" = ".doc-index.md" ]; then
      continue
    fi

    # 相对路径
    local rel_path="${file#$DOCS_DIR/}"

    # 提取标题: 第一个 # 开头的行
    local title=""
    title=$(grep -m 1 '^#' "$file" 2>/dev/null | sed 's/^#\+[[:space:]]*//' || true)
    if [ -z "$title" ]; then
      title=$(basename "$file" .md)
    fi

    # 提取描述: 标题之后的第一个非空非标题行
    local desc=""
    desc=$(awk '
      /^#/ { found_title = 1; next }
      found_title && /^[[:space:]]*$/ { next }
      found_title && !/^#/ { print; exit }
    ' "$file" 2>/dev/null || true)

    # 截断描述到 120 字符
    if [ ${#desc} -gt 120 ]; then
      desc="${desc:0:117}..."
    fi

    # 统计行数，给 subagent 一个文件体量参考
    local lines
    lines=$(wc -l < "$file" | tr -d ' ')

    # 输出索引条目
    if [ -n "$desc" ]; then
      echo "- \`$rel_path\` (${lines}L): **$title** - $desc"
    else
      echo "- \`$rel_path\` (${lines}L): **$title**"
    fi

    count=$((count + 1))
  done < <(find "$DOCS_DIR" -name '*.md' -not -path '*/\.*' -type f -print0 | sort -z)

  echo ""
  echo "共 ${count} 个文档"
  echo "<!-- DOC-INDEX-END -->"
}

# 输出到文件或 stdout
if [ "$OUTPUT_FILE" = "-" ]; then
  generate_index
else
  generate_index > "$OUTPUT_FILE"
  echo "索引已生成: $OUTPUT_FILE (扫描目录: $DOCS_DIR)" >&2
fi
