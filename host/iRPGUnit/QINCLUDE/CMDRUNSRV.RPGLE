**FREE
/if defined(IRPGUNIT_CMDRUNSRV)
/eof
/endif
/define IRPGUNIT_CMDRUNSRV
// ==========================================================================
//  iRPGUnit - Command Line Toolkit.
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
//                        Structure: library/object format defining where results are stored
//                        Contains execution statistics, timing data, and failure details
// @param testsuitename - Test suite service program object containing test procedures
//                        Structure: library/service program identifying the test suite to execute
//                        Must be a valid *SRVPGM object with exported test procedures
// @param testprocs     - List of specific test procedure names to execute (optional filtering)
//                        Structure: Array of procedure names for selective execution
//                        If empty, all test procedures in the suite are executed
// @param order         - Execution order specification for test procedures:
//                        *API     = Execute in the order defined by the test suite
//                        *REVERSE = Execute in reverse order
//                        Controls sequence of test procedure execution
// @param detail        - Level of detail for test output and reporting:
//                        *BASIC = Full details for failures and errors, no detail for
//                                 successes.
//                        *ALL   = Full detail in all cases.
// @param onFailure     - Mode of how assertions are processed:
//                        *ABORT    = Processing of the test case is aborted after the
//                                    first failed assertion
//                        *CONTINUE = Test case processing continues even if an assertion
//                                    fails.
// @param output        - Output format specification for test results:
//                        *ALLWAYS = Creates a report regardless of the test result.
//                        *ERROR   = Creates a report in case of failures and errors, only.
//                        *NONE    = Does not create any report.
// @param libl          - Library list configuration for test execution environment
//                        Structure: Defines the library search order during test execution
//                        Ensures proper resolution of objects and dependencies
// @param qJobD         - Job description object for test environment setup
//                        Structure: library/object format specifying job attributes
//                        Controls job environment, locale, and system settings
// @param rclrsc        - Resource cleanup specification after test execution:
//                        *NO      = Resources are not reclaimed.
//                        *ALLWAYS = Resources are reclaimed after each test case and
//                                   at the end of the test suite.
//                        *ONCE    = Resources are reclaimed at the end of the test
//                                   suite.
// @param xmlstmf       - XML stream file path for structured output
//                        Stream file path for generating XML-formatted test results
//                        Enables integration with CI/CD tools and reporting systems
// @param xmlType       - Specifies the type of the generated XML stream file.
//                        *TYPE1   = Original XML format created by iRPGUnit <= v5.1.0.r
//                        *TYPE2   = New XML format created by iRPGUnit v6.0.0.r.
//                        *VSCODE1 = XML format for the VS Code 'IBM i Testing' extension.
// @param msg           - Message of the test result.
//
// @return Status code indicating overall test execution outcome:
//         0 = All tests passed successfully
//         >0 = Number of failed test procedures
//         -1 = Test suite not found or invalid
//         -2 = Environment setup error
//         -3 = Resource allocation failure
//         -99 = Unexpected system error
///
dcl-pr runTestSuite ind extproc('CMDRUNSRV_runTestSuite');
  userSpace     likeds(object_t) options(*omit) const;
  testSuiteName likeds(object_t) const;
  testProcs     likeds(procNms_t) const;
  order         like(order_t) const;
  detail        like(detail_t) const;
  onFailure     like(onFailure_t) const;
  output        like(output_t) const;
  libl          likeds(libl_t) const;
  qJobD         likeds(object_t) const;
  rclrsc        like(rclrsc_t) const;
  xmlstmf       like(stmf_t) const;
  xmlType       like(xmlType_t) const;
  msg           varchar(256);
end-pr;

///
// Execute a complete test case with setup and teardown procedures.
// Runs the specified test procedure along with its associated setup and
// teardown procedures in the proper sequence. Captures and returns
// comprehensive test execution results including timing and outcome.
//
// @param testproc - Test procedure to execute
// @param setup    - Setup procedure to run before the test (may be null)
// @param tearDown - Teardown procedure to run after the test (may be null)
//
// @return Complete test result with execution details and outcome
///
dcl-pr runTestProc extproc('CMDRUNSRV_runTestProc') likeds(testCaseResult_t);
  testproc likeds(proc_t) const;
  setup    likeds(proc_t) const;
  tearDown likeds(proc_t) const;
end-pr;

