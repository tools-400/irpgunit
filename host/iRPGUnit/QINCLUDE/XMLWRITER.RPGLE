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
// @param filePath        - Full IFS path where the XML file will be created and written
//                          Can be absolute or relative path (up to 1024 characters)
//                          Directory must exist and be writable by the current user
//                          Existing files will be overwritten without warning
//                          Example: '/tmp/test-results.xml' or '/home/user/reports/junit.xml'
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
// @param xmlType         - Specifies the type of XML to produce. The possible values are:
//                            *JENKINS1 - Legacy type.
//                            *JENKINS2 - Extended type with 'expected' and 'actual' values.
//                            *VSCODE1  - Output type for VS Code.
// @param onFailure       - Specifies the behavior on failed assertions. The possible values are:
//                            *ABORT    - Aborts on a failed assertion.
//                            *CONTINUE - Continues after a failed assertion.
// @param isJUnitStyle    - Specifies whether the test case fails on the first
//                          failed assertion. Fails on the first failed assertion
//                          if set to *on, otherwise continues.
///

dcl-pr writeXmlFile extproc('XMLWRITER_writeXmlFile');
  filePath        char(1024) const;
  testSuite       likeds(testSuite_t) const;
  testSuiteName   likeds(Object_t) const;
  testSuiteResult likeds(testSuiteResult_t) const;
  xmlType         like(xmlType_t) const;
  onFailure       like(onFailure_t) const;
  isJUnitStyle    ind const;
end-pr;

// ==========================================================================
//  Internal stuff.
// ==========================================================================

dcl-s xmlName_t varchar(100) template;
dcl-s xmlValue_t varchar(500) template;
dcl-s xmlBuffer_t varchar(3000) template;
dcl-s xmlBufferLarge_t varchar(10000) template;

dcl-ds xmlWriter_t qualified template;
  xmlType       like(xmlType_t);
  onFailure     like(onFailure_t);
  isJUnitStyle  ind;
  isPrettyPrint ind;
  indLvl        int(10);
end-ds;

dcl-ds sharedChars_t qualified template;
  START_CDATA varchar(30);
  END_CDATA   varchar(30);
end-ds;

///
// Returns the XML representation of a test case event.
///
dcl-pr writeTestCaseEventXml extproc('XMLWRITER_writeTestCaseEventXml');
  abstractTestEvent likeds(abstractTestEvent_t) const;
end-pr;

///
// Produces the 'No value' message.
///
dcl-pr crtNoValueMsg varchar(256) extproc('XMLWRITER_crtNoValueMsg');
  name       varchar(20) const;
  assertProc like(assertProcNm_t) const;
end-pr;

///
// Escapes a given value for beeing added to a XML string.
//
// Use this StackOverflow answer for implementing escaping:
// https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
///
dcl-pr escapeXml like(xmlBuffer_t) extproc('XMLWRITER_escapeXml');
  xml like(xmlBuffer_t) options(*varsize) const;
end-pr;

///
// Returns the name of the assertion depending of the test case type.
///
dcl-pr getAssertProcName like(procNm_t) extproc('XML_WRITER_getAssertProcName');
  abstractTestEvent likeds(abstractTestEvent_t) const;
end-pr;

///
// Returns the name of the test case as is.
///
dcl-pr getTestCaseName like(procNm_t) extproc('XMLWRITER_getTestCaseName');
  testCaseResult likeds(testCaseResult_t) const;
end-pr;

///
// Returns the indention for pretty printing.
///
dcl-pr indent varchar(100) extproc('XMLWRITER_indent');
end-pr;

///
// Returns the linefeed character for pretty printing.
///
dcl-pr newLine varchar(10) extproc('XMLWRITER_newLine');
end-pr;

///
// Returns the XML representation of 'outcome'.
///
dcl-pr outcomeToXml varchar(30) extproc('XMLWRITER_outcomeToXml');
  outcome like(outcome_t) const;
end-pr;

///
// Write an XML element.
///
dcl-pr writeXmlElement extproc('XMLWRITER_writeXmlElement');
  name  like(xmlName_t) options(*varsize) const;
  value like(xmlValue_t) options(*varsize) const;
end-pr;

///
// Starts an XML element.
///
dcl-pr startXmlElement like(xmlName_t) extproc('XMLWRITER_startXmlElement');
  name like(xmlName_t) value;
end-pr;

///
// Starts an XML element.
///
dcl-pr endXmlElement like(xmlName_t) extproc('XMLWRITER_endXmlElement');
  name like(xmlName_t) value;
end-pr;

///
// Produces an empty XML element.
///
dcl-pr emptyXmlElement like(xmlName_t) extproc('XMLWRITER_emptyXmlElement');
  name   like(xmlName_t) value;
end-pr;

///
// Writes the specified data to the XML output file.
///
dcl-pr appendToXmlFile extproc('XMLWRITER_appendToXmlFile');
  text like(xmlBufferLarge_t) options(*varsize);
end-pr;

