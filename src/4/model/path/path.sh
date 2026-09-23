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

cmd_model() {
    [ -n "$1" ] || { echo "エラー: モデル名が必要です" >&2 && exit 1; }
    # 💡 修正: config.sh 側で末尾スラッシュが保証されているため、単純な結合で100%安全
    local full_path="${OJT_VOICE_ROOT}${1}.htsvoice"
    if [ -f "${full_path}" ]; then
        echo "${full_path}"
    else
        echo "エラー: 指定された音声モデルファイルが実在しません: ${full_path}" >&2 && exit 1
    fi
}

cmd_name() {
    local speaker="$1"
    local tone="$2"
    
    [ -n "${speaker}" ] || { echo "エラー: 話者名が必要です" >&2 && exit 1; }
    
    if [ "${ARGS_COUNT}" -lt 3 ]; then
        echo "エラー: 調子の引数が足りません。調子がない場合は '\$NONE' または '' (空文字) を指定してください。modelコマンドで直接指定したほうが早いでしょう。" >&2
        exit 1
    fi

    if [ "${tone}" = '$NONE' ] || [ -z "${tone}" ]; then
        tone='$NONE'
    fi

    local model
    model=$("${OJT_NAME}" get "${speaker}" "${tone}" 2>/dev/null) || {
        echo "エラー: 指定された話者名と調子の組み合わせが辞書にありません" >&2 && exit 1
    }
    cmd_model "${model}"
}

SUBCOMMAND="$1"
ARGS_COUNT=$#
shift || true

case "${SUBCOMMAND}" in
    model) cmd_model "$1" ;;
    name)  cmd_name "$1" "$2" ;;
    *)     _printHelp ;;
esac
