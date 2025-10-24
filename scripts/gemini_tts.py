#!/usr/bin/env python3
"""
Gemini TTS API wrapper for podcast generation
Based on the working example with multi-speaker support
"""

import base64
import mimetypes
import os
import struct
from typing import Optional, List, Dict, Any, Union
from pathlib import Path

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Installing required dependencies...")
    os.system("pip install google-genai")
    from google import genai
    from google.genai import types


class GeminiTTS:
    """Gemini TTS API wrapper for podcast generation"""
    
    # Available voice names
    AVAILABLE_VOICES = ["Zephyr", "Puck", "Charon", "Kore", "Uranus", "Fenrir"]
    
    def __init__(self, api_key: Optional[str] = None, model: Optional[str] = None):
        """Initialize Gemini TTS client"""
        self.api_key = api_key or os.getenv('GEMINI_API_KEY')
        if not self.api_key:
            raise ValueError("Gemini API key not found in environment variables")
        
        self.model = model or os.getenv('GEMINI_TTS_MODEL', 'gemini-2.5-pro-preview-tts')
        self.client = genai.Client(api_key=self.api_key)
    
    def save_audio_file(self, file_path: str, audio_data: bytes, mime_type: str) -> str:
        """Save audio data to file, converting to WAV if needed"""
        file_extension = mimetypes.guess_extension(mime_type)
        
        if file_extension is None:
            file_extension = ".wav"
            audio_data = self._convert_to_wav(audio_data, mime_type)
        
        if not file_path.endswith(file_extension):
            file_path += file_extension
        
        with open(file_path, "wb") as f:
            f.write(audio_data)
        
        return file_path
    
    def _convert_to_wav(self, audio_data: bytes, mime_type: str) -> bytes:
        """Convert audio data to WAV format with proper header"""
        parameters = self._parse_audio_mime_type(mime_type)
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
    
    def _parse_audio_mime_type(self, mime_type: str) -> Dict[str, int]:
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
    
    def generate_speech(self, 
                       text: str, 
                       voice_name: str = "Zephyr",
                       temperature: float = 0.8,
                       output_file: Optional[str] = None) -> str:
        """Generate speech from text using single voice"""
        
        if voice_name not in self.AVAILABLE_VOICES:
            raise ValueError(f"Voice '{voice_name}' not available. Choose from: {self.AVAILABLE_VOICES}")
        
        contents = [
            types.Content(
                role="user",
                parts=[types.Part.from_text(text=text)],
            ),
        ]
        
        generate_content_config = types.GenerateContentConfig(
            temperature=temperature,
            response_modalities=["audio"],
            speech_config=types.SpeechConfig(
                voice_config=types.VoiceConfig(
                    prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name=voice_name)
                )
            ),
        )

        audio_chunks = []
        for chunk in self.client.models.generate_content_stream(
            model=self.model,
            contents=contents,
            config=generate_content_config,
        ):
            if (chunk.candidates and 
                chunk.candidates[0].content and 
                chunk.candidates[0].content.parts and
                chunk.candidates[0].content.parts[0].inline_data and
                chunk.candidates[0].content.parts[0].inline_data.data):
                
                inline_data = chunk.candidates[0].content.parts[0].inline_data
                audio_chunks.append(inline_data.data)
        
        if not audio_chunks:
            raise RuntimeError("No audio data generated")
        
        # Combine all audio chunks
        combined_audio = b''.join(audio_chunks)
        
        # Save to file
        if output_file is None:
            output_file = f"output_single_{voice_name.lower()}"
        
        saved_file = self.save_audio_file(output_file, combined_audio, "audio/wav")
        print(f"✓ Generated speech saved to: {saved_file}")
        
        return saved_file
    
    def generate_podcast_interview(self,
                                  script: str,
                                  speaker_configs: List[Dict[str, str]],
                                  temperature: float = 1.0,
                                  output_file: Optional[str] = None) -> str:
        """Generate multi-speaker podcast interview"""
        
        # Validate speaker configurations
        speaker_voice_configs = []
        for config in speaker_configs:
            speaker = config.get('speaker')
            voice_name = config.get('voice', 'Zephyr')
            
            if speaker is None:
                raise ValueError("Each speaker config must have a 'speaker' field")
            
            if voice_name not in self.AVAILABLE_VOICES:
                raise ValueError(f"Voice '{voice_name}' not available. Choose from: {self.AVAILABLE_VOICES}")
            
            speaker_voice_configs.append(
                types.SpeakerVoiceConfig(
                    speaker=speaker,
                    voice_config=types.VoiceConfig(
                        prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name=voice_name)
                    ),
                )
            )
        
        contents = [
            types.Content(
                role="user",
                parts=[types.Part.from_text(text=script)],
            ),
        ]
        
        generate_content_config = types.GenerateContentConfig(
            temperature=temperature,
            response_modalities=["audio"],
            speech_config=types.SpeechConfig(
                multi_speaker_voice_config=types.MultiSpeakerVoiceConfig(
                    speaker_voice_configs=speaker_voice_configs
                )
            ),
        )

        audio_chunks = []
        for chunk in self.client.models.generate_content_stream(
            model=self.model,
            contents=contents,
            config=generate_content_config,
        ):
            if (chunk.candidates and 
                chunk.candidates[0].content and 
                chunk.candidates[0].content.parts and
                chunk.candidates[0].content.parts[0].inline_data and
                chunk.candidates[0].content.parts[0].inline_data.data):
                
                inline_data = chunk.candidates[0].content.parts[0].inline_data
                audio_chunks.append(inline_data.data)
        
        if not audio_chunks:
            raise RuntimeError("No audio data generated")
        
        # Combine all audio chunks
        combined_audio = b''.join(audio_chunks)
        
        # Save to file
        if output_file is None:
            output_file = "output_podcast_interview"
        
        saved_file = self.save_audio_file(output_file, combined_audio, "audio/wav")
        print(f"✓ Generated podcast interview saved to: {saved_file}")
        
        return saved_file
    
    def generate_podcast_script(self, topic: str, style: str = "interview", duration: str = "5 minutes") -> str:
        """Generate a podcast script using Gemini's text generation"""
        
        prompt = f"""Create a {duration} {style} style podcast script about "{topic}".
        
For interview style, include:
- Host introduction
- Guest introduction  
- Natural conversation flow with questions and answers
- Speaker labels (Host:, Guest:)

Make it engaging and informative with natural transitions."""

        contents = [
            types.Content(
                role="user",
                parts=[types.Part.from_text(text=prompt)],
            ),
        ]
        
        response = self.client.models.generate_content(
            model="gemini-2.5-pro-preview-tts",
            contents=contents,
            config=types.GenerateContentConfig(temperature=0.8)
        )
        
        return response.text


