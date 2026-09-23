#!/usr/bin/env python3
import sys
import os
import subprocess
import locale

OJT_VOICE_ROOT = "/home/pi/root/sys/env/tool/openjtalk/voice/"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TSV_FILE = os.path.join(SCRIPT_DIR, "name.tsv")
OJT_LIST_PY = os.path.join(SCRIPT_DIR, "..", "list", "ojt_list.py")

locale.setlocale(locale.LC_ALL, 'ja_JP.UTF-8')

def print_help():
    with open(os.path.join(SCRIPT_DIR, "help.txt"), "r", encoding="utf-8") as f:
        text = f.read().replace("${OJT_VOICE_ROOT}", OJT_VOICE_ROOT)
    print(text, file=sys.stderr)
    sys.exit(1)

def load_tsv():
    config = {}
    if not os.path.exists(TSV_FILE): return config
    with open(TSV_FILE, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("#") or not line.strip(): continue
            parts = line.strip().split("\t")
            if len(parts) >= 3:
                spk, delim, tones = parts[0], parts[1], parts[2].split(",")
                config[spk] = {
                    "delim": "" if delim == "$NONE" else delim,
                    "tones": ["" if t == "$NONE" else t for t in tones]
                }
    return config

def get_all_list_models():
    res = subprocess.run([sys.executable, OJT_LIST_PY, "list"], capture_output=True, text=True, check=True)
    return res.stdout.splitlines()

def cmd_get_model(speaker, tone, config):
    if speaker not in config:
        print("エラー: 話者名が辞書にありません", file=sys.stderr)
        sys.exit(1)
    if tone not in config[speaker]["tones"]:
        print("エラー: 指定された調子がありません", file=sys.stderr)
        sys.exit(1)
    return f"{speaker}{config[speaker]['delim']}{tone}"

def cmd_has(speaker, tone, config):
    try:
        model = cmd_get_model(speaker, tone, config)
        res = subprocess.run([sys.executable, OJT_LIST_PY, "has", model])
        return res.returncode == 0
    except SystemExit:
        return False

def main():
    if len(sys.argv) < 2: print_help()
    subcommand = sys.argv
    config = load_tsv()

    if subcommand == "get":
        if len(sys.argv) < 4:
            print("エラー: getには話者名と調子が必要です。", file=sys.stderr)
            sys.exit(1)
        print(cmd_get_model(sys.argv[2], sys.argv[3], config))
        
    elif subcommand == "has":
        sys.exit(0 if cmd_has(sys.argv[2], sys.argv[3], config) else 1)
        
    elif subcommand == "hasEcho":
        is_match = cmd_has(sys.argv[2], sys.argv[3], config)
        print("Yes" if is_match else "No")
        sys.exit(0 if is_match else 1)
        
    elif subcommand == "list":
        for spk, info in config.items():
            for t in info["tones"]:
                print(f"{spk}\t{t}")
                
    elif subcommand == "listTalker":
        tsv_speakers = set(config.keys())
        all_models = get_all_list_models()
        standalone = []
        for m in all_models:
            matched = False
            for spk, info in config.items():
                prefix = f"{spk}{info['delim']}"
                if (prefix and m.startswith(prefix)) or m.startswith(spk):
                    matched = True
                    break
            if not matched: standalone.append(m)
        all_talkers = sorted(list(tsv_speakers) + standalone, key=locale.strxfrm)
        for t in all_talkers: print(t)
        
    elif subcommand == "listHasToneTalker":
        for spk in sorted(config.keys(), key=locale.strxfrm): print(spk)
        
    elif subcommand == "countTalker":
        # listTalker の結果行数を数える
        tsv_speakers = set(config.keys())
        all_models = get_all_list_models()
        standalone = [m for m in all_models if not any((f"{spk}{info['delim']}" and m.startswith(f"{spk}{info['delim']}")) or m.startswith(spk) for spk, info in config.items())]
        print(len(tsv_speakers) + len(standalone))
        
    elif subcommand == "countHasToneTalker":
        print(len(config))
        
    elif subcommand == "countTone":
        speaker = sys.argv[2] if len(sys.argv) > 2 else ""
        if speaker not in config:
            print("エラー: 指定話者は調子差異がありません", file=sys.stderr)
            sys.exit(1)
        print(len(config[speaker]["tones"]))
    else:
        print_help()

if __name__ == "__main__":
    main()
