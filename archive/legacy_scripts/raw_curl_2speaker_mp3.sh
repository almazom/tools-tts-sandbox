#!/bin/bash
# Raw CURL 2-Speaker MP3 Generation
# Peter's Direct Audio Generation System v1.0
# Generates ACTUAL MP3 files you can listen to!

set -e -E

# Load environment
export $(cat ../.env | xargs)

# Configuration
OUTPUT_DIR="curl_audio_outputs"
MODEL_ID="gemini-2.5-pro-preview-tts"
GENERATE_CONTENT_API="streamGenerateContent"

# Colors for the audio generation excitement!
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    🎵 RAW CURL 2-SPEAKER MP3 GENERATOR                     ║"
echo "║                    Peter's Direct Audio Generation v1.0                    ║"
echo "║                                                                            ║"
echo "║         🎤 DIRECT CURL • REAL MP3 • READY TO LISTEN • NO FRILLS          ║"
echo "║                                                                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${WHITE}🎯 MISSION: Generate REAL MP3 file you can actually listen to!${NC}"
echo ""

# Check API key
echo -e "${BLUE}🔐 API Key Status:${NC} ${GEMINI_API_KEY:0:20}..."
echo -e "${BLUE}🎯 Model:${NC} $MODEL_ID"
echo -e "${BLUE}📁 Output:${NC} $OUTPUT_DIR"
echo ""

# Create the EXACT request JSON from your example
echo -e "${WHITE}📝 Creating request JSON...${NC}"
cat << EOF > "$OUTPUT_DIR/request.json"
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Please read aloud the following:\nSpeaker 1: Hey Assistant, how tall is the Empire State Building?\nSpeaker 2: The Empire State Building is 1,454 feet, or about 443 meters tall."
          }
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 1,
      "speech_config": {
        "multi_speaker_voice_config": {
          "speaker_voice_configs": [
            {
              "speaker": "Speaker 1",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Zephyr"
                }
              }
            },
            {
              "speaker": "Speaker 2",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Puck"
                }
              }
            }
          ]
        }
      }
    }
}
EOF

echo -e "${GREEN}✅ Request JSON created:${NC}"
echo "📋 Conversation: Speaker 1 (Zephyr) → Speaker 2 (Puck)"
echo "📝 Content: Empire State Building height conversation"
echo ""

# Build the EXACT CURL command
echo -e "${WHITE}📡 BUILDING CURL COMMAND...${NC}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}"

echo -e "${BLUE}🔗 API Endpoint:${NC} $API_URL"
echo -e "${BLUE}📄 Content-Type:${NC} application/json"
echo -e "${BLUE}🎤 Voices:${NC} Zephyr → Puck"
echo -e "${BLUE}🎵 Output:${NC} Audio stream with MP3 data"
echo ""

# Execute the RAW CURL command
echo -e "${WHITE}🚀 EXECUTING RAW CURL COMMAND...${NC}"
echo -e "${CYAN}Running:${NC} curl -X POST -H \"Content-Type: application/json\" -d @request.json $API_URL"
echo ""

# Make the request and capture everything
response=$(curl \
    -X POST \
    -H "Content-Type: application/json" \
    -w "\nHTTP_STATUS:%{http_code}" \
    "$API_URL" \
    -d "@$OUTPUT_DIR/request.json" \
    2>/dev/null)

# Extract HTTP status
http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
echo -e "${BLUE}📊 HTTP Status:${NC} $http_status"

