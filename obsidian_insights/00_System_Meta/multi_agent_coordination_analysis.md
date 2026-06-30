---
type: system_meta
tags:
  - architecture
  - multi-agent
  - cursor
  - double-brain
  - git-workflow
date: 2026-06-30
title: 多智能体协同架构深度剖析
---

# 多智能体协同架构（Multi-Agent System）深度剖析

是的，你的理解完全正确。这是一套标准的 **Master-Worker（调度-执行）** 多智能体协同架构。在这种架构下，各个组件各司其职，通过高内聚、低耦合的设计，避免了单个大模型因任务过于复杂而导致的「注意力分散」和「逻辑混乱」。

---

## 一、多智能体协同拓扑图

```
                      ┌────────────────────────┐
                      │    用户输入 (User Input)│
                      └───────────┬────────────┘
                                  │
                                  ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │           1. Master Agent (总调度/路由器) —— .cursorrules         │
 │ - 负责全局上下文注入（用户 11 年大数据背景、抗催躁心法）             │
 │ - 根据输入场景，自动分发任务至对应 Worker Agent                  │
 └──────┬─────────────────┬─────────────────┬─────────────────┬─────┘
        │                 │                 │                 │
        │ (路由A)         │ (路由B)         │ (路由C)         │ (路由D)
        ▼                 ▼                 ▼                 ▼
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
 │  Worker 1   │   │  Worker 2   │   │  Worker 3   │   │  Worker 4   │
 │日常综合决策 │   │命途深度诊断 │   │二选一对比PK │   │双模极简秒杀 │
 │ (01_daily)  │   │ (02_life)   │   │ (03_binary) │   │ (04_dual)   │
 └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
        │                 │                 │                 │
        └─────────────────┼─────────────────┴─────────────────┘
                          │ (输出初步决策草案)
                          ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │         2. Evaluator Agent (审查官/Guardrail) —— 内置于调度         │
 │ - 独立于 Worker 的 Critic（批判者）角色                          │
 │ - 运行 RAG 幻觉检测：强制比对 Obsidian 历史踩坑记录              │
 │ - 运行周期泡沫检测：强行拷问是否符合「格林斯潘看跌期权」逻辑     │
 └────────────────────────┬─────────────────────────────────┘
                          │
            ┌─────────────┴─────────────┐
            │ (自检评分评估)            │
            ▼                           ▼
      【得分 < 90 分】             【得分 ≥ 90 分】
   〔触发 Iterate 循环〕        〔输出最终决策方案〕
   返回 Worker 重新修正          写入 Obsidian 决策日志
                                提交变更至本地 Gitea / GitHub
```

---

## 二、核心角色与生态位拆解

### 1. 总调度 Agent (Master / Router) —— 物理载体：`.cursorrules`

**职责**：系统的「大脑」与「通讯中心」。

**第一性原理**：Context Control（上下文控制）。它不负责具体的决策推演，而是确保不论启用哪个 Worker，AI 都不会忘记用户的「11 年电信架构背景」、「短期求首单、长期防泡沫」的底层基线。它就像一个项目经理，拿到任务后，决定分派给哪位专员。

### 2. 垂直领域执行 Agent (Worker Agents) —— 物理载体：`.cursor/agents/*.md`

**职责**：具体的「干活专员」，只专注于自己擅长的特定场景。

**第一性原理**：Specialization（专业分工）。

| Worker | 场景 | 专长 |
|--------|------|------|
| 01_daily | 日常综合决策 | 细节拆解与机会成本计算 |
| 02_life | 命途深度诊断 | 哲学思考、心性卡点复盘 |
| 03_binary | 二选一对比 PK | 多维度加权打分与量化对比 |
| 04_dual | 双模极简秒杀 | 长周期隐藏路径挖掘与短周期极简秒杀 |

### 3. 审查与防幻觉 Agent (Critic / Guardrail) —— 物理载体：`.cursorrules` 中的 Evaluate 环节

**职责**：专职「唱反调」和「Debug」。

**第一性原理**：Actor-Critic（双轨制衡）。干活的 Worker 容易「自我感动」或为了讨好用户给出过于乐观的推演。审查 Agent 则是一个冷酷的「红队审计员」，手持 Obsidian 的历史失败记录（RAG）和格林斯潘周期理论，给 Worker 的草案挑刺、扣分，不达标就打回重写（Iterate）。

### 4. 共享 Memory 数据总线 —— 物理载体：Obsidian 软链接

**职责**：所有 Agent 共用的「黑板（Blackboard）」。

**第一性原理**：Grounding（事实锚定）。确保 Worker 在「Observe」阶段，以及 Evaluator 在「Evaluate」阶段，调取的都是用户大脑中真实沉淀的知识与记忆，而不是 LLM 预训练权重中的通用废话。

---

## 三、这套多智能体架构的优势

### 极高的可维护性（Decoupling）

