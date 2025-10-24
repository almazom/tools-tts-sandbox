# 🎙️ TTS Manager - Universal Podcast Generation Tool

A comprehensive bash script for generating podcast-quality audio using **Gemini API** and **MiniMax API**.

## 🚀 Quick Start

```bash
# Simple single speaker with Gemini (default)
./scripts/tts-manager.sh -t "Hello, welcome to our podcast!"

# Two-speaker podcast with Gemini
./scripts/tts-manager.sh -t "Host: Welcome to the show!\nGuest: Thanks for having me!" -s 2

# MiniMax with emotion
./scripts/tts-manager.sh -p minimax -t "This is exciting news!" --emotion happy
```

## 📋 Prerequisites

### For Gemini API
```bash
# Install dependencies
pip install google-genai python-dotenv

# Set API key
export GEMINI_API_KEY="your-api-key-here"
```

### For MiniMax API
```bash
# Set API key
export MINIMAX_API_KEY="your-api-key-here"
```

## 🎛️ Features

### Supported Providers

| Provider | Single Speaker | Multi-Speaker | Voice Cloning | Emotion Control |
|----------|----------------|---------------|---------------|-----------------|
| **Gemini** | ✅ | ✅ (2 speakers) | ❌ | ✅ (via prompts) |
| **MiniMax** | ✅ | ❌ | ✅ | ✅ (7 emotions) |

### Gemini Features

- **9 Built-in Voices**: Zephyr, Puck, Charon, Kore, Uranus, Fenrir, Aoede, Leda, Orus
- **Multi-Speaker Support**: Up to 2 speakers with distinct voices
- **Style Control**: Natural language prompts for style, tone, and emotion
- **Temperature Control**: Voice variation (0.0-1.0)
- **Pace Control**: Slow, normal, fast
- **High Quality**: 24kHz, 16-bit PCM

### MiniMax Features

- **7 Emotions**: neutral, happy, sad, angry, fearful, disgusted, surprised
- **Voice Customization**: Speed (0.5-2.0), Volume (0.0-2.0), Pitch (-12 to 12)
- **Multiple Models**: speech-02-hd, speech-02-turbo, speech-01-hd, speech-01-turbo
- **Flexible Output**: Multiple sample rates (8-44.1kHz), bitrates (64-320kbps)
- **Language Boost**: Auto-detect or specify language
- **Voice Cloning**: Clone custom voices (requires 10+ seconds audio)

## 📖 Usage Examples

### Basic Examples

```bash
# 1. Single speaker with default Gemini
./scripts/tts-manager.sh -t "Hello world!"

# 2. Choose a specific voice
./scripts/tts-manager.sh -t "Welcome!" --voice-1 Charon

# 3. From a text file
./scripts/tts-manager.sh -f script.txt

# 4. Custom output location
./scripts/tts-manager.sh -t "Hello!" -o my_audio.wav
```

### Gemini Advanced Examples

```bash
# 1. Two-speaker podcast
./scripts/tts-manager.sh \
  -t "Host: Welcome to Tech Talk!\nGuest: Happy to be here!" \
  -s 2 \
  --voice-1 Zephyr \
  --voice-2 Puck

# 2. With style and tone control
./scripts/tts-manager.sh \
  -t "Welcome to our meditation session" \
  --voice-1 Kore \
  --style "calm and soothing" \
  --tone "peaceful and relaxing" \
  --pace slow

# 3. Energetic announcement
./scripts/tts-manager.sh \
  -t "Big news everyone!" \
  --voice-1 Fenrir \
  --emotion "enthusiastic and energetic" \
  --pace fast \
  --temperature 1.0

# 4. Professional business podcast
./scripts/tts-manager.sh \
  -t "Host: Today we discuss market trends.\nGuest: Yes, it's fascinating." \
  -s 2 \
  --voice-1 Charon \
  --voice-2 Orus \
  --style "professional and authoritative" \
  --tone "formal and informative"

# 5. Storytelling with dramatic voice
./scripts/tts-manager.sh \
  -f story.txt \
  --voice-1 Fenrir \
  --style "dramatic and engaging" \
  --emotion "mysterious and suspenseful" \
  --pace normal
```

### MiniMax Advanced Examples

