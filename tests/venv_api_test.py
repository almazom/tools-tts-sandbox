#!/usr/bin/env python3
"""
Test the actual API call with timeout to detect hanging point
"""

import sys
import os
import signal
import time

# Add parent directory to Python path
sys.path.insert(0, '/root/zoo/tools_tts_sandbox/scripts')

def timeout_handler(signum, frame):
    print(f"❌ TIMEOUT: Operation took longer than 30 seconds!")
    raise TimeoutError("API call timed out")

print("🔍 Testing actual Gemini TTS API call...")

try:
    from gemini_tts import GeminiTTS
    print("✅ Module imported")

    api_key = "your_api_key_here"
    tts = GeminiTTS(api_key=api_key)
    print("✅ Client initialized")

    test_text = "Привет мир"
    output_file = "/tmp/test_api_output.wav"

    print(f"🔍 Starting TTS generation...")
    print(f"   Text: '{test_text}'")
    print(f"   Output: {output_file}")
    print(f"   Voice: Zephyr")
    print(f"   Temperature: 0.9")

    # Set timeout
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(30)

    start_time = time.time()

    result = tts.generate_speech(
        text=test_text,
        voice_name='Zephyr',
        output_file=output_file,
        temperature=0.9
    )

    end_time = time.time()
    signal.alarm(0)  # Cancel timeout

    print(f"✅ SUCCESS! Generated in {end_time - start_time:.2f} seconds")
    print(f"✅ Result: {result}")

    # Check file
    if os.path.exists(output_file):
        size = os.path.getsize(output_file)
        print(f"✅ File created: {size} bytes")
        if size > 1000:  # Should be at least 1KB for audio
            print("🎉 TEST PASSED! Audio file generated successfully")
        else:
            print("⚠️  File seems too small")
    else:
        print("❌ File not created")

except TimeoutError as e:
    print(f"❌ {e}")
    print("🔍 The API call is hanging - this is the root cause!")
    print("🔍 Possible issues:")
    print("   - Network connectivity problems")
    print("   - API key issues")
    print("   - Rate limiting")
    print("   - Server-side problems")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()