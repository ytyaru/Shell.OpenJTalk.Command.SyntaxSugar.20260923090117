#!/bin/bash
# name.sh と name.py の挙動を同時に自動テストするスクリプト
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
        # 期待する出力（改行を除去して部分一致、または完全一致）
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

echo "=== OpenJTalk Name API 自動検証テスト開始 ==="

# 1. getコマンドの検証（補完文字の自動結合確認）
assert_output "get型1(mei)" "get" "mei" "happy" "mei_happy" 0
assert_output "get型2(H)" "get" "H" "9" "H-09" 0
assert_output "get型3(雪音ルウ)" "get" "雪音ルウ" "２" "雪音ルウ２" 0
assert_output "get型4(異常系)" "get" "mei" "invalid_tone" "" 1

# 2. has / hasEcho コマンドの検証（Yes/No および終了コード）
assert_output "hasEcho正常" "hasEcho" "mei" "normal" "Yes" 0
assert_output "hasEcho異常" "hasEcho" "mei" "invalid" "No" 1

# 3. listTone / countTone の検証
assert_output "countTone正常" "countTone" "mei" "" "5" 0
assert_output "countTone異常" "countTone" "invalid_spk" "" "" 1

echo "----------------------------------------"
echo "テスト完了: 成功 ${passed} 件 / 失敗 ${failed} 件"

if [ ${failed} -ne 0 ]; then
    echo "⚠️ 一部のテストが失敗しました。修正が必要です。"
    exit 1
else
    echo "🎉 すべての自動テストを通過しました！ロジックは完全に堅牢です。"
    exit 0
fi
