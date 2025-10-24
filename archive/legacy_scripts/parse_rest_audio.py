#!/usr/bin/env python3
"""
Parse REST API responses and extract audio data from Gemini TTS
"""

import json
import base64
import re
import sys
from pathlib import Path
from typing import List, Dict, Any, Optional


def extract_audio_data_from_response(response_data: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Extract audio data from Gemini REST API response"""
    audio_chunks = []
    
    try:
        # Navigate through the response structure
        if 'candidates' in response_data:
            for candidate in response_data['candidates']:
                if 'content' in candidate and 'parts' in candidate['content']:
                    for part in candidate['content']['parts']:
                        # Look for inline data (audio)
                        if 'inlineData' in part:
                            inline_data = part['inlineData']
                            if 'data' in inline_data and 'mimeType' in inline_data:
                                audio_chunks.append({
                                    'data': inline_data['data'],
                                    'mime_type': inline_data['mimeType'],
                                    'type': 'base64'
                                })
                        # Look for text responses
                        elif 'text' in part:
                            print(f"Text response: {part['text'][:100]}...")
    except Exception as e:
        print(f"Error extracting audio data: {e}")
    
    return audio_chunks


def extract_audio_from_streaming_response(response_text: str) -> List[Dict[str, Any]]:
    """Extract audio data from streaming response (multiple JSON objects)"""
    audio_chunks = []
    
    # Split response by lines and try to parse each as JSON
    lines = response_text.strip().split('\n')
    
    for line in lines:
        if line.strip():
            try:
                # Try to parse each line as JSON
                data = json.loads(line)
                chunks = extract_audio_data_from_response(data)
                audio_chunks.extend(chunks)
            except json.JSONDecodeError:
                # Skip non-JSON lines
                continue
    
    return audio_chunks


def save_audio_data(audio_data_b64: str, mime_type: str, output_file: str) -> str:
    """Save base64 encoded audio data to file"""
    try:
        # Decode base64 data
        audio_bytes = base64.b64decode(audio_data_b64)
        
        # Determine file extension from mime type
        ext_map = {
            'audio/wav': '.wav',
            'audio/mp3': '.mp3',
            'audio/mpeg': '.mp3',
            'audio/ogg': '.ogg',
            'audio/webm': '.webm',
            'audio/mp4': '.mp4',
            'audio/L16': '.pcm'
        }
        
        file_extension = ext_map.get(mime_type, '.bin')
        if not output_file.endswith(file_extension):
            output_file += file_extension
        
        # Save to file
        with open(output_file, 'wb') as f:
            f.write(audio_bytes)
        
        file_size = len(audio_bytes)
        print(f"✓ Saved audio file: {output_file} ({file_size} bytes)")
        return output_file
        
    except Exception as e:
        print(f"❌ Error saving audio data: {e}")
        return None


def analyze_response_file(file_path: str) -> Dict[str, Any]:
    """Analyze a REST API response file"""
    print(f"\n📊 Analyzing: {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        file_info = {
            'file_size': len(content),
            'is_json': False,
            'is_streaming': False,
            'audio_chunks': [],
            'text_responses': []
        }
        
        # Check if it's streaming response (multiple JSON objects)
        if content.strip().startswith('{') and '\n{' in content:
            file_info['is_streaming'] = True
            print("  - Detected streaming response format")
            audio_chunks = extract_audio_from_streaming_response(content)
        else:
            # Try to parse as single JSON
            try:
                data = json.loads(content)
                file_info['is_json'] = True
                print("  - Valid JSON format detected")
                audio_chunks = extract_audio_data_from_response(data)
            except json.JSONDecodeError:
                print("  - Not valid JSON format")
                audio_chunks = []
        
        file_info['audio_chunks'] = audio_chunks
        print(f"  - Found {len(audio_chunks)} audio chunks")
        
        # Look for text responses
        if 'text' in content.lower():
            # Extract text responses using regex
            text_matches = re.findall(r'"text":\s*"([^"]*)"', content)
            file_info['text_responses'] = text_matches
            if text_matches:
                print(f"  - Found {len(text_matches)} text responses")
        
        return file_info
        
    except Exception as e:
        print(f"❌ Error analyzing file: {e}")
        return None


def process_all_response_files(output_dir: str = ".tmp/outputs"):
    """Process all JSON response files in the output directory"""
    output_path = Path(output_dir)
    if not output_path.exists():
        print(f"❌ Output directory not found: {output_dir}")
        return
    
    # Find all JSON files
    json_files = list(output_path.glob("*.json"))
    response_files = [f for f in json_files if "response" in f.name or "test" in f.name]
    
    if not response_files:
        print(f"❌ No response files found in {output_dir}")
        return
    
    print(f"📁 Found {len(response_files)} response files to process")
    
    all_audio_files = []
    
    for response_file in response_files:
        print(f"\n{'='*60}")
        file_info = analyze_response_file(str(response_file))
        
        if file_info and file_info['audio_chunks']:
            print(f"\n🎵 Extracting audio from {response_file.name}...")
            
            for i, chunk in enumerate(file_info['audio_chunks']):
                output_name = f"{response_file.stem}_audio_{i+1}"
                output_file = str(response_path := output_path / output_name)
                
                saved_file = save_audio_data(
                    chunk['data'], 
                    chunk['mime_type'], 
                    output_file
                )
                
                if saved_file:
                    all_audio_files.append(saved_file)
    
    print(f"\n{'='*60}")
    print(f"✅ Processing complete!")
    print(f"📁 Total audio files extracted: {len(all_audio_files)}")
    
    if all_audio_files:
        print("\nExtracted audio files:")
        for audio_file in all_audio_files:
            print(f"  - {audio_file}")


def main():
    """Main function to parse REST API responses"""
    print("🔊 Gemini REST API Audio Parser")
    print("=================================")
    
    if len(sys.argv) > 1:
        # Process specific file
        file_path = sys.argv[1]
        if not Path(file_path).exists():
            print(f"❌ File not found: {file_path}")
            return 1
        
        file_info = analyze_response_file(file_path)
        
        if file_info and file_info['audio_chunks']:
            print(f"\n🎵 Extracting audio data...")
            for i, chunk in enumerate(file_info['audio_chunks']):
                output_name = f"extracted_audio_{i+1}"
                save_audio_data(chunk['data'], chunk['mime_type'], output_name)
    else:
        # Process all files in output directory
        process_all_response_files()
    
    return 0


if __name__ == "__main__":
    exit(main())