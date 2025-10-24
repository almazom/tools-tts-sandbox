#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test to confirm Russian text encoding issue in bash script
"""

import subprocess
import sys

# Test 1: Direct Python call (should work)
print("🔍 Test 1: Direct Python call with Russian text")
direct_test = '''
import sys
sys.path.insert(0, "/root/zoo/tools_tts_sandbox/scripts")
from gemini_tts import GeminiTTS

tts = GeminiTTS(api_key="your_api_key_here")
result = tts.generate_speech(
    text="Привет как дела",
    voice_name="Zephyr",
    output_file="/tmp/direct_russian_test.wav",
    temperature=0.9
)
print(f"✅ Direct call success: {result}")
'''

result = subprocess.run([sys.executable, "-c", direct_test],
                       capture_output=True, text=True, encoding='utf-8')
print(f"Exit code: {result.returncode}")
print(f"Stdout: {result.stdout}")
if result.stderr:
    print(f"Stderr: {result.stderr}")

print("\n" + "="*50 + "\n")

# Test 2: Simulate bash script approach (might fail)
print("🔍 Test 2: Simulating bash script variable substitution")
bash_simulation = '''
import sys
sys.path.insert(0, "/root/zoo/tools_tts_sandbox/scripts")
from gemini_tts import GeminiTTS

tts = GeminiTTS(api_key="your_api_key_here")

# This simulates how bash script embeds the text
text = '''Привет как дела'''
print(f"Text embedded as: {repr(text)}")
print(f"Text length: {len(text)}")
print(f"Text type: {type(text)}")

result = tts.generate_speech(
    text=text,
    voice_name="Zephyr",
    output_file="/tmp/bash_simulation_russian_test.wav",
    temperature=0.9
)
print(f"✅ Bash simulation success: {result}")
'''

result = subprocess.run([sys.executable, "-c", bash_simulation],
                       capture_output=True, text=True, encoding='utf-8')
print(f"Exit code: {result.returncode}")
print(f"Stdout: {result.stdout}")
if result.stderr:
    print(f"Stderr: {result.stderr}")