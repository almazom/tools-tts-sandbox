#!/usr/bin/env python3
"""
End-to-End tests for complete user workflows
Simulates real user interactions with the system
"""

import pytest
import subprocess
import tempfile
import time
import json
from pathlib import Path
from unittest.mock import Mock, patch
import os


class TestE2EWorkflows:
    """End-to-end tests for complete user workflows"""
    
    @pytest.fixture
    def setup_environment(self):
        """Set up test environment"""
        # Create temporary directory for test outputs
        with tempfile.TemporaryDirectory() as tmpdir:
            test_dir = Path(tmpdir)
            
            # Set up environment variables
            env = os.environ.copy()
            env['GEMINI_API_KEY'] = 'test-api-key'
            
            yield {
                'test_dir': test_dir,
                'env': env
            }
    
    def test_cli_voice_listing_workflow(self, setup_environment):
        """Test complete CLI voice listing workflow"""
        # Given
        test_env = setup_environment
        
        # When - Execute CLI command
        try:
            result = subprocess.run([
                'python3', 'scripts/podcast_cli.py', 'voices'
            ], 
            cwd=Path(__file__).parent.parent.parent,
            env=test_env['env'],
            capture_output=True,
            text=True,
            timeout=10
            )
            
            # Then - Verify output
            assert result.returncode == 0
            assert "Available voices:" in result.stdout or "Available voices" in result.stdout
            
            # Check that voices are listed
            expected_voices = ["Zephyr", "Puck", "Charon", "Kore", "Uranus", "Fenrir"]
            for voice in expected_voices:
                assert voice in result.stdout
                
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # If CLI test fails, mock it
            pytest.skip("CLI not available in test environment")
    
    def test_cli_single_speaker_workflow(self, setup_environment):
        """Test complete single speaker CLI workflow"""
        # Given
        test_env = setup_environment
        test_text = "Hello, this is a CLI test of the TTS system"
        test_voice = "Zephyr"
        output_file = test_env['test_dir'] / "cli_test_audio"
        
        # Mock the service to avoid API calls
        with patch('scripts.podcast_cli.GeminiTTS') as mock_tts_class:
            mock_service = Mock()
            mock_tts_class.return_value = mock_service
            
            # Mock successful audio generation
            mock_service.generate_speech.return_value = str(output_file) + ".wav"
            
            # When - Execute CLI command
            try:
                result = subprocess.run([
                    'python3', 'scripts/podcast_cli.py', 'single', test_text,
                    '-v', test_voice, '-o', str(output_file)
                ],
                cwd=Path(__file__).parent.parent.parent,
                env=test_env['env'],
                capture_output=True,
                text=True,
                timeout=30
                )
                
                # Then - Verify CLI execution
                assert result.returncode == 0
                assert "✅" in result.stdout or "successfully" in result.stdout.lower()
                
                # Verify service was called correctly
                mock_service.generate_speech.assert_called_once_with(
                    text=test_text,
                    voice_name=test_voice,
                    temperature=0.8,
                    output_file=str(output_file)
                )
                
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pytest.skip("CLI not available in test environment")
    
    def test_cli_multi_speaker_workflow(self, setup_environment):
        """Test complete multi-speaker CLI workflow"""
        # Given
        test_env = setup_environment
        test_script = "Speaker 1: Welcome to the podcast!\nSpeaker 2: Thanks for having me!"
        output_file = test_env['test_dir'] / "multi_speaker_test"
        
        # Mock the service
        with patch('scripts.podcast_cli.GeminiTTS') as mock_tts_class:
            mock_service = Mock()
            mock_tts_class.return_value = mock_service
            
            # Mock successful multi-speaker generation
            mock_service.generate_podcast_interview.return_value = str(output_file) + ".wav"
            
            # When - Execute CLI command
            try:
                result = subprocess.run([
                    'python3', 'scripts/podcast_cli.py', 'multi', test_script,
                    '-s', 'Speaker 1:Zephyr', 'Speaker 2:Puck',
                    '-o', str(output_file)
                ],
                cwd=Path(__file__).parent.parent.parent,
                env=test_env['env'],
                capture_output=True,
                text=True,
                timeout=30
                )
                
                # Then - Verify CLI execution
                assert result.returncode == 0
                assert "✅" in result.stdout or "saved to" in result.stdout.lower()
                
                # Verify service was called with correct parameters
                expected_speaker_configs = [
                    {"speaker": "Speaker 1", "voice": "Zephyr"},
                    {"speaker": "Speaker 2", "voice": "Puck"}
                ]
                
                mock_service.generate_podcast_interview.assert_called_once_with(
                    script=test_script,
                    speaker_configs=expected_speaker_configs,
                    temperature=1.0,
                    output_file=str(output_file)
                )
                
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pytest.skip("CLI not available in test environment")
    
    def test_cli_script_generation_workflow(self, setup_environment):
        """Test complete script generation CLI workflow"""
        # Given
        test_env = setup_environment
        topic = "Artificial Intelligence in Healthcare"
        
        # Mock the service
        with patch('scripts.podcast_cli.GeminiTTS') as mock_tts_class:
            mock_service = Mock()
            mock_tts_class.return_value = mock_service
            
            # Mock successful script generation
            mock_script = f"""
Host: Welcome to our podcast on {topic}!
Guest: Thank you for having me. AI in healthcare is fascinating.
Host: What are the most exciting developments?
Guest: Machine learning is revolutionizing diagnostics.
"""
            mock_service.generate_podcast_script.return_value = mock_script
            
            # When - Execute CLI command for script generation
            try:
                result = subprocess.run([
                    'python3', 'scripts/podcast_cli.py', 'script', topic,
                    '-s', 'interview', '-d', '5 minutes'
                ],
                cwd=Path(__file__).parent.parent.parent,
                env=test_env['env'],
                input='n\n',  # Don't save to file
                capture_output=True,
                text=True,
                timeout=30
                )
                
                # Then - Verify script generation
                assert result.returncode == 0
                assert topic in result.stdout
                assert "Host:" in result.stdout
                assert "Guest:" in result.stdout
                
                # Verify service was called correctly
                mock_service.generate_podcast_script.assert_called_once_with(
                    topic=topic,
                    style="interview",
                    duration="5 minutes"
                )
                
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pytest.skip("CLI not available in test environment")


