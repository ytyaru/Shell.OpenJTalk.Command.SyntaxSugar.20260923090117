#!/bin/bash
# OpenJTalkのvoice一覧、件数、存在確認スクリプト
# ojt-list.sh list				# 全件取得
# ojt-list.sh grep 絞り込み名（部分一致または正規表現に合致したものだけlistする）
# ojt-list.sh count
# ojt-list.sh count 絞り込み名（絞り込み名があるときは部分一致または正規表現が渡されたものとする。全件からgrepで絞り込んだ件数を返す）
# ojt-list.sh has 絞り込み名（完全一致）
# ojt-list.sh any 絞り込み名（部分一致または正規表現）
set -e
OJT_VOICE_ROOT=/home/pi/root/sys/env/tool/openjtalk/voice/
_listVoice() { find "${OJT_VOICE_ROOT}" -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort; }
cmd_list()  { _listVoice; }
cmd_grep()  { [ -z "$1" ] && echo "エラー: 絞り込み名が必要です" >&2 && exit 1; _listVoice | grep -e "$1"; }
cmd_count() { [ -z "$1" ] && _listVoice | wc -l || _listVoice | grep -e "$1" | wc -l; }
# ステータスのみ返却 (0=真, 1=偽)
cmd_has() { [ -z "$1" ] && echo "エラー: 話者名が必要です" >&2 && exit 1; _listVoice | grep -xFq "$1"; }
cmd_any() { [ -z "$1" ] && echo "エラー: 絞り込み名が必要です" >&2 && exit 1; _listVoice | grep -q -e "$1"; }
# ステータス返却 ＋ 画面に Yes/No を出力
cmd_hasEcho() { cmd_has "$1" && echo "Yes" || { echo "No"; return 1; }; }
cmd_anyEcho() { cmd_any "$1" && echo "Yes" || { echo "No"; return 1; }; }
# --- メイン処理 ---
SUBCOMMAND="$1"
shift || true
case "${SUBCOMMAND}" in
    list)    cmd_list ;;
    grep)    cmd_grep "$1" ;;
    count)   cmd_count "$1" ;;
    has)     cmd_has "$1" ;;
    any)     cmd_any "$1" ;;
    hasEcho) cmd_hasEcho "$1" ;;
    anyEcho) cmd_anyEcho "$1" ;;
    *)
        echo "使い方:" >&2
        echo "  $0 list / grep <名前> / count [名前]" >&2
        echo "  $0 has <名前> / any <名前>     (終了ステータス 0か1 を返却)" >&2
        echo "  $0 hasEcho <名前> / anyEcho <名前> (Yes/No を出力 ＋ ステータス返却)" >&2
        exit 1
        ;;
esac
