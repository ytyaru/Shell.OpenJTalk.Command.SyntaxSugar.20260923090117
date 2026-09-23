#!/bin/bash
set -e
cd "$(dirname "$0")"

OJT_NAME="../name/name.sh"

if [ -f "../../config.sh" ]; then
    . "../../config.sh"
else
    echo "エラー: config.sh が見つかりません" >&2 && exit 1
fi

_printHelp() { local t; t="$(cat "./help.txt")"; echo "${t//\${OJT_VOICE_ROOT\}/$OJT_VOICE_ROOT}" >&2; exit 1; }
_require()   { [ -z "$1" ] && echo "エラー: $2が必要です" >&2 && exit 1 || true; }

cmd_model() {
    _require "$1" "モデル名"
    local full_path="${OJT_VOICE_ROOT}${1}.htsvoice"
    if [ -f "${full_path}" ]; then
        echo "${full_path}"
    else
        echo "エラー: 指定された音声モデルファイルが実在しません: ${full_path}" >&2 && exit 1
    fi
}

cmd_name() {
    _require "$1" "話者名"
    
    # 💡 引数の個数そのものをチェック：2個未満（調子を忘れた時）は即エラー
    if [ "${ARGS_COUNT}" -lt 3 ]; then
        echo "エラー: 調子の引数が足りません。調子がない場合は '\$NONE' または '' (空文字) を指定してください。modelコマンドで直接指定したほうが早いでしょう。" >&2
        exit 1
    fi

    local tone="$2"
    # '$NONE' または 空文字の場合のみ「何もない状態」と判定
    if [ "${tone}" = '$NONE' ] || [ -z "${tone}" ]; then
        tone=""
    fi

    # name/name.sh を使って正確なモデル名を解決する（空の場合は下位に $NONE を明示）
    local model
    model=$("${OJT_NAME}" get "$1" "${tone:-$NONE}" 2>/dev/null) || {
        echo "エラー: 指定された話者名と調子の組み合わせが辞書にありません" >&2 && exit 1
    }
    cmd_model "${model}"
}

SUBCOMMAND="$1"
# shiftする前に元の引数カウントを保持
ARGS_COUNT=$#
shift || true

case "${SUBCOMMAND}" in
    model) cmd_model "$1" ;;
    name)  cmd_name "$1" "$2" ;;
    *)     _printHelp ;;
esac

