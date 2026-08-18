#!/usr/bin/env bash
# B2B 售前工作流 —— 一键安装
# 用法: curl -fsSL <raw-url>/install.sh | bash
set -euo pipefail

REPO="tanchunzhuo/b2b-presales-workflow"
NAME="b2b-presales-workflow"
BRANCH="main"
TARBALL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}"

echo ""
echo "  B2B 售前工作流 · 安装程序"
echo "  ------------------------------------"

# 探测已安装的 Agent 平台
CANDIDATES=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.cursor/skills"
  "$HOME/.agents/skills"
)

TARGETS=()
for d in "${CANDIDATES[@]}"; do
  parent="$(dirname "$d")"
  if [ -d "$parent" ]; then
    TARGETS+=("$d")
  fi
done

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "  未检测到已安装的 Agent 平台，默认安装到 ~/.claude/skills"
  TARGETS=("$HOME/.claude/skills")
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "  下载中..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$TARBALL" -o "$TMP/pkg.tar.gz"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TMP/pkg.tar.gz" "$TARBALL"
else
  echo "  错误：需要 curl 或 wget" >&2
  exit 1
fi

tar -xzf "$TMP/pkg.tar.gz" -C "$TMP"
SRC="$TMP/${NAME}-${BRANCH}"

if [ ! -d "$SRC" ]; then
  echo "  错误：解压后未找到目录 $SRC" >&2
  exit 1
fi

for t in "${TARGETS[@]}"; do
  mkdir -p "$t"
  rm -rf "${t:?}/${NAME}"
  cp -R "$SRC" "${t}/${NAME}"
  echo "  ✓ 已安装 → ${t}/${NAME}"
done

echo ""
echo "  安装完成。试试对你的 Agent 说："
echo "    研判一下 XX 公司"
echo "    帮我准备下周的客户拜访"
echo ""
echo "  ⚠️  提醒：所有对外材料必须经人工确认后使用。"
echo ""
