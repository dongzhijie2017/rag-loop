---
name: git-workflow
description: 标准化的 Git 分支管理与发布工作流。支持自动同步远程变更（解决 Bot 提交冲突）、特性开发（feat）、预发布（release）、正式发布（publish/tag）及分支清理。特别适用于与 GitHub Actions 自动化提交共存的项目。
author: dongzhijie
version: 1.3.0
requirements:
  tools:
    - name: git
    - name: make
---

# git-workflow

这是一套标准化的 Git 分支管理工作流，旨在解决以下痛点：
1. **GitHub Actions 冲突**：当机器人定时向主分支提交数据（如 `fund_data/`）时，本地直接 push 会报错。本工作流通过 `make sync` 使用 `rebase` 策略将机器人提交“垫”在本地修改之下。
2. **分支管理混乱**：强制执行 `feat/xxx` -> `release/vX.Y.Z` -> `main` 的路径，确保主分支绝对稳定。
3. **发布流程自动化**：自动完成非快进合并 (`--no-ff`)、生成结构化 Tag 日志、推送等重复劳动。
4. **代码完整性保护 (S2 机制)**：防止在多轮对话中，由于 AI 的上下文窗口限制或错误判断，导致旧代码被遗漏、误删或弱化。

## When to use

当用户表达以下意图时，优先使用本 skill：

### 1. 同步与解决冲突
- “代码推不上去，报 non-fast-forward 错误”
- “同步一下机器人提交的数据”
- **指令**: `make sync`

### 2. 开启新功能开发
- “我想开发一个新的功能”
- “帮我创建一个特性分支”
- **指令**: `make feat NAME=your-feature-name`

### 3. 正式发布 (重点：结构化 Tag)
- “发布新版本”
- “完成上线流程”
- **指令**: `make publish V=1.x.x`

## Core Principles

- **主分支稳定性**：所有代码必须经过 `release` 分支验证。
- **Rebase 优先**：保持提交历史线性。
- **文档化发布**：每个 Tag 必须包含描述性日志，方便回溯。
- **S2 进阶保护 (Safety & Stability Pro)**：在修改任何现有文件前，必须进行三维自检（变动点、依赖性、验证路径）并结合 Git 状态安全提示。

## Implementation Details (S2 机制 v1.3.0)

### 代码 Review 与执行规范：
在向用户提供代码更新（尤其是在执行 `Edit` 或 `Write` 之前）时，Claude 必须执行以下流程：

1. **结构化变更清单 (Safety Check)**:
    - **[新增]**: 本次引入的具体功能。
    - **[保留 & 依赖声明]**: 明确列出与本次修改有耦合关系、必须保留的旧函数/变量（严禁只写“保留所有”）。
    - **[优化/删除]**: 明确指出被替代或清理的逻辑。
    - **[验证指引]**: 提供一段 1-3 行的测试命令或脚本，用于证明新增功能有效且未破坏保留功能。

2. **Git 安全提示**: “在您确认授权我写入前，请确保您已使用 `make feat NAME=xxx` 切换到了特性分支，且当前工作区 (`git status`) 是干净的。”

3. **显式确认**: “我已经确认本次更新没有遗漏您的核心逻辑，且已准备好验证方案，请您审阅并确认执行。”

## Examples

### 1. 核心代码重构 (S2 机制应用)
用户：“把 AI 逻辑整合进 valuation.py。”
Skill：“好的。在正式修改前，我已完成 S2 安全扫描：
- **[新增]**: 引入 `AIAnalyzer` 类的实例调用及 `analyze_invest` 方法。
- **[保留 & 依赖声明]**: 明确保留 `DataEngine` 缓存逻辑、`get_enriched_snapshot` 数据流，并确保新逻辑兼容旧有的 `pe_quantile` 字段。
- **[验证指引]**: 修改后请运行 `python -m auto_invest run`，检查生成的报告中是否包含 'AI 智能解读' 章节。

**Git 安全提示**: 请确保当前在 `feat/ai-brain` 分支。
确认逻辑完整，请您授权我进行集成。”
