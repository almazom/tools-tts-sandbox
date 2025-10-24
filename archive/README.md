# 🎙️ Gemini TTS Podcast Generator

A comprehensive podcast generation toolkit using Google's Gemini API for text-to-speech conversion with multi-speaker support and professional audio processing.

## 🌟 Features

### Core TTS Functionality
- **Single Speaker TTS**: Convert text to speech with 6 different voices
- **Multi-Speaker Interviews**: Create podcast conversations with multiple speakers
- **Script Generation**: AI-powered podcast script creation
- **Professional Audio**: Automatic format conversion with proper headers
- **Streaming Audio**: Real-time audio generation with chunk processing

### Voice Selection
- **Zephyr**: Natural, conversational tone
- **Puck**: Friendly, engaging voice
- **Charon**: Professional, authoritative
- **Kore**: Warm, approachable
- **Uranus**: Distinctive, memorable
- **Fenrir**: Strong, dramatic

### Technical Features
- **Multiple Audio Formats**: WAV, MP3 with proper formatting
- **REST API Integration**: Complete API testing infrastructure
- **Command-Line Interface**: Professional CLI tools
- **Comprehensive Testing**: Multi-layer testing strategy
- **Production Ready**: Enterprise-grade implementation

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

### 5. Generate Script First
```bash
python3 scripts/podcast_cli.py script "AI in Healthcare" -s interview
```

## 🏗️ Project Structure

```
├── .env                              # Environment variables (API keys)
├── .gitignore                       # Git ignore rules
├── requirements.txt                 # Python dependencies
├── README.md                        # This file
├── SETUP_GUIDE.md                   # Detailed setup instructions
├── venv/                           # Python virtual environment
├── .tmp/                           # Temporary files and testing
│   ├── audio_outputs/              # Generated audio files
│   └── curl_audio_outputs/         # CURL-generated audio files
├── scripts/                        # Main application code
│   ├── gemini_tts.py               # Core TTS wrapper class
│   └── podcast_cli.py              # Command-line interface
└── tests/                          # Test files and suites
```

## 🔧 Installation

### Prerequisites
- Python 3.7+
- Git
- GitHub CLI (for repository management)
- curl (for API testing)

### Setup
1. Clone the repository
2. Create virtual environment: `python3 -m venv venv`
3. Activate virtual environment: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Set up environment variables in `.env`
6. Run tests to verify installation

## 📖 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete installation and usage guide
- **[API Documentation](https://ai.google.dev/gemini-api/docs)** - Official Gemini API docs
- **[Audio Guide](https://ai.google.dev/gemini-api/docs/audio)** - Audio-specific documentation

## 🧪 Testing

### Run All Tests
```bash
# Run comprehensive test suite
bash .tmp/auth_testing_master.sh

# Run CURL tests
bash .tmp/test_curl_tts.sh

# Run REST API tests
bash .tmp/test_rest_api.sh
```

### Test Specific Functionality
```bash
# Test single speaker
python3 .tmp/test_gemini_tts.py

# Test multi-speaker
bash .tmp/raw_curl_2speaker_mp3.sh
```

## 🔐 Authentication

The system supports multiple authentication methods:
- **API Key Authentication**: Primary method via environment variables
- **Bearer Token**: Alternative authentication method
- **Comprehensive Testing**: Authentication validation suite

## 📊 API Usage

### Direct REST API
```bash
# Test with curl
curl -X POST \
  -H "Content-Type: application/json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-tts:streamGenerateContent?key=YOUR_API_KEY" \
  -d @request.json
```

### Python Integration
```python
from scripts.gemini_tts import GeminiTTS

tts = GeminiTTS()
audio_file = tts.generate_speech("Hello world!", voice_name="Zephyr")
```

## 🎯 Success Criteria

✅ **Audio Generation**: Real, listenable audio files
✅ **Multi-Speaker Support**: Natural conversation flow
✅ **Professional Quality**: High-quality audio output
✅ **Comprehensive Testing**: Multi-layer validation
✅ **Production Ready**: Enterprise-grade implementation

## 🔍 Troubleshooting

### Common Issues
1. **API Rate Limits**: Check usage at https://ai.google.dev/usage
2. **Authentication Errors**: Verify API key in .env file
3. **Audio Format Issues**: Check MIME type handling
4. **Network Connectivity**: Ensure HTTPS access to Google APIs

### Debug Mode
```bash
# Enable debug logging
export DEBUG=true
python3 scripts/podcast_cli.py single "test" -v Zephyr
```

## 🚀 Advanced Usage

### Custom Voice Configuration
```python
speaker_configs = [
    {"speaker": "Host", "voice": "Zephyr"},
    {"speaker": "Guest", "voice": "Puck"}
]
tts.generate_podcast_interview(script, speaker_configs)
```

### Batch Processing
```bash
# Generate multiple files
for voice in Zephyr Puck Charon Kore Uranus Fenrir; do
    python3 scripts/podcast_cli.py single "Testing voice $voice" -v $voice -o "voice_$voice"
done
```

## 📈 Performance

- **Streaming Processing**: Real-time audio generation
- **Efficient Memory Usage**: Chunk-based processing
- **Multi-format Support**: Automatic format conversion
- **Error Recovery**: Robust error handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Google AI**: For the amazing Gemini API
- **GitHub**: For providing the platform
- **Python Community**: For excellent libraries
- **Open Source**: For making this possible

---

*Generated with ❤️ and 🐱 supervision in mom's basement*
