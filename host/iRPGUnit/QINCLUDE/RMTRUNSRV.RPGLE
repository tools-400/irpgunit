**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Adapter.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Executes a test suite remotely and returns comprehensive test results
//
// This procedure serves as the main entry point for remote test execution, providing
// a comprehensive interface for running iRPGUnit test suites with full control over
// execution environment, output formatting, and result collection. It handles both
// complete test suite execution and selective test procedure runs with detailed
// reporting capabilities.
//
// @param userspace     - User space object for storing detailed test results and metrics
//                        Structure: library/object format defining where results are stored
//                        Contains execution statistics, timing data, and failure details
// @param testsuitename - Test suite service program object containing test procedures
//                        Structure: library/service program identifying the test suite to execute
//                        Must be a valid *SRVPGM object with exported test procedures
// @param testprocs     - List of specific test procedure names to execute (optional filtering)
//                        Structure: Array of procedure names for selective execution
//                        If empty, all test procedures in the suite are executed
// @param order         - Execution order specification for test procedures:
//                        '*API' = Execute in the order defined by the test suite
//                        '*REVERSE' = Execute in reverse order
//                        Controls sequence of test procedure execution
// @param detail        - Level of detail for test output and reporting:
//                        '*BASIC' = Summary information only
//                        '*ALL' = Detailed execution information including timings
//                        '*FAILURE' = Detailed information for failures only
// @param output        - Output format specification for test results:
//                        '*NONE' = No output formatting
//                        '*VERBOSE' = Detailed console output
//                        '*CSV' = Comma-separated values format
// @param libl          - Library list configuration for test execution environment
//                        Structure: Defines the library search order during test execution
//                        Ensures proper resolution of objects and dependencies
// @param qJobD         - Job description object for test environment setup
//                        Structure: library/object format specifying job attributes
//                        Controls job environment, locale, and system settings
// @param rclrsc        - Resource cleanup specification after test execution:
//                        '*YES' = Clean up temporary objects and resources
//                        '*NO' = Leave resources for debugging or analysis
// @param xmlstmf       - XML stream file path for structured output
//                        Stream file path for generating XML-formatted test results
//                        Enables integration with CI/CD tools and reporting systems
// @param xmlType       - Specifies the type of the generated XML stream file.
//                        *TYPE1 = original type created by iRPGUnit <= v5.1.0.r
//                        *TYPE2 = new type that associates a Json object to XML
//                                 element '<failure>'. The Json object includes
//                                 the stack trace as well as the 'expected' and
//                                 'actual' test values.
//
// @return Status code indicating overall test execution outcome:
//         0 = All tests passed successfully
//         >0 = Number of failed test procedures
//         -1 = Test suite not found or invalid
//         -2 = Environment setup error
//         -3 = Resource allocation failure
//         -99 = Unexpected system error
///
dcl-pr rpgunit_runTestSuite int(10) extproc('RMTRUNSRV_rpgunit_runTestSuite');
  userSpace     likeds(object_t) const;
  testSuiteName likeds(object_t) const;
  testProcs     likeds(procNms_t) const;
  order         like(order_t) const;
  detail        like(detail_t) const;
  output        like(output_t) const;
  libl          likeds(libl_t) const;
  qJobD         likeds(object_t) const;
  rclrsc        like(rclrsc_t) const;
  xmlstmf       like(stmf_t) const;
  xmlType       like(xmlType_t) const;
end-pr;

