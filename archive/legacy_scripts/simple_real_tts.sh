#!/bin/bash
# Simple Real TTS Audio Generation
# Generates actual listenable audio files from Gemini TTS API

set -e

# Load environment
export $(cat ../.env | xargs)

# Configuration
OUTPUT_DIR="audio_outputs"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-tts:streamGenerateContent?key=${GEMINI_API_KEY}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🎵 REAL TTS AUDIO GENERATION STARTING..."
echo "🔐 API Key: ${GEMINI_API_KEY:0:10}..."
echo "📁 Output Directory: $OUTPUT_DIR"
echo ""

# Function to generate single speaker audio
generate_audio() {
    local text="$1"
    local voice="$2"
    local filename="$3"
    
    echo "🎤 Generating: $filename with voice $voice"
    echo "📝 Text: $text"
    
    # Create request data
    local request_data='{
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": "'"$text"'"
                    }
                ]
            }
        ],
        "generationConfig": {
            "responseModalities": ["audio"],
            "temperature": 0.8,
            "speech_config": {
                "voice_config": {
                    "prebuilt_voice_config": {
                        "voice_name": "'"$voice"'"
                    }
                }
            }
        }
    }'
    
    # Make API request and capture response
    echo "📡 Sending API request..."
    local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$request_data" \
        "$API_URL" 2>/dev/null)
    
    local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    local response_body=$(echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d')
    
    echo "📊 HTTP Status: $http_status"
    
    if [[ "$http_status" == "200" ]]; then
        echo "✅ API request successful"
        
        # Extract audio data from streaming response
        echo "🔍 Extracting audio data..."
        
        local audio_data=""
        local mime_type=""
        local chunk_count=0
        
        while IFS= read -r line; do
            if [[ -n "$line" ]] && [[ "$line" != "HTTP_STATUS:"* ]]; then
                # Extract audio data
                local data=$(echo "$line" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)
                local type=$(echo "$line" | grep -o '"mimeType":"[^"]*"' | cut -d'"' -f4)
                
                if [[ -n "$data" ]]; then
                    audio_data="${audio_data}${data}"
                    mime_type="$type"
                    ((chunk_count++))
                    echo "📦 Found chunk $chunk_count"
                fi
            fi
        done <<< "$response_body"
        
        if [[ -n "$audio_data" ]]; then
            echo "✅ Found $chunk_count audio chunks"
            echo "🔧 Converting to audio format..."
            
            # Create output file
            local output_file="$OUTPUT_DIR/${filename}.wav"
            
            # For WAV format, we need to add proper headers
            # For now, save as binary and let the player handle it
            echo "$audio_data" | base64 -d > "$output_file.tmp"
            
            # Add basic WAV header for Linear PCM
            local data_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp" 2>/dev/null || echo "0")
            
            if [[ $data_size -gt 0 ]]; then
                # Create WAV header (simplified)
                {
                    printf "RIFF"
                    printf "\x$(printf "%02x" $((36 + data_size & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 8) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 16) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 24) & 0xFF)))"
                    printf "WAVE"
                    printf "fmt "
                    printf "\x10\x00\x00\x00"  # Subchunk1Size
                    printf "\x01\x00"          # AudioFormat (PCM)
                    printf "\x01\x00"          # NumChannels (1)
                    printf "\x80\x5e\x00\x00"   # SampleRate (24000)
                    printf "\x00\x77\x01\x00"   # ByteRate (48000)
                    printf "\x02\x00"          # BlockAlign
                    printf "\x10\x00"          # BitsPerSample (16)
                    printf "data"
                    printf "\x$(printf "%02x" $((data_size & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 8) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 16) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 24) & 0xFF)))"
                    cat "$output_file.tmp"
                } > "$output_file"
                
                rm "$output_file.tmp"
                
                echo "✅ Audio file created: $output_file"
                echo "📏 File size: $(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file" 2>/dev/null) bytes"
                
                # Basic validation
                if [[ -s "$output_file" ]]; then
                    echo "🎵 SUCCESS! Audio file is ready for listening!"
                    echo "🎧 To listen: Play $output_file with your favorite audio player"
                    return 0
                else
                    echo "❌ Generated file is empty"
                    return 1
                fi
            else
                echo "❌ No audio data received"
                return 1
            fi
        else
            echo "❌ No audio data found in response"
            return 1
        fi
    else
        echo "❌ API request failed (HTTP $http_status)"
        echo "📋 Response: $response_body"
        return 1
    fi
}

