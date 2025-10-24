#!/usr/bin/env python3
"""
Test script for Gemini TTS functionality
Based on the provided example code
"""

import base64
import mimetypes
import os
import re
import struct
import sys
from pathlib import Path

# Add project root to path for imports
sys.path.append(str(Path(__file__).parent.parent))

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Installing required dependencies...")
    os.system("pip install google-genai")
    from google import genai
    from google.genai import types


def save_binary_file(file_name, data):
    """Save binary audio data to file"""
    with open(file_name, "wb") as f:
        f.write(data)
    print(f"✓ Audio file saved: {file_name}")


def parse_audio_mime_type(mime_type: str) -> dict[str, int | None]:
    """Parse bits per sample and rate from audio MIME type"""
    bits_per_sample = 16
    rate = 24000

    parts = mime_type.split(";")
    for param in parts:
        param = param.strip()
        if param.lower().startswith("rate="):
            try:
                rate_str = param.split("=", 1)[1]
                rate = int(rate_str)
            except (ValueError, IndexError):
                pass
        elif param.startswith("audio/L"):
            try:
                bits_per_sample = int(param.split("L", 1)[1])
            except (ValueError, IndexError):
                pass

    return {"bits_per_sample": bits_per_sample, "rate": rate}


def convert_to_wav(audio_data: bytes, mime_type: str) -> bytes:
    """Convert audio data to WAV format with proper header"""
    parameters = parse_audio_mime_type(mime_type)
    bits_per_sample = parameters["bits_per_sample"]
    sample_rate = parameters["rate"]
    num_channels = 1
    data_size = len(audio_data)
    bytes_per_sample = bits_per_sample // 8
    block_align = num_channels * bytes_per_sample
    byte_rate = sample_rate * block_align
    chunk_size = 36 + data_size

    # Create WAV header
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF",          # ChunkID
        chunk_size,       # ChunkSize
        b"WAVE",          # Format
        b"fmt ",          # Subchunk1ID
        16,               # Subchunk1Size
        1,                # AudioFormat (PCM)
        num_channels,     # NumChannels
        sample_rate,      # SampleRate
        byte_rate,        # ByteRate
        block_align,      # BlockAlign
        bits_per_sample,  # BitsPerSample
        b"data",          # Subchunk2ID
        data_size         # Subchunk2Size
    )
    return header + audio_data


def test_single_speaker_tts():
    """Test single speaker TTS generation"""
    print("🎤 Testing Single Speaker TTS...")
    
    client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
    
    model = "gemini-2.5-pro-preview-tts"
    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="Welcome to our podcast! Today we'll explore the fascinating world of artificial intelligence and its impact on everyday life."),
            ],
        ),
    ]
    
    generate_content_config = types.GenerateContentConfig(
        temperature=0.8,
        response_modalities=["audio"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Zephyr")
            )
        ),
    )

    file_index = 0
    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=generate_content_config,
    ):
        if (chunk.candidates and 
            chunk.candidates[0].content and 
            chunk.candidates[0].content.parts and
            chunk.candidates[0].content.parts[0].inline_data and
            chunk.candidates[0].content.parts[0].inline_data.data):
            
            file_name = f"single_speaker_{file_index}"
            file_index += 1
            inline_data = chunk.candidates[0].content.parts[0].inline_data
            data_buffer = inline_data.data
            file_extension = mimetypes.guess_extension(inline_data.mime_type)
            
            if file_extension is None:
                file_extension = ".wav"
                data_buffer = convert_to_wav(inline_data.data, inline_data.mime_type)
            
            save_binary_file(f"{file_name}{file_extension}", data_buffer)


def test_multi_speaker_tts():
    """Test multi-speaker TTS generation (podcast interview style)"""
    print("🎙️ Testing Multi-Speaker TTS (Podcast Interview)...")
    
    client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
    
    model = "gemini-2.5-pro-preview-tts"
    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Please read aloud the following in a podcast interview style:
Speaker 1: We're seeing a noticeable shift in consumer preferences across several sectors. What seems to be driving this change?
Speaker 2: It appears to be a combination of factors, including greater awareness of sustainability issues and a growing demand for personalized experiences."""),
            ],
        ),
    ]
    
    generate_content_config = types.GenerateContentConfig(
        temperature=1,
        response_modalities=["audio"],
        speech_config=types.SpeechConfig(
            multi_speaker_voice_config=types.MultiSpeakerVoiceConfig(
                speaker_voice_configs=[
                    types.SpeakerVoiceConfig(
                        speaker="Speaker 1",
                        voice_config=types.VoiceConfig(
                            prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Zephyr")
                        ),
                    ),
                    types.SpeakerVoiceConfig(
                        speaker="Speaker 2",
                        voice_config=types.VoiceConfig(
                            prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Puck")
                        ),
                    ),
                ]
            ),
        ),
    )

    file_index = 0
    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=generate_content_config,
    ):
        if (chunk.candidates and 
            chunk.candidates[0].content and 
            chunk.candidates[0].content.parts and
            chunk.candidates[0].content.parts[0].inline_data and
            chunk.candidates[0].content.parts[0].inline_data.data):
            
            file_name = f"multi_speaker_{file_index}"
            file_index += 1
            inline_data = chunk.candidates[0].content.parts[0].inline_data
            data_buffer = inline_data.data
            file_extension = mimetypes.guess_extension(inline_data.mime_type)
            
            if file_extension is None:
                file_extension = ".wav"
                data_buffer = convert_to_wav(inline_data.data, inline_data.mime_type)
            
            save_binary_file(f"{file_name}{file_extension}", data_buffer)


if __name__ == "__main__":
    print("🚀 Testing Gemini TTS Functionality")
    print("=" * 40)
    
    # Check if API key is available
    if not os.environ.get("GEMINI_API_KEY"):
        print("❌ Error: GEMINI_API_KEY not found in environment variables")
        sys.exit(1)
    
    try:
        # Test single speaker
        test_single_speaker_tts()
        print()
        
        # Test multi-speaker
        test_multi_speaker_tts()
        
        print("\n✅ All tests completed successfully!")
        
    except Exception as e:
        print(f"❌ Error during testing: {e}")
        sys.exit(1)