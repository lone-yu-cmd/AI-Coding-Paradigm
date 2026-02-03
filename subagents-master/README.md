# 子智能体目录 (Subagents Master)

本目录用于存放所有子智能体的配置文件。每个子智能体都有独立的文件夹，包含其配置文档。

## 子智能体列表

| 名称 | 描述 | 路径 |
|------|------|------|
| [code-mysql-converter](./code-mysql-converter/subagent.md) | 代码逻辑与 MySQL 语句互转的智能体 | `./code-mysql-converter/` |

## 目录结构

```
subagents-master/
├── README.md                    # 本索引文件
├── code-mysql-converter/        # 代码-MySQL转换器
│   └── subagent.md              # 子智能体配置文档
└── ...                          # 更多子智能体
```

## 子智能体配置说明

每个子智能体的 `subagent.md` 文件包含以下六个部分：

1. **名称**（必填）：子智能体的唯一标识
2. **描述**（必填）：功能和用途的简要说明
3. **场景提示词**（必填）：定义角色、行为和专业能力
4. **工具**（可选）：可使用的内置工具名称
5. **MCP**（可选）：可使用的 MCP Server 名称
6. **知识库**（可选）：可关联的知识库名称