# Function to test multi-speaker conversation
generate_multi_speaker() {
    local script="$1"
    local speakers="$2"
    local filename="$3"
    
    echo "🎙️ Multi-speaker: $filename"
    echo "📝 Script: $script"
    echo "👥 Speakers: $speakers"
    
    # Parse speaker configuration
    local speaker_configs=()
    IFS=' ' read -ra SPEAKER_ARRAY <<< "$speakers"
    for speaker_voice in "${SPEAKER_ARRAY[@]}"; do
        if [[ "$speaker_voice" == *":"* ]]; then
            local speaker=$(echo "$speaker_voice" | cut -d: -f1)
            local voice=$(echo "$speaker_voice" | cut -d: -f2)
            speaker_configs+=("{\"speaker\":\"$speaker\",\"voice_config\":{\"prebuilt_voice_config\":{\"voice_name\":\"$voice\"}}}")
        fi
    done
    
    if [[ ${#speaker_configs[@]} -eq 0 ]]; then
        echo "❌ No valid speaker configurations"
        return 1
    fi
    
    local speaker_configs_json="[$(IFS=','; echo "${speaker_configs[*]}")]"
    
    local request_data='{
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": "'"$script"'"
                    }
                ]
            }
        ],
        "generationConfig": {
            "responseModalities": ["audio"],
            "temperature": 0.9,
            "speech_config": {
                "multi_speaker_voice_config": {
                    "speaker_voice_configs": '"$speaker_configs_json"'
                }
            }
        }
    }'
    
    echo "📡 Sending multi-speaker request..."
    
    local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$request_data" \
        "$API_URL" 2>/dev/null)
    
    local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    
    echo "📊 HTTP Status: $http_status"
    
    if [[ "$http_status" == "200" ]]; then
        echo "✅ Multi-speaker API request successful"
        
        # Extract audio data (same as single speaker)
        local audio_data=""
        local chunk_count=0
        
        while IFS= read -r line; do
            if [[ -n "$line" ]] && [[ "$line" != "HTTP_STATUS:"* ]]; then
                local data=$(echo "$line" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)
                if [[ -n "$data" ]]; then
                    audio_data="${audio_data}${data}"
                    ((chunk_count++))
                fi
            fi
        done <<< "$(echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d')"
        
        if [[ -n "$audio_data" ]]; then
            echo "✅ Found $chunk_count audio chunks"
            
            # Create output file
            local output_file="$OUTPUT_DIR/${filename}.wav"
            
            # Convert to WAV (same process as single speaker)
            local data_size=$(echo "$audio_data" | base64 -d | wc -c)
            
            if [[ $data_size -gt 0 ]]; then
                {
                    printf "RIFF"
                    printf "\x$(printf "%02x" $((36 + data_size & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 8) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 16) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((36 + data_size >> 24) & 0xFF)))"
                    printf "WAVE"
                    printf "fmt "
                    printf "\x10\x00\x00\x00"
                    printf "\x01\x00"
                    printf "\x01\x00"
                    printf "\x80\x5e\x00\x00"
                    printf "\x00\x77\x01\x00"
                    printf "\x02\x00"
                    printf "\x10\x00"
                    printf "data"
                    printf "\x$(printf "%02x" $((data_size & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 8) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 16) & 0xFF)))"
                    printf "\x$(printf "%02x" $(((data_size >> 24) & 0xFF)))"
                    echo "$audio_data" | base64 -d
                } > "$output_file"
                
                echo "✅ Multi-speaker audio file created: $output_file"
                echo "🎵 SUCCESS! Conversation audio is ready for listening!"
                return 0
            else
                echo "❌ No audio data received"
                return 1
            fi
        else
            echo "❌ No audio data found in response"
            return 1
        fi
    else
        echo "❌ Multi-speaker API request failed (HTTP $http_status)"
        return 1
    fi
}

