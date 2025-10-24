#!/usr/bin/env python3
"""
Minimal test case for Gemini TTS debugging
Following the Automated Reproduction Case (ARC) Protocol
"""

import os
import sys
from pathlib import Path

# Add scripts directory to path
scripts_dir = '/root/zoo/tools_tts_sandbox/scripts'
sys.path.insert(0, scripts_dir)

print("🔍 Debugging: Starting minimal Gemini TTS test")
print(f"🔍 Debugging: scripts_dir = {scripts_dir}")
print(f"🔍 Debugging: Python path includes scripts directory")

try:
    print("🔍 Debugging: Attempting to import gemini_tts...")
    from gemini_tts import GeminiTTS
    print("✅ Debugging: Successfully imported gemini_tts")
except ImportError as e:
    print(f"❌ Debugging: Failed to import gemini_tts: {e}")
    sys.exit(1)

try:
    print("🔍 Debugging: Checking environment variables...")
    api_key = os.getenv('GEMINI_API_KEY')
    print(f"🔍 Debugging: GEMINI_API_KEY exists: {bool(api_key)}")
    if not api_key:
        print("❌ Debugging: GEMINI_API_KEY not found in environment")
        sys.exit(1)

    print("🔍 Debugging: Initializing GeminiTTS client...")
    tts = GeminiTTS(
        api_key=api_key,
        model='gemini-2.5-pro-preview-tts'
    )
    print("✅ Debugging: Successfully initialized GeminiTTS client")
except Exception as e:
    print(f"❌ Debugging: Failed to initialize GeminiTTS: {e}")
    sys.exit(1)

# Minimal test case
test_text = "Привет мир"
output_file = "/tmp/debug_test.wav"

print(f"🔍 Debugging: Attempting to generate speech...")
print(f"🔍 Debugging: Text: '{test_text}'")
print(f"🔍 Debugging: Output file: {output_file}")
print(f"🔍 Debugging: Voice: Zephyr")
print(f"🔍 Debugging: Temperature: 0.9")

try:
    # This is where it gets stuck - add timeout monitoring
    import signal

    def timeout_handler(signum, frame):
        print("❌ Debugging: Operation timed out after 30 seconds!")
        raise TimeoutError("TTS generation timed out")

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(30)  # 30 second timeout

    print("🔍 Debugging: Calling tts.generate_speech()...")
    result = tts.generate_speech(
        text=test_text,
        voice_name='Zephyr',
        output_file=output_file,
        temperature=0.9
    )

    signal.alarm(0)  # Cancel timeout

    print(f"✅ Debugging: Successfully generated speech: {result}")

    # Check if file exists and has content
    if os.path.exists(output_file):
        file_size = os.path.getsize(output_file)
        print(f"✅ Debugging: Output file exists, size: {file_size} bytes")
        if file_size > 0:
            print("✅ Debugging: File has content - test PASSED!")
        else:
            print("❌ Debugging: File is empty - test FAILED!")
    else:
        print("❌ Debugging: Output file was not created - test FAILED!")

except TimeoutError as e:
    print(f"❌ Debugging: {e}")
    print("🔍 Debugging: This indicates the API call is hanging without progress")
    sys.exit(1)
except Exception as e:
    print(f"❌ Debugging: TTS generation failed: {e}")
    import traceback
    print("🔍 Debugging: Full traceback:")
    traceback.print_exc()
    sys.exit(1)

print("🎯 Debugging: Minimal test completed successfully!")