#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SH_CMD="${SCRIPT_DIR}/list.sh"

passed=0
failed=0

assert_output() {
    local label="$1" sub="$2" arg1="$3" expected="$4" exp_code="$5"
    set +e
    out=$($SH_CMD "$sub" "$arg1" 2>/dev/null)
    code=$?
    set -e
    if [ "$out" = "$expected" ] && [ "$code" -eq "$exp_code" ]; then
        passed=$((passed + 1))
    else
        echo "❌ Bashテスト失敗 [${label}]"
        echo "   期待値: [${expected}] (コード: ${exp_code})"
        echo "   実際の出力: [${out}] (コード: ${code})"
        failed=$((failed + 1))
    fi
}

echo "=== OpenJTalk list.sh 自動検証テスト開始 ==="

assert_output "has正常" "has" "mei_normal" "" 0
assert_output "has異常" "has" "invalid_model_name" "" 1
assert_output "hasEcho正常" "hasEcho" "mei_normal" "Yes" 0
assert_output "hasEcho異常" "hasEcho" "invalid_model_name" "No" 1
assert_output "any正常" "any" "mei_" "" 0
assert_output "any異常" "any" "invalid_prefix_" "" 1
assert_output "anyEcho正常" "anyEcho" "mei_" "Yes" 0
assert_output "anyEcho異常" "anyEcho" "invalid_prefix_" "No" 1

echo "----------------------------------------"
echo "Bashテスト完了: 成功 ${passed} 件 / 失敗 ${failed} 件"
exit ${failed}
