#!/bin/bash

# Test script for Gemini TTS using curl
# This script tests direct API calls to Gemini TTS endpoints

echo "🚀 Testing Gemini TTS with curl"
echo "==============================="

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable not set"
    echo "Please set it first: export GEMINI_API_KEY='your-api-key'"
    exit 1
fi

# Base URL for Gemini API
BASE_URL="https://generativelanguage.googleapis.com/v1beta"
MODEL="gemini-2.5-pro-preview-tts"

# Create temporary directory for test outputs
mkdir -p .tmp/outputs

echo "📍 Testing basic text generation..."
curl -X POST "${BASE_URL}/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, this is a test of the Gemini TTS system."
      }]
    }],
    "generationConfig": {
      "temperature": 0.8,
      "topK": 40,
      "topP": 0.95,
      "maxOutputTokens": 1024
    }
  }' > .tmp/outputs/basic_text.json

echo "✓ Basic text response saved to .tmp/outputs/basic_text.json"

echo ""
echo "🎤 Testing single speaker TTS (streaming)..."
# Note: This is a simplified test - actual TTS streaming requires proper audio handling
curl -X POST "${BASE_URL}/models/${MODEL}:streamGenerateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Welcome to our podcast! This is a test of the text to speech system."
      }]
    }],
    "generationConfig": {
      "temperature": 0.8,
      "responseModalities": ["audio"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Zephyr"
          }
        }
      }
    }
  }' > .tmp/outputs/single_speaker_stream.json

echo "✓ Single speaker audio response saved to .tmp/outputs/single_speaker_stream.json"

echo ""
echo "🎙️ Testing multi-speaker TTS..."
curl -X POST "${BASE_URL}/models/${MODEL}:streamGenerateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Speaker 1: Hello and welcome to our tech podcast.\nSpeaker 2: Thanks for having me! Im excited to discuss AI today."
      }]
    }],
    "generationConfig": {
      "temperature": 1.0,
      "responseModalities": ["audio"],
      "speechConfig": {
        "multiSpeakerVoiceConfig": {
          "speakerVoiceConfigs": [
            {
              "speaker": "Speaker 1",
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Zephyr"
                }
              }
            },
            {
              "speaker": "Speaker 2",
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Puck"
                }
              }
            }
          ]
        }
      }
    }
  }' > .tmp/outputs/multi_speaker_stream.json

echo "✓ Multi-speaker audio response saved to .tmp/outputs/multi_speaker_stream.json"

echo ""
echo "📊 Checking response formats..."
echo "Basic text response structure:"
head -20 .tmp/outputs/basic_text.json | python3 -m json.tool

echo ""
echo "✅ All curl tests completed!"
echo "Check .tmp/outputs/ directory for detailed responses"