```bash
# 1. Happy announcement
./scripts/tts-manager.sh \
  -p minimax \
  -t "Congratulations on your achievement!" \
  --emotion happy \
  --speed 1.1

# 2. Sad message with slow pace
./scripts/tts-manager.sh \
  -p minimax \
  -t "We remember those we've lost." \
  --emotion sad \
  --speed 0.8 \
  --pitch -2

# 3. Angry character voice
./scripts/tts-manager.sh \
  -p minimax \
  -t "This is unacceptable!" \
  --emotion angry \
  --volume 1.5 \
  --pitch 3

# 4. High-quality professional audio
./scripts/tts-manager.sh \
  -p minimax \
  -t "Welcome to our premium podcast" \
  --model speech-02-hd \
  --sample-rate 44100 \
  --bitrate 320000 \
  --emotion neutral

# 5. Custom voice with settings
./scripts/tts-manager.sh \
  -p minimax \
  -t "This is my custom voice" \
  --voice-id "custom_voice_123" \
  --speed 1.2 \
  --volume 1.0 \
  --pitch 0 \
  --emotion happy
```

### Production Podcast Examples

```bash
# 1. Interview podcast (Gemini)
./scripts/tts-manager.sh \
  -f interview_script.txt \
  -s 2 \
  --voice-1 Zephyr \
  --voice-2 Puck \
  --style "conversational and natural" \
  --tone "friendly and engaging" \
  -o "podcast_episode_001.wav"

# 2. News broadcast (Gemini)
./scripts/tts-manager.sh \
  -f news_script.txt \
  --voice-1 Charon \
  --style "professional news anchor" \
  --tone "authoritative and clear" \
  --pace normal \
  -o "news_broadcast.wav"

# 3. Meditation guide (MiniMax)
./scripts/tts-manager.sh \
  -p minimax \
  -f meditation_script.txt \
  --emotion neutral \
  --speed 0.7 \
  --volume 0.9 \
  --pitch -3 \
  --sample-rate 44100 \
  -o "meditation_guide.wav"

# 4. Educational content (Gemini)
./scripts/tts-manager.sh \
  -f lesson_script.txt \
  --voice-1 Kore \
  --style "educational and clear" \
  --tone "warm and approachable" \
  --pace normal \
  --temperature 0.8 \
  -o "lesson_01.wav"
```

## 🎨 Voice Characteristics

### Gemini Voices

| Voice | Characteristics | Best For |
|-------|----------------|----------|
| **Zephyr** | Natural, conversational | General content, casual podcasts |
| **Puck** | Friendly, engaging | Storytelling, kids content |
| **Charon** | Professional, authoritative | Business, news, academic |
| **Kore** | Warm, approachable | Tutorials, support, friendly service |
| **Uranus** | Distinctive, memorable | Brand identity, unique voice |
| **Fenrir** | Strong, dramatic | Movie trailers, epic storytelling |
| **Aoede** | Musical, lyrical | Poetry, artistic content |
| **Leda** | Elegant, refined | Luxury brands, sophisticated content |
| **Orus** | Deep, commanding | Leadership, motivational content |

### MiniMax Emotions

| Emotion | Use Cases |
|---------|-----------|
| **neutral** | Professional content, news, factual information |
| **happy** | Celebrations, positive announcements, upbeat content |
| **sad** | Emotional stories, tributes, somber topics |
| **angry** | Dramatic characters, intense moments |
| **fearful** | Suspenseful stories, warnings |
| **disgusted** | Critical commentary, negative reviews |
| **surprised** | Exciting announcements, plot twists |

## 📝 Multi-Speaker Format

For 2-speaker podcasts with Gemini, format your text with speaker labels:

```text
Host: Welcome to Tech Talk, the podcast where we explore the latest in technology.
Guest: Thanks for having me! I'm excited to discuss AI developments.
Host: Let's dive right in. What's the most exciting trend you're seeing?
Guest: I'd say it's the advancement in natural language processing.
```

Alternative formats supported:
```text
Speaker 1: Your text here
Speaker 2: More text here
```

## ⚙️ Configuration Reference

### Gemini Parameters

| Parameter | Type | Range/Options | Default | Description |
|-----------|------|---------------|---------|-------------|
| `--model` | string | gemini-2.5-pro-preview-tts, gemini-2.5-flash-tts | pro-preview | Model selection |
| `--voice-1` | string | 9 voices | Zephyr | Primary voice |
| `--voice-2` | string | 9 voices | Puck | Secondary voice (2-speaker) |
| `--temperature` | float | 0.0-1.0 | 0.9 | Voice variation |
| `--style` | string | Free text | - | Style description |
| `--tone` | string | Free text | - | Tone description |
| `--pace` | string | slow, normal, fast | normal | Speaking pace |
| `--emotion` | string | Free text | - | Emotional delivery |

### MiniMax Parameters

