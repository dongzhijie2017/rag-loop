---
name: gitea-github-sync
description: >-
  以局域网 Gitea (http://192.168.0.120:3000/) 为代码主仓，GitHub 仅作代码镜像的双远程工作流。
  新项目初始化、配置 origin/github 双 remote、推送与同步时优先使用本技能。
  触发词：Gitea、192.168.0.120、双远程、代码同步 GitHub、新建项目仓库、push 到内网。
author: dongzhijie
version: 1.0.0
category: Engineering/Git
triggers:
  - 新建项目
  - 初始化仓库
  - 推到 Gitea
  - 同步到 GitHub
  - 双远程
requirements:
  tools:
    - name: git
  skills:
    - git-workflow
---

# Gitea + GitHub 双远程工作流

> **SSOT 路径**: `/Users/dongzhijie/同步空间/个人知识库/ClaudeSkills/gitea-github-sync/`
> 部署说明见 [USAGE.md](USAGE.md)

## 架构原则

| 远程 | 角色 | 地址模式 | 同步范围 |
|------|------|----------|----------|
| `origin` | **主仓（Gitea）** | `http://192.168.0.120:3000/<user>/<repo>.git` | 全部 Git 跟踪内容（代码 + 内网数据） |
| `github` | **代码镜像** | `git@github.com:<user>/<repo>.git` | **仅源代码**；运行时数据、Bot 数据、密钥不同步 |

**铁律**：
1. 所有 push **先 Gitea、后 GitHub**
2. GitHub 上不出现 `.env`、密钥、大体积生成物、Bot 定时写入的数据目录
3. 若 Gitea 有仅供内网的数据分支（如 `data/*`），**禁止** push 到 `github`

## When to use

- 用户说「新建项目」「初始化仓库」「推到 Gitea / 内网」
- 用户说「同步到 GitHub」「只同步代码」
- Agent 需要配置 `git remote`、首次 push、或双远程推送
- **每个新项目启动时**，与 `git-workflow` 一并导入并执行初始化

## 脚本路径（SSOT）

```bash
SKILLS_ROOT="/Users/dongzhijie/同步空间/个人知识库/ClaudeSkills"
INIT_SCRIPT="$SKILLS_ROOT/gitea-github-sync/scripts/init-dual-remote.sh"
PUSH_SCRIPT="$SKILLS_ROOT/gitea-github-sync/scripts/push-code-only.sh"
```

项目内已导入时，也可使用：`.agents/skills/gitea-github-sync/scripts/`

## 新项目初始化

### 方式 A：脚本（推荐）

```bash
bash "$SKILLS_ROOT/gitea-github-sync/scripts/init-dual-remote.sh" <gitea-user> <repo-name> [github-user]
```

脚本会：`git init`、写入标准 `.gitignore` 模板（若不存在）、添加 `origin`（Gitea）与 `github` 远程。

### 方式 B：手动

```bash
git init
git remote add origin http://192.168.0.120:3000/<GITEA_USER>/<REPO>.git
git remote add github git@github.com:<GITHUB_USER>/<REPO>.git
```

**前置**：在 Gitea Web UI (`http://192.168.0.120:3000/`) 创建空仓库；GitHub 侧创建同名空仓库（若需镜像）。

### 首次提交（Gitea Web 建仓前）

```bash
git add .
git commit -m "chore: initial commit"
```

### Gitea 建仓后首推（仅一次，不用 push-code-only.sh）

Gitea Web 建好空仓库后（示例：Synapse-OS → `synapse-os`）：

```bash
cd /Users/dongzhijie/Synapse-OS
git push -u origin main
git branch --set-upstream-to=origin/main main
```

详见 [USAGE.md § 三](USAGE.md#三gitea-建仓后首推阶段-d--仅一次)。

## 日常推送（建库完成以后）

```bash
bash .agents/skills/gitea-github-sync/scripts/push-code-only.sh           # 当前分支
bash .agents/skills/gitea-github-sync/scripts/push-code-only.sh feat/xxx  # 指定分支
```

Agent 执行 push 前必须：
1. 确认 `.gitignore` 已排除不应上 GitHub 的路径（见 [reference.md](reference.md)）
2. `git remote -v` 确认 `origin` 指向 Gitea
3. 先 `git push origin <branch>`，再按需 `git push github <branch>`

## 已有项目迁移到 Gitea 主仓

```bash
git remote rename origin github
git remote add origin http://192.168.0.120:3000/<GITEA_USER>/<REPO>.git
git push -u origin --all
git push origin --tags
bash "$SKILLS_ROOT/gitea-github-sync/scripts/push-code-only.sh" main
```

## 与 git-workflow 的配合

- `make sync` / `make feat` / `make publish` 默认针对 `origin`（Gitea）— **符合预期**
- `make publish` 完成后，额外执行 `push-code-only.sh` 将 release 同步到 GitHub（**建仓后**的日常操作）
- 从 GitHub 拉 Bot 数据时：`git fetch github` + 选择性 cherry-pick，**不要**把数据目录 push 回 GitHub

## Agent 检查清单

```
- [ ] 已导入 gitea-github-sync 到 .agents/skills/
- [ ] origin → http://192.168.0.120:3000/...
- [ ] github → git@github.com:...
- [ ] .gitignore 含数据/密钥排除项
- [ ] 当前分支非 data/* 才 push github
- [ ] 已 push origin，再 push github
```

## 附加资源

- 部署与日常使用：[USAGE.md](USAGE.md)
- 不同步路径与分支策略：[reference.md](reference.md)
