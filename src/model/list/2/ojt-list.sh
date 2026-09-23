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
# 基礎となる話者リストを出力する関数（全件）
_listVoice() { find "${OJT_VOICE_ROOT}" -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort; }
# --- サブコマンドの実装 ---
cmd_list() { _listVoice; }
cmd_grep() {
    local query="$1"
    if [ -z "$query" ]; then
        echo "エラー: grep サブコマンドには絞り込み名が必要です。" >&2
        exit 1
    fi
    # 部分一致 / 正規表現で絞り込み
    _listVoice | grep -e "$query"
}

cmd_count() {
    local query="$1"
    if [ -z "$query" ]; then
        # 絞り込み名がないときは全件数
        _listVoice | wc -l
    else
        # 絞り込み名があるときは、部分一致 / 正規表現で絞り込んだ件数
        _listVoice | grep -e "$query" | wc -l
    fi
}

cmd_has() {
    local query="$1"
    if [ -z "$query" ]; then
        echo "エラー: has サブコマンドには話者名が必要です。" >&2
        exit 1
    fi

    # 完全一致（-xF）で判定
    if _listVoice | grep -xFq "$query"; then
        echo "有る"
        return 0
    else
        echo "無い"
        return 1
    fi
}

cmd_any() {
    local query="$1"
    if [ -z "$query" ]; then
        echo "エラー: any サブコマンドには絞り込み名が必要です。" >&2
        exit 1
    fi

    # 部分一致 / 正規表現が1件でもあれば真(0)、なければ偽(1)
    if _listVoice | grep -q -e "$query"; then
        echo "有る"
        return 0
    else
        echo "無い"
        return 1
    fi
}

# --- メイン処理（引数解析） ---

SUBCOMMAND="$1"
shift || true # サブコマンドをずらして、絞り込み名を $1 にする

case "${SUBCOMMAND}" in
    list)  cmd_list ;;
    grep)  cmd_grep "$1" ;;
    count) cmd_count "$1" ;;
    has)   cmd_has "$1" ;;
    any)   cmd_any "$1" ;;
    *)
        echo "使い方:" >&2
        echo "  $0 list" >&2
        echo "  $0 grep <絞り込み名>" >&2
        echo "  $0 count [絞り込み名]" >&2
        echo "  $0 has <話者名(完全一致)>" >&2
        echo "  $0 any <絞り込み名(部分一致)>" >&2
        exit 1
        ;;
esac
