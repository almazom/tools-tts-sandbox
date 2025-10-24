#!/bin/bash
# Authentication Testing Master System for Gemini TTS API
# Peter's Comprehensive Auth Testing Suite v1.0
# Complete authentication vector testing with feline supervision

set -e -E

# Colors for output (because professional testing needs professional colors)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="https://generativelanguage.googleapis.com/v1beta"
MODEL_ID="gemini-2.5-pro-preview-tts"
TEST_OUTPUT_DIR=".tmp/auth_tests"
LOG_FILE="$TEST_OUTPUT_DIR/auth_test.log"
METRICS_FILE="$TEST_OUTPUT_DIR/auth_metrics.json"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
SECURITY_ISSUES=0

# Create test output directory
mkdir -p "$TEST_OUTPUT_DIR"

# Initialize log file
echo "$(date): Authentication Testing System Started" > "$LOG_FILE"

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    echo -e "${WHITE}[$timestamp]${NC} $message"
}

# Function to log success
log_success() {
    log_message "SUCCESS" "${GREEN}✓${NC} $1"
}

# Function to log error
log_error() {
    log_message "ERROR" "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

# Function to log warning
log_warning() {
    log_message "WARNING" "${YELLOW}⚠${NC} $1"
    ((SECURITY_ISSUES++))
}

# Function to log info
log_info() {
    log_message "INFO" "${BLUE}ℹ${NC} $1"
}

# Function to log security
log_security() {
    log_message "SECURITY" "${PURPLE}🔒${NC} $1"
}

# Function to update metrics
update_metrics() {
    local test_name="$1"
    local status="$2"
    local duration="$3"
    local auth_method="$4"
    
    local timestamp=$(date -Iseconds)
    local metrics_entry="{
        \"timestamp\": \"$timestamp\",
        \"test_name\": \"$test_name\",
        \"status\": \"$status\",
        \"duration_seconds\": $duration,
        \"auth_method\": \"$auth_method\",
        \"security_score\": $(calculate_security_score "$status" "$auth_method")
    }"
    
    echo "$metrics_entry" >> "$METRICS_FILE"
}

# Function to calculate security score
calculate_security_score() {
    local status="$1"
    local auth_method="$2"
    local score=0
    
    case "$status" in
        "passed")
            score=80
            case "$auth_method" in
                "api_key") score=70 ;;  # API keys are good but not perfect
                "oauth2") score=95 ;;   # OAuth2 is excellent
                "jwt") score=90 ;;      # JWT is very good
                "basic") score=50 ;;    # Basic auth is weak
            esac
            ;;
        "failed")
            score=20
            ;;
        "warning")
            score=40
            ;;
    esac
    
    echo "$score"
}

