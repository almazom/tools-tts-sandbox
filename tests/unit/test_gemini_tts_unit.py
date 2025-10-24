#!/usr/bin/env python3
"""
Unit tests for GeminiTTS class following TDD principles
Test-First Development approach with comprehensive coverage
"""

import pytest
import tempfile
import os
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock, call
import base64

# Import the system under test
sys.path.append(str(Path(__file__).parent.parent.parent))
from scripts.gemini_tts import GeminiTTS


class TestGeminiTTSInitialization:
    """Test TTS service initialization"""
    
    def test_initialization_with_api_key(self):
        """Test service initialization with explicit API key"""
        # Given
        api_key = "test-api-key-123"
        
        # When
        with patch('scripts.gemini_tts.genai') as mock_genai:
            service = GeminiTTS(api_key=api_key)
        
        # Then
        assert service.api_key == api_key
        assert service.model == "gemini-2.5-pro-preview-tts"  # default model
    
    def test_initialization_with_env_var(self):
        """Test service initialization with environment variable"""
        # Given
        api_key = "env-api-key-456"
        
        # When
        with patch.dict(os.environ, {'GEMINI_API_KEY': api_key}):
            with patch('scripts.gemini_tts.genai') as mock_genai:
                service = GeminiTTS()
        
        # Then
        assert service.api_key == api_key
    
    def test_initialization_with_custom_model(self):
        """Test service initialization with custom model"""
        # Given
        api_key = "test-api-key"
        custom_model = "custom-gemini-model"
        
        # When
        with patch('scripts.gemini_tts.genai') as mock_genai:
            service = GeminiTTS(api_key=api_key, model=custom_model)
        
        # Then
        assert service.model == custom_model
    
    def test_initialization_without_api_key_raises_error(self):
        """Test that initialization fails without API key"""
        # Given/When/Then
        with patch.dict(os.environ, {}, clear=True):  # Clear env vars
            with pytest.raises(ValueError, match="Gemini API key not found"):
                with patch('scripts.gemini_tts.genai') as mock_genai:
                    GeminiTTS()


class TestVoiceValidation:
    """Test voice name validation"""
    
    def test_valid_voice_names_accepted(self):
        """Test that all valid voice names are accepted"""
        # Given
        valid_voices = ["Zephyr", "Puck", "Charon", "Kore", "Uranus", "Fenrir"]
        
        with patch('scripts.gemini_tts.genai') as mock_genai:
            service = GeminiTTS(api_key="test-key")
        
        # When/Then
        for voice in valid_voices:
            # Should not raise an exception
            assert voice in service.AVAILABLE_VOICES
    
    def test_invalid_voice_name_raises_error(self):
        """Test that invalid voice names raise appropriate errors"""
        # Given
        invalid_voice = "InvalidVoice123"
        
        with patch('scripts.gemini_tts.genai') as mock_genai:
            service = GeminiTTS(api_key="test-key")
        
        # When/Then
        with pytest.raises(ValueError, match="Voice 'InvalidVoice123' not available"):
            service.generate_speech("test text", voice_name=invalid_voice)


