#!/usr/bin/env python3
"""
Comprehensive test runner for Gemini TTS Podcast Generator
Executes all test suites and generates reports
"""

import pytest
import sys
import os
from pathlib import Path
import json
import time
from datetime import datetime


def run_unit_tests():
    """Run unit tests with coverage"""
    print("🧪 Running Unit Tests...")
    unit_test_path = Path(__file__).parent / "unit" / "test_gemini_tts_unit.py"
    
    return pytest.main([
        str(unit_test_path),
        "-v",
        "--tb=short",
        "--cov=scripts",
        "--cov-report=term-missing",
        "--cov-report=html:tests/reports/coverage",
        "--cov-report=json:tests/reports/coverage.json"
    ])


def run_integration_tests():
    """Run integration tests"""
    print("🔗 Running Integration Tests...")
    integration_test_path = Path(__file__).parent / "integration" / "test_rest_api_integration.py"
    
    return pytest.main([
        str(integration_test_path),
        "-v",
        "--tb=short"
    ])


def run_e2e_tests():
    """Run end-to-end tests"""
    print("🎯 Running End-to-End Tests...")
    e2e_test_path = Path(__file__).parent / "e2e" / "test_e2e_workflows.py"
    
    return pytest.main([
        str(e2e_test_path),
        "-v",
        "--tb=short"
    ])


def run_bdd_tests():
    """Run BDD tests with pytest-bdd"""
    print("📋 Running BDD Tests...")
    features_dir = Path(__file__).parent / "features"
    
    return pytest.main([
        str(features_dir),
        "-v",
        "--tb=short",
        "--bdd"
    ])


def run_rest_api_tests():
    """Run REST API specific tests"""
    print("🔌 Running REST API Tests...")
    
    # Run the REST API test scripts
    rest_api_scripts = [
        ".tmp/test_rest_api.sh",
        ".tmp/rest_api_test_suite.sh"
    ]
    
    results = []
    for script in rest_api_scripts:
        script_path = Path(__file__).parent.parent / script
        if script_path.exists():
            print(f"Running {script}...")
            try:
                import subprocess
                result = subprocess.run(
                    [str(script_path)],
                    env={**os.environ, 'GEMINI_API_KEY': 'test-api-key'},
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                results.append({
                    'script': script,
                    'returncode': result.returncode,
                    'stdout': result.stdout,
                    'stderr': result.stderr
                })
            except (subprocess.TimeoutExpired, FileNotFoundError) as e:
                results.append({
                    'script': script,
                    'returncode': 1,
                    'stdout': '',
                    'stderr': str(e)
                })
    
    return results


def generate_test_report(all_results):
    """Generate comprehensive test report"""
    print("📊 Generating Test Report...")
    
    report = {
        'timestamp': datetime.now().isoformat(),
        'summary': {
            'total_tests': 0,
            'passed': 0,
            'failed': 0,
            'skipped': 0
        },
        'test_suites': {}
    }
    
    # Process results
    for suite_name, result in all_results.items():
        if isinstance(result, list):  # REST API results
            suite_passed = all(r['returncode'] == 0 for r in result)
            report['test_suites'][suite_name] = {
                'status': 'passed' if suite_passed else 'failed',
                'details': result
            }
            if suite_passed:
                report['summary']['passed'] += 1
            else:
                report['summary']['failed'] += 1
        elif result == 0:  # pytest results
            report['test_suites'][suite_name] = {
                'status': 'passed',
                'returncode': result
            }
            report['summary']['passed'] += 1
        else:
            report['test_suites'][suite_name] = {
                'status': 'failed',
                'returncode': result
            }
            report['summary']['failed'] += 1
    
    # Calculate totals
    report['summary']['total_tests'] = len(report['test_suites'])
    
    return report


def print_test_summary(report):
    """Print test summary to console"""
    print("\n" + "="*60)
    print("🎯 TEST EXECUTION SUMMARY")
    print("="*60)
    print(f"Timestamp: {report['timestamp']}")
    print(f"Total Test Suites: {report['summary']['total_tests']}")
    print(f"✅ Passed: {report['summary']['passed']}")
    print(f"❌ Failed: {report['summary']['failed']}")
    print(f"⏭️  Skipped: {report['summary']['skipped']}")
    
    print("\n📋 Test Suite Details:")
    for suite_name, suite_result in report['test_suites'].items():
        status_icon = "✅" if suite_result['status'] == 'passed' else "❌"
        print(f"  {status_icon} {suite_name}: {suite_result['status'].upper()}")
        
        if suite_result['status'] == 'failed' and 'details' in suite_result:
            for detail in suite_result['details']:
                if detail['returncode'] != 0:
                    print(f"    ❌ {detail['script']}: {detail['stderr'][:100]}...")
    
    print("\n" + "="*60)


def save_report_to_file(report, filename="test_report.json"):
    """Save report to JSON file"""
    reports_dir = Path(__file__).parent / "reports"
    reports_dir.mkdir(exist_ok=True)
    
    report_file = reports_dir / filename
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"📄 Test report saved to: {report_file}")
    return report_file


def main():
    """Main test runner function"""
    print("🚀 Gemini TTS Podcast Generator - Test Runner")
    print("="*60)
    
    # Test configuration
    test_suites = {
        'unit_tests': run_unit_tests,
        'integration_tests': run_integration_tests,
        'e2e_tests': run_e2e_tests,
        'bdd_tests': run_bdd_tests,
        'rest_api_tests': run_rest_api_tests
    }
    
    # Run selected test suites
    all_results = {}
    
    # Check for command line arguments
    if len(sys.argv) > 1:
        # Run specific test suites
        selected_suites = sys.argv[1:]
        for suite_name in selected_suites:
            if suite_name in test_suites:
                print(f"\n🔍 Running {suite_name}...")
                try:
                    result = test_suites[suite_name]()
                    all_results[suite_name] = result
                except Exception as e:
                    print(f"❌ Error running {suite_name}: {e}")
                    all_results[suite_name] = 1
            else:
                print(f"⚠️  Unknown test suite: {suite_name}")
    else:
        # Run all test suites
        print("\n🔍 Running all test suites...")
        for suite_name, suite_func in test_suites.items():
            print(f"\n{'='*40}")
            print(f"Running {suite_name.replace('_', ' ').title()}...")
            print('='*40)
            
            try:
                result = suite_func()
                all_results[suite_name] = result
            except Exception as e:
                print(f"❌ Error running {suite_name}: {e}")
                all_results[suite_name] = 1
    
    # Generate and display report
    report = generate_test_report(all_results)
    print_test_summary(report)
    
    # Save report to file
    report_file = save_report_to_file(report)
    
    # Generate HTML report if pytest-html is available
    try:
        import pytest_html
        print(f"\n📊 HTML reports available in: {Path(__file__).parent / 'reports'}")
    except ImportError:
        print("\n💡 Install pytest-html for HTML test reports: pip install pytest-html")
    
    # Return appropriate exit code
    failed_suites = [name for name, result in all_results.items() 
                    if (isinstance(result, list) and any(r['returncode'] != 0 for r in result)) or
                       (not isinstance(result, list) and result != 0)]
    
    if failed_suites:
        print(f"\n❌ Test execution failed for suites: {', '.join(failed_suites)}")
        return 1
    else:
        print("\n✅ All tests passed!")
        return 0


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)