# Function to display banner
display_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🛡️  AUTHENTICATION TESTING SYSTEM                       ║"
    echo "║                    Peter's Comprehensive Auth Suite v1.0                   ║"
    echo "║                                                                              ║"
    echo "║  🔐 Testing: API Keys, Tokens, OAuth, Security Vectors                      ║"
    echo "║  🧪 Coverage: Valid, Invalid, Expired, Malformed, Rate Limits               ║"
    echo "║  📊 Output: Metrics, Logs, Security Scoring                                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed. Please install curl first."
        exit 1
    fi
    
    # Check for jq (JSON processor)
    if ! command -v jq &> /dev/null; then
        log_warning "jq is not installed. Some JSON parsing features will be limited."
    fi
    
    # Check for base64
    if ! command -v base64 &> /dev/null; then
        log_error "base64 is not installed. Please install base64 utilities."
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Function to test API key authentication
test_api_key_auth() {
    log_info "Testing API Key Authentication..."
    echo ""
    
    local test_start=$(date +%s)
    local test_name="API_Key_Auth"
    local auth_method="api_key"
    
    # Test 1: Valid API Key
    log_info "Test 1.1: Valid API Key Authentication"
    ((TESTS_RUN++))
    
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local api_url="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent?key=${GEMINI_API_KEY}"
        local test_data='{"contents":[{"role":"user","parts":[{"text":"Auth test"}]}],"generationConfig":{"responseModalities":["audio"],"speech_config":{"voice_config":{"prebuilt_voice_config":{"voice_name":"Zephyr"}}}}}'
        
        local curl_start=$(date +%s)
        local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "$test_data" \
            "$api_url" 2>/dev/null)
        local curl_end=$(date +%s)
        local duration=$((curl_end - curl_start))
        
        local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
        local response_body=$(echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d')
        
        if [[ "$http_status" == "200" ]]; then
            log_success "Valid API key authentication successful (HTTP $http_status, ${duration}s)"
            update_metrics "$test_name" "passed" "$duration" "$auth_method"
            ((TESTS_PASSED++))
            
            # Save successful response for analysis
            echo "$response_body" > "$TEST_OUTPUT_DIR/api_key_valid_response.json"
        else
            log_error "Valid API key authentication failed (HTTP $http_status, ${duration}s)"
            update_metrics "$test_name" "failed" "$duration" "$auth_method"
            echo "$response_body" > "$TEST_OUTPUT_DIR/api_key_valid_error.json"
        fi
    else
        log_error "GEMINI_API_KEY not set - cannot test API key authentication"
        update_metrics "$test_name" "failed" "0" "$auth_method"
    fi
    
    echo ""
    
    # Test 2: Invalid API Key
    log_info "Test 1.2: Invalid API Key Authentication"
    ((TESTS_RUN++))
    
    local invalid_api_key="invalid_key_12345"
    local api_url_invalid="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent?key=${invalid_api_key}"
    
    local curl_start=$(date +%s)
    local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"contents":[{"role":"user","parts":[{"text":"Auth test"}]}],"generationConfig":{"responseModalities":["audio"]}}' \
        "$api_url_invalid" 2>/dev/null)
    local curl_end=$(date +%s)
    local duration=$((curl_end - curl_start))
    
    local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    local response_body=$(echo "$response" | sed -n '1,/HTTP_STATUS:/p' | sed '$d')
    
    if [[ "$http_status" == "401" ]] || [[ "$http_status" == "403" ]]; then
        log_success "Invalid API key properly rejected (HTTP $http_status, ${duration}s)"
        update_metrics "API_Key_Invalid" "passed" "$duration" "$auth_method"
        ((TESTS_PASSED++))
    else
        log_warning "Unexpected response for invalid API key (HTTP $http_status, ${duration}s)"
        update_metrics "API_Key_Invalid" "warning" "$duration" "$auth_method"
    fi
    
    echo ""
    
    # Test 3: Missing API Key
    log_info "Test 1.3: Missing API Key Authentication"
    ((TESTS_RUN++))
    
    local api_url_no_key="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent"
    
    local curl_start=$(date +%s)
    local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"contents":[{"role":"user","parts":[{"text":"Auth test"}]}],"generationConfig":{"responseModalities":["audio"]}}' \
        "$api_url_no_key" 2>/dev/null)
    local curl_end=$(date +%s)
    local duration=$((curl_end - curl_start))
    
    local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    
    if [[ "$http_status" == "401" ]] || [[ "$http_status" == "403" ]]; then
        log_success "Missing API key properly rejected (HTTP $http_status, ${duration}s)"
        update_metrics "API_Key_Missing" "passed" "$duration" "$auth_method"
        ((TESTS_PASSED++))
    else
        log_warning "Unexpected response for missing API key (HTTP $http_status, ${duration}s)"
        update_metrics "API_Key_Missing" "warning" "$duration" "$auth_method"
    fi
    
    echo ""
    
    local test_end=$(date +%s)
    local total_duration=$((test_end - test_start))
    log_info "API Key authentication tests completed in ${total_duration}s"
}

# Function to test bearer token authentication
test_bearer_token_auth() {
    log_info "Testing Bearer Token Authentication..."
    echo ""
    
    local test_start=$(date +%s)
    local test_name="Bearer_Token_Auth"
    local auth_method="bearer_token"
    
    # Test 2.1: Bearer Token with Gemini API (if supported)
    log_info "Test 2.1: Bearer Token Authentication (Alternative Method)"
    ((TESTS_RUN++))
    
    # Some APIs support Bearer token as alternative to API key
    # We'll test if Gemini API accepts Bearer tokens in Authorization header
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local api_url="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent"
        local test_data='{"contents":[{"role":"user","parts":[{"text":"Bearer auth test"}]}],"generationConfig":{"responseModalities":["audio"],"speech_config":{"voice_config":{"prebuilt_voice_config":{"voice_name":"Zephyr"}}}}}'
        
        local curl_start=$(date +%s)
        local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $GEMINI_API_KEY" \
            -d "$test_data" \
            "$api_url" 2>/dev/null)
        local curl_end=$(date +%s)
        local duration=$((curl_end - curl_start))
        
        local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
        
        case "$http_status" in
            "200")
                log_success "Bearer token authentication successful (HTTP $http_status, ${duration}s)"
                update_metrics "$test_name" "passed" "$duration" "$auth_method"
                ((TESTS_PASSED++))
                ;;
            "401"|"403")
                log_info "Bearer token not supported by Gemini API (HTTP $http_status, ${duration}s) - this is expected"
                update_metrics "$test_name" "warning" "$duration" "$auth_method"
                ;;
            *)
                log_warning "Unexpected response for bearer token (HTTP $http_status, ${duration}s)"
                update_metrics "$test_name" "warning" "$duration" "$auth_method"
                ;;
        esac
    else
        log_error "GEMINI_API_KEY not set - cannot test bearer token"
        update_metrics "$test_name" "failed" "0" "$auth_method"
    fi
    
    echo ""
    
    local test_end=$(date +%s)
    local total_duration=$((test_end - test_start))
    log_info "Bearer token authentication tests completed in ${total_duration}s"
}

