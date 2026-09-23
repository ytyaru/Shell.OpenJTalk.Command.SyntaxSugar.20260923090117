#!/usr/bin/env bash
Error() { L=$BASH_LINENO; Highlight $L BR 'ERROR' "$@"; exit $L; }
Success() { Highlight $BASH_LINENO BG '' "$@"; }
Debug() { [ -n "$DEBUG" ] && Highlight $BASH_LINENO BB 'DEBUG' "$@" || :; }
Warn() { Highlight $BASH_LINENO BY 'WARN' "$@"; }
Highlight() { #$1:$BASH_LINENO, $2:Color(R,G,B,Y,C,M,K,W,B*...), $3:Header, $4...:Message
	local L="$1"
	local C=91
	local H="$3"
	case $2 in
		"K") C=30;;	"BK") C=90;;
		"R") C=31;;	"BR") C=91;;
		"G") C=32;;	"BG") C=92;;
		"Y") C=33;;	"BY") C=93;;
		"B") C=34;;	"BB") C=94;;
		"M") C=35;;	"BM") C=95;;
		"C") C=36;;	"BC") C=96;;
		"W") C=37;;	"BW") C=97;;
	esac
	Reset() { echo -en "\e[0m"; }
	Bold() { echo -en "\e[1m"; }
	Color() { echo -en "\e[${C}m"; }
	Header() { [ -n "$H" ] && { Bold; Color; echo -en "$H $L"': '; Reset; } || :; }
	Show() { Reset; Header; Color; echo -e "$msg" 1>&2; Reset; }
	#local ERR_CODE=$BASH_LINENO; [ 0 -eq $ERR_CODE ] && ERR_CODE=255;
	#local args=("$@"); local msg="$(IFS=$'\n'; echo -e "${args[*]}")"
	local args=("${@:4}"); local msg="$(IFS=$'\n'; echo -e "${args[*]}")"
	Show
}
