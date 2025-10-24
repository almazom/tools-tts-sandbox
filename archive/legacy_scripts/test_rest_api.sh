#!/bin/bash
set -e -E

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Testing Gemini REST API TTS${NC}"
echo "=================================="

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${RED}❌ Error: GEMINI_API_KEY environment variable not set${NC}"
    echo "Please set it first: export GEMINI_API_KEY='your-api-key'"
    exit 1
fi

# API Configuration
MODEL_ID="gemini-2.5-pro-preview-tts"
GENERATE_CONTENT_API="streamGenerateContent"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}"

# Create output directory
mkdir -p .tmp/outputs

echo -e "${YELLOW}📍 Testing Multi-Speaker Podcast Interview${NC}"

# Create request JSON file
cat > .tmp/outputs/rest_request.json << 'EOF'
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

echo "✓ Request JSON created: .tmp/outputs/rest_request.json"

# Make the API call
echo -e "${YELLOW}🔄 Calling Gemini REST API...${NC}"
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  "${API_URL}" \
  -d '@.tmp/outputs/rest_request.json' \
  -o .tmp/outputs/rest_response.json \
  -w "\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n"

echo "✓ Response saved to: .tmp/outputs/rest_response.json"

# Check response format
echo -e "${YELLOW}📊 Analyzing response...${NC}"
if [ -s .tmp/outputs/rest_response.json ]; then
    echo "Response file size: $(wc -c < .tmp/outputs/rest_response.json) bytes"
    
    # Check if response contains audio data (base64 encoded)
    if grep -q "inlineData" .tmp/outputs/rest_response.json || grep -q "audio" .tmp/outputs/rest_response.json; then
        echo -e "${GREEN}✓ Response appears to contain audio data${NC}"
    else
        echo -e "${RED}⚠ Response may not contain expected audio data${NC}"
    fi
    
    # Show first few lines of response
    echo "First 200 characters of response:"
    head -c 200 .tmp/outputs/rest_response.json
    echo "..."
    
else
    echo -e "${RED}❌ No response received or empty response${NC}"
fi

echo ""
echo -e "${GREEN}✅ REST API test completed!${NC}"
echo "Check .tmp/outputs/ for detailed results"