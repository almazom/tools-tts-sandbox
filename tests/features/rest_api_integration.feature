Feature: REST API Integration for TTS
  As a developer
  I want to integrate with the Gemini REST API
  So that I can generate speech programmatically

  Background:
    Given the Gemini REST API is available
    And I have a valid API endpoint
    And I understand the request/response format

  @critical @api-contract
  Scenario: Successful single speaker REST API call
    Given I have a valid API key
    And I prepare a REST request with:
      | model       | gemini-2.5-pro-preview-tts |
      | text        | Hello REST API test        |
      | voice       | Zephyr                     |
      | temperature | 0.8                        |
    When I send a POST request to the TTS endpoint
    Then the response status should be 200
    And the response should contain audio data
    And the audio data should be base64 encoded
    And the MIME type should be audio/L16 or audio/wav

  @critical @api-contract
  Scenario: Successful multi-speaker REST API call
    Given I have a valid API key
    And I prepare a multi-speaker REST request with:
      | model       | gemini-2.5-pro-preview-tts |
      | text        | Speaker 1: Hello\nSpeaker 2: Hi! |
      | speakers    | Speaker 1:Zephyr,Speaker 2:Puck |
      | temperature | 1.0                        |
    When I send a POST request to the TTS endpoint
    Then the response status should be 200
    And the response should contain streaming audio data
    And each audio chunk should be properly formatted

  @api-contract @streaming
  Scenario: Handle streaming response format
    Given I make a successful REST API call
    When the API returns a streaming response
    Then each line should be a valid JSON object
    And each JSON object should follow the schema:
      """
      {
        "candidates": [{
          "content": {
            "parts": [{
              "inlineData": {
                "mimeType": "string",
                "data": "base64_string"
              }
            }]
          }
        }]
      }
      """

  @error-handling @api-responses
  Scenario: Handle 429 rate limit error
    Given I have exceeded my API rate limit
    When I send a REST API request
    Then the response status should be 429
    And the response should contain error code 429
    And the error message should mention rate limits
    And the error should suggest checking billing settings

  @error-handling @api-responses
  Scenario: Handle 401 authentication error
    Given I have an invalid API key
    When I send a REST API request
    Then the response status should be 401
    And the response should contain an authentication error
    And the error message should indicate invalid credentials

  @error-handling @api-responses
  Scenario: Handle 400 bad request error
    Given I prepare an invalid REST request with malformed JSON
    When I send the request to the API endpoint
    Then the response status should be 400
    And the response should contain validation errors
    And the error should indicate what was wrong with the request

  @error-handling @api-responses
  Scenario: Handle 503 service unavailable
    Given the Gemini API service is temporarily unavailable
    When I send a REST API request
    Then the response status should be 503
    And the response should contain a service unavailable error
    And the error should suggest retrying later

  @api-validation @request-format
  Scenario Outline: Validate request parameter combinations
    Given I prepare a REST request with "<parameter>" set to "<value>"
    When I send the request to the API endpoint
    Then the response should be "<expected_result>"

    Examples:
      | parameter       | value           | expected_result |
      | empty text      | ""              | error           |
      | invalid voice   | "InvalidVoice"  | error           |
      | invalid model   | "invalid-model" | error           |
      | negative temp   | -1.0            | error           |
      | high temp       | 2.0             | error           |

  @api-performance @response-time
  Scenario: API response time acceptance criteria
    Given I prepare a standard TTS request
    When I send the request and measure response time
    Then the response should be received within 30 seconds
    And the response should contain valid audio data
    And the response size should be reasonable for the request

  @api-reliability @retry-logic
  Scenario: Implement retry logic for transient failures
    Given I implement retry logic with exponential backoff
    When I encounter a transient API failure
    Then the system should retry up to 3 times
    And each retry should wait progressively longer
    And if all retries fail, provide a clear error message

  @api-headers @content-negotiation
  Scenario: Validate HTTP headers
    Given I prepare a REST API request
    When I send the request with headers:
      | Header           | Value                |
      | Content-Type     | application/json     |
      | Accept          | application/json     |
      | User-Agent      | Gemini-TTS-Client/1.0 |
    Then the API should accept the request
    And the response should have appropriate headers
    And the Content-Type should be application/json

  @api-payload @size-limits
  Scenario: Test API payload size limits
    Given I prepare requests with different payload sizes:
      | size_category | text_length |
      | small         | 50          |
      | medium        | 500         |
      | large         | 2000        |
      | very_large    | 5000        |
    When I send each request to the API
    Then all requests should be processed successfully
    And response times should scale appropriately

  @api-consistency @multiple-calls
  Scenario: API consistency across multiple calls
    Given I make the same API request 5 times
    When each request uses identical parameters
    Then all responses should have the same structure
    And the audio quality should be consistent
    And the response format should be identical

  @api-versioning @compatibility
  Scenario: Handle API version compatibility
    Given I use the current API version
    When the API version changes in the future
    Then the system should handle version changes gracefully
    And provide migration path documentation
    And maintain backward compatibility where possible

  @api-monitoring @health-check
  Scenario: API health monitoring
    Given I implement API health checks
    When I periodically check API availability
    Then I should receive accurate status information
    And be able to detect API outages
    And receive alerts when the API is unavailable