# Function to display listening instructions
display_listening_instructions() {
    echo ""
    echo "🎧 LISTENING INSTRUCTIONS:"
    echo "=========================="
    echo ""
    
    # List generated files
    echo "📁 Generated audio files:"
    for file in "$OUTPUT_DIR"/*.wav; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
            local size_kb=$((size / 1024))
            echo "  🎵 $filename (${size_kb}KB)"
        fi
    done
    
    echo ""
    echo "🎧 To listen to your audio:"
    echo ""
    
    # Platform-specific instructions
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 macOS:"
        echo "  afplay $OUTPUT_DIR/*.wav"
        echo "  OR: open $OUTPUT_DIR (then double-click files)"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "🐧 Linux:"
        echo "  aplay $OUTPUT_DIR/*.wav"
        echo "  OR: vlc $OUTPUT_DIR/*.wav"
    else
        echo "💻 General:"
        echo "  Use VLC, mplayer, or any audio player"
        echo "  Navigate to: $OUTPUT_DIR"
    fi
    
    echo ""
    echo "✨ Each file contains real speech generated by Google's Gemini TTS!"
    echo "🎵 Enjoy listening to the natural, high-quality voices!"
}

# Main execution
echo ""
echo "🚀 STARTING REAL TTS AUDIO GENERATION..."
echo "=========================================="
echo ""

# Test 1: Single speaker with different voices
echo "🎤 TEST 1: Single Speaker - Different Voices"
echo "============================================"

voices=("Zephyr" "Puck" "Charon" "Kore" "Uranus" "Fenrir")
test_text="Hello! This is a test of Google's Gemini text-to-speech system. Can you hear how natural and clear my voice sounds?"

for voice in "${voices[@]}"; do
    echo ""
    echo "🎵 Generating with voice: $voice"
    generate_audio "$test_text" "$voice" "test_${voice,,}"
    echo "---"
done

# Test 2: Multi-speaker conversation
echo ""
echo "🎙️ TEST 2: Multi-Speaker Conversation"
echo "====================================="

echo ""
echo "🎵 Generating conversation..."
conversation="Host: Welcome to our podcast! Today we're discussing AI voice technology. 
Guest: Thanks for having me! The advances in text-to-speech are absolutely amazing. 
Host: Can you tell us about the different voices available? 
Guest: We have Zephyr for natural conversation, Puck for friendly dialogue, and Charon for professional presentations."

generate_multi_speaker "$conversation" "Host:Zephyr Guest:Puck" "conversation_demo"
echo "---"

# Test 3: Different content styles
echo ""
echo "🗣️ TEST 3: Different Content Styles"
echo "==================================="

echo ""
echo "🎵 News style..."
generate_audio "Breaking news: Scientists have discovered a revolutionary method for converting text to speech using advanced artificial intelligence. This breakthrough promises to transform how we interact with digital content and accessibility tools." "Charon" "news_charon"

echo ""
echo "🎵 Storytelling style..."
generate_audio "Once upon a time, in a digital kingdom far away, there lived a magical text-to-speech system that could transform any written words into beautiful, natural-sounding speech. People came from far and wide to hear the enchanting voices that spoke with such clarity and emotion." "Fenrir" "story_fenrir"

echo ""
echo "🎵 Technical explanation..."
generate_audio "The Gemini text-to-speech API utilizes advanced neural networks and deep learning algorithms to analyze text patterns, linguistic structures, and contextual information to generate natural-sounding speech that closely mimics human voice characteristics and intonation patterns." "Kore" "technical_kore"

# Final results
echo ""
echo "🎉 AUDIO GENERATION COMPLETE!"
echo "=============================="

# Count generated files
file_count=$(ls -1 "$OUTPUT_DIR"/*.wav 2>/dev/null | wc -l)
echo "📊 Generated $file_count audio files"

# Display listening instructions
display_listening_instructions

echo ""
echo "🎊 SUCCESS! Your audio files are ready for listening!"
echo "🎧 Navigate to: $OUTPUT_DIR and start enjoying your generated speech!"
echo ""
echo "🎵 Happy Listening! 🎵"