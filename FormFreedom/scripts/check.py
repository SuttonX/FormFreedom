#!/usr/bin/env python3
"""Run existing mock regression checks from any working directory."""
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
engine = shutil.which('luatex')
args = [engine, '--luaonly'] if engine else None
if not args:
    for candidate in ('lua5.4', 'lua5.3', 'lua'):
        engine = shutil.which(candidate)
        if engine:
            args = [engine]
            break
if not args:
    sys.exit('Install Lua 5.3+ or luatex to run the mock tests.')
for test in sorted((root / 'tests').glob('verify-formfreedom-*.lua')):
    subprocess.run(args + [str(test)], cwd=root, check=True)
print('All mock checks passed. In-game tests remain necessary for code changes.')