def main():
    """Test the Gemini TTS functionality"""
    print("🎙️ Testing Gemini TTS Podcast Generator")
    print("=" * 40)
    
    try:
        tts = GeminiTTS()
        print("✓ Gemini TTS client initialized")
        
        # Test single speaker
        print("\n🎤 Testing single speaker...")
        tts.generate_speech(
            "Welcome to our podcast! Today we'll explore the fascinating world of artificial intelligence.",
            voice_name="Zephyr",
            output_file=".tmp/test_single"
        )
        
        # Test multi-speaker interview
        print("\n🎙️ Testing multi-speaker interview...")
        interview_script = """Please read aloud the following in a podcast interview style:
Speaker 1: Welcome to Tech Talks! Today we're discussing AI in healthcare. I'm joined by Dr. Smith.
Speaker 2: Thanks for having me! AI is revolutionizing medical diagnostics.
Speaker 1: What are the most promising applications you're seeing?
Speaker 2: Machine learning models can now detect diseases earlier than traditional methods."""
        
        speaker_configs = [
            {"speaker": "Speaker 1", "voice": "Zephyr"},
            {"speaker": "Speaker 2", "voice": "Puck"}
        ]
        
        tts.generate_podcast_interview(
            script=interview_script,
            speaker_configs=speaker_configs,
            output_file=".tmp/test_interview"
        )
        
        print("\n✅ All tests completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())