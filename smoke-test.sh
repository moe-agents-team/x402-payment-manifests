#!/usr/bin/env bash
# public/x402-workbench/smoke-test.sh — x402 v2 Manifest 轻量烟雾验证脚本
#
# 用途: 从 .well-known/x402.json 拉取 x402 v2 Manifest 并校验关键字段。
# 安全提醒: 执行前请先下载审阅本脚本，禁止通过管道直接执行（禁 curl ... | bash）。
#
# 校验项:
#   1. x402Version === 2
#   2. payment_methods_v2[0].network === "eip155:8453"
#   3. products 中 tier1-probe amount === "100000"
#   4. payment_methods_v2[0].payTo === 金库地址
#
# 输出: 清晰 PASS/FAIL 回执，任一校验失败非零退出。

set -euo pipefail

MANIFEST_URL="${1:-https://moe-agents-team.github.io/x402-payment-manifests/.well-known/x402.json}"
VAULT_ADDR="0xf270041f431efc7cc91cad83f9605e3f2ee96176"
EXPECTED_NETWORK="eip155:8453"
EXPECTED_AMOUNT="100000"
EXPECTED_X402_VERSION=2

echo "============================================================"
echo "  x402 v2 Manifest 烟雾验证 (Smoke Test)"
echo "  目标: $MANIFEST_URL"
echo "============================================================"
echo ""
echo "[安全提醒] 请先下载审阅本脚本后再执行，严禁通过管道直接执行（禁 curl ... | bash）。"
echo ""

# 拉取 Manifest
echo "▶ 正在拉取 Manifest ..."
if ! RESPONSE=$(curl -fsSL --max-time 10 "$MANIFEST_URL" 2>/dev/null); then
  echo "✖ 端点不可达或拉取失败: $MANIFEST_URL"
  exit 4
fi

# 解析字段（依赖 jq）
if ! command -v jq >/dev/null 2>&1; then
  echo "✖ 未安装 jq，无法解析 JSON Manifest。请先安装 jq。"
  exit 2
fi

X402_VERSION=$(echo "$RESPONSE" | jq -r '.x402Version // empty')
V2_NETWORK=$(echo "$RESPONSE" | jq -r '.payment_methods_v2[0].network // empty')
V2_PAYTO=$(echo "$RESPONSE" | jq -r '.payment_methods_v2[0].payTo // empty')
TIER1_AMOUNT=$(echo "$RESPONSE" | jq -r '.products[] | select(.id=="tier1-probe") | .amount // empty')

FAIL=0

echo ""
echo "┌──────────────────────────────────────────────────────────┐"
echo "│ 校验结果                                                  │"
echo "├──────────────────────────────────────────────────────────┤"

# 校验 1: x402Version
if [ "$X402_VERSION" = "$EXPECTED_X402_VERSION" ]; then
  echo "│ [PASS] x402Version = $X402_VERSION (预期 $EXPECTED_X402_VERSION)       │"
else
  echo "│ [FAIL] x402Version = ${X402_VERSION:-缺失} (预期 $EXPECTED_X402_VERSION) │"
  FAIL=1
fi

# 校验 2: v2 network
if [ "$V2_NETWORK" = "$EXPECTED_NETWORK" ]; then
  echo "│ [PASS] payment_methods_v2[0].network = $V2_NETWORK                       │"
else
  echo "│ [FAIL] payment_methods_v2[0].network = ${V2_NETWORK:-缺失} (预期 $EXPECTED_NETWORK) │"
  FAIL=1
fi

# 校验 3: tier1-probe amount
if [ "$TIER1_AMOUNT" = "$EXPECTED_AMOUNT" ]; then
  echo "│ [PASS] tier1-probe.amount = $TIER1_AMOUNT (预期 $EXPECTED_AMOUNT wei)    │"
else
  echo "│ [FAIL] tier1-probe.amount = ${TIER1_AMOUNT:-缺失} (预期 $EXPECTED_AMOUNT)│"
  FAIL=1
fi

# 校验 4: payTo / 金库地址
if [ "$V2_PAYTO" = "$VAULT_ADDR" ]; then
  echo "│ [PASS] payTo = $V2_PAYTO (金库地址匹配)                                   │"
else
  echo "│ [FAIL] payTo = ${V2_PAYTO:-缺失} (预期 $VAULT_ADDR)                      │"
  FAIL=1
fi

echo "└──────────────────────────────────────────────────────────┘"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "[PASS] x402 v2 Manifest 所有校验项通过，可进行后续 EIP-3009 握手。"
  exit 0
else
  echo "[FAIL] Manifest 校验未通过，请检查上述失败项后再进行操作。"
  exit 2
fi
