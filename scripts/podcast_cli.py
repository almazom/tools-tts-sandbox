#!/usr/bin/env python3
"""
Command-line interface for podcast generation using Gemini TTS
"""

import argparse
import os
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent))

from gemini_tts import GeminiTTS


def main():
    parser = argparse.ArgumentParser(description="Generate podcasts using Gemini TTS")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Single speaker command
    single_parser = subparsers.add_parser("single", help="Generate single speaker audio")
    single_parser.add_argument("text", help="Text to convert to speech")
    single_parser.add_argument("-v", "--voice", default="Zephyr", 
                              choices=GeminiTTS.AVAILABLE_VOICES,
                              help="Voice to use (default: Zephyr)")
    single_parser.add_argument("-o", "--output", help="Output file name (without extension)")
    single_parser.add_argument("-t", "--temperature", type=float, default=0.8,
                              help="Temperature for generation (default: 0.8)")
    
    # Multi-speaker command
    multi_parser = subparsers.add_parser("multi", help="Generate multi-speaker audio")
    multi_parser.add_argument("script", help="Script with speaker labels (e.g., 'Speaker 1: Hello')")
    multi_parser.add_argument("-s", "--speakers", nargs="+", required=True,
                             help="Speaker configurations (format: SpeakerName:VoiceName)")
    multi_parser.add_argument("-o", "--output", help="Output file name (without extension)")
    multi_parser.add_argument("-t", "--temperature", type=float, default=1.0,
                             help="Temperature for generation (default: 1.0)")
    
    # Script generation command
    script_parser = subparsers.add_parser("script", help="Generate podcast script")
    script_parser.add_argument("topic", help="Topic for the podcast")
    script_parser.add_argument("-s", "--style", default="interview",
                              choices=["interview", "discussion", "narrative"],
                              help="Style of podcast (default: interview)")
    script_parser.add_argument("-d", "--duration", default="5 minutes",
                              help="Approximate duration (default: 5 minutes)")
    
    # List voices command
    voices_parser = subparsers.add_parser("voices", help="List available voices")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return 1
    
    try:
        tts = GeminiTTS()
        
        if args.command == "voices":
            print("🎤 Available voices:")
            for voice in GeminiTTS.AVAILABLE_VOICES:
                print(f"  • {voice}")
            return 0
        
        if args.command == "single":
            print(f"🎤 Generating single speaker audio with voice '{args.voice}'...")
            output_file = tts.generate_speech(
                text=args.text,
                voice_name=args.voice,
                temperature=args.temperature,
                output_file=args.output
            )
            print(f"✅ Audio saved to: {output_file}")
        
        elif args.command == "multi":
            print(f"🎙️ Generating multi-speaker podcast...")
            
            # Parse speaker configurations
            speaker_configs = []
            for speaker_config in args.speakers:
                if ":" not in speaker_config:
                    print(f"❌ Error: Invalid speaker config '{speaker_config}'. Use format: SpeakerName:VoiceName")
                    return 1
                
                speaker, voice = speaker_config.split(":", 1)
                speaker_configs.append({
                    "speaker": speaker.strip(),
                    "voice": voice.strip()
                })
            
            output_file = tts.generate_podcast_interview(
                script=args.script,
                speaker_configs=speaker_configs,
                temperature=args.temperature,
                output_file=args.output
            )
            print(f"✅ Podcast saved to: {output_file}")
        
        elif args.command == "script":
            print(f"📝 Generating {args.style} style script about '{args.topic}'...")
            script = tts.generate_podcast_script(
                topic=args.topic,
                style=args.style,
                duration=args.duration
            )
            print("\n🎙️ Generated Script:")
            print("=" * 50)
            print(script)
            print("=" * 50)
            
            # Optionally save the script
            save_file = input("\nSave script to file? (y/N): ").lower().strip()
            if save_file == 'y':
                filename = input("Enter filename (without .txt): ").strip()
                if not filename.endswith('.txt'):
                    filename += '.txt'
                
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(script)
                print(f"✅ Script saved to: {filename}")
        
        return 0
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())