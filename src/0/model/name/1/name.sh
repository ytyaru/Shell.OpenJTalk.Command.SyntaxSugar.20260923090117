#!/bin/bash
set -e
OJT_VOICE_ROOT=/home/pi/root/sys/env/tool/openjtalk/voice/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TSV_FILE="${SCRIPT_DIR}/name.tsv"
OJT_LIST="${SCRIPT_DIR}/../list/list.sh"

_printHelp() { local t; t="$(cat "${SCRIPT_DIR}/help.txt")"; echo "${t//\${OJT_VOICE_ROOT\}/$OJT_VOICE_ROOT}" >&2; exit 1; }
_echo()      { "$@" && echo "Yes" || { echo "No"; return 1; }; }
_require()   { [ -z "$1" ] && echo "エラー: $2が必要です" >&2 && exit 1 || true; }

# TSVから該当話者の行を取得
_getLine()   { grep -v '^#' "${TSV_FILE}" | grep -E "^$1\t"; }

# $NONE 予約語を空文字に置換するフィルター
_filterNone() { sed 's/\$NONE//g'; }

cmd_getModel() {
    _require "$1" "話者名"; _require "$2" "調子";
    local line delim tones
    line="$(_getLine "$1")" || { echo "エラー: 話者名が辞書にありません" >&2; exit 1; }
    delim="$(echo "$line" | cut -f2)"
    tones="$(echo "$line" | cut -f3)"
    # 調子が存在するかチェック
    echo ",${tones}," | grep -q ",$2," || { echo "エラー: 指定された調子がありません" >&2; exit 1; }
    echo "${1}${delim}${2}" | _filterNone
}

cmd_has()    { cmd_getModel "$1" "$2" >/dev/null 2>&1 && "${OJT_LIST}" has "$(cmd_getModel "$1" "$2")"; }

cmd_list() {
    grep -v '^#' "${TSV_FILE}" | while read -r line; do
        local spk delim tones
        spk="$(echo "$line" | cut -f1)"
        delim="$(echo "$line" | cut -f2 | _filterNone)"
        tones="$(echo "$line" | cut -f3 | tr ',' ' ')"
        for t in ${tones}; do
            local t_disp="${t/\$NONE/}"
            echo -e "${spk}\t${t_disp}"
        done
    done
}

cmd_listTalker() {
    # TSVに登録されている話者 ＋ list.sh から調子を持たない単体モデルも合算して一覧する
    { grep -v '^#' "${TSV_FILE}" | cut -f1; "${OJT_LIST}" list | while read -r v; do
        local matched=0
        while read -r line; do
            local spk delim
            spk="$(echo "$line" | cut -f1)"
            delim="$(echo "$line" | cut -f2 | _filterNone)"
            if [[ -n "$delim" && "$v" == "${spk}${delim}"* ]] || [[ "$v" == "${spk}"* ]]; then
                matched=1; break
            fi
        done < <(grep -v '^#' "${TSV_FILE}")
        [ $matched -eq 0 ] && echo "$v" || true
    done; } | sort -u
}

cmd_listHasToneTalker() { grep -v '^#' "${TSV_FILE}" | cut -f1; }
cmd_countTalker()       { cmd_listTalker | wc -l; }
cmd_countHasToneTalker() { cmd_listHasToneTalker | wc -l; }

cmd_countTone() {
    _require "$1" "話者名"
    local line tones
    line="$(_getLine "$1")" || { echo "エラー: 指定話者は調子差異がありません" >&2; exit 1; }
    tones="$(echo "$line" | cut -f3)"
    echo ",${tones}," | tr ',' '\n' | grep -v '^$' | wc -l
}

SUBCOMMAND="$1"
shift || true

case "${SUBCOMMAND}" in
    get)                cmd_getModel "$1" "$2" ;;
    has)                cmd_has "$1" "$2" ;;
    hasEcho)            _echo cmd_has "$1" "$2" ;;
    list)               cmd_list ;;
    listTalker)         cmd_listTalker ;;
    listHasToneTalker)  cmd_listHasToneTalker ;;
    countTalker)        cmd_countTalker ;;
    countHasToneTalker) cmd_countHasToneTalker ;;
    countTone)          cmd_countTone "$1" ;;
    *)                  _printHelp ;;
esac
