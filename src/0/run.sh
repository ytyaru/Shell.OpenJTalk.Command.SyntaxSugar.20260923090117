#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# OpenJTalkを簡単に呼び出せるスクリプトを書く。
# CreatedAt: 20260923090044
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	ParseCommand() {
		THIS_NAME=`basename "$BASH_SOURCE"`
		SUMMARY='このプログラムの要約です。'
		VERSION=0.0.1
		ARG_FLAG=; ARG_OPT=;
		Help() { eval "echo -e \"$(cat help.txt)\""; }
		Version() { echo "$VERSION"; }
		while getopts ":hvfo:" OPT; do
		case $OPT in
			h) Help; exit 0;;
			v) Version; exit 0;;
			f) ARG_FLAG=1; exit 0;;
			o) ARG_OPT="$OPTARG"; ;;
		esac
		done
		shift $(($OPTIND - 1))
		ParseSubCommand() {
			[ 0 -eq $# ] && return || :;
			case $1 in
			-h|--help|help) Help; exit 0;;
			-v|--version|version) Version; exit 0;;
			esac
		}
		ParseSubCommand "$@"
		[ $# -eq 0 ] && { Error '位置引数は必須です。'; Help; exit 1; } || :;
	}
	ParseCommand "$@"
}
Run "$@"
