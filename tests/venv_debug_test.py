#!/usr/bin/env python3
"""
Simple test inside venv directory to test gemini_tts module
"""

import sys
import os

# Add parent directory to Python path
sys.path.insert(0, '/root/zoo/tools_tts_sandbox/scripts')

print("🔍 Testing gemini_tts module import...")
try:
    from gemini_tts import GeminiTTS
    print("✅ Successfully imported GeminiTTS")

    # Test basic functionality
    api_key = "your_api_key_here"
    tts = GeminiTTS(api_key=api_key)
    print("✅ Successfully initialized GeminiTTS")

    # Check available voices
    print(f"🔍 Available voices: {tts.AVAILABLE_VOICES}")

    print("🎯 Basic module test completed successfully!")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()