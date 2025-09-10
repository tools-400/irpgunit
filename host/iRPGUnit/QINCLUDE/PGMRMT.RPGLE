**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Test Runner.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Remote test runner program for executing iRPGUnit test suites
//
// This is the main entry point for the iRPGUnit plug-in test runner that executes
// unit tests in a separate job environment. It provides comprehensive test execution
// with configurable output formats, library list management, and resource cleanup.
// The program can run individual test procedures or complete test suites with
// detailed reporting and XML output capabilities.
//
// @param go_returncode - Return code indicating overall test execution status:
//                        0 = All tests passed successfully
//                        >0 = Number of failed tests or execution error
//                        <0 = System error or configuration issue
// @param gi_userspace  - User space object for storing detailed test results and metrics
//                        Structure: library/object format for result storage
// @param gi_testsuite  - Test suite object containing the tests to execute
//                        Structure: library/service program containing test procedures
// @param gi_procnames  - Procedure names structure for selective test execution
//                        Allows running specific test procedures instead of entire suite
// @param gi_order      - Test execution order specification:
//                        Controls the sequence in which test procedures are executed
// @param gi_detail     - Detail level for test output and reporting:
//                        Controls verbosity of test execution reporting
// @param gi_output     - Output format specification for test results:
//                        Determines format and destination of test output
// @param gi_libl       - Library list configuration for test execution environment
//                        Defines the library search order during test execution
// @param gi_qJobD      - Job description object for test environment setup
//                        Specifies job attributes and environment for test execution
// @param gi_rclrsc     - Resource cleanup specification after test execution:
//                        Controls cleanup behavior for temporary objects and resources
// @param gi_xmlstmf    - XML stream file path for structured output (optional parameter)
//                        When specified, generates XML-formatted test results
///
dcl-pr pgmrmt extpgm('PGMRMT');
  go_returncode int(10);
  gi_userspace  likeds(object_t) const;
  gi_testsuite  likeds(object_t) const;
  gi_procnames  likeds(procNms_t) const;
  gi_order      like(order_t) const;
  gi_detail     like(detail_t) const;
  gi_output     like(output_t) const;
  gi_libl       likeds(libl_t) const;
  gi_qJobD      likeds(object_t) const;
  gi_rclrsc     like(rclrsc_t) const;
  gi_xmlstmf    like(stmf_fl_t) options(*nopass) const;
end-pr;

