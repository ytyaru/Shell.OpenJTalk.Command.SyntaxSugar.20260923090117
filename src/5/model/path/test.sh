#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SH_CMD="${SCRIPT_DIR}/path.sh"

passed=0
failed=0

assert_output() {
    local label="$1" sub="$2" arg1="$3" arg2="$4" expected_suffix="$5" exp_code="$6"
    set +e
    # 💡 引数不足テストの時は、第4引数をコマンドライン自体に含めないように厳密に分離
    if [ "${label}" = "name解決引数不足エラー" ]; then
        out=$($SH_CMD "$sub" "$arg1" 2>/dev/null)
    else
        out=$($SH_CMD "$sub" "$arg1" "$arg2" 2>/dev/null)
    fi
    code=$?
    set -e
    
    if { [ -n "${expected_suffix}" ] && [[ "$out" == *"${expected_suffix}" ]] && [ "$code" -eq "$exp_code" ]; } || \
       { [ -z "${expected_suffix}" ] && [ -z "$out" ] && [ "$code" -eq "$exp_code" ]; }; then
        passed=$((passed + 1))
    else
        echo "❌ Bash path.sh テスト失敗 [${label}]"
        echo "   期待する末尾: [${expected_suffix}] (コード: ${exp_code})"
        echo "   実際の出力: [${out}] (コード: ${code})"
        failed=$((failed + 1))
    fi
}

echo "=== OpenJTalk path.sh 自動検証テスト開始 ==="

assert_output "model直接指定正常" "model" "mei_normal" "" "mei_normal.htsvoice" 0
assert_output "model直接指定異常" "model" "invalid_filename" "" "" 1
assert_output "model直接指定正常(雪音ルウ２)" "model" "雪音ルウ２" "" "雪音ルウ２.htsvoice" 0

assert_output "name解決正常" "name" "mei" "normal" "mei_normal.htsvoice" 0
assert_output "name解決(NONEリテラル)" "name" "雪音ルウ" '$NONE' "雪音ルウ.htsvoice" 0
assert_output "name解決(空文字)" "name" "雪音ルウ" "" "雪音ルウ.htsvoice" 0
assert_output "name解決引数不足エラー" "name" "雪音ルウ" "" "" 1
assert_output "name解決(雪音ルウ+２)" "name" "雪音ルウ" '２' "雪音ルウ２.htsvoice" 0


echo "----------------------------------------"
echo "Bash path.sh テスト完了: 成功 ${passed} 件 / 失敗 ${failed} 件"
exit ${failed}
