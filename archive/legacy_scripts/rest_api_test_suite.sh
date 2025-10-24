#!/bin/bash
set -e -E

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎙️ Gemini REST API TTS Test Suite${NC}"
echo "===================================="

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${RED}❌ Error: GEMINI_API_KEY environment variable not set${NC}"
    echo "Please set it first: export GEMINI_API_KEY='your-api-key'"
    exit 1
fi

# API Configuration
MODEL_ID="gemini-2.5-pro-preview-tts"
GENERATE_CONTENT_API="streamGenerateContent"
BASE_URL="https://generativelanguage.googleapis.com/v1beta/models"

# Create output directory
mkdir -p .tmp/outputs

# Function to make API call and save response
make_api_call() {
    local test_name="$1"
    local request_file="$2"
    local output_file="$3"
    
    echo -e "${YELLOW}Testing: ${test_name}${NC}"
    
    API_URL="${BASE_URL}/${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}"
    
    curl \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      "${API_URL}" \
      -d "@${request_file}" \
      -o ".tmp/outputs/${output_file}" \
      -w "HTTP Status: %{http_code} | Response Time: %{time_total}s\n" \
      2>/dev/null
    
    echo "✓ Response saved: .tmp/outputs/${output_file}"
    
    # Check response size and content
    if [ -s ".tmp/outputs/${output_file}" ]; then
        local file_size=$(wc -c < ".tmp/outputs/${output_file}")
        echo "  File size: ${file_size} bytes"
        
        # Check for audio data indicators
        if grep -q "inlineData\|audio\|data:audio" ".tmp/outputs/${output_file}" 2>/dev/null; then
            echo -e "  ${GREEN}✓ Contains audio data${NC}"
        else
            echo -e "  ${RED}⚠ No obvious audio data found${NC}"
        fi
    else
        echo -e "  ${RED}❌ Empty response${NC}"
    fi
    echo ""
}

# Test 1: Basic Multi-Speaker Interview
echo -e "${BLUE}Test 1: Multi-Speaker Interview (Zephyr + Puck)${NC}"
cat > .tmp/outputs/test1_request.json << 'EOF'
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Please read aloud the following in a podcast interview style:\nSpeaker 1: We're seeing a noticeable shift in consumer preferences across several sectors. What seems to be driving this change?\nSpeaker 2: It appears to be a combination of factors, including greater awareness of sustainability issues and a growing demand for personalized experiences."
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
make_api_call "Multi-Speaker Interview" ".tmp/outputs/test1_request.json" "test1_response.json"

# Test 2: Single Speaker with Different Voice
echo -e "${BLUE}Test 2: Single Speaker (Charon Voice)${NC}"
cat > .tmp/outputs/test2_request.json << 'EOF'
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Welcome to our technology podcast. Today we'll explore the latest innovations in artificial intelligence and machine learning."
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
            "voice_name": "Charon"
          }
        }
      }
    }
}
EOF
make_api_call "Single Speaker (Charon)" ".tmp/outputs/test2_request.json" "test2_response.json"

# Test 3: Three-Speaker Conversation
echo -e "${BLUE}Test 3: Three-Speaker Conversation${NC}"
cat > .tmp/outputs/test3_request.json << 'EOF'
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Create a podcast discussion with three speakers:\nHost: Welcome to Tech Talks! Today we have two amazing guests.\nGuest 1: Thank you for having me, I'm excited to discuss AI ethics.\nGuest 2: It's great to be here, I work on AI safety research."
          }
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 0.9,
      "speech_config": {
        "multi_speaker_voice_config": {
          "speaker_voice_configs": [
            {
              "speaker": "Host",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Zephyr"
                }
              }
            },
            {
              "speaker": "Guest 1",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Kore"
                }
              }
            },
            {
              "speaker": "Guest 2",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Uranus"
                }
              }
            }
          ]
        }
      }
    }
}
EOF
make_api_call "Three-Speaker Discussion" ".tmp/outputs/test3_request.json" "test3_response.json"

# Test 4: Different Temperature Settings
echo -e "${BLUE}Test 4: Low Temperature (More Predictable)${NC}"
cat > .tmp/outputs/test4_request.json << 'EOF'
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "News update: The stock market closed higher today with tech stocks leading gains."
          }
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 0.2,
      "speech_config": {
        "voice_config": {
          "prebuilt_voice_config": {
            "voice_name": "Fenrir"
          }
        }
      }
    }
}
EOF
make_api_call "Low Temperature (Fenrir)" ".tmp/outputs/test4_request.json" "test4_response.json"

# Test 5: Narrative Style
echo -e "${BLUE}Test 5: Storytelling Narrative${NC}"
cat > .tmp/outputs/test5_request.json << 'EOF'
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Tell a short story in a narrative voice: Once upon a time, in a digital world far away, there lived a small AI who dreamed of understanding human emotions."
          }
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 0.7,
      "speech_config": {
        "voice_config": {
          "prebuilt_voice_config": {
            "voice_name": "Puck"
          }
        }
      }
    }
}
EOF
make_api_call "Narrative Storytelling" ".tmp/outputs/test5_request.json" "test5_response.json"

# Summary
echo -e "${BLUE}📊 Test Suite Summary${NC}"
echo "====================="
echo "All test requests and responses saved to: .tmp/outputs/"
echo ""
echo "Files created:"
ls -la .tmp/outputs/*.json 2>/dev/null | wc -l | xargs echo "  - JSON files:"
ls -la .tmp/outputs/test*_request.json 2>/dev/null | sed 's/^/    /'
ls -la .tmp/outputs/test*_response.json 2>/dev/null | sed 's/^/    /'

echo ""
echo -e "${GREEN}✅ REST API Test Suite completed!${NC}"
echo "Check individual response files for detailed results."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Analyze response files for audio data format"
echo "  2. Extract and decode audio data if present"
echo "  3. Test audio playback"
echo "  4. Implement audio extraction in Python scripts"