///
// Load and activate a test suite from a service program.
// Dynamically loads the specified service program, activates it, and
// discovers all test procedures, setup, and teardown procedures within it.
// The resulting test suite contains all necessary information to execute
// the tests.
//
// @param srvPgm - Service program object containing the test procedures
//
// @return Fully loaded test suite ready for execution
///
dcl-pr loadTestSuite extproc('CMDRUNSRV_loadTestSuite') likeds(testSuite_t);
  srvPgm likeds(object_t) const;
end-pr;

///
// Raise an iRPGUnit runtime error.
// Throws a standardized error within the test framework, typically used
// for critical failures that should halt test execution immediately.
// This procedure does not return to the caller.
//
// @param msg - Error message describing the failure condition
///
dcl-pr raiseRUError extproc('CMDRUNSRV_raiseRUError');
  msg varchar(256) const;
end-pr;

///
// Create a test suite and allocate resources.
//
// @param srvPgm - Qualified service programm
//
// @return test suite
///
dcl-pr crtTestSuite likeds(testSuite_t) extproc('CMDRUNSRV_crtTestSuite');
  srvPgm const likeds(object_t);
end-pr;

///
// Reclaim allocated resources for a test suite.
// Performs cleanup operations on a test suite by releasing any allocated
// memory, closing resources, and properly deactivating the associated
// service program to prevent memory leaks.
//
// @param testSuite - Test suite whose resources should be reclaimed
///
dcl-pr rclTestSuite extproc('CMDRUNSRV_rclTestSuite');
  testSuite likeds(testSuite_t);
end-pr;

///
// Execute a specific test case within a test suite.
// Runs the test case at the specified index, including setup and teardown
// procedures if available, and returns the complete test execution results.
//
// @param testSuite - Test suite containing the test case
// @param testIdx   - Zero-based index of the test case to execute
// @param seqNbr    - Sequence number of the order the test cases are executed
//
// @return Complete test result including outcome and execution details
///
dcl-pr runTestCase extproc('CMDRUNSRV_runTestCase') likeds(testCaseResult_t);
  testSuite likeds(testSuite_t) const;
  testIdx   int(10) const;
  seqNbr          int(10) const;
end-pr;

///
// Run a setup, teardown or test procedure.
// Safely executes a procedure pointer while capturing any
// assertion failures or runtime errors that occur during execution.
//
// @param proc           - Procedure pointer
// @param result         - Test result
// @param procNamePrefix - Prefix of the test name procedure. One of:
//                         setupsuite, setup, teardown, teardownsuite
//
// @return Test result
///
dcl-pr runProc likeds(testCaseResult_t) extproc('CMDRUNSRV_runProc');
  proc            pointer(*proc) const;
  result          likeds(testCaseResult_t) value;
  procNamePrefix  like(assertProcNm_t) const;
end-pr;

///
// Initialize a test result structure with default values.
// Creates a clean test result data structure and sets
// default values before a test case is executed.
//
// @param outcome  - Initial outcome of the test result
// @param testName - Name of the test procedure
//
// @return Initialized test result structure
///
dcl-pr initTestResult likeds(testCaseResult_t) extproc('CMDRUNSRV_initTestResult');
  outcome  like(outcome_t) const;
  testName like(procNm_t) const;
end-pr;

///
// Disposes a test result and frees resources.
// Deallocates dynamic list and clears the test
// result data structure.
//
// @param testResult - The test result to be disposed
// @param idx        - Index (starting at 1) of the test result that is disposed
///
dcl-pr disposeTestResult extproc('CMDRUNSRV_disposeTestResult');
  testResult likeds(testCaseResult_t);
  idx        int(10) options(*nopass: *omit) const;
end-pr;

///
// Disposes a list of test events and frees resources.
//
// @param hTestEvents - The list of test events to be disposed
// @param idx         - Index (starting at 1) of the test result that is disposed
///
dcl-pr disposeTestEvents extproc('CMDRUNSRV_disposeTestEvents');
  hTestEvents pointer;
  idx         int(10) options(*nopass: *omit) const;
end-pr;

///
// Disposes a test event.
//
// @param idx - Index (starting at 1) of the test event that is disposed
///
dcl-pr disposeTestEvent extproc('CMDRUNSRV_disposeTestEvent');
  hTestEvents pointer const;
  idx         int(10) const;
end-pr;