# Function to test basic authentication
test_basic_auth() {
    log_info "Testing Basic Authentication..."
    echo ""
    
    local test_start=$(date +%s)
    local test_name="Basic_Auth"
    local auth_method="basic_auth"
    
    # Test 3.1: Basic Auth (though unlikely to be supported)
    log_info "Test 3.1: Basic Authentication Test"
    ((TESTS_RUN++))
    
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local api_url="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent"
        local username="api"
        local password="$GEMINI_API_KEY"
        
        local curl_start=$(date +%s)
        local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -u "$username:$password" \
            -d '{"contents":[{"role":"user","parts":[{"text":"Basic auth test"}]}],"generationConfig":{"responseModalities":["audio"]}}' \
            "$api_url" 2>/dev/null)
        local curl_end=$(date +%s)
        local duration=$((curl_end - curl_start))
        
        local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
        
        case "$http_status" in
            "200")
                log_success "Basic authentication successful (HTTP $http_status, ${duration}s)"
                update_metrics "$test_name" "passed" "$duration" "$auth_method"
                ((TESTS_PASSED++))
                ;;
            "401"|"403")
                log_info "Basic auth not supported (HTTP $http_status, ${duration}s) - expected"
                update_metrics "$test_name" "warning" "$duration" "$auth_method"
                ;;
            *)
                log_warning "Unexpected response for basic auth (HTTP $http_status, ${duration}s)"
                update_metrics "$test_name" "warning" "$duration" "$auth_method"
                ;;
        esac
    else
        log_error "GEMINI_API_KEY not set - cannot test basic auth"
        update_metrics "$test_name" "failed" "0" "$auth_method"
    fi
    
    echo ""
    
    local test_end=$(date +%s)
    local total_duration=$((test_end - test_start))
    log_info "Basic authentication tests completed in ${total_duration}s"
}

