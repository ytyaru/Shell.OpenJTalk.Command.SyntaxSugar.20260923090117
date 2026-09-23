#!/usr/bin/env python3
import sys
import os
import subprocess
import locale
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TSV_FILE = os.path.join(SCRIPT_DIR, "name.tsv")
OJT_LIST_PY = os.path.join(SCRIPT_DIR, "..", "list", "ojt_list.py")
CONFIG_SH = os.path.join(SCRIPT_DIR, "..", "..", "config.sh")

locale.setlocale(locale.LC_ALL, 'ja_JP.UTF-8')

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

def load_tsv():
    config = {}
    if not os.path.exists(TSV_FILE): return config
    with open(TSV_FILE, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("#") or not line: continue
            parts = line.split("\t")
            if len(parts) >= 3:
                spk, delim, tones_str = parts[0], parts[1], parts[2]
                tones = tones_str.split(",")
                config[spk] = {
                    "delim": "" if delim == "$NONE" else delim,
                    "tones": ["" if t == "$NONE" else t for t in tones]
                }
    return config

def get_all_list_models():
    res = subprocess.run([sys.executable, OJT_LIST_PY, "list"], capture_output=True, text=True, check=True, cwd=os.path.dirname(OJT_LIST_PY))
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
        res = subprocess.run([sys.executable, OJT_LIST_PY, "has", model], cwd=os.path.dirname(OJT_LIST_PY))
        return res.returncode == 0
    except SystemExit:
        return False

def main():
    if len(sys.argv) < 2: print_help()
    subcommand = sys.argv[1]
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
            for t in info["tones"]: print(f"{spk}\t{t}")
    elif subcommand == "listTalker":
        tsv_speakers = set(config.keys())
        all_models = get_all_list_models()
        standalone = []
        for m in all_models:
            matched = False
            for spk, info in config.items():
                prefix = f"{spk}{info['delim']}"
                if (prefix and m.startswith(prefix)) or m.startswith(spk):
                    matched = True; break
            if not matched: standalone.append(m)
        all_talkers = sorted(list(tsv_speakers) + standalone, key=locale.strxfrm)
        for t in all_talkers: print(t)
    elif subcommand == "listHasToneTalker":
        for spk in sorted(config.keys(), key=locale.strxfrm): print(spk)
    elif subcommand == "listTone":
        if len(sys.argv) < 3 or sys.argv[2] not in config:
            print("エラー: 指定話者は調子差異がありません", file=sys.stderr)
            sys.exit(1)
        for t in config[sys.argv[2]]["tones"]: print(t)
    elif subcommand == "countTalker":
        tsv_speakers = set(config.keys())
        all_models = get_all_list_models()
        standalone = [m for m in all_models if not any((f"{spk}{info['delim']}" and m.startswith(f"{spk}{info['delim']}")) or m.startswith(spk) for spk, info in config.items())]
        print(len(tsv_speakers) + len(standalone))
    elif subcommand == "countHasToneTalker":
        print(len(config))
    elif subcommand == "countTone":
        if len(sys.argv) < 3 or sys.argv[2] not in config:
            print("エラー: 指定話者は調子差異がありません", file=sys.stderr)
            sys.exit(1)
        print(len(config[sys.argv[2]]["tones"]))
    else:
        print_help()

if __name__ == "__main__":
    main()