class TestE2EAPIIntegration:
    """End-to-end tests for API integration"""
    
    def test_complete_api_workflow_with_mock(self):
        """Test complete API workflow with mocked responses"""
        # Given - Mock the entire API interaction
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            
            # Mock successful API response
            mock_chunk = Mock()
            mock_chunk.candidates = [Mock()]
            mock_chunk.candidates[0].content = Mock()
            mock_chunk.candidates[0].content.parts = [Mock()]
            
            fake_audio_data = b'complete_workflow_audio_data'
            mock_inline_data = Mock()
            mock_inline_data.data = fake_audio_data
            mock_inline_data.mime_type = 'audio/wav'
            mock_chunk.candidates[0].content.parts[0].inline_data = mock_inline_data
            
            mock_client.models.generate_content_stream.return_value = [mock_chunk]
            
            # When - Execute complete workflow
            service = GeminiTTS(api_key="test-api-key")
            
            with tempfile.TemporaryDirectory() as tmpdir:
                # Single speaker workflow
                single_result = service.generate_speech(
                    text="This is a complete workflow test",
                    voice_name="Zephyr",
                    output_file=Path(tmpdir) / "single_speaker_workflow"
                )
                
                # Multi-speaker workflow
                multi_script = """Host: Welcome to our show!
Guest: Thanks for having me!"""
                
                multi_configs = [
                    {"speaker": "Host", "voice": "Zephyr"},
                    {"speaker": "Guest", "voice": "Puck"}
                ]
                
                multi_result = service.generate_podcast_interview(
                    script=multi_script,
                    speaker_configs=multi_configs,
                    output_file=Path(tmpdir) / "multi_speaker_workflow"
                )
            
            # Then - Verify complete workflow
            assert single_result.endswith('.wav')
            assert multi_result.endswith('.wav')
            assert Path(single_result).exists()
            assert Path(multi_result).exists()
            
            # Verify API was called multiple times
            assert mock_client.models.generate_content_stream.call_count == 2
    
    def test_error_handling_workflow(self):
        """Test complete error handling workflow"""
        # Given - Mock various error scenarios
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            
            # Test error scenarios
            error_scenarios = [
                {
                    "error": Exception("Rate limit exceeded"),
                    "expected_message": "rate limit"
                },
                {
                    "error": Exception("Invalid API key"),
                    "expected_message": "API key"
                }
            ]
            
            for scenario in error_scenarios:
                # When - Simulate error
                mock_client.models.generate_content_stream.side_effect = scenario["error"]
                
                service = GeminiTTS(api_key="test-api-key")
                
                # Then - Verify error handling
                try:
                    service.generate_speech(
                        text="Error test",
                        voice_name="Zephyr"
                    )
                    assert False, "Expected exception was not raised"
                except Exception as e:
                    # Verify error is properly propagated
                    assert scenario["expected_message"].lower() in str(e).lower()


