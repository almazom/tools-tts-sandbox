#!/usr/bin/env python3
"""
Improved Gemini TTS Generation Script
Includes retry logic, better error handling, and API testing
"""

import os
import sys
import base64
import time
import random
import json
from pathlib import Path

# Add scripts directory to path
scripts_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, scripts_dir)

try:
    from gemini_tts import GeminiTTS
    import google.generativeai as genai
except ImportError as e:
    print(f"Import error: {e}")
    print("Please ensure google-generativeai is installed: pip install google-generativeai")
    sys.exit(1)

def test_api_connectivity(api_key, model):
    """Test if Gemini API is accessible and has TTS models"""
    try:
        genai.configure(api_key=api_key)
        models = genai.list_models()
        tts_models = [m for m in models if 'tts' in m.name.lower()]

        if not tts_models:
            print(f"No TTS models found. Available models: {[m.name for m in models[:5]]}")
            return False

        print(f"API connectivity test passed. Found {len(tts_models)} TTS models")
        return True
    except Exception as e:
        print(f"API connectivity test failed: {e}")
        return False

def generate_tts_with_retry(api_key, model, text, voice_name, temperature, pace, max_retries=3):
    """Generate TTS with retry logic and exponential backoff"""

    # Initialize TTS
    try:
        tts = GeminiTTS(api_key=api_key, model=model)
    except Exception as e:
        print(f"Failed to initialize TTS: {e}")
        return None

    print(f"Generating TTS for text length: {len(text)} characters")

    for attempt in range(max_retries):
        try:
            if attempt > 0:
                # Add jitter and exponential backoff
                delay = (2 ** attempt) + random.uniform(0, 1)
                print(f"Retry attempt {attempt + 1}/{max_retries} after {delay:.1f}s delay...")
                time.sleep(delay)

            # Generate content
            filename = tts.generate_content(
                text=text,
                voice_name=voice_name,
                temperature=temperature,
                pace=pace
            )

            if filename and Path(filename).exists():
                print(f"Successfully generated: {filename}")
                return filename
            else:
                raise Exception(f"Generation returned invalid filename: {filename}")

        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt == max_retries - 1:
                print("All retry attempts failed")
                return None

    return None

def main():
    """Main function to handle command line arguments and generate TTS"""

    # Parse arguments
    if len(sys.argv) != 7:
        print("Usage: python3 gemini_tts_improved.py <api_key> <model> <encoded_text> <voice_name> <temperature> <pace>")
        sys.exit(1)

    api_key = sys.argv[1]
    model = sys.argv[2]
    encoded_text = sys.argv[3]
    voice_name = sys.argv[4]
    temperature = float(sys.argv[5])
    pace = sys.argv[6]

    # Decode text
    try:
        text = base64.b64decode(encoded_text).decode('utf-8')
    except Exception as e:
        print(f"Failed to decode text: {e}")
        sys.exit(1)

    # Test API connectivity first
    if not test_api_connectivity(api_key, model):
        print("API connectivity test failed")
        sys.exit(1)

    # Generate TTS
    filename = generate_tts_with_retry(
        api_key=api_key,
        model=model,
        text=text,
        voice_name=voice_name,
        temperature=temperature,
        pace=pace
    )

    if filename:
        print(f"SUCCESS: {filename}")
        sys.exit(0)
    else:
        print("FAILURE: TTS generation failed")
        sys.exit(1)

if __name__ == "__main__":
    main()