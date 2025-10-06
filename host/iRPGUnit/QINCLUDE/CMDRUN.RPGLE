**FREE
/if not defined(CMDRUN)
/define CMDRUN
// ==========================================================================
//  iRPGUnit - Command line runner.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// ---------------------------------------
//  Exported for self-tests
// ---------------------------------------

// Handle a test case error.
dcl-pr handleError extproc('handleError');
  testProcNm      const like(procNm_t);
  excpMsgInfo     const likeds(msg_t);
  result          likeds(result_t);
end-pr;

// Handle a test case failure.
dcl-pr handleFailure extproc('handleFailure');
  testProcNm      const like(procNm_t);
  failure         const likeds(assertFailEvtLong_t);
  result          likeds(result_t);
end-pr;

// Handle a test case success.
dcl-pr handleSuccess extproc('handleSuccess');
  testProcNm      const like(procNm_t);
  assertionCnt    int(10) const;
end-pr;

///
// Main entry point for the RUCALLTST command processor.
// Coordinates the complete test execution workflow including test suite
// loading, environment setup, test execution, and result reporting.
// Handles all command parameters and orchestrates the testing process.
//
// @param testSuiteName - Test suite service program object to execute
// @param testProcs     - Specific test procedures to run (or *ALL for all tests)
// @param order         - Test execution order (*API or *REVERSE)
// @param detail        - Logging detail level (*BASIC, *ALL, *FAILURE)
// @param output        - Output destination format (*SPOOLFILE, *STDOUT)
// @param libl          - Library list configuration for test execution
// @param jobD          - Job description for environment setup
// @param rclRsc        - Resource reclamation option (*YES, *NO, *ALWAYS)
// @param xmlStmf       - XML output stream file path for test results
// @param xmlType       - Specifies the type of the generated XML stream file.
//                        *TYPE1 = original type created by iRPGUnit <= v5.1.0.r
//                        *TYPE2 = new type that associates a Json object to XML
//                                 element '<failure>'. The Json object includes
//                                 the stack trace as well as the 'expected' and
//                                 'actual' test values.
///
dcl-pr cmdrun extpgm('RUCALLTST');
  testSuiteName likeds(object_t) const;
  testProcs     likeds(procNms_t) const;
  order         like(order_t) const;
  detail        like(detail_t) const;
  output        like(output_t) const;
  libl          likeds(libl_t) const;
  jobD          likeds(object_t) const;
  rclRsc        like(rclrsc_t) const;
  xmlStmf       like(stmf_t) const;
  xmlType       like(xmlType_t) const;
end-pr;

///
// Generates a standardized test completion summary message.
// Formats test execution statistics into a user-friendly message
// that summarizes the overall test run results including counts
// of test cases, assertions, failures, and errors.
//
// @param testcasecnt - Total number of test cases executed
// @param assertCnt   - Total number of assertions performed
// @param failureCnt  - Total number of test failures encountered
// @param errorCnt    - Total number of test errors encountered
//
// @return Formatted completion message string ready for display
///
dcl-pr fmtCompMsg varchar(256) extproc('CMDRUN_fmtCompMsg');
  testcasecnt int(10) const;
  assertCnt   int(10) const;
  failureCnt  int(10) const;
  errorCnt    int(10) const;
end-pr;

///
// Formats an object structure into a readable qualified name string.
// Converts object name and library components into standard
// library/object notation for user display and logging purposes.
//
// @param obj - Object structure containing name and library information
//
// @return Formatted qualified object name (LIBRARY/OBJECT format)
///
dcl-pr fmtObjNm varchar(21) extproc('CMDRUN_fmtObjNm');
  obj likeds(object_t) const;
end-pr;

///
// Initializes the test suite environment and executes setup procedures.
// Prepares the testing environment by calling suite-level setup
// procedures and establishing the necessary context for test execution.
//
// @param testSuite - Test suite structure containing setup information
// @param result    - Test result accumulator to update with setup results
//
// @return Success indicator for setup completion
///
dcl-pr setupTestSuite char(1) extproc('CMDRUN_setupTestSuite');
  testSuite likeds(testSuite_t) const;
  result    likeds(result_t);
end-pr;

///
// Cleans up the test suite environment and executes teardown procedures.
// Performs suite-level cleanup by calling teardown procedures
// and releasing resources used during test execution.
//
// @param testSuite - Test suite structure containing teardown information
// @param result    - Test result accumulator to update with teardown results
//
// @return Success indicator for teardown completion
///
dcl-pr tearDownTestSuite char(1) extproc('CMDRUN_tearDownTestSuite');
  testSuite likeds(testSuite_t) const;
  result    likeds(result_t);
end-pr;

///
// Orchestrates the execution of all test cases within a test suite.
// Manages the test execution flow including individual test setup,
// execution, teardown, and result collection based on specified
// execution parameters and filtering criteria.
//
// @param result         - Test result accumulator for collecting execution statistics
// @param testSuite      - Test suite containing test procedures to execute
// @param testProcsToRun - Filter specifying which test procedures to execute
// @param order          - Execution order specification (*API or *REVERSE)
// @param detail         - Detail level for logging and output
// @param rclRsc         - Resource reclamation strategy between tests
///
dcl-pr runTests extproc('CMDRUN_runTests');
  result         likeds(result_t);
  testSuite      likeds(testSuite_t) const;
  testProcsToRun likeds(procNms_t) const;
  order          char(8) const;
  detail         char(6) const;
  rclRsc         char(10) const;
end-pr;

///
// Validates and restores the library list if modifications were detected.
// Monitors library list changes during test execution and restores
// the original library list configuration when required to maintain
// environment consistency between test runs.
//
// @param mustRestoreLibl - Flag indicating whether library list restoration is required
// @param savedLibl       - Previously saved library list configuration data
///
dcl-pr checkAndRestoreLibl extproc('CMDRUN_checkAndRestoreLibl');
  mustRestoreLibl ind const;
  savedLibl       likeds(libLData_t) const;
end-pr;

/include qinclude,TEMPLATES

/endif
