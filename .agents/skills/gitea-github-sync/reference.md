# Gitea + GitHub 双远程 — 参考

## Gitea 实例

- **URL**: http://192.168.0.120:3000/
- **协议**: HTTP（内网）；可按需配置 SSH
- **主 remote 名**: `origin`

## 不同步到 GitHub 的内容

### 必须通过 .gitignore 排除

```
.env
.env.*
*.pem
*.key
credentials.json
secrets/
```

### 运行时 / 生成数据（按项目扩展）

```
fund_data/
data/
logs/
.cache/
*.sqlite
*.db
dist/
build/
node_modules/
__pycache__/
.venv/
```

### 仅 Gitea 跟踪的分支

| 分支模式 | Gitea | GitHub |
|----------|-------|--------|
| `main` / `master` | ✅ | ✅ |
| `feat/*` | ✅ | ✅ |
| `release/*` | ✅ | ✅（发布前） |
| `data/*` | ✅ | ❌ 禁止 push |
| `bot/*` | ✅ | ❌ 禁止 push |

## 认证

| 目标 | 推荐方式 |
|------|----------|
| Gitea | 内网 HTTP + Personal Access Token，或 SSH |
| GitHub | SSH (`git@github.com`) 或 `gh auth login` |

Gitea Token：Gitea → Settings → Applications → Generate Token（`repo` 权限）。

## 远程命名约定（SSOT）

```
origin  = Gitea  (主仓，全量)
github  = GitHub (镜像，仅代码)
```

不要使用 `gitea` + `origin=GitHub` 的反向配置，避免与 git-workflow 及 Makefile 假设冲突。
