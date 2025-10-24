Feature: Multi-Speaker Podcast Generation
  As a podcaster
  I want to create conversations between multiple speakers with different voices
  So that I can produce engaging podcast episodes

  Background:
    Given the Gemini TTS service is available
    And I have a valid API key
    And the multi-speaker functionality is enabled

  @critical @happy-path
  Scenario: Generate two-speaker interview
    Given I have the following script:
      """
      Speaker 1: Welcome to Tech Talks! Today we're discussing AI.
      Speaker 2: Thanks for having me! AI is fascinating field.
      """
    When I generate multi-speaker audio with:
      | Speaker 1 | Zephyr |
      | Speaker 2 | Puck   |
    Then the audio file should be created successfully
    And the conversation should flow naturally
    And each speaker should have a distinct voice

  @critical @happy-path
  Scenario: Generate three-speaker panel discussion
    Given I have the following script:
      """
      Host: Welcome to our panel discussion on climate change.
      Expert 1: The data shows concerning trends in global temperatures.
      Expert 2: We need immediate action to address these challenges.
      """
    When I generate multi-speaker audio with:
      | Host     | Zephyr |
      | Expert 1 | Kore   |
      | Expert 2 | Charon |
    Then the audio file should be created successfully
    And all three voices should be distinguishable
    And the audio quality should be consistent

  @critical @conversation-flow
  Scenario Outline: Test natural conversation patterns
    Given I have a <conversation_type> script
    When I generate multi-speaker audio with appropriate voices
    Then the conversation should sound natural
    And speaker transitions should be smooth

    Examples:
      | conversation_type |
      | interview         |
      | debate            |
      | casual_discussion |
      | news_reporting    |
      | educational       |

  @speaker-label-validation
  Scenario: Handle various speaker label formats
    Given I have the following script with different label formats:
      """
      HOST: Welcome everyone!
      Guest 1: Thank you for having me.
      [Expert]: It's great to be here.
      """
    When I configure speakers with:
      | HOST     | Zephyr |
      | Guest 1  | Puck   |
      | [Expert] | Kore   |
    Then the audio should be generated successfully
    And each speaker should be recognized correctly

  @voice-combinations
  Scenario Outline: Test different voice combinations
    Given I have a two-speaker script
    When I generate audio with voice combination "<voice1>" and "<voice2>"
    Then the voices should be distinguishable
    And the combination should sound pleasant

    Examples:
      | voice1  | voice2  |
      | Zephyr  | Puck    |
      | Kore    | Charon  |
      | Uranus  | Fenrir  |
      | Zephyr  | Kore    |
      | Puck    | Charon  |

  @script-format-validation
  Scenario: Handle scripts with stage directions
    Given I have the following script with stage directions:
      """
      Speaker 1: Welcome to the show! (enthusiastically)
      Speaker 2: (pausing) Thank you... I'm excited to be here.
      Speaker 1: Let's discuss [technology] trends.
      """
    When I generate multi-speaker audio
    Then the audio should be generated successfully
    And the system should handle parentheses appropriately

  @long-conversation
  Scenario: Generate lengthy multi-speaker conversation
    Given I have a script with 20 exchanges between speakers
    And the total text length is appropriate for a 10-minute podcast
    When I generate multi-speaker audio
    Then the audio file should be created successfully
    And the audio should maintain quality throughout
    And speaker voices should remain consistent

  @temperature-effects
  Scenario Outline: Test temperature settings for conversations
    Given I have a casual conversation script
    When I generate multi-speaker audio with temperature "<temp>"
    Then the conversation should reflect the temperature setting
    And speaker interactions should feel "<style>"

    Examples:
      | temp | style               |
      | 0.3  | more formal         |
      | 0.7  | naturally balanced  |
      | 1.0  | more dynamic        |

  @edge-cases @validation
  Scenario: Handle missing speaker configuration
    Given I have the following script:
      """
      Speaker 1: Hello!
      Speaker 2: Hi there!
      Speaker 3: Welcome!
      """
    And I only configure speakers for Speaker 1 and Speaker 2
    When I attempt to generate multi-speaker audio
    Then the system should return an error
    And the error should indicate missing speaker configuration

  @edge-cases @validation
  Scenario: Handle mismatched speaker labels
    Given I have the following script:
      """
      Alice: Hello!
      Bob: Hi there!
      """
    And I configure speakers for Speaker 1 and Speaker 2
    When I attempt to generate multi-speaker audio
    Then the system should return an error
    And the error should indicate speaker label mismatch

  @error-handling @resilience
  Scenario: Handle API failures during multi-speaker generation
    Given I have a valid multi-speaker script
    When the API fails during generation
    Then the system should handle the error gracefully
    And preserve any partial audio data
    And provide meaningful error information

  @performance @multi-speaker
  Scenario: Performance test for multi-speaker generation
    Given I have a script with multiple speakers
    And the script contains typical podcast content
    When I generate multi-speaker audio
    Then the response time should scale appropriately with complexity
    And should complete within reasonable time limits

  @output-quality @multi-speaker
  Scenario: Verify multi-speaker audio quality
    Given I have generated multi-speaker audio
    When I analyze the audio file
    Then the audio should have consistent volume levels
    And speaker transitions should be smooth
    And there should be no audio artifacts or glitches
    And each speaker's voice should be clearly distinguishable

  @complex-scenarios
  Scenario: Handle overlapping dialogue
    Given I have the following script with rapid exchanges:
      """
      Speaker 1: What do you think?
      Speaker 2: I agree completely!
      Speaker 1: Great! Let's move on.
      Speaker 2: Perfect, next topic.
      """
    When I generate multi-speaker audio
    Then the rapid exchanges should be clear
    And each speaker should be distinguishable
    And the conversation flow should be natural