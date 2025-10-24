Feature: Single Speaker Text-to-Speech Generation
  As a content creator
  I want to convert text to speech with different voices
  So that I can create audio content with various vocal styles

  Background:
    Given the Gemini TTS service is available
    And I have a valid API key
    And the audio output directory exists

  @critical @happy-path
  Scenario: Generate speech with default voice
    Given I have the text "Hello, welcome to our podcast!"
    When I generate single speaker audio with voice "Zephyr"
    Then the audio file should be created successfully
    And the audio file should have a .wav extension
    And the audio duration should be appropriate for the text length

  @critical @happy-path
  Scenario: Generate speech with different voices
    Given I have the text "Technology is changing our world every day."
    When I generate single speaker audio with voice "Puck"
    Then the audio file should be created successfully
    And the audio should be clear and understandable
    And the voice should sound natural and engaging

  @critical @voice-variety
  Scenario Outline: Test all available voices
    Given I have the text "This is a test of the Gemini TTS system."
    When I generate single speaker audio with voice "<voice>"
    Then the audio file should be created successfully
    And the audio quality should be acceptable

    Examples:
      | voice   |
      | Zephyr  |
      | Puck    |
      | Charon  |
      | Kore    |
      | Uranus  |
      | Fenrir  |

  @temperature-variation
  Scenario Outline: Test different temperature settings
    Given I have the text "The weather today is quite interesting."
    When I generate single speaker audio with voice "Zephyr" and temperature "<temp>"
    Then the audio file should be created successfully
    And the speech should reflect the temperature setting

    Examples:
      | temp  | expected_style           |
      | 0.2   | more predictable         |
      | 0.5   | balanced                 |
      | 0.8   | natural                  |
      | 1.0   | more varied              |

  @edge-cases @validation
  Scenario: Handle empty text input
    Given I have empty text ""
    When I attempt to generate single speaker audio
    Then the system should return an appropriate error
    And the error message should be "Text cannot be empty"

  @edge-cases @validation
  Scenario: Handle invalid voice name
    Given I have the text "Hello world"
    When I attempt to generate audio with voice "InvalidVoice"
    Then the system should return a validation error
    And the error should list available voices

  @edge-cases @long-text
  Scenario: Handle very long text input
    Given I have text with 5000 characters
    When I generate single speaker audio with voice "Zephyr"
    Then the audio file should be created successfully
    And the system should handle the long text gracefully

  @error-handling @resilience
  Scenario: Handle API rate limiting
    Given I have the text "Testing rate limits"
    When I exceed the API rate limit and generate audio
    Then the system should handle the 429 error gracefully
    And provide a meaningful error message about rate limits
    And suggest checking billing settings

  @error-handling @resilience
  Scenario: Handle network timeout
    Given I have the text "Network test"
    When the API request times out
    Then the system should retry the request
    And if still failing, provide a timeout error message

  @error-handling @resilience
  Scenario: Handle invalid API key
    Given I have an invalid API key
    When I attempt to generate audio
    Then the system should return an authentication error
    And provide instructions for setting up a valid API key

  @performance @acceptance
  Scenario: Performance acceptance criteria
    Given I have typical podcast intro text (50-100 words)
    When I generate single speaker audio
    Then the response time should be less than 30 seconds
    And the audio file should be generated successfully
    And the audio quality should be clear and professional

  @output-validation @file-handling
  Scenario: Verify audio file properties
    Given I have the text "Audio properties test"
    When I generate single speaker audio with voice "Zephyr"
    Then the audio file should exist
    And the file should not be empty
    And the file should have proper WAV headers
    And the file should be playable by standard audio players