**FREE
// ==========================================================================
//  iRPGUnit - XML File Writer.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Writes test results to an XML file in JUnit-compatible format
//
// Generates a comprehensive XML report of test execution results in JUnit format,
// compatible with most CI/CD systems, IDEs, and build tools. The XML output includes
// detailed test case information, execution times, failure details, and test suite
// metadata. This enables seamless integration with automated testing pipelines and
// provides standardized reporting for test results analysis.
//
// @param filepath      - Full IFS path where the XML file will be created and written
//                        Can be absolute or relative path (up to 1024 characters)
//                        Directory must exist and be writable by the current user
//                        Existing files will be overwritten without warning
//                        Example: '/tmp/test-results.xml' or '/home/user/reports/junit.xml'
// @param testSuite     - Test suite data structure containing comprehensive test information
//                        Includes test procedure metadata, setup/teardown information,
//                        and organizational details about the test suite structure
//                        Must be properly initialized with valid test suite data
// @param testSuiteName - Qualified object name identifying the test suite service program
//                        Structure: library/object format for the source test suite
//                        Used in XML for test suite identification and traceability
//                        Appears in XML as test suite name and class attributes
// @param result        - Test execution results data structure containing detailed outcomes
//                        Includes individual test case results, timing information,
//                        failure details, error messages, and execution statistics
//                        Contains both summary and detailed test execution data
///
dcl-pr writeXmlFile extproc('XMLWRITER_writeXmlFile');
  filepath       char(1024) const;
  testSuite      likeds(testSuite_t) const;
  testSuiteName  likeds(Object_t) const;
  result         likeds(result_t) const;
end-pr;

