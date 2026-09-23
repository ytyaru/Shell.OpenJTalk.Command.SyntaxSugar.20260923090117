#!/bin/bash
set -e

# ojt-list.sh のパス（同一ディレクトリ想定）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OJT_LIST="${SCRIPT_DIR}/ojt-list.sh"

# 【話者ごとの個別ルール定義】
# $1: 話者名 -> 出力: "区切り文字"
_getDelim() {
    case "$1" in
        mei|takumi)  echo "_" ;;
        tohoku-f01|type|H) echo "-" ;;
        海賊まさ)    echo "ver" ;;
        *)           echo "" ;; # 雪音ルウ, ひめる, J などは区切りなし
    esac
}

# 【改名・エイリアス解決】
# $1: 入力話者名 -> 出力: 正式話者名
_resolveSpeaker() {
    [ "$1" = "M" ] && echo "風音桜凪" || echo "$1"
}

# --- コマンド実装 ---

# 話者名と調子名から正確なモデル名を合成する
# $1: 話者名, $2: 調子名
cmd_getModel() {
    local spk delim
    spk="$(_resolveSpeaker "$1")"
    delim="$(_getDelim "${spk}")"
    echo "${spk}${delim}$2"
}

# 指定話者の全調子名（差分名）をリスト出力する
# $1: 話者名
cmd_listTone() {
    local spk delim
    spk="$(_resolveSpeaker "$1")"
    delim="$(_getDelim "${spk}")"
    
    # 1. 話者名でgrepし、2. 話者名+区切り文字の部分を削除して調子名だけを抽出
    if [ -n "${delim}" ]; then
        "${OJT_LIST}" grep "^${spk}${delim}" | sed "s/^${spk}${delim}//"
    else
        # 区切り文字がない場合は、前方一致から話者名自体を一削りする
        "${OJT_LIST}" grep "^${spk}" | sed "s/^${spk}//"
    fi
}

# 指定話者の調子名の数を返す
cmd_countTone() {
    cmd_listTone "$1" | wc -l
}

# 指定話者に指定の調子が存在するか (0/1)
cmd_hasTone() {
    local model
    model="$(cmd_getModel "$1" "$2")"
    "${OJT_LIST}" has "${model}"
}

# --- メイン処理 ---
SUBCOMMAND="$1"
shift || true

case "${SUBCOMMAND}" in
    getModel)  cmd_getModel "$1" "$2" ;;
    listTone)  cmd_listTone "$1" ;;
    countTone) cmd_countTone "$1" ;;
    hasTone)   cmd_hasTone "$1" "$2" ;;
    *)
        echo "使い方:" >&2
        echo "  $0 getModel <話者名> <調子名>" >&2
        echo "  $0 listTone <話者名>" >&2
        echo "  $0 countTone <話者名>" >&2
        echo "  $0 hasTone <話者名> <調子名>" >&2
        exit 1
        ;;
esac

