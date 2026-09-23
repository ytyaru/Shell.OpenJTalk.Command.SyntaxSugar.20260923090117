#!/usr/bin/env python3
import unittest
import subprocess
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_PY = os.path.join(SCRIPT_DIR, "list.py") # 💡 ojt_ を排除

class TestOjtList(unittest.TestCase):
    def run_cmd(self, sub, arg=""):
        args = [sys.executable, TARGET_PY, sub]
        if arg: args.append(arg)
        res = subprocess.run(args, capture_output=True, text=True)
        return res.stdout.strip(), res.returncode

    def test_has_success(self):
        out, code = self.run_cmd("has", "mei_normal")
        self.assertEqual(out, "")
        self.assertEqual(code, 0)

    def test_has_failed(self):
        out, code = self.run_cmd("has", "invalid_model_name")
        self.assertEqual(out, "")
        self.assertEqual(code, 1)

    def test_has_echo_success(self):
        out, code = self.run_cmd("hasEcho", "mei_normal")
        self.assertEqual(out, "Yes")
        self.assertEqual(code, 0)

    def test_has_echo_failed(self):
        out, code = self.run_cmd("hasEcho", "invalid_model_name")
        self.assertEqual(out, "No")
        self.assertEqual(code, 1)

    def test_any_success(self):
        out, code = self.run_cmd("any", "mei_")
        self.assertEqual(out, "")
        self.assertEqual(code, 0)

    def test_any_failed(self):
        out, code = self.run_cmd("any", "invalid_prefix_")
        self.assertEqual(out, "")
        self.assertEqual(code, 1)

    def test_any_echo_success(self):
        out, code = self.run_cmd("anyEcho", "mei_")
        self.assertEqual(out, "Yes")
        self.assertEqual(code, 0)

    def test_any_echo_failed(self):
        out, code = self.run_cmd("anyEcho", "invalid_prefix_")
        self.assertEqual(out, "No")
        self.assertEqual(code, 1)

if __name__ == "__main__":
    unittest.main()