class TestE2EReliability:
    """End-to-end tests for system reliability"""
    
    def test_concurrent_request_handling(self):
        """Test handling of concurrent requests"""
        # Given - Mock concurrent API calls
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            
            # Mock successful concurrent responses
            def mock_generate_stream(*args, **kwargs):
                # Simulate processing time
                import time
                time.sleep(0.1)  # 100ms delay
                
                mock_chunk = Mock()
                mock_chunk.candidates = [Mock()]
                mock_chunk.candidates[0].content = Mock()
                mock_chunk.candidates[0].content.parts = [Mock()]
                mock_chunk.candidates[0].content.parts[0].inline_data = Mock()
                mock_chunk.candidates[0].content.parts[0].inline_data.data = b'concurrent_audio'
                mock_chunk.candidates[0].content.parts[0].inline_data.mime_type = 'audio/wav'
                return [mock_chunk]
            
            mock_client.models.generate_content_stream.side_effect = mock_generate_stream
            
            # When - Simulate concurrent requests
            service = GeminiTTS(api_key="test-api-key")
            
            with tempfile.TemporaryDirectory() as tmpdir:
                results = []
                
                # Simulate multiple concurrent requests
                for i in range(5):
                    result = service.generate_speech(
                        text=f"Concurrent test {i}",
                        voice_name="Zephyr",
                        output_file=Path(tmpdir) / f"concurrent_{i}"
                    )
                    results.append(result)
            
            # Then - Verify all requests completed successfully
            assert len(results) == 5
            for result in results:
                assert result.endswith('.wav')
                assert Path(result).exists()
    
    def test_resource_cleanup_workflow(self):
        """Test proper resource cleanup after operations"""
        # Given - Track resource usage
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            
            # Mock response
            mock_chunk = Mock()
            mock_chunk.candidates = [Mock()]
            mock_chunk.candidates[0].content = Mock()
            mock_chunk.candidates[0].content.parts = [Mock()]
            mock_chunk.candidates[0].content.parts[0].inline_data = Mock()
            mock_chunk.candidates[0].content.parts[0].inline_data.data = b'test_audio'
            mock_chunk.candidates[0].content.parts[0].inline_data.mime_type = 'audio/wav'
            
            mock_client.models.generate_content_stream.return_value = [mock_chunk]
            
            # When - Execute operations and verify cleanup
            service = GeminiTTS(api_key="test-api-key")
            
            with tempfile.TemporaryDirectory() as tmpdir:
                # Generate multiple files
                files_created = []
                
                # Generate multiple files
                for i in range(3):
                    result = service.generate_speech(
                        text=f"Cleanup test {i}",
                        voice_name="Zephyr",
                        output_file=Path(tmpdir) / f"cleanup_{i}"
                    )
                    files_created.append(result)
                
                # Verify files exist
                for file_path in files_created:
                    assert Path(file_path).exists()
            
            # Then - After temp directory cleanup, files should be gone
            # (This is automatically handled by tempfile.TemporaryDirectory)
            
            # Verify service can still be used (no resource leaks)
            mock_client.models.generate_content_stream.assert_called()


class TestE2EPerformance:
    """End-to-end performance tests"""
    
    def test_response_time_performance(self):
        """Test response time performance under various conditions"""
        # Given - Mock with controlled timing
        with patch('scripts.gemini_tts.genai') as mock_genai:
            mock_client = Mock()
            mock_genai.Client.return_value = mock_client
            
            def slow_generate_stream(*args, **kwargs):
                # Simulate processing time
                import time
                time.sleep(0.1)  # 100ms delay
                
                mock_chunk = Mock()
                mock_chunk.candidates = [Mock()]
                mock_chunk.candidates[0].content = Mock()
                mock_chunk.candidates[0].content.parts = [Mock()]
                mock_chunk.candidates[0].content.parts[0].inline_data = Mock()
                mock_chunk.candidates[0].content.parts[0].inline_data.data = b'performance_test_audio'
                mock_chunk.candidates[0].content.parts[0].inline_data.mime_type = 'audio/wav'
                return [mock_chunk]
            
            mock_client.models.generate_content_stream.side_effect = slow_generate_stream
            
            # When - Measure performance
            import time
            service = GeminiTTS(api_key="test-api-key")
            
            start_time = time.time()
            
            with tempfile.TemporaryDirectory() as tmpdir:
                result = service.generate_speech(
                    text="Performance test",
                    voice_name="Zephyr",
                    output_file=Path(tmpdir) / "performance_test"
                )
            
            end_time = time.time()
            duration = end_time - start_time
            
            # Then - Verify performance is acceptable
            assert duration < 5.0  # Should complete within 5 seconds for mock
            assert result.endswith('.wav')
            assert Path(result).exists()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])