#!/bin/bash
set -e
# 💡 自身のディレクトリに移動
cd "$(dirname "$0")"

TSV_FILE="./name.tsv"
OJT_LIST="../list/list.sh"

if [ -f "../../config.sh" ]; then
    . "../../config.sh"
else
    echo "エラー: config.sh が見つかりません" >&2 && exit 1
fi
OJT_VOICE_ROOT="${OJT_VOICE_ROOT%/}"

_printHelp() { local t; t="$(cat "./help.txt")"; echo "${t//\${OJT_VOICE_ROOT\}/$OJT_VOICE_ROOT}" >&2; exit 1; }
_echo()      { "$@" && echo "Yes" || { echo "No"; return 1; }; }
_require()   { [ -z "$1" ] && echo "エラー: $2が必要です" >&2 && exit 1 || true; }
_getLine()   { grep -v '^#' "${TSV_FILE}" | awk -F'\t' -v s="$1" '$1==s'; }
_filterNone() { sed 's/\$NONE//g'; }

cmd_getModel() {
    _require "$1" "話者名"; _require "$2" "調子";
    local line delim tones
    line="$(_getLine "$1")"
    [ -n "$line" ] || { echo "エラー: 話者名が辞書にありません" >&2; exit 1; }
    delim="$(echo "$line" | cut -f2)"
    tones="$(echo "$line" | cut -f3)"
    echo ",${tones}," | grep -q ",$2," || { echo "エラー: 指定された調子がありません" >&2; exit 1; }
    echo "${1}${delim}${2}" | _filterNone
}

cmd_has() {
    local model
    model=$(cmd_getModel "$1" "$2" 2>/dev/null) || return 1
    # 💡 自身の位置が固定されているので、単純な相対パスのまま実行可能
    "${OJT_LIST}" has "${model}"
}

cmd_list() {
    grep -v '^#' "${TSV_FILE}" | while read -r line; do
        local spk delim tones
        spk="$(echo "$line" | cut -f1)"
        delim="$(echo "$line" | cut -f2 | _filterNone)"
        tones="$(echo "$line" | cut -f3 | tr ',' ' ')"
        for t in ${tones}; do echo -e "${spk}\t${t/\$NONE/}"; done
    done
}

cmd_listTalker() {
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

cmd_listHasToneTalker() { grep -v '^#' "${TSV_FILE}" | cut -f1 | sort; }

cmd_listTone() {
    _require "$1" "話者名"
    local line tones
    line="$(_getLine "$1")"
    [ -n "$line" ] || { echo "エラー: 指定話者は調子差異がありません" >&2; exit 1; }
    tones="$(echo "$line" | cut -f3)"
    echo "${tones}" | tr ',' '\n' | _filterNone
}

cmd_countTalker()       { cmd_listTalker | wc -l; }
cmd_countHasToneTalker() { cmd_listHasToneTalker | wc -l; }

cmd_countTone() {
    _require "$1" "話者名"
    local line
    line="$(_getLine "$1")"
    [ -n "$line" ] || { echo "エラー: 指定話者は調子差異がありません" >&2; exit 1; }
    cmd_listTone "$1" | grep -v '^$' | wc -l
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
    listTone)           cmd_listTone "$1" ;;
    countTalker)        cmd_countTalker ;;
    countHasToneTalker) cmd_countHasToneTalker ;;
    countTone)          cmd_countTone "$1" ;;
    *)                  _printHelp ;;
esac