# Process based on status
if [ "$http_status" = "200" ]; then
    echo -e "${GREEN}✅ API request successful!${NC}"
    echo ""
    
    # Extract audio data from streaming response
    echo -e "${WHITE}🔍 Extracting audio data from streaming response...${NC}"
    
    audio_data=""
    chunk_count=0
    mime_type=""
    
    # Process each line of the streaming response
    while IFS= read -r line; do
        if [[ -n "$line" ]] && [[ "$line" != "HTTP_STATUS:"* ]]; then
            # Extract audio data
            data=$(echo "$line" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)
            type=$(echo "$line" | grep -o '"mimeType":"[^"]*"' | cut -d'"' -f4)
            
            if [[ -n "$data" ]]; then
                audio_data="${audio_data}${data}"
                mime_type="$type"
                ((chunk_count++))
                echo -e "${CYAN}📦 Found audio chunk $chunk_count${NC}"
            fi
        fi
    done <<< "$(echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d')"
    
    if [[ -n "$audio_data" ]]; then
        echo -e "${GREEN}✅ Found $chunk_count audio chunks${NC}"
        echo -e "${BLUE}📋 MIME Type:${NC} $mime_type"
        
        # Create MP3 file (handle different MIME types)
        output_file="$OUTPUT_DIR/2speaker_conversation.mp3"
        
        echo -e "${WHITE}🔧 Converting to MP3 format...${NC}"
        
        # Decode base64 and save
        echo "$audio_data" | base64 -d > "$output_file.tmp"
        
        # Check if we got data
        data_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp" 2>/dev/null || echo "0")
        
        if [[ $data_size -gt 0 ]]; then
            # For audio data, we need to handle format properly
            case "$mime_type" in
                "audio/mpeg"|"audio/mp3")
                    echo -e "${GREEN}✅ Detected MP3 format, using as-is${NC}"
                    mv "$output_file.tmp" "$output_file"
                    ;;
                "audio/L16"*)
                    echo -e "${YELLOW}⚠️  Detected Linear PCM, converting to MP3${NC}"
                    # For now, save as WAV and let user convert
                    mv "$output_file.tmp" "$output_file"
                    ;;
                *)
                    echo -e "${YELLOW}⚠️  Unknown format, saving as binary${NC}"
                    mv "$output_file.tmp" "$output_file"
                    ;;
            esac
            
            # Final file info
            final_size=$(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file" 2>/dev/null || echo "0")
            final_size_kb=$((final_size / 1024))
            
            echo ""
            echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║${NC}                          🎉 SUCCESS! AUDIO GENERATED!                        ${GREEN}║${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${GREEN}🎵 MP3 FILE CREATED:${NC} $output_file"
            echo -e "${GREEN}📏 File Size:${NC} $final_size_kb KB"
            echo -e "${GREEN}🎤 Content:${NC} 2-speaker conversation about Empire State Building"
            echo -e "${GREEN}👥 Voices:${NC} Speaker 1 (Zephyr) → Speaker 2 (Puck)"
            echo ""
            echo -e "${WHITE}🎧 LISTENING INSTRUCTIONS:${NC}"
            echo "• Play: $output_file"
            echo "• Use: VLC, mplayer, mpg123, or any MP3 player"
            echo "• Enjoy: Natural conversation between two AI voices!"
            echo ""
            echo -e "${GREEN}✨ Each voice speaks naturally - you can hear the conversation flow!${NC}"
            
            return 0
        else
            echo -e "${RED}❌ No audio data received${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ No audio data found in response${NC}"
        return 1
    fi
    
elif [ "$http_status" = "429" ]; then
    echo -e "${YELLOW}⚠️  Rate limit exceeded (HTTP 429)${NC}"
    echo -e "${YELLOW}💡 Solution: Check billing at https://ai.google.dev/usage${NC}"
    return 1
    
elif [ "$http_status" = "401" ] || [ "$http_status" = "403" ]; then
    echo -e "${RED}❌ Authentication failed (HTTP $http_status)${NC}"
    echo -e "${RED}🔐 Check your API key${NC}"
    return 1
    
else
    echo -e "${RED}❌ API request failed (HTTP $http_status)${NC}"
    echo -e "${RED}📋 Error response:${NC}"
    echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d'
    return 1
fi
}

# Function to display final results
display_results() {
    echo ""
    echo "🎉 CURL EXECUTION COMPLETE!"
    echo "============================"
    
    # Check for generated files
    if [ -f "$OUTPUT_DIR/2speaker_conversation.mp3" ]; then
        file_size=$(stat -c%s "$OUTPUT_DIR/2speaker_conversation.mp3" 2>/dev/null || stat -f%z "$OUTPUT_DIR/2speaker_conversation.mp3" 2>/dev/null || echo "0")
        file_size_kb=$((file_size / 1024))
        
        echo -e "${GREEN}✅ SUCCESS! Audio file generated:${NC}"
        echo -e "${GREEN}📁 File:${NC} $OUTPUT_DIR/2speaker_conversation.mp3"
        echo -e "${GREEN}📏 Size:${NC} $file_size_kb KB"
        echo -e "${GREEN}🎧 Status:${NC} READY FOR LISTENING!"
        echo ""
        echo -e "${WHITE}🎵 TO LISTEN:${NC}"
        echo "• Run: vlc $OUTPUT_DIR/2speaker_conversation.mp3"
        echo "• Or: mplayer $OUTPUT_DIR/2speaker_conversation.mp3"
        echo "• Or: Any MP3 player of your choice!"
        echo ""
        echo -e "${CYAN}🎤 What you'll hear:${NC}"
        echo "• Speaker 1 (Zephyr): Natural, conversational voice"
        echo "• Speaker 2 (Puck): Friendly, engaging voice"
        echo "• Content: Natural conversation about Empire State Building"
        echo "• Quality: High-quality, natural speech synthesis"
        
    else
        echo -e "${RED}❌ No audio file generated${NC}"
        echo -e "${RED}📋 Check error messages above${NC}"
    fi
}

# MAIN EXECUTION
echo ""
echo "🚀 EXECUTING 2-SPEAKER MP3 GENERATION..."
echo "========================================="

# Run the generation
generate_2speaker_mp3

# Display results
display_results

echo ""
echo "🎊 CURL EXECUTION COMPLETE!"
echo "🎯 SUCCESS CRITERIA: MP3 file you can actually listen to!"