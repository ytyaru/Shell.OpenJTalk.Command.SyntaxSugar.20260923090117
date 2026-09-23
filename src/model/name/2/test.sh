#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SH_CMD="${SCRIPT_DIR}/name.sh"
PY_CMD="python3 ${SCRIPT_DIR}/name.py"

passed=0
failed=0

assert_output() {
    local label="$1" sub="$2" arg1="$3" arg2="$4" expected="$5" exp_code="$6"
    for cmd in "${SH_CMD}" "${PY_CMD}"; do
        set +e
        out=$($cmd "$sub" "$arg1" "$arg2" 2>/dev/null)
        code=$?
        set -e
        if [ "$out" = "$expected" ] && [ "$code" -eq "$exp_code" ]; then
            passed=$((passed + 1))
        else
            echo "❌ 失敗 [${label}] 使用コマンド: ${cmd} ${sub} ${arg1} ${arg2}"
            echo "   期待値: [${expected}] (コード: ${exp_code})"
            echo "   実際の出力: [${out}] (コード: ${code})"
            failed=$((failed + 1))
        fi
    done
}

echo "=== OpenJTalk Name API リアル環境自動検証テスト開始 ==="

assert_output "get型1(mei)" "get" "mei" "happy" "mei_happy" 0
assert_output "get型2(H)" "get" "H" "9" "H-09" 0
assert_output "get型3(雪音ルウ)" "get" "雪音ルウ" "２" "雪音ルウ２" 0
assert_output "get型4(異常系)" "get" "mei" "invalid_tone" "" 1

# 実ファイルが存在するのであれば、当然 Yes/コード0 になるべき箇所
assert_output "hasEcho正常" "hasEcho" "mei" "normal" "Yes" 0
assert_output "hasEcho異常" "hasEcho" "mei" "invalid" "No" 1

assert_output "countTone正常" "countTone" "mei" "" "5" 0
# 存在しない話者には何も出力せず、終了コード 1（エラー）を返すのが正しい挙動
assert_output "countTone異常" "countTone" "invalid_spk" "" "" 1

echo "----------------------------------------"
echo "テスト完了: 成功 ${passed} 件 / 失敗 ${failed} 件"

if [ ${failed} -ne 0 ]; then
    echo "⚠️ 現実のファイル状態とロジックに不整合があります。テスト失敗。"
    exit 1
else
    echo "🎉 すべての自動テストを完全通過しました！現実のファイルと辞書が完全に一致しています。"
    exit 0
fi
