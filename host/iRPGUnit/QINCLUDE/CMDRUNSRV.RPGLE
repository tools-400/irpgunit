**FREE
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
// Execute a complete test case with setup and teardown procedures.
// Runs the specified test procedure along with its associated setup and
// teardown procedures in the proper sequence. Captures and returns
// comprehensive test execution results including timing and outcome.
//
// @param testproc - Test procedure to execute
// @param setup    - Setup procedure to run before the test (may be null)
// @param teardown - Teardown procedure to run after the test (may be null)
//
// @return Complete test result with execution details and outcome
///
dcl-pr runTestProc extproc('CMDRUNSRV_runTestProc') likeds(testResult_t);
  testproc likeds(proc_t) const;
  setup    likeds(proc_t) const;
  teardown likeds(proc_t) const;
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
//
// @return Complete test result including outcome and execution details
///
dcl-pr runTest extproc('CMDRUNSRV_runTest') likeds(testResult_t);
  testSuite likeds(testSuite_t) const;
  testIdx   int(10) const;
end-pr;

///
// Run a setup, teardown or test procedure.
// Safely executes a procedure pointer while capturing any
// assertion failures or runtime errors that occur during execution.
//
// @param proc   - Procedure pointer
// @param result - Test result
//
// @return Test result
///
dcl-pr runProc likeds(testResult_t) extproc('CMDRUNSRV_runProc');
  proc   pointer(*proc) const;
  result likeds(testResult_t);
end-pr;

///
// Initialize a test result structure with default values.
// Creates a clean test result data structure and sets
// default values before a test case is executed.
//
// @param testName - Name of the test procedure
//
// @return Initialized test result structure
///
dcl-pr initTestResult likeds(testResult_t) extproc('CMDRUNSRV_initTestResult');
  testName like(procNm_t) const;
end-pr;