如果你未来想升级「二选一对比」的打分算法，你只需要修改 `03_binary_choice.md` 这一个文件，完全不需要变更总调度 `.cursorrules`。这符合软件工程的「开闭原则」（对扩展开放，对修改关闭）。

### 防爆产出与自我收敛（Convergence）

单个 Prompt 模式下，AI 很容易胡说八道。在这套架构中，由于引入了 Evaluator 的评分和最长 5 轮的 Iterate 循环，最终输出的决策都是经过「生成 → 挑刺 → 修正 → 再挑刺」闭环洗礼后的「高纯度结晶」。

### 版本控制的安全感（Version Control）

配合 Gitea / GitHub 双端控制，你的调度规则（Master）与 4 套智能体（Workers）每一次的优化，都能留下代码历史痕迹，随时可回滚，确保决策系统本身也是一个「稳定演进的产品」。

---

## 四、本地工程演进与双端同步规范（RAG-LOOP 2026-06-30 升级）

为了保证整个多智能体系统的「提示词即代码（Prompt-as-Code）」以及「决策日志」能够安全、稳定、自动化地流转，系统已经沉淀了一套标准化的工程初始化与运维流。

### 1. 物理目录结构

在 Obsidian 库（`acknowledge`）内，项目实操与迭代知识独立托管于以下结构中：

```
acknowledge/
├── rag-loop/
│   ├── README.md                              # 项目知识入口 [[rag-loop/README]]
│   └── RAG-LOOP_空项目初始化与双远程仓库实操.md  # 完整实操手册 [[RAG-LOOP_空项目初始化与双远程仓库实操]]
└── 05-iteration-logs/
    └── 2026-06-30-rag-loop-project-init-knowledge-deposit.md  # 2026-06-30 实测迭代日志
```

> Obsidian 知识库路径：`/Users/dongzhijie/同步空间/个人知识库/acknowledge`  
> 代码仓库路径：`/Users/dongzhijie/同步空间/个人知识库/RAG-LOOP`

### 2. 双远程仓库部署策略 (Dual-Remote Strategy)

为了同时兼顾「本地绝对隐私与高可用安全备份（Gitea）」以及「云端镜像/生态沉淀（GitHub Public）」，系统强制执行双远程仓库绑定流。

#### 初始化金律（核心禁令）

| 禁令 | 说明 |
|------|------|
| **不要跟随平台默认 `git init` 指引** | 默认指引无法处理双端 upstream 覆盖与非空冲突问题 |
| **Gitea 建仓不要勾选「初始化仓库」** | 必须保持 Gitea 库为空，防止本地推送时发生历史线冲突 |
| **必须使用 `init-dual-remote.sh`** | 技能导入与双 remote 初始化专用脚本 |

#### GitHub 镜像可行性

GitHub 作为 **Public** 镜像完全可行，用于沉淀非敏感的系统元代码及提示词模板；敏感的个人决策数据通过 `.gitignore` 强行限制在本地 Gitea 主仓。

#### 首推命令与 Upstream 规范

```bash
# 首推 Gitea 主仓
git push -u origin main
git branch --set-upstream-to=origin/main main

# 首推 GitHub 镜像
git push -u github main

# github push 可能覆盖 upstream，必须改回 Gitea
git branch --set-upstream-to=origin/main main
```

这能确立 **Gitea 为第一主力源**，GitHub 为镜像同步源，确保多智能体调度代码在两端的无缝同步。

### 3. 日常高效运维机制 (Daily Workflow)

在日常决策和智能体模板更迭中，禁止频繁手动运行繁琐的 Git 命令。

**极简推送流**：本地智能体提示词调优、`.cursorrules` 优化后，一键运行：

```bash
bash .agents/skills/gitea-github-sync/scripts/push-code-only.sh
```

脚本将自动完成：**先推 Gitea（origin）→ 再镜像 GitHub（github）**。`data/*`、`bot/*` 分支自动跳过 GitHub。

### 4. 知识复用与快速冷启动

未来当你在本地启动新的 AI 转型项目或系统模块时：

1. 在 Obsidian 中点击进入 [[rag-loop/README]] 或 [[RAG-LOOP_空项目初始化与双远程仓库实操]]
2. 复制实操模板，只需替换脚本中的**仓库名**与**本地路径**
3. 1 分钟内完成全新项目的双远程 RAG-Loop 环境搭建

---

## 相关链接

| 资源 | 路径 |
|------|------|
| RAG-LOOP 项目入口 | `acknowledge/rag-loop/README.md` |
| 双远程实操手册 | `acknowledge/rag-loop/RAG-LOOP_空项目初始化与双远程仓库实操.md` |
| 2026-06-30 迭代日志 | `acknowledge/05-iteration-logs/2026-06-30-rag-loop-project-init-knowledge-deposit.md` |
| init 脚本 | `.agents/skills/gitea-github-sync/scripts/init-dual-remote.sh` |
| 日常推送脚本 | `.agents/skills/gitea-github-sync/scripts/push-code-only.sh` |