///
// Disposes a callstack.
//
// @param hCallstack - Handle of the callstack to be disposed
// @param idx        - Index of the test result that is disposed
///
dcl-pr disposeCallstack extproc('CMDRUNSRC_disposeCallstack');
  pCallstack pointer;
  idx        int(10) options(*nopass: *omit) const;
end-pr;

///
// Orchestrates the execution of all test cases within a test suite.
// Manages the test execution flow including individual test setup,
// execution, teardown, and result collection based on specified
// execution parameters and filtering criteria.
//
// @param testSuiteResult - Test result accumulator for collecting execution statistics
// @param testSuite       - Test suite containing test procedures to execute
// @param testProcsToRun  - Filter specifying which test procedures to execute
// @param order           - Execution order specification (*API or *REVERSE)
// @param detail          - Detail level for logging and output
// @param rclRsc          - Resource reclamation strategy between tests
///
dcl-pr runTests extproc('CMDRUNSRV_runTests');
  testSuiteResult likeds(testSuiteResult_t);
  testSuite       likeds(testSuite_t) const;
  testProcsToRun  likeds(procNms_t) const;
  order           char(8) const;
  detail          char(6) const;
  rclRsc          char(10) const;
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
dcl-pr fmtCompMsg varchar(256) extproc('CMDRUNSRV_fmtCompMsg');
  testcasecnt int(10) const;
  assertCnt   int(10) const;
  failureCnt  int(10) const;
  errorCnt    int(10) const;
end-pr;

// Returns the last recorded failure event.
dcl-pr getLastFailureEvent likeds(testFailureEvent_t) extproc('CMDRUNSRV_getLastFailureEvent');
  testResult likeds(testCaseResult_t) const;
end-pr;

// Returns the last recorded error event.
dcl-pr getLastErrorEvent likeds(runtimeErrorEvent_t) extproc('CMDRUNSRV_getLastErrorEvent');
  testResult likeds(testCaseResult_t) const;
end-pr;

dcl-pr writeTestReport extproc('CMRUNSRV_writeTestReport');
  testSuite       likeds(testSuite_t) const;
  testSuiteName   likeds(Object_t) const;
  testSuiteResult likeds(testSuiteResult_t);
end-pr;


///
// Adds a "success" test event.
///
dcl-pr addSuccessTestEvent int(10) extproc('CMDRUNSRV_addSuccessTestEvent');
  hTestEvents      pointer const;
  successTestEvent likeds(testSuccessEvent_t);
end-pr;


///
// Adds a "failure" test event.
///
dcl-pr addFailureTestEvent int(10) extproc('CMDRUNSRV_addFailureTestEvent');
  hTestEvents      pointer const;
  failureTestEvent likeds(testFailureEvent_t);
end-pr;


///
// Adds a "error" test event.
///
dcl-pr addErrorTestEvent int(10) extproc('CMDRUNSRV_addErrorTestEvent');
  hTestEvents    pointer const;
  errorTestEvent likeds(runtimeErrorEvent_t);
end-pr;

///
// Builds the name of the test case as it is displayed in the XML.
// Uses the test case name for assertion mode *ABORT, otherwise
// builds the names with template 'testName.assertProcName'.
// If all assertions are executed, the name of the "virtual" test
// is created as 'testName.assertProcName', otherwise 'testName'.
///
dcl-pr buildReportTestCaseName like(string_t) extproc('CMDRUNSRV_buildReportTestCaseName');
  testCaseResult likeds(testCaseResult_t) const;
  abstractTestEvent likeds(abstractTestEvent_t) const;
end-pr;

///
// Returns the number of assertions as displayed in the XML.
// Returns the total number of assertions for assertion mode *ABORT,
// otherwise 1.
// If all assertions are executed, the number of assertions per "virtual"
// test case is 1, otherwise the total number of assertions.
///
dcl-pr getReportNumAsserts int(10) extproc('CMDRUNSRV_getReportNumAsserts');
  testCaseResult likeds(testCaseResult_t) const;
end-pr;

///
// Returns the number of assertions as displayed in the XML.
// Returns the total number of assertions for assertion mode *ABORT,
// otherwise 1.
// IF all assertions are eceuted, the total execution time is divided
// by the totall number of assertions. There is no way to figure out
// how long it took to process a specific assertion.
///
dcl-pr getReportExecutionTimeTestCase int(10);
  testCaseResult likeds(testCaseResult_t) const;
end-pr;

/include qinclude,templates

