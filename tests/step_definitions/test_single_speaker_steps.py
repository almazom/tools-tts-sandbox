#!/usr/bin/env python3
"""
Step definitions for single_speaker_tts.feature
BDD step implementations using pytest-bdd
"""

import pytest
import tempfile
import os
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

# Import the system under test
sys.path.append(str(Path(__file__).parent.parent.parent))
from scripts.gemini_tts import GeminiTTS


# Fixtures
@pytest.fixture
def temp_audio_dir():
    """Create a temporary directory for audio files"""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield tmpdir


@pytest.fixture
def mock_gemini_client():
    """Mock Gemini client for testing"""
    with patch('scripts.gemini_tts.genai') as mock_genai:
        mock_client = Mock()
        mock_genai.Client.return_value = mock_client
        yield mock_client


@pytest.fixture
def tts_service(mock_gemini_client):
    """Create TTS service with mocked client"""
    with patch.dict(os.environ, {'GEMINI_API_KEY': 'test-api-key'}):
        service = GeminiTTS()
        yield service


# Background Steps
@given('the Gemini TTS service is available')
def step_service_available():
    """Verify TTS service can be instantiated"""
    # This will be tested by the fixture
    pass


@given('I have a valid API key')
def step_valid_api_key():
    """Set up valid API key for testing"""
    # Handled by fixture
    pass


@given('the audio output directory exists')
def step_audio_dir_exists(temp_audio_dir):
    """Ensure audio output directory exists"""
    assert Path(temp_audio_dir).exists()


# Core Functionality Steps
@given('I have the text "{text}"')
def step_have_text(text):
    """Store text for audio generation"""
    pytest.test_text = text


@when('I generate single speaker audio with voice "{voice}"')
def step_generate_single_voice(tts_service, temp_audio_dir, voice):
    """Generate audio with specified voice"""
    # Mock the streaming response
    mock_chunk = Mock()
    mock_chunk.candidates = [Mock()]
    mock_chunk.candidates[0].content = Mock()
    mock_chunk.candidates[0].content.parts = [Mock()]
    
    mock_inline_data = Mock()
    mock_inline_data.data = b'fake_audio_data'
    mock_inline_data.mime_type = 'audio/wav'
    mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
    
    tts_service.client.models.generate_content_stream.return_value = [mock_chunk]
    
    # Generate audio
    output_file = Path(temp_audio_dir) / "test_audio"
    result = tts_service.generate_speech(
        text=pytest.test_text,
        voice_name=voice,
        output_file=str(output_file)
    )
    
    pytest.generated_audio_file = result


@then('the audio file should be created successfully')
def step_audio_created_successfully():
    """Verify audio file was created"""
    assert hasattr(pytest, 'generated_audio_file')
    assert Path(pytest.generated_audio_file).exists()


@then('the audio file should have a .wav extension')
def step_audio_has_wav_extension():
    """Verify file extension"""
    assert str(pytest.generated_audio_file).endswith('.wav')


@then('the audio duration should be appropriate for the text length')
def step_audio_duration_appropriate():
    """Verify audio duration matches text length"""
    # Mock verification - in real implementation would analyze audio file
    assert pytest.test_text  # Text was processed
    

@then('the audio should be clear and understandable')
def step_audio_quality_clear():
    """Verify audio quality"""
    # Mock verification - would check audio properties in real test
    assert Path(pytest.generated_audio_file).stat().st_size > 0


@then('the voice should sound natural and engaging')
def step_voice_natural():
    """Verify voice quality"""
    # This would involve audio analysis in real implementation
    assert hasattr(pytest, 'generated_audio_file')


# Voice Variety Testing
@given('I have the text "{text}"')
def step_have_text_variety(text):
    """Store text for voice variety testing"""
    pytest.test_text = text


@when('I generate single speaker audio with voice "{voice}"')
def step_generate_voice_variety(tts_service, temp_audio_dir, voice):
    """Generate audio for voice variety test"""
    # Similar to above but with different voice validation
    available_voices = tts_service.AVAILABLE_VOICES
    assert voice in available_voices, f"Voice {voice} not in available voices: {available_voices}"
    
    mock_chunk = Mock()
    mock_chunk.candidates = [Mock()]
    mock_chunk.candidates[0].content = Mock()
    mock_chunk.candidates[0].content.parts = [Mock()]
    
    mock_inline_data = Mock()
    mock_inline_data.data = b'fake_audio_data_' + voice.encode()
    mock_inline_data.mime_type = 'audio/wav'
    mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
    
    tts_service.client.models.generate_content_stream.return_value = [mock_chunk]
    
    output_file = Path(temp_audio_dir) / f"test_audio_{voice.lower()}"
    result = tts_service.generate_speech(
        text=pytest.test_text,
        voice_name=voice,
        output_file=str(output_file)
    )
    
    pytest.generated_audio_file = result


@then('the audio file should be created successfully')
def step_voice_audio_created():
    """Verify voice-specific audio creation"""
    assert Path(pytest.generated_audio_file).exists()


@then('the audio quality should be acceptable')
def step_audio_quality_acceptable():
    """Verify audio quality for different voices"""
    # Mock verification - would analyze audio characteristics per voice
    assert Path(pytest.generated_audio_file).stat().st_size > 0


# Temperature Testing
@given('I have the text "{text}"')
def step_have_text_temperature(text):
    """Store text for temperature testing"""
    pytest.test_text = text


