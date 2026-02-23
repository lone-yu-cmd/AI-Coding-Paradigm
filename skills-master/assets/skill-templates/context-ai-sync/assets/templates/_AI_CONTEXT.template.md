# {{MODULE_NAME}} 模块

> 模块详情文档，帮助 AI 理解模块的职责和实现细节。
> 文档大小限制：< 10KB

---

## 模块职责（Responsibility）

<!-- AUTO_SYNC_START -->

### 核心职责

{{MODULE_RESPONSIBILITY}}

### 模块边界

- **负责**：{{RESPONSIBILITIES}}
- **不负责**：{{NON_RESPONSIBILITIES}}

<!-- AUTO_SYNC_END -->

---

## 文件结构（File Structure）

<!-- AUTO_SYNC_START -->

```
{{MODULE_PATH}}/
{{FILE_TREE}}
```

### 文件说明

| 文件 | 职责 | 重要程度 |
|-----|-----|---------|
{{FILE_TABLE}}

<!-- AUTO_SYNC_END -->

---

## 关键接口（Key Interfaces）

<!-- AUTO_SYNC_START -->

### 导出的公共接口

```{{LANGUAGE}}
{{PUBLIC_INTERFACES}}
```

### 主要函数/方法

| 名称 | 参数 | 返回值 | 说明 |
|-----|-----|-------|-----|
{{FUNCTION_TABLE}}

<!-- AUTO_SYNC_END -->

---

## 依赖关系（Dependencies）

<!-- AUTO_SYNC_START -->

### 内部依赖（本项目模块）

| 依赖模块 | 用途 | 关键接口 |
|---------|-----|---------|
{{INTERNAL_DEPS_TABLE}}

### 外部依赖（第三方库）

| 依赖名称 | 版本 | 用途 |
|---------|-----|-----|
{{EXTERNAL_DEPS_TABLE}}

### 被依赖情况

本模块被以下模块依赖：
{{DEPENDENTS_LIST}}

<!-- AUTO_SYNC_END -->

---

## 常见操作指南（Common Operations）

<!-- MANUAL_START -->

### 如何添加新功能

1. 步骤一：...
2. 步骤二：...
3. 步骤三：...

### 如何修改现有功能

1. 步骤一：...
2. 步骤二：...

### 如何进行测试

```bash
# 测试命令示例
{{TEST_COMMAND}}
```

### 注意事项

- ⚠️ 注意事项 1
- ⚠️ 注意事项 2

<!-- MANUAL_END -->

---

## 代码示例（Code Examples）

<!-- MANUAL_START -->

### 基本用法

```{{LANGUAGE}}
// 示例代码
{{BASIC_USAGE_EXAMPLE}}
```

### 高级用法

```{{LANGUAGE}}
// 高级示例代码
{{ADVANCED_USAGE_EXAMPLE}}
```

<!-- MANUAL_END -->

---

## 已知问题与限制（Known Issues & Limitations）

<!-- MANUAL_START -->

### 当前限制

- 限制 1：...
- 限制 2：...

### 待改进项

- [ ] 改进项 1
- [ ] 改进项 2

<!-- MANUAL_END -->

---

## 变更历史（Change History）

<!-- AUTO_SYNC_START -->

| 日期 | 变更类型 | 说明 |
|-----|---------|-----|
{{CHANGE_HISTORY_TABLE}}

<!-- AUTO_SYNC_END -->

---

> 📅 本文档由 AI Context Sync Skill 生成
> 🔄 AUTO_SYNC 区域会在代码变更时自动更新
> ✏️ MANUAL 区域供人工编辑，不会被自动覆盖
