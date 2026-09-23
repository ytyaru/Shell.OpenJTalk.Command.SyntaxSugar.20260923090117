#!/usr/bin/env python3
import sys
import os
import re

OJT_VOICE_ROOT = "/home/pi/root/sys/env/tool/openjtalk/voice/"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def get_voices():
    if not os.path.exists(OJT_VOICE_ROOT): return []
    files = [f for f in os.listdir(OJT_VOICE_ROOT) if os.path.isfile(os.path.join(OJT_VOICE_ROOT, f))]
    return sorted([os.path.splitext(f)[0] for f in files])

def print_help():
    with open(os.path.join(SCRIPT_DIR, "help.txt"), "r", encoding="utf-8") as f:
        text = f.read().replace("__OJT_VOICE_ROOT__", OJT_VOICE_ROOT)
    print(text, file=sys.stderr)
    sys.exit(1)

def main():
    if len(sys.argv) < 2: print_help()
    subcommand = sys.argv[1]
    query = sys.argv[2] if len(sys.argv) > 2 else ""
    
    # サブコマンドに応じた必須引数のラベル定義
    REQUIRED_ARGS = {
        "grep": "絞込名", "any": "絞込名", "anyEcho": "絞込名",
        "has": "モデル名", "hasEcho": "モデル名"
    }

    # 引数チェックのメッセージを統一
    if subcommand in REQUIRED_ARGS and not query:
        print(f"エラー: {subcommand}には{REQUIRED_ARGS[subcommand]}が必要です。", file=sys.stderr)
        sys.exit(1)

    voices = get_voices()

    if subcommand == "list":
        for v in voices: print(v)
    elif subcommand == "grep":
        for v in voices:
            if re.search(query, v): print(v)
    elif subcommand == "count":
        print(len([v for v in voices if re.search(query, v)]) if query else len(voices))
    elif subcommand in ["has", "hasEcho"]:
        is_match = query in voices
        if subcommand == "hasEcho": print("Yes" if is_match else "No")
        sys.exit(0 if is_match else 1)
    elif subcommand in ["any", "anyEcho"]:
        is_match = any(re.search(query, v) for v in voices)
        if subcommand == "anyEcho": print("Yes" if is_match else "No")
        sys.exit(0 if is_match else 1)
    else:
        print_help()

if __name__ == "__main__":
    main()