class TestSingleSpeakerGeneration:
    """Test single speaker audio generation"""
    
    @pytest.fixture
    def mock_service(self):
        """Create service with mocked dependencies"""
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            service = GeminiTTS(api_key="test-key")
            yield service, mock_client
    
    def test_successful_single_speaker_generation(self, mock_service):
        """Test successful single speaker generation"""
        # Given
        service, mock_client = mock_service
        test_text = "Hello, this is a test"
        test_voice = "Zephyr"
        
        # Mock streaming response
        mock_chunk = Mock()
        mock_chunk.candidates = [Mock()]
        mock_chunk.candidates[0].content = Mock()
        mock_chunk.candidates[0].content.parts = [Mock()]
        
        mock_inline_data = Mock()
        mock_inline_data.data = b'fake_audio_data'
        mock_inline_data.mime_type = 'audio/wav'
        mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
        
        mock_client.models.generate_content_stream.return_value = [mock_chunk]
        
        # When
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_audio"
            result = service.generate_speech(
                text=test_text,
                voice_name=test_voice,
                output_file=str(output_file)
            )
        
        # Then
        assert result.endswith('.wav')
        assert Path(result).exists()
        
        # Verify API was called correctly
        mock_client.models.generate_content_stream.assert_called_once()
        call_args = mock_client.models.generate_content_stream.call_args
        
        # Verify request structure
        assert 'model' in call_args.kwargs
        assert 'contents' in call_args.kwargs
        assert 'config' in call_args.kwargs
        
        # Verify content structure
        contents = call_args.kwargs['contents']
        assert len(contents) == 1
        assert contents[0].role == 'user'
        assert len(contents[0].parts) == 1
        assert contents[0].parts[0].text == test_text
    
    def test_single_speaker_with_different_temperatures(self, mock_service):
        """Test generation with different temperature settings"""
        # Given
        service, mock_client = mock_service
        test_text = "Temperature test"
        test_voice = "Puck"
        
        # Test different temperatures
        temperatures = [0.2, 0.5, 0.8, 1.0]
        
        for temp in temperatures:
            # Mock response
            mock_chunk = Mock()
            mock_chunk.candidates = [Mock()]
            mock_chunk.candidates[0].content = Mock()
            mock_chunk.candidates[0].content.parts = [Mock()]
            
            mock_inline_data = Mock()
            mock_inline_data.data = b'audio_data_temp_' + str(temp).encode()
            mock_inline_data.mime_type = 'audio/wav'
            mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
            
            mock_client.models.generate_content_stream.return_value = [mock_chunk]
            
            # When
            with tempfile.TemporaryDirectory() as tmpdir:
                output_file = Path(tmpdir) / f"test_audio_{temp}"
                result = service.generate_speech(
                    text=test_text,
                    voice_name=test_voice,
                    temperature=temp,
                    output_file=str(output_file)
                )
            
            # Then
            assert result.endswith('.wav')
            assert Path(result).exists()
            
            # Verify temperature was used
            call_args = mock_client.models.generate_content_stream.call_args
            config = call_args.kwargs['config']
            # Would verify temperature in config
    
    def test_single_speaker_empty_text_raises_error(self, mock_service):
        """Test that empty text raises appropriate error"""
        # Given
        service, mock_client = mock_service
        empty_text = ""
        
        # When/Then
        with pytest.raises(ValueError, match="Text cannot be empty"):
            service.generate_speech(text=empty_text, voice_name="Zephyr")
        
        # Verify API was not called
        mock_client.models.generate_content_stream.assert_not_called()


class TestMultiSpeakerGeneration:
    """Test multi-speaker audio generation"""
    
    @pytest.fixture
    def mock_service(self):
        """Create service with mocked dependencies"""
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            service = GeminiTTS(api_key="test-key")
            yield service, mock_client
    
    def test_successful_two_speaker_generation(self, mock_service):
        """Test successful two-speaker generation"""
        # Given
        service, mock_client = mock_service
        test_script = """Speaker 1: Hello!
Speaker 2: Hi there!"""
        speaker_configs = [
            {"speaker": "Speaker 1", "voice": "Zephyr"},
            {"speaker": "Speaker 2", "voice": "Puck"}
        ]
        
        # Mock streaming response
        mock_chunk = Mock()
        mock_chunk.candidates = [Mock()]
        mock_chunk.candidates[0].content = Mock()
        mock_chunk.candidates[0].content.parts = [Mock()]
        
        mock_inline_data = Mock()
        mock_inline_data.data = b'multi_speaker_audio_data'
        mock_inline_data.mime_type = 'audio/wav'
        mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
        
        mock_client.models.generate_content_stream.return_value = [mock_chunk]
        
        # When
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_multi_audio"
            result = service.generate_podcast_interview(
                script=test_script,
                speaker_configs=speaker_configs,
                output_file=str(output_file)
            )
        
        # Then
        assert result.endswith('.wav')
        assert Path(result).exists()
        
        # Verify multi-speaker configuration
        call_args = mock_client.models.generate_content_stream.call_args
        config = call_args.kwargs['config']
        
        # Verify multi-speaker voice config was used
        assert hasattr(config, 'speech_config')
        assert hasattr(config.speech_config, 'multi_speaker_voice_config')
        
        speaker_configs = config.speech_config.multi_speaker_voice_config.speaker_voice_configs
        assert len(speaker_configs) == 2
        assert speaker_configs[0].speaker == "Speaker 1"
        assert speaker_configs[1].speaker == "Speaker 2"
    
    def test_three_speaker_generation(self, mock_service):
        """Test three-speaker generation"""
        # Given
        service, mock_client = mock_service
        test_script = """Host: Welcome!
Expert 1: Thank you!
Expert 2: Great to be here!"""
        
        speaker_configs = [
            {"speaker": "Host", "voice": "Zephyr"},
            {"speaker": "Expert 1", "voice": "Kore"},
            {"speaker": "Expert 2", "voice": "Charon"}
        ]
        
        # Mock response
        mock_chunk = Mock()
        mock_chunk.candidates = [Mock()]
        mock_chunk.candidates[0].content = Mock()
        mock_chunk.candidates[0].content.parts = [Mock()]
        
        mock_inline_data = Mock()
        mock_inline_data.data = b'three_speaker_audio'
        mock_inline_data.mime_type = 'audio/wav'
        mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
        
        mock_client.models.generate_content_stream.return_value = [mock_chunk]
        
        # When
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_three_speaker"
            result = service.generate_podcast_interview(
                script=test_script,
                speaker_configs=speaker_configs,
                output_file=str(output_file)
            )
        
        # Then
        assert result.endswith('.wav')
        assert Path(result).exists()
        
        # Verify three speakers configured
        call_args = mock_client.models.generate_content_stream.call_args
        config = call_args.kwargs['config']
        speaker_configs = config.speech_config.multi_speaker_voice_config.speaker_voice_configs
        assert len(speaker_configs) == 3
    
    def test_invalid_speaker_config_raises_error(self, mock_service):
        """Test that invalid speaker configuration raises error"""
        # Given
        service, mock_client = mock_service
        test_script = """Speaker 1: Hello!"""
        
        # Missing speaker field
        invalid_configs = [
            {"voice": "Zephyr"}  # Missing "speaker" field
        ]
        
        # When/Then
        with pytest.raises(ValueError, match="Each speaker config must have a 'speaker' field"):
            service.generate_podcast_interview(
                script=test_script,
                speaker_configs=invalid_configs
            )
        
        # Verify API was not called
        mock_client.models.generate_content_stream.assert_not_called()
    
    def test_invalid_voice_in_speaker_config_raises_error(self, mock_service):
        """Test that invalid voice names in speaker config raise errors"""
        # Given
        service, mock_client = mock_service
        test_script = """Speaker 1: Hello!"""
        
        invalid_configs = [
            {"speaker": "Speaker 1", "voice": "InvalidVoice"}
        ]
        
        # When/Then
        with pytest.raises(ValueError, match="Voice 'InvalidVoice' not available"):
            service.generate_podcast_interview(
                script=test_script,
                speaker_configs=invalid_configs
            )
        
        # Verify API was not called
        mock_client.models.generate_content_stream.assert_not_called()


class TestAudioProcessing:
    """Test audio file processing and format conversion"""
    
    @pytest.fixture
    def mock_service(self):
        """Create service with mocked dependencies"""
        with patch('scripts.gemini_tts.genai'):
            service = GeminiTTS(api_key="test-key")
            yield service
    
    def test_wav_conversion_from_raw_audio(self, mock_service):
        """Test WAV conversion from raw audio data"""
        # Given
        raw_audio_data = b'raw_audio_data_123'
        mime_type = "audio/L16;rate=24000"
        
        # When
        wav_data = mock_service._convert_to_wav(raw_audio_data, mime_type)
        
        # Then
        assert isinstance(wav_data, bytes)
        assert len(wav_data) > len(raw_audio_data)  # Should include WAV header
        
        # Verify WAV header structure
        assert wav_data[:4] == b'RIFF'  # RIFF header
        assert wav_data[8:12] == b'WAVE'  # WAVE format
        assert wav_data[12:16] == b'fmt '  # fmt chunk
        assert wav_data[36:40] == b'data'  # data chunk
    
    def test_wav_conversion_preserves_audio_data(self, mock_service):
        """Test that WAV conversion preserves original audio data"""
        # Given
        raw_audio_data = b'test_audio_data_456'
        mime_type = "audio/L16;rate=24000"
        
        # When
        wav_data = mock_service._convert_to_wav(raw_audio_data, mime_type)
        
        # Then
        # Extract audio data from WAV (after header)
        header_size = 44  # Standard WAV header size
        extracted_audio = wav_data[header_size:]
        
        assert extracted_audio == raw_audio_data
    
    def test_mime_type_parsing(self, mock_service):
        """Test MIME type parameter parsing"""
        # Given/When/Then
        mime_type_16bit = "audio/L16;rate=24000"
        params_16bit = mock_service._parse_audio_mime_type(mime_type_16bit)
        assert params_16bit["bits_per_sample"] == 16
        assert params_16bit["rate"] == 24000
        
        # Test different bit depths
        mime_type_8bit = "audio/L8;rate=16000"
        params_8bit = mock_service._parse_audio_mime_type(mime_type_8bit)
        assert params_8bit["bits_per_sample"] == 8
        assert params_8bit["rate"] == 16000
        
        # Test default values
        mime_type_no_params = "audio/wav"
        params_default = mock_service._parse_audio_mime_type(mime_type_no_params)
        assert params_default["bits_per_sample"] == 16  # Default
        assert params_default["rate"] == 24000  # Default
    
    def test_audio_file_saving_with_wav_format(self, mock_service):
        """Test saving audio data to file with WAV format"""
        # Given
        audio_data_b64 = base64.b64encode(b'test_audio_content').decode()
        mime_type = "audio/wav"
        
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_audio"
            
            # When
            result = mock_service.save_audio_file(
                str(output_file), 
                base64.b64decode(audio_data_b64), 
                mime_type
            )
            
            # Then
            assert result.endswith('.wav')
            assert Path(result).exists()
            
            # Verify file content
            with open(result, 'rb') as f:
                content = f.read()
            assert content == b'test_audio_content'
    
    def test_audio_file_saving_with_conversion(self, mock_service):
        """Test saving audio data with format conversion"""
        # Given
        raw_audio_data = b'raw_audio_content'
        audio_data_b64 = base64.b64encode(raw_audio_data).decode()
        mime_type = "audio/L16;rate=24000"
        
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_audio"
            
            # When
            result = mock_service.save_audio_file(
                str(output_file), 
                base64.b64decode(audio_data_b64), 
                mime_type
            )
            
            # Then
            assert result.endswith('.wav')
            assert Path(result).exists()
            
            # Verify WAV format (should have header)
            with open(result, 'rb') as f:
                content = f.read()
            assert content.startswith(b'RIFF')
            assert len(content) > len(raw_audio_data)  # Header added


class TestErrorHandlingAndResilience:
    """Test error handling and resilience patterns"""
    
    @pytest.fixture
    def mock_service(self):
        """Create service with mocked dependencies"""
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            service = GeminiTTS(api_key="test-key")
            yield service, mock_client
    
    def test_api_rate_limit_handling(self, mock_service):
        """Test handling of API rate limits"""
        # Given
        service, mock_client = mock_service
        
        # Mock rate limit exception
        from google.api_core.exceptions import ResourceExhausted
        mock_client.models.generate_content_stream.side_effect = ResourceExhausted("429 Rate limit exceeded")
        
        # When/Then
        with pytest.raises(ResourceExhausted) as exc_info:
            service.generate_speech("test text", voice_name="Zephyr")
        
        assert "429" in str(exc_info.value) or "ResourceExhausted" in str(exc_info.value)
    
    def test_network_timeout_handling(self, mock_service):
        """Test handling of network timeouts"""
        # Given
        service, mock_client = mock_service
        
        # Mock timeout exception
        from google.api_core.exceptions import DeadlineExceeded
        mock_client.models.generate_content_stream.side_effect = DeadlineExceeded("504 Deadline exceeded")
        
        # When/Then
        with pytest.raises(DeadlineExceeded):
            service.generate_speech("test text", voice_name="Zephyr")
    
    def test_invalid_api_key_handling(self, mock_service):
        """Test handling of invalid API key"""
        # Given
        service, mock_client = mock_service
        
        # Mock authentication error
        from google.auth.exceptions import InvalidValue
        mock_client.models.generate_content_stream.side_effect = InvalidValue("Invalid API key")
        
        # When/Then
        with pytest.raises(InvalidValue):
            service.generate_speech("test text", voice_name="Zephyr")
    
    def test_malformed_response_handling(self, mock_service):
        """Test handling of malformed API responses"""
        # Given
        service, mock_client = mock_service
        
        # Mock malformed response
        mock_chunk = Mock()
        mock_chunk.candidates = None  # Malformed response
        mock_client.models.generate_content_stream.return_value = [mock_chunk]
        
        # When
        with tempfile.TemporaryDirectory() as tmpdir:
            output_file = Path(tmpdir) / "test_audio"
            
            # Should handle gracefully
            with pytest.raises(RuntimeError, match="No audio data generated"):
                service.generate_speech(
                    text="test text",
                    voice_name="Zephyr",
                    output_file=str(output_file)
                )


if __name__ == "__main__":
    pytest.main([__file__, "-v"])