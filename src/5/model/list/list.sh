#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ -f "../../config.sh" ]; then
    . "../../config.sh"
else
    echo "エラー: config.sh が見つかりません" >&2 && exit 1
fi

_listVoice() { find "${OJT_VOICE_ROOT}" -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort; }
_printHelp() { local t; t="$(cat "./help.txt")"; echo "${t//\${OJT_VOICE_ROOT\}/$OJT_VOICE_ROOT}" >&2; exit 1; }
_echo()      { "$@" && echo "Yes" || { echo "No"; return 1; }; }
_find()      { [ -n "$1" ] || { echo "エラー: $2が必要です" >&2 && exit 1; }; _listVoice | grep $3 "$1"; }

cmd_list()   { _listVoice; }
cmd_count()  { [ -z "$1" ] && _listVoice | wc -l || _listVoice | grep -e "$1" | wc -l; }
cmd_grep()   { _find "$1" "絞込名" "-e"; }
cmd_has()    { _find "$1" "モデル名" "-xFq"; }
cmd_any()    { _find "$1" "絞込名" "-q -e"; }

SUBCOMMAND="$1"
shift || true

case "${SUBCOMMAND}" in
    list)    cmd_list ;;
    grep)    cmd_grep "$1" ;;
    count)   cmd_count "$1" ;;
    has)     cmd_has "$1" ;;
    any)     cmd_any "$1" ;;
    hasEcho) _echo cmd_has "$1" ;;
    anyEcho) _echo cmd_any "$1" ;;
    *)       _printHelp ;;
esac
