**FREE
// ==========================================================================
//  iRPGUnit - Extract Test Cases.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Activate Test Suite for Execution
//
// Prepares a test suite for execution by loading and activating all test
// procedures. Sets up the test environment and marks procedures as ready
// for execution within the specified activation group.
//
// @param testSuite - Test suite structure to activate (modified by reference)
// @param actMark - Activation mark to identify the activation group context
///
dcl-pr activateTestSuite extproc('EXTTST_activateTestSuite');
  testSuite likeds(testSuite_t);
  actMark   like(actMark_t) const;
end-pr;

///
// Retrieve Test Procedure Information
//
// Returns detailed information about a specific test procedure within a test
// suite. Provides access to procedure metadata including name, address, and
// execution context for test runner operations.
//
// @param testSuite - Test suite containing the desired test procedure
// @param testIdx   - Zero-based index of the test procedure to retrieve
//
// @return Procedure structure containing test procedure details
///
dcl-pr getTestProc likeds(proc_t) extproc('EXTTST_getTestProc');
  testSuite likeds(testSuite_t) const;
  testIdx   int(10) const;
end-pr;

///
// Build Test Suite from Procedure List
//
// Analyzes a list of procedure names and constructs a test suite containing
// all procedures that match test case naming conventions. Filters procedures
// to identify setup, teardown, and test methods for organized execution.
//
// @param procNmList - List of procedure names to analyze for test patterns
//
// @return Constructed test suite structure containing identified test procedures
///
dcl-pr getTestSuite likeds(testSuite_t) extproc('EXTTST_getTestSuite');
  procNmList likeds(procNmList_t) const;
end-pr;

///
// Get Test Case Name
//
// Retrieves the name of a specific test case within a test suite. Used for
// test reporting, logging, and identification purposes during test execution.
//
// @param testSuite - Test suite containing the test case
// @param testIdx   - Zero-based index of the test case to query
//
// @return Name of the specified test case procedure
///
dcl-pr getTestNm extproc('EXTTST_getTestNm') like(procNm_t);
  testSuite likeds(testSuite_t) const;
  testIdx   int(10) const;
end-pr;
