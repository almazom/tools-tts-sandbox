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
├── requirements.txt                 # Python dependencies
├── SETUP_GUIDE.md                   # Quick setup instructions
├── venv/                           # Python virtual environment
├── scripts/                        # Production scripts
│   ├── tts-manager.sh              # Main TTS generation tool
│   ├── tts-quick.sh                # Convenience wrapper (auto venv)
│   ├── podcast-generator.sh        # AI podcast orchestrator
│   ├── gemini_tts.py               # Core TTS library
│   └── podcast_cli.py              # CLI interface
├── outputs/                        # Generated audio files
├── examples/                       # Usage examples
├── docs/                           # Documentation
│   ├── guides/                     # User guides
│   └── analysis/                   # Project analyses
└── tests/                          # Test suite
```

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Option A: Manual setup
export $(cat .env | xargs)
source venv/bin/activate

# Option B: Use convenience wrapper (auto-activates venv)
scripts/tts-quick.sh --help
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

### 🚀 Getting Started
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Quick setup and installation

### 📚 User Guides
- **[TTS Manager Guide](docs/guides/TTS_MANAGER_GUIDE.md)** - Complete guide for tts-manager.sh
- **[Podcast Generator Guide](docs/guides/PODCAST_GENERATOR_GUIDE.md)** - AI-powered podcast creation
- **[REST API Guide](docs/guides/REST_API_GUIDE.md)** - API reference and examples

### 📊 Project Reference
- **[Project Structure](docs/analysis/PROJECT_STRUCTURE.md)** - Detailed codebase structure
- **[Project Analysis](docs/analysis/PROJECT_ANALYSIS.md)** - Technical analysis
- **[Complete Summary](docs/analysis/COMPLETE_SUMMARY.md)** - Full project summary

### 🔗 External Resources
- **[Gemini API Documentation](https://ai.google.dev/gemini-api/docs)** - Official API docs

## 🧪 Testing
```bash
# Test Python implementation
. venv/bin/activate && export $(cat .env | xargs) && python3 .tmp/test_gemini_tts.py

# Test curl endpoints
export GEMINI_API_KEY="your-api-key" && ./.tmp/test_curl_tts.sh
```

## 🎯 Ready to Use!
Your podcast generation toolkit is complete and ready for production. Start creating amazing podcasts! 🎙️