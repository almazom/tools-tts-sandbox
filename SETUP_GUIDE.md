# 🎙️ Gemini TTS Podcast Generator - Setup Guide

## ✅ What's Been Built

A complete podcast generation toolkit using Google's Gemini API with TTS capabilities:

### 🏗️ Project Structure
```
/root/zoo/tools_tts_sandbox/
├── .env                              # Environment variables (API keys)
├── .gitignore                       # Git ignore rules
├── README.md                        # Project overview
├── requirements.txt                 # Python dependencies
├── SETUP_GUIDE.md                   # This file
├── venv/                           # Python virtual environment
├── .tmp/                           # Temporary test files
│   ├── test_gemini_tts.py          # Python test script
│   ├── test_curl_tts.sh            # Curl test script (executable)
│   └── outputs/                    # Test output directory
├── scripts/                        # Main application code
│   ├── gemini_tts.py               # Core TTS wrapper class
│   └── podcast_cli.py              # Command-line interface (executable)
└── tests/                          # Future test files
```

## 🚀 Features Implemented

### 1. Single Speaker TTS
- Convert any text to speech using available voices
- Configurable temperature for voice variation
- Automatic WAV file generation

### 2. Multi-Speaker Podcast Interviews
- Multiple speakers with different voices
- Speaker-labeled scripts (e.g., "Speaker 1:", "Speaker 2:")
- Natural conversation flow generation

### 3. Available Voices
- Zephyr, Puck, Charon, Kore, Uranus, Fenrir
- Each voice has distinct characteristics

### 4. Command-Line Interface
Easy-to-use CLI for all operations:
```bash
# List available voices
python3 scripts/podcast_cli.py voices

# Single speaker
python3 scripts/podcast_cli.py single "Hello world" -v Zephyr -o output

# Multi-speaker interview
python3 scripts/podcast_cli.py multi "Speaker 1: Hello\nSpeaker 2: Hi there!" \
  -s "Speaker 1:Zephyr" "Speaker 2:Puck" -o interview

# Generate podcast script
python3 scripts/podcast_cli.py script "AI in Healthcare" -s interview -d "10 minutes"
```

## 🔧 Environment Setup

### 1. Environment Variables (.env)
```bash
GEMINI_API_KEY=your_api_key_here  # Get from Google Cloud Console
GEMINI_TTS_MODEL=gemini-2.5-flash-preview-tts
```

### 2. Virtual Environment
```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # or . venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Load Environment Variables
```bash
# Load .env file before running scripts
export $(cat .env | xargs)
```

## 🧪 Testing

### Python Test Script
```bash
. venv/bin/activate && export $(cat .env | xargs) && python3 .tmp/test_gemini_tts.py
```

### Curl Test Script
```bash
export GEMINI_API_KEY="your-api-key"
./.tmp/test_curl_tts.sh
```

## 📋 Usage Examples

### 1. Quick Single Speaker Test
```bash
. venv/bin/activate
export $(cat .env | xargs)
python3 scripts/podcast_cli.py single "Welcome to our AI podcast!" -v Zephyr
```

### 2. Create Multi-Speaker Interview
```bash
. venv/bin/activate
export $(cat .env | xargs)

SCRIPT="Speaker 1: Welcome to Tech Talks! Today we're discussing AI.\nSpeaker 2: Thanks for having me! AI is fascinating.\nSpeaker 1: What excites you most about it?\nSpeaker 2: The potential to solve complex problems!"

python3 scripts/podcast_cli.py multi "$SCRIPT" \
  -s "Speaker 1:Zephyr" "Speaker 2:Puck" \
  -o ai_interview
```

### 3. Generate Script First, Then Audio
```bash
# Generate script
. venv/bin/activate
export $(cat .env | xargs)
python3 scripts/podcast_cli.py script "Machine Learning Basics" -s interview

# Then use the generated script for audio
python3 scripts/podcast_cli.py multi "[paste generated script]" \
  -s "Host:Zephyr" "Guest:Puck" -o ml_podcast
```

## 🎯 Next Steps

1. **Test with your API key** - The current key has rate limits
2. **Experiment with different voices** - Try all 6 available voices
3. **Create longer podcasts** - Test with 10-15 minute scripts
4. **Add post-processing** - Audio editing, background music
5. **Batch generation** - Create multiple episodes at once
6. **Web interface** - Build a web UI for easier usage

## 🔧 Troubleshooting

### Common Issues

1. **API Rate Limits**
   - Error: `429 RESOURCE_EXHAUSTED`
   - Solution: Check your Google AI Studio billing/quota settings

2. **Environment Variables**
   - Error: `Gemini API key not found`
   - Solution: Run `export $(cat .env | xargs)` before scripts

3. **Dependencies**
   - Error: `ModuleNotFoundError`
   - Solution: Activate virtual environment and install requirements

4. **Voice Names**
   - Only use available voices: Zephyr, Puck, Charon, Kore, Uranus, Fenrir

## 📚 API Documentation

- [Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
- [TTS Multi-speaker Guide](https://ai.google.dev/gemini-api/docs/audio#multi-speaker)
- [Rate Limits](https://ai.google.dev/gemini-api/docs/rate-limits)

## 🎉 Success!

Your podcast generation toolkit is ready! The setup includes:
- ✅ Environment configuration
- ✅ Dependency management
- ✅ Core TTS functionality
- ✅ Multi-speaker support
- ✅ Command-line interface
- ✅ Test scripts
- ✅ Documentation

Start creating your podcasts! 🎙️