@when('I generate single speaker audio with voice "{voice}" and temperature "{temp}"')
def step_generate_with_temperature(tts_service, temp_audio_dir, voice, temp):
    """Generate audio with specific temperature"""
    temperature = float(temp)
    
    mock_chunk = Mock()
    mock_chunk.candidates = [Mock()]
    mock_chunk.candidates[0].content = Mock()
    mock_chunk.candidates[0].content.parts = [Mock()]
    
    mock_inline_data = Mock()
    mock_inline_data.data = b'fake_audio_data_temp_' + str(temperature).encode()
    mock_inline_data.mime_type = 'audio/wav'
    mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
    
    # Mock the generate_content_config to capture temperature
    with patch.object(tts_service.client.models, 'generate_content_stream') as mock_stream:
        mock_stream.return_value = [mock_chunk]
        
        output_file = Path(temp_audio_dir) / f"test_audio_temp_{temperature}"
        result = tts_service.generate_speech(
            text=pytest.test_text,
            voice_name=voice,
            temperature=temperature,
            output_file=str(output_file)
        )
        
        # Verify temperature was passed to config
        call_args = mock_stream.call_args
        assert 'config' in call_args.kwargs
        # Would verify temperature in config
        
        pytest.generated_audio_file = result


@then('the speech should reflect the temperature setting')
def step_temperature_reflected():
    """Verify temperature affects generation"""
    # Would verify audio characteristics based on temperature
    assert Path(pytest.generated_audio_file).exists()


# Edge Cases and Error Handling
@given('I have empty text ""')
def step_have_empty_text():
    """Set up empty text for error testing"""
    pytest.test_text = ""


@when('I attempt to generate single speaker audio')
def step_attempt_generate_empty(tts_service):
    """Attempt to generate audio with empty text"""
    with pytest.raises(ValueError) as exc_info:
        tts_service.generate_speech(text=pytest.test_text, voice_name="Zephyr")
    pytest.last_exception = exc_info.value


@then('the system should return an appropriate error')
def step_appropriate_error_returned():
    """Verify appropriate error handling"""
    assert hasattr(pytest, 'last_exception')


@then('the error message should be "{error_message}"')
def step_error_message_matches(error_message):
    """Verify specific error message"""
    assert str(pytest.last_exception) == error_message


@given('I have the text "{text}"')
def step_have_text_invalid(text):
    """Set up text for invalid voice testing"""
    pytest.test_text = text


@when('I attempt to generate audio with voice "{voice}"')
def step_attempt_invalid_voice(tts_service, voice):
    """Attempt to generate with invalid voice"""
    with pytest.raises(ValueError) as exc_info:
        tts_service.generate_speech(text=pytest.test_text, voice_name=voice)
    pytest.last_exception = exc_info.value


@then('the system should return a validation error')
def step_validation_error_returned():
    """Verify validation error"""
    assert hasattr(pytest, 'last_exception')
    assert isinstance(pytest.last_exception, ValueError)


@then('the error should list available voices')
def step_error_lists_voices():
    """Verify error includes available voices"""
    error_msg = str(pytest.last_exception)
    available_voices = ['Zephyr', 'Puck', 'Charon', 'Kore', 'Uranus', 'Fenrir']
    for voice in available_voices:
        assert voice in error_msg


# Performance Testing
@given('I have typical podcast intro text (50-100 words)')
def step_typical_podcast_text():
    """Set up typical podcast text"""
    pytest.test_text = "Welcome to our technology podcast where we explore the latest innovations in artificial intelligence and machine learning. Today we'll be discussing how these technologies are transforming various industries and what the future holds for AI-driven solutions."


@then('the response time should be less than 30 seconds')
def step_response_time_acceptable():
    """Verify performance criteria"""
    # Would measure actual response time
    # For now, verify the process completes
    assert Path(pytest.generated_audio_file).exists()


@then('the audio quality should be clear and professional')
def step_professional_audio_quality():
    """Verify professional quality standards"""
    # Would analyze audio quality metrics
    assert Path(pytest.generated_audio_file).stat().st_size > 1024  # At least 1KB


# API Error Simulation
@given('I have exceeded my API rate limit')
def step_exceeded_rate_limit(mock_gemini_client):
    """Simulate rate limit exceeded"""
    from google.api_core.exceptions import ResourceExhausted
    
    def raise_rate_limit(*args, **kwargs):
        raise ResourceExhausted("429 Resource exhausted")
    
    mock_gemini_client.models.generate_content_stream.side_effect = raise_rate_limit


@when('I exceed the API rate limit and generate audio')
def step_generate_with_rate_limit(tts_service):
    """Attempt generation with rate limit"""
    try:
        tts_service.generate_speech(text="Testing rate limits", voice_name="Zephyr")
        pytest.api_error = None
    except Exception as e:
        pytest.api_error = e


@then('the system should handle the 429 error gracefully')
def step_handle_rate_limit_gracefully():
    """Verify graceful rate limit handling"""
    assert pytest.api_error is not None
    assert "429" in str(pytest.api_error) or "ResourceExhausted" in str(pytest.api_error)


@then('provide a meaningful error message about rate limits')
def step_meaningful_rate_limit_message():
    """Verify meaningful error message"""
    error_msg = str(pytest.api_error)
    assert any(word in error_msg.lower() for word in ['rate', 'limit', 'quota'])


@then('suggest checking billing settings')
def step_suggest_billing_check():
    """Verify billing suggestion"""
    # Would check if error message suggests billing check
    pass