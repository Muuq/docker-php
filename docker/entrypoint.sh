#!/bin/sh
set -e

# ホストの UID/GID を環境変数で受け取る（デフォルトは 1000）
HOST_UID=${HOST_UID:-1000}
HOST_GID=${HOST_GID:-1000}

# www-data をホスト UID/GID に合わせる
groupmod -g "$HOST_GID" www-data || true
usermod -u "$HOST_UID" -g "$HOST_GID" www-data || true

# tmp ディレクトリ権限調整
mkdir -p tmp/cache/models tmp/cache/persistent
chown -R :www-data tmp
chmod -R 770 tmp

# 引数コマンドを実行（通常は apache2-foreground）
exec "$@"
