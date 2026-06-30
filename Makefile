# 设定默认的 shell
SHELL := /bin/bash

# 变量定义
CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION ?= $(shell date +%Y%m%d)

.PHONY: help sync feat release publish clean

help:
	@echo "=================================================="
	@echo "          工作流自动化工具 (Git Workflow)         "
	@echo "=================================================="
	@echo "可用命令:"
	@echo "  make sync             - 解决冲突：拉取远程 master 并使用 rebase 垫底"
	@echo "  make feat NAME=xxx    - 开启新特性：从最新 master 创建 feat/xxx 分支"
	@echo "  make release V=x.y.z  - 准备发布：从最新 master 创建 release/vX.Y.Z 分支"
	@echo "  make publish V=x.y.z  - 完成发布：合并 release 到 master 并打 Tag 推送"
	@echo "  make clean            - 清理分支：删除已合并的 feat 和 release 分支"
	@echo "=================================================="

# 1. 同步远程代码（解决 GitHub Actions 冲突）
sync:
	@echo "正在拉取远程 master 并 rebase..."
	git fetch origin
	git rebase origin/main || git rebase origin/master
	@echo "同步完成！如果发生冲突，请手动解决后执行 git rebase --continue"

# 2. 开启新功能开发 (例如: make feat NAME=moneyflow)
feat:
	@if [ -z "$(NAME)" ]; then echo "错误: 请提供特性名称，例如 make feat NAME=moneyflow"; exit 1; fi
	git checkout main || git checkout master
	git pull origin main --rebase || git pull origin master --rebase
	git checkout -b feat/$(NAME)
	@echo "已切换到新分支: feat/$(NAME)，开始你的开发吧！"

# 3. 创建 Release 分支 (例如: make release V=1.4.0)
release:
	@if [ -z "$(V)" ]; then echo "错误: 请提供版本号，例如 make release V=1.4.0"; exit 1; fi
	git checkout main || git checkout master
	git pull origin main --rebase || git pull origin master --rebase
	git checkout -b release/v$(V)
	@echo "已创建发布分支: release/v$(V)。"
	@echo "现在你可以使用 'git merge feat/你的分支名' 将特性合并进来进行测试。"

# 4. 归档并打 Tag (例如: make publish V=1.4.0)
publish:
	@if [ -z "$(V)" ]; then echo "错误: 请提供版本号，例如 make publish V=1.4.0"; exit 1; fi
	@echo "正在合并 release/v$(V) 到主分支..."
	git checkout main || git checkout master
	git merge --no-ff release/v$(V) -m "Merge release v$(V)"
	git tag -a v$(V) -m "Release version $(V)"
	git push origin $$(git rev-parse --abbrev-ref HEAD) --tags
	@echo "版本 v$(V) 已发布并推送到远程！"

# 5. 清理本地已合并的分支
clean:
	@echo "正在清理本地已合并的分支..."
	git checkout main || git checkout master
	@git branch --merged | egrep -v "(^\*|master|main)" | xargs -r git branch -d
	@echo "清理完成！"
