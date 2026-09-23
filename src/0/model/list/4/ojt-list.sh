#!/bin/bash
set -e
OJT_VOICE_ROOT=/home/pi/root/sys/env/tool/openjtalk/voice/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
_listVoice() { find "${OJT_VOICE_ROOT}" -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort; }
_printHelp() { sed "s|__OJT_VOICE_ROOT__|${OJT_VOICE_ROOT}|g" "${SCRIPT_DIR}/help.txt" >&2; exit 1; }
_echo() { "$1" && echo "Yes" || { echo "No"; return 1; }; }
cmd_list()  { _listVoice; }
cmd_grep()  { [ -z "$1" ] && echo "エラー: 絞込名が必要です" >&2 && exit 1; _listVoice | grep -e "$1"; }
cmd_count() { [ -z "$1" ] && _listVoice | wc -l || _listVoice | grep -e "$1" | wc -l; }
cmd_has()   { [ -z "$1" ] && echo "エラー: モデル名が必要です" >&2 && exit 1; _listVoice | grep -xFq "$1"; }
cmd_any()   { [ -z "$1" ] && echo "エラー: 絞込名が必要です" >&2 && exit 1; _listVoice | grep -q -e "$1"; }
#cmd_hasEcho() { cmd_has "$1" && echo "Yes" || { echo "No"; return 1; }; }
#cmd_anyEcho() { cmd_any "$1" && echo "Yes" || { echo "No"; return 1; }; }
SUBCOMMAND="$1"
shift || true
case "${SUBCOMMAND}" in
    list)    cmd_list ;;
    grep)    cmd_grep "$1" ;;
    count)   cmd_count "$1" ;;
    has)     cmd_has "$1" ;;
    any)     cmd_any "$1" ;;
#    hasEcho) cmd_hasEcho "$1" ;;
#    anyEcho) cmd_anyEcho "$1" ;;
    hasEcho) _echo($(cmd_has "$1")) ;;
    anyEcho) _echo($(cmd_any "$1")) ;;
    *)       _printHelp ;;
esac