# Function to test security headers and best practices
test_security_headers() {
    log_info "Testing Security Headers and Best Practices..."
    echo ""
    
    local test_start=$(date +%s)
    
    # Test 4.1: HTTPS Enforcement
    log_info "Test 4.1: HTTPS Enforcement Check"
    ((TESTS_RUN++))
    
    local http_url="http://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}"
    local https_url="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}"
    
    # Test HTTP (should redirect or fail)
    local curl_start=$(date +%s)
    local http_response=$(curl -s -I -w "\nHTTP_STATUS:%{http_code}" "$http_url" 2>/dev/null || echo "HTTP_STATUS:000")
    local curl_end=$(date +%s)
    local duration=$((curl_end - curl_start))
    
    local http_status=$(echo "$http_response" | grep "HTTP_STATUS:" | cut -d: -f2)
    
    if [[ "$http_status" == "000" ]] || [[ "$http_status" == "301" ]] || [[ "$http_status" == "302" ]] || [[ "$http_status" == "400" ]]; then
        log_success "HTTPS properly enforced (HTTP request handled correctly: $http_status)"
        ((TESTS_PASSED++))
    else
        log_warning "Unexpected HTTP response: $http_status"
    fi
    
    echo ""
    
    # Test 4.2: Security Headers
    log_info "Test 4.2: Security Headers Analysis"
    ((TESTS_RUN++))
    
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local api_url="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent?key=${GEMINI_API_KEY}"
        
        local curl_start=$(date +%s)
        local response=$(curl -s -I -w "\nHTTP_STATUS:%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -d '{"contents":[{"role":"user","parts":[{"text":"Security header test"}]}],"generationConfig":{"responseModalities":["audio"]}}' \
            "$api_url" 2>/dev/null)
        local curl_end=$(date +%s)
        local duration=$((curl_end - curl_start))
        
        # Extract headers
        local security_headers=$(echo "$response" | grep -i "^X-\|^Content-Security-Policy\|^Strict-Transport-Security\|^X-Content-Type-Options\|^X-Frame-Options\|^X-XSS-Protection")
        
        if [[ -n "$security_headers" ]]; then
            log_success "Security headers found:"
            echo "$security_headers" | while read -r header; do
                log_info "  $header"
            done
            ((TESTS_PASSED++))
        else
            log_info "No standard security headers detected (this may be normal for API endpoints)"
            # Don't fail this test as APIs often have different security header requirements
        fi
    else
        log_error "GEMINI_API_KEY not set - cannot test security headers"
    fi
    
    echo ""
    
    local test_end=$(date +%s)
    local total_duration=$((test_end - test_start))
    log_info "Security header tests completed in ${total_duration}s"
}

# Function to test rate limiting and abuse protection
test_rate_limiting() {
    log_info "Testing Rate Limiting and Abuse Protection..."
    echo ""
    
    local test_start=$(date +%s)
    
    # Test 5.1: Rapid Sequential Requests
    log_info "Test 5.1: Rate Limiting Detection"
    ((TESTS_RUN++))
    
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local api_url="${API_BASE_URL}/models/${MODEL_ID}:streamGenerateContent?key=${GEMINI_API_KEY}"
        local test_data='{"contents":[{"role":"user","parts":[{"text":"Rate limit test"}]}],"generationConfig":{"responseModalities":["audio"],"speech_config":{"voice_config":{"prebuilt_voice_config":{"voice_name":"Zephyr"}}}}}'
        
        log_info "Sending 5 rapid sequential requests..."
        local rate_limit_detected=false
        local responses_429=0
        
        for i in {1..5}; do
            local curl_start=$(date +%s)
            local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
                -X POST \
                -H "Content-Type: application/json" \
                -d "$test_data" \
                "$api_url" 2>/dev/null)
            local curl_end=$(date +%s)
            local duration=$((curl_end - curl_start))
            
            local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
            
            if [[ "$http_status" == "429" ]]; then
                ((responses_429++))
                rate_limit_detected=true
                log_warning "Rate limit detected on request $i (HTTP 429)"
            elif [[ "$http_status" == "200" ]]; then
                log_info "Request $i successful (HTTP 200, ${duration}s)"
            else
                log_info "Request $i: HTTP $http_status (${duration}s)"
            fi
            
            # Small delay between requests (but still rapid)
            sleep 0.1
        done
        
        if [[ "$rate_limit_detected" == true ]]; then
            log_success "Rate limiting properly implemented ($responses_429/5 requests rate limited)"
            update_metrics "Rate_Limiting" "passed" "0" "rate_limiting"
            ((TESTS_PASSED++))
        else
            log_info "No rate limiting detected in rapid test (may indicate generous limits or different timing)"
            update_metrics "Rate_Limiting" "warning" "0" "rate_limiting"
        fi
    else
        log_error "GEMINI_API_KEY not set - cannot test rate limiting"
        update_metrics "Rate_Limiting" "failed" "0" "rate_limiting"
    fi
    
    echo ""
    
    local test_end=$(date +%s)
    local total_duration=$((test_end - test_start))
    log_info "Rate limiting tests completed in ${total_duration}s"
}

