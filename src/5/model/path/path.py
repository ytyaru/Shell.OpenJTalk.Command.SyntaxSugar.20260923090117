#!/usr/bin/env python3
import sys
import os
import subprocess
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OJT_NAME_PY = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "name", "name.py"))
CONFIG_SH = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "..", "config.sh"))

def load_config_sh():
    if not os.path.exists(CONFIG_SH):
        print("エラー: config.sh が見つかりません", file=sys.stderr)
        sys.exit(1)
    with open(CONFIG_SH, "r", encoding="utf-8") as f:
        content = f.read()
    match = re.search(r'OJT_VOICE_ROOT=["\']?([^"\']+)["\']?', content)
    if match: return match.group(1)
    print("エラー: config.sh 内に OJT_VOICE_ROOT が定義されていません", file=sys.stderr)
    sys.exit(1)

OJT_VOICE_ROOT = load_config_sh()

def print_help():
    with open(os.path.join(SCRIPT_DIR, "help.txt"), "r", encoding="utf-8") as f:
        text = f.read().replace("${OJT_VOICE_ROOT}", OJT_VOICE_ROOT)
    print(text, file=sys.stderr)
    sys.exit(1)

def cmd_model(model_name):
    if not model_name:
        print("エラー: モデル名が必要です", file=sys.stderr)
        sys.exit(1)
    full_path = os.path.join(OJT_VOICE_ROOT, f"{model_name}.htsvoice")
    if os.path.exists(full_path):
        print(full_path)
    else:
        print(f"エラー: 指定された音声モデルファイルが実在しません: ${full_path}", file=sys.stderr)
        sys.exit(1)

def cmd_name(speaker, tone, has_tone_arg):
    if not speaker:
        print("エラー: 話者名が必要です", file=sys.stderr)
        sys.exit(1)
    
    if not has_tone_arg:
        print("エラー: 調子の引数が足りません。調子がない場合は '$NONE' または '' (空文字) を指定してください。modelコマンドで直接指定したほうが早いでしょう。", file=sys.stderr)
        sys.exit(1)
        
    actual_tone = "$NONE" if tone in ["$NONE", ""] else tone
    
    res = subprocess.run([sys.executable, OJT_NAME_PY, "get", speaker, actual_tone], capture_output=True, text=True)
    if res.returncode != 0:
        print("エラー: 指定された話者名と調子の組み合わせが辞書にありません", file=sys.stderr)
        sys.exit(1)
        
    model_name = res.stdout.strip()
    cmd_model(model_name)

def main():
    if len(sys.argv) < 2: print_help()
    
    # 💡 修正: インデックスを 1 ではなく 2, 3 から正確に取得する
    subcommand = sys.argv[1] if len(sys.argv) > 1 else ""
    
    if subcommand == "model":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        cmd_model(query)
    elif subcommand == "name":
        spk = sys.argv[2] if len(sys.argv) > 2 else ""
        tone = sys.argv[3] if len(sys.argv) > 3 else ""
        has_tone_arg = len(sys.argv) > 3
        cmd_name(spk, tone, has_tone_arg)
    else:
        print_help()

if __name__ == "__main__":
    main()
