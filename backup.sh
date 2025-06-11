#!/bin/bash
# 设置仓库路径和备份远程名
REPO_DIR="/home/ubuntu/hexo-blog"
BACKUP_REMOTE="backup"   # 事先在本地 git remote add backup <url>

cd "$REPO_DIR" || exit 1

# 拉取最新更新（非必须，可去掉）
git pull origin master

# 推送本地 master 到 GitHub（origin）
git push origin master

# （可选）把日志写到文件
echo "$(date '+%Y-%m-%d %H:%M:%S') backup finished" >> "$REPO_DIR/backup.log"
