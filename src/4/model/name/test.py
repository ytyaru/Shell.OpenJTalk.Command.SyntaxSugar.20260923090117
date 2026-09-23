#!/usr/bin/env python3
import unittest
import subprocess
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_PY = os.path.join(SCRIPT_DIR, "name.py")

class TestName(unittest.TestCase):
    def run_cmd(self, sub, arg1="", arg2=""):
        args = [sys.executable, TARGET_PY, sub]
        if arg1: args.append(arg1)
        if arg2: args.append(arg2)
        res = subprocess.run(args, capture_output=True, text=True)
        return res.stdout.strip(), res.returncode

    def test_get_mei(self):
        out, code = self.run_cmd("get", "mei", "happy")
        self.assertEqual(out, "mei_happy")
        self.assertEqual(code, 0)

    def test_get_h(self):
        out, code = self.run_cmd("get", "H", "9")
        self.assertEqual(out, "H-09")
        self.assertEqual(code, 0)

    def test_get_ru(self):
        out, code = self.run_cmd("get", "雪音ルウ", "２")
        self.assertEqual(out, "雪音ルウ２")
        self.assertEqual(code, 0)

    def test_get_failed(self):
        out, code = self.run_cmd("get", "mei", "invalid_tone")
        self.assertEqual(code, 1)

    def test_has_success(self):
        out, code = self.run_cmd("has", "mei", "normal")
        self.assertEqual(code, 0)

    def test_has_failed(self):
        out, code = self.run_cmd("has", "mei", "invalid")
        self.assertEqual(code, 1)

    def test_has_echo_success(self):
        out, code = self.run_cmd("hasEcho", "mei", "normal")
        self.assertEqual(out, "Yes")
        self.assertEqual(code, 0)

    def test_has_echo_failed(self):
        out, code = self.run_cmd("hasEcho", "mei", "invalid")
        self.assertEqual(out, "No")
        self.assertEqual(code, 1)

    def test_count_tone_success(self):
        out, code = self.run_cmd("countTone", "mei")
        self.assertEqual(out, "5")
        self.assertEqual(code, 0)

    def test_count_tone_failed(self):
        out, code = self.run_cmd("countTone", "invalid_spk")
        self.assertEqual(code, 1)

if __name__ == "__main__":
    unittest.main()

