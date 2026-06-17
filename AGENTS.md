# 2noteless Agent Rules

## 基本规则

- 默认中文交付；必须保留英文命令、API、文件名、类型名时，保留原文。
- 先读现有结构再改代码，沿用本项目的 SwiftUI 分层：`DesignSystem/`、`Components/`、`Features/`。
- 做最小可验证改动；不要把模块 2-10 的真实业务逻辑提前塞进首页首轮。
- 修改后至少跑一次项目构建；无法运行时说明具体原因和已验证内容。
- 色彩 token 必须在 Figma 与 `Assets.xcassets` 之间 1:1 对齐；视图代码不要直接写 hex。See `docs/design-system.md`.
- 图片占位优先用 SF Symbols、`Canvas`、`Shape` 或 `Color` 色块，保证 Preview 缺资源时仍可见。

## Agent skills

### Issue tracker

本仓库使用 local markdown issues；需要拆任务时写入 `.scratch/<feature>/`。See `docs/agents/issue-tracker.md`.

### Triage labels

使用默认 triage label vocabulary。See `docs/agents/triage-labels.md`.

### Domain docs

single-context：根目录 `CONTEXT.md` 加 `docs/adr/`。See `docs/agents/domain.md`.