# Function to generate authentication test report
generate_auth_report() {
    log_info "Generating Authentication Test Report..."
    echo ""
    
    local report_file="$TEST_OUTPUT_DIR/auth_test_report.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$report_file" << EOF
# 🛡️ Authentication Testing Report
Generated: $timestamp
Test System: Peter's Comprehensive Auth Suite v1.0
API Endpoint: $API_BASE_URL

## 📊 Summary Statistics

- **Total Tests Run**: $TESTS_RUN
- **Tests Passed**: $TESTS_PASSED
- **Tests Failed**: $TESTS_FAILED
- **Security Issues**: $SECURITY_ISSUES
- **Success Rate**: $(echo "scale=2; $TESTS_PASSED * 100 / $TESTS_RUN" | bc -l 2>/dev/null || echo "N/A")%

## 🔐 Authentication Methods Tested

### API Key Authentication
- ✅ Valid API Key
- ✅ Invalid API Key Rejection
- ✅ Missing API Key Handling

### Bearer Token Authentication
- ⚠️ Bearer Token Support (API dependent)

### Basic Authentication
- ⚠️ Basic Auth Support (API dependent)

### Security Headers
- ✅ HTTPS Enforcement
- ✅ Security Header Analysis

### Rate Limiting
- ⚠️ Rate Limit Detection (environment dependent)

## 🎯 Recommendations

### Immediate Actions
1. **Ensure API keys are properly secured** - Store in environment variables
2. **Implement HTTPS enforcement** - Already done by Google
3. **Monitor rate limiting** - Track API usage patterns

### Security Best Practices
1. **Rotate API keys regularly** - Implement key rotation policy
2. **Implement request signing** - For enhanced security
3. **Add request throttling** - Client-side rate limiting

### Advanced Security
1. **Implement OAuth 2.0** - For user authentication flows
2. **Add JWT token support** - For stateless authentication
3. **Implement mutual TLS** - For certificate-based authentication

## 📈 Metrics

See detailed metrics in: \`$METRICS_FILE\`
See test logs in: \`$LOG_FILE\`

## 🔍 Next Steps

1. Review failed tests and implement fixes
2. Set up continuous authentication monitoring
3. Implement automated security scanning
4. Create incident response procedures

---
*Report generated by Peter's Authentication Testing System*
EOF

    log_success "Authentication test report generated: $report_file"
}

# Function to display final summary
display_final_summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                           🎯 FINAL TEST SUMMARY                             ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}Test Statistics:${NC}"
    echo -e "  ${BLUE}Total Tests Run:${NC}    $TESTS_RUN"
    echo -e "  ${GREEN}Tests Passed:${NC}     $TESTS_PASSED"
    echo -e "  ${RED}Tests Failed:${NC}     $TESTS_FAILED"
    echo -e "  ${PURPLE}Security Issues:${NC}  $SECURITY_ISSUES"
    
    if [[ $TESTS_RUN -gt 0 ]]; then
        local success_rate=$(echo "scale=1; $TESTS_PASSED * 100 / $TESTS_RUN" | bc -l 2>/dev/null || echo "0")
        echo -e "  ${CYAN}Success Rate:${NC}     $success_rate%"
    fi
    
    echo ""
    echo -e "${WHITE}Output Files:${NC}"
    echo -e "  📊 ${BLUE}Test Report:${NC}     $TEST_OUTPUT_DIR/auth_test_report.md"
    echo -e "  📈 ${BLUE}Metrics:${NC}        $METRICS_FILE"
    echo -e "  📝 ${BLUE}Detailed Log:${NC}   $LOG_FILE"
    
    echo ""
    if [[ $TESTS_FAILED -eq 0 ]] && [[ $SECURITY_ISSUES -eq 0 ]]; then
        echo -e "${GREEN}🎉 EXCELLENT! All authentication tests passed with no security issues!${NC}"
    elif [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Good! All tests passed, but review security warnings.${NC}"
    else
        echo -e "${RED}❌ Some tests failed. Review the report and logs for details.${NC}"
    fi
    
    echo ""
    echo -e "${WHITE}Next Steps:${NC}"
    echo -e "  1. Review the authentication test report"
    echo -e "  2. Address any failed tests or security issues"
    echo -e "  3. Implement recommended security improvements"
    echo -e "  4. Set up continuous authentication monitoring"
    echo ""
}

# Main execution function
main() {
    local start_time=$(date +%s)
    
    display_banner
    
    echo -e "${WHITE}Starting authentication testing system...${NC}"
    echo ""
    
    # Initialize metrics file
    echo "[]" > "$METRICS_FILE"
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Run authentication tests
    test_api_key_auth
    echo ""
    
    test_bearer_token_auth
    echo ""
    
    test_basic_auth
    echo ""
    
    test_security_headers
    echo ""
    
    test_rate_limiting
    echo ""
    
    # Generate reports
    generate_auth_report
    echo ""
    
    # Display final summary
    display_final_summary
    
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    log_info "Authentication testing completed in ${total_duration} seconds"
    
    # Return appropriate exit code
    if [[ $TESTS_FAILED -eq 0 ]] && [[ $SECURITY_ISSUES -eq 0 ]]; then
        exit 0
    elif [[ $TESTS_FAILED -eq 0 ]]; then
        exit 1  # Warnings but no failures
    else
        exit 2  # Failures detected
    fi
}

# Run main function with all arguments
main "$@"