**FREE
// ==========================================================================
//  iRPGUnit - VS Code File Writer.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Writes the XML test cases section.
//
// @param testSuite       - Test suite data structure containing comprehensive test information
//                          Includes test procedure metadata, setup/teardown information,
//                          and organizational details about the test suite structure
//                          Must be properly initialized with valid test suite data
// @param testSuiteName   - Qualified object name identifying the test suite service program
//                          Structure: library/object format for the source test suite
//                          Used in XML for test suite identification and traceability
//                          Appears in XML as test suite name and class attributes
// @param testSuiteResult - Test execution results data structure containing detailed outcomes
//                          Includes individual test case results, timing information,
//                          failure details, error messages, and execution statistics
//                          Contains both summary and detailed test execution data
///
dcl-pr VSCode_writeTestCases extproc('VSCODE_VSCode_writeTestCases');
  testSuite       likeds(testSuite_t) const;
  testSuiteName   likeds(Object_t) const;
  testSuiteResult likeds(testSuiteResult_t) const;
end-pr;