| Parameter | Type | Range/Options | Default | Description |
|-----------|------|---------------|---------|-------------|
| `--model` | string | speech-02-hd, speech-02-turbo, etc. | speech-02-hd | Model selection |
| `--voice-id` | string | Voice ID | - | Custom/cloned voice ID |
| `--speed` | float | 0.5-2.0 | 1.0 | Speaking speed |
| `--volume` | float | 0.0-2.0 | 1.0 | Audio volume |
| `--pitch` | int | -12 to 12 | 0 | Voice pitch |
| `--emotion` | string | 7 emotions | neutral | Emotional tone |
| `--sample-rate` | int | 8000-44100 | 24000 | Audio sample rate (Hz) |
| `--bitrate` | int | 64000-320000 | 128000 | Audio bitrate (bps) |
| `--language-boost` | string | auto, language code | auto | Language enhancement |

## 🔧 Troubleshooting

### Common Issues

**1. "GEMINI_API_KEY not set"**
```bash
# Solution: Export your API key
export GEMINI_API_KEY="your-key-here"

# Or add to .env file
echo "GEMINI_API_KEY=your-key-here" >> .env
```

**2. "MiniMax does not support multi-speaker"**
```bash
# Solution: Use Gemini for 2-speaker podcasts
./scripts/tts-manager.sh -p gemini -s 2 -t "Host: Hello\nGuest: Hi"
```

**3. "Missing dependencies"**
```bash
# Install Python dependencies
pip install google-genai python-dotenv

# Ensure curl is installed
sudo apt-get install curl  # Ubuntu/Debian
```

**4. "Invalid voice"**
```bash
# Check available voices
./scripts/tts-manager.sh --help

# Use correct voice name (case-sensitive)
./scripts/tts-manager.sh --voice-1 Zephyr  # Correct
./scripts/tts-manager.sh --voice-1 zephyr  # Wrong
```

## 📊 Output Formats

The script supports multiple output formats:

| Format | Quality | Size | Use Case |
|--------|---------|------|----------|
| **WAV** | Highest | Large | Editing, production |
| **MP3** | Good | Medium | Distribution, streaming |
| **FLAC** | Lossless | Large | Archival, mastering |

```bash
# Specify output format
./scripts/tts-manager.sh -t "Hello" --format mp3
./scripts/tts-manager.sh -t "Hello" --format flac
```

## 🎯 Best Practices

### For Podcasts

1. **Use 2 speakers for interviews** with distinct voices
2. **Set appropriate pace** - normal for most content, slow for complex topics
3. **Add style descriptions** for better context
4. **Use high sample rates** (44100 Hz) for final production
5. **Test different voices** to find the right match for your brand

### For Quality

1. **Keep text chunks reasonable** (under 900 bytes per segment for Gemini)
2. **Use proper punctuation** for natural pauses
3. **Add emphasis** with capital letters or punctuation
4. **Review generated audio** before publishing
5. **Consider post-processing** for professional polish

### For Performance

1. **Use turbo models** for faster generation during testing
2. **Use HD models** for final production
3. **Cache frequently used segments** to save API calls
4. **Batch process** multiple episodes efficiently

## 📈 Performance Comparison

| Provider | Model | Speed | Quality | Multi-Speaker | Emotion Control |
|----------|-------|-------|---------|---------------|-----------------|
| Gemini | pro-preview | Medium | Excellent | Yes (2) | Via prompts |
| Gemini | flash-tts | Fast | Very Good | Yes (2) | Via prompts |
| MiniMax | speech-02-hd | Medium | Excellent | No | 7 presets |
| MiniMax | speech-02-turbo | Fast | Very Good | No | 7 presets |

## 🔒 Security Notes

- Never commit API keys to version control
- Use environment variables or `.env` file
- Rotate API keys regularly
- Monitor API usage and costs
- Use `.gitignore` for sensitive files

## 📚 Additional Resources

- [Gemini API Documentation](https://ai.google.dev/gemini-api/docs/speech-generation)
- [MiniMax API Documentation](https://api.minimax.chat/document/guides/text-to-speech)
- [Audio Post-Processing Guide](./docs/audio_processing.md)
- [Podcast Production Tips](./docs/podcast_tips.md)

## 🤝 Contributing

Contributions welcome! Please:
1. Test thoroughly with both providers
2. Update documentation
3. Follow existing code style
4. Add examples for new features

## 📄 License

This project is part of the Gemini TTS Podcast Generator toolkit.

---

**Need help?** Run `./scripts/tts-manager.sh --help` for detailed usage information.
