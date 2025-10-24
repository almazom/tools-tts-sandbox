# 🎙️ Podcast Generator with Gemini API TTS

A complete toolkit for generating podcasts using Google's Gemini API for text-to-speech conversion.

## ✅ Features Implemented
- **Single Voice TTS**: Convert text to speech with 6 different voices
- **Multi-Speaker Interviews**: Create podcast conversations with multiple speakers
- **Script Generation**: AI-powered podcast script creation
- **Command-Line Interface**: Easy-to-use CLI for all operations
- **Multiple Audio Formats**: Automatic WAV conversion with proper headers
- **Streaming Audio**: Real-time audio generation with chunk processing

## 🏗️ Project Structure
```
├── .env                              # Environment variables (API keys)
├── .gitignore                       # Git ignore rules
├── requirements.txt                 # Python dependencies
├── SETUP_GUIDE.md                   # Detailed setup instructions
├── venv/                           # Python virtual environment
├── .tmp/                           # Temporary test files
│   ├── test_gemini_tts.py          # Python test script
│   ├── test_curl_tts.sh            # Curl test script
│   └── outputs/                    # Test outputs
├── scripts/                        # Main application
│   ├── gemini_tts.py               # Core TTS wrapper class
│   └── podcast_cli.py              # Command-line interface
└── tests/                          # Test files
```

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Load environment variables
export $(cat .env | xargs)

# Activate virtual environment
source venv/bin/activate
```

### 2. List Available Voices
```bash
python3 scripts/podcast_cli.py voices
```

### 3. Generate Single Speaker Audio
```bash
python3 scripts/podcast_cli.py single "Hello world!" -v Zephyr
```

### 4. Create Multi-Speaker Interview
```bash
SCRIPT="Speaker 1: Welcome!\nSpeaker 2: Thanks for having me!"
python3 scripts/podcast_cli.py multi "$SCRIPT" -s "Speaker 1:Zephyr" "Speaker 2:Puck"
```

## 🎤 Available Voices
- **Zephyr** - Natural, conversational
- **Puck** - Friendly, engaging  
- **Charon** - Professional, authoritative
- **Kore** - Warm, approachable
- **Uranus** - Distinctive, memorable
- **Fenrir** - Strong, dramatic

## 📖 Documentation
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup and usage guide
- **[API Documentation](https://ai.google.dev/gemini-api/docs)** - Official Gemini API docs

## 🧪 Testing
```bash
# Test Python implementation
. venv/bin/activate && export $(cat .env | xargs) && python3 .tmp/test_gemini_tts.py

# Test curl endpoints
export GEMINI_API_KEY="your-api-key" && ./.tmp/test_curl_tts.sh
```

## 🎯 Ready to Use!
Your podcast generation toolkit is complete and ready for production. Start creating amazing podcasts! 🎙️