# 🔌 Gemini REST API TTS Guide

Complete guide for using Gemini REST API for text-to-speech with multi-speaker support.

## 📋 API Endpoints

### Base URL
```
https://generativelanguage.googleapis.com/v1beta
```

### TTS Endpoint
```
POST /models/{model_id}:streamGenerateContent?key={API_KEY}
```

**Model ID**: `gemini-2.5-pro-preview-tts`

## 🎤 Request Format

### Headers
```http
Content-Type: application/json
Accept: application/json
```

### Basic Structure
```json
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Your text here with speaker labels"
          }
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 1.0,
      "speech_config": {
        // Single or multi-speaker configuration
      }
    }
}
```

## 🗣️ Single Speaker Configuration

```json
{
  "speech_config": {
    "voice_config": {
      "prebuilt_voice_config": {
        "voice_name": "Zephyr"
      }
    }
  }
}
```

## 👥 Multi-Speaker Configuration

```json
{
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
```

## 🎭 Available Voices

| Voice Name | Style | Best For |
|------------|--------|----------|
| **Zephyr** | Natural, conversational | General narration, hosting |
| **Puck** | Friendly, engaging | Interviews, discussions |
| **Charon** | Professional, authoritative | News, formal presentations |
| **Kore** | Warm, approachable | Educational content |
| **Uranus** | Distinctive, memorable | Character voices |
| **Fenrir** | Strong, dramatic | Storytelling, dramatic content |

## 🔧 Parameters

### Temperature
- **Range**: 0.0 to 1.0
- **Low (0.2)**: More predictable, consistent speech
- **High (1.0)**: More varied, expressive speech
- **Default**: 0.8

### Response Modalities
Always include `"audio"` for TTS:
```json
"responseModalities": ["audio"]
```

## 📝 Text Formatting

### Speaker Labels
Use clear speaker labels for multi-speaker:
```
Speaker 1: Hello and welcome!
Speaker 2: Thanks for having me.
Host: Let's start with your background.
Guest: I've been working in AI for 10 years.
```

### Script Structure
```
Speaker 1: [Opening statement or question]
Speaker 2: [Response or answer]
Speaker 1: [Follow-up or transition]
Speaker 2: [Additional comments]
```

## 🚀 Quick Start Examples

### 1. Basic Single Speaker
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-tts:streamGenerateContent?key=YOUR_API_KEY" \
  -d '{
    "contents": [{
      "role": "user",
      "parts": [{"text": "Hello, this is a test of the Gemini TTS system."}]
    }],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 0.8,
      "speech_config": {
        "voice_config": {
          "prebuilt_voice_config": {"voice_name": "Zephyr"}
        }
      }
    }
  }'
```

### 2. Two-Speaker Interview
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-tts:streamGenerateContent?key=YOUR_API_KEY" \
  -d '{
    "contents": [{
      "role": "user",
      "parts": [{"text": "Speaker 1: Welcome to our podcast!\nSpeaker 2: Thanks for having me!"}]
    }],
    "generationConfig": {
      "responseModalities": ["audio"],
      "temperature": 1.0,
      "speech_config": {
        "multi_speaker_voice_config": {
          "speaker_voice_configs": [
            {
              "speaker": "Speaker 1",
              "voice_config": {
                "prebuilt_voice_config": {"voice_name": "Zephyr"}
              }
            },
            {
              "speaker": "Speaker 2",
              "voice_config": {
                "prebuilt_voice_config": {"voice_name": "Puck"}
              }
            }
          ]
        }
      }
    }
  }'
```

## 📊 Response Format

### Streaming Response
The API returns streaming JSON responses, one per line:
```json
{"candidates": [{"content": {"parts": [{"inlineData": {"mimeType": "audio/L16;rate=24000", "data": "BASE64_AUDIO_DATA"}}]}}]}
{"candidates": [{"content": {"parts": [{"inlineData": {"mimeType": "audio/L16;rate=24000", "data": "BASE64_AUDIO_DATA"}}]}}]}
```

### Audio Data Extraction
Audio data is base64 encoded in the `inlineData.data` field with MIME type in `inlineData.mimeType`.

## 🧪 Testing Tools

### 1. REST API Test Suite
```bash
export GEMINI_API_KEY="your-api-key"
./.tmp/rest_api_test_suite.sh
```

### 2. Parse Audio from Responses
```bash
# Parse all response files
python3 .tmp/parse_rest_audio.py

# Parse specific file
python3 .tmp/parse_rest_audio.py .tmp/outputs/test1_response.json
```

### 3. Basic REST API Test
```bash
export GEMINI_API_KEY="your-api-key"
./.tmp/test_rest_api.sh
```

## 🔍 Debugging Tips

### 1. Check Response Format
```bash
curl -X POST [your-request] | head -c 500
```

### 2. Validate JSON Structure
```bash
cat request.json | python3 -m json.tool
```

### 3. Monitor HTTP Status
```bash
curl -w "\nHTTP Status: %{http_code}\n" [your-request]
```

## ⚠️ Common Issues

### 1. Rate Limiting
- **Error**: `429 RESOURCE_EXHAUSTED`
- **Solution**: Check quota at https://ai.dev/usage

### 2. Invalid JSON
- **Error**: `400 Bad Request`
- **Solution**: Validate JSON formatting, check trailing commas

### 3. Missing Audio Data
- **Symptom**: Response contains only text
- **Solution**: Ensure `"responseModalities": ["audio"]` is set

### 4. Speaker Recognition Issues
- **Symptom**: All speech uses same voice
- **Solution**: Check speaker labels match configuration exactly

## 🎯 Best Practices

1. **Use Streaming**: Always use `streamGenerateContent` for TTS
2. **Clear Speaker Labels**: Make speaker names consistent
3. **Test Voices**: Try different voices for different content types
4. **Monitor Usage**: Track API usage and costs
5. **Handle Errors**: Implement proper error handling
6. **Validate Responses**: Check for audio data before processing

## 📚 Integration Examples

See the main toolkit:
- `scripts/gemini_tts.py` - Python wrapper class
- `scripts/podcast_cli.py` - Command-line interface
- `.tmp/parse_rest_audio.py` - Audio extraction utility

## 🔗 Related Documentation
- [Gemini API Audio Guide](https://ai.google.dev/gemini-api/docs/audio)
- [Multi-speaker TTS](https://ai.google.dev/gemini-api/docs/audio#multi-speaker)
- [Rate Limits](https://ai.google.dev/gemini-api/docs/rate-limits)