#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SH_CMD="${SCRIPT_DIR}/name.sh"

passed=0
failed=0

assert_output() {
    local label="$1" sub="$2" arg1="$3" arg2="$4" expected="$5" exp_code="$6"
    set +e
    out=$($SH_CMD "$sub" "$arg1" "$arg2" 2>/dev/null)
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

echo "=== OpenJTalk name.sh 自動検証テスト開始 ==="

assert_output "get型1(mei)" "get" "mei" "happy" "mei_happy" 0
assert_output "get型2(H)" "get" "H" "9" "H-09" 0
assert_output "get型3(雪音ルウ)" "get" "雪音ルウ" "２" "雪音ルウ２" 0
assert_output "get型4(異常系)" "get" "mei" "invalid_tone" "" 1

assert_output "has正常" "has" "mei" "normal" "" 0
assert_output "has異常" "has" "mei" "invalid" "" 1
assert_output "hasEcho正常" "hasEcho" "mei" "normal" "Yes" 0
assert_output "hasEcho異常" "hasEcho" "mei" "invalid" "No" 1

assert_output "countTone正常" "countTone" "mei" "" "5" 0
assert_output "countTone異常" "countTone" "invalid_spk" "" "" 1

echo "----------------------------------------"
echo "Bash name.sh テスト完了: 成功 ${passed} 件 / 失敗 ${failed} 件"
exit ${failed}
