#!/usr/bin/env python3
"""
Simulate exactly what the bash script generates
"""

import os
import sys
from pathlib import Path

# Add scripts directory to path
scripts_dir = '/root/zoo/tools_tts_sandbox/scripts'
sys.path.insert(0, scripts_dir)

from gemini_tts import GeminiTTS

# Initialize TTS (exactly like bash script)
api_key = os.getenv('GEMINI_API_KEY')
if not api_key:
    raise ValueError("GEMINI_API_KEY not found in environment")

tts = GeminiTTS(
    api_key=api_key,
    model='gemini-2.5-pro-preview-tts'
)

# Configuration (exactly like bash script)
text = '''Привет как дела'''
output_file = './outputs/tts_gemini_single_20251024_143118.wav'
num_speakers = 1

print("🔍 Simulating bash script Python code...")

try:
    if num_speakers == 1:
        print("Generating single speaker audio...")
        tts.generate_speech(
            text=text,
            voice_name='Zephyr',
            output_file=output_file,
            temperature=0.9
        )
    else:
        print("Multi-speaker not tested here")

    print(f"✓ Audio generated successfully: {output_file}")

except Exception as e:
    print(f"✗ Error: {str(e)}")
    import traceback
    traceback.print_exc()