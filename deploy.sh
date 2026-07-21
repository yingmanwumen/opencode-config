#!/bin/bash
set -e

echo "==> Setting up git hooks path..."
git config core.hooksPath .githooks

echo "==> Making hooks executable..."
chmod +x .githooks/*

echo "==> Deploying Magic Context config..."
mkdir -p ~/.config/cortexkit
cp configs/magic-context.jsonc ~/.config/cortexkit/magic-context.jsonc

echo "==> Done. Magic Context config synced to ~/.config/cortexkit/"
echo "    Run './deploy' again after 'git pull' to re-sync,"
echo "    or let the post-merge hook handle it automatically."
