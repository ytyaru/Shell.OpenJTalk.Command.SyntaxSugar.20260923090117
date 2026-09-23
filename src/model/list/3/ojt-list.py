#!/usr/bin/env python3
import sys
import os
import glob

OJT_VOICE_ROOT = "/home/pi/root/sys/env/tool/openjtalk/voice/"

def get_voices():
    # パスからファイル名を取得し、拡張子を消してソート
    files = glob.glob(os.path.join(OJT_VOICE_ROOT, "*"))
    voices = [os.path.splitext(os.path.basename(f))[0] for f in files if os.path.isfile(f)]
    return sorted(voices)

def main():
    if len(sys.argv) < 2:
        sys.exit(1)
        
    subcommand = sys.argv[1]
    query = sys.argv[2] if len(sys.argv) > 2 else ""
    voices = get_voices()

    if subcommand == "list":
        for v in voices:
            if not query or query in v:
                print(v)
    elif subcommand == "count":
        print(len([v for v in voices if query in v]))
    elif subcommand == "has":
        # 完全一致
        print("有る" if query in voices else "無い")
        sys.exit(0 if query in voices else 1)
    elif subcommand == "any":
        # 部分一致が1件以上あるか
        has_any = any(query in v for v in voices)
        sys.exit(0 if has_any else 1)

if __name__ == "__main__":
    main()

