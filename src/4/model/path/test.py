#!/usr/bin/env python3
import unittest
import subprocess
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_PY = os.path.join(SCRIPT_DIR, "path.py")

class TestPath(unittest.TestCase):
    def run_cmd(self, sub, arg1=None, arg2=None):
        args = [sys.executable, TARGET_PY, sub]
        if arg1 is not None: args.append(arg1)
        if arg2 is not None: args.append(arg2)
        res = subprocess.run(args, capture_output=True, text=True)
        return res.stdout.strip(), res.returncode

    def test_model_success(self):
        out, code = self.run_cmd("model", "mei_normal")
        self.assertTrue(out.endswith("mei_normal.htsvoice"))
        self.assertEqual(code, 0)

    def test_model_failed(self):
        out, code = self.run_cmd("model", "invalid_filename")
        self.assertEqual(code, 1)

    def test_name_success(self):
        out, code = self.run_cmd("name", "mei", "normal")
        self.assertTrue(out.endswith("mei_normal.htsvoice"))
        self.assertEqual(code, 0)

    def test_name_none_token(self):
        out, code = self.run_cmd("name", "雪音ルウ", "$NONE")
        self.assertTrue(out.endswith("雪音ルウ.htsvoice"))
        self.assertEqual(code, 0)

    def test_name_empty_string(self):
        out, code = self.run_cmd("name", "雪音ルウ", "")
        self.assertTrue(out.endswith("雪音ルウ.htsvoice"))
        self.assertEqual(code, 0)

    def test_name_missing_args(self):
        out, code = self.run_cmd("name", "雪音ルウ")
        self.assertEqual(code, 1)

if __name__ == "__main__":
    unittest.main()
