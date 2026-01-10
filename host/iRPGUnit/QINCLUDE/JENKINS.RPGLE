**FREE
// ==========================================================================
//  iRPGUnit - Jenkins File Writer.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-pr Jenkins_writeTestCases extproc('JENKINS_Jenkins_writeTestCases');
  testSuite     likeds(testSuite_t) const;
  testSuiteName likeds(Object_t) const;
  result        likeds(testSuiteResult_t) const;
end-pr;

///
// Builds and returns a callstack version 1 item.
///
dcl-pr Jenkins_writeTestCaseFailureV1 extproc('JENKINS_Jenkins_writeTestCaseFailureV1');
  pCallstack  pointer const;
end-pr;

///
// Builds and returns a callstack version 2 item.
///
dcl-pr Jenkins_buildCallStackV2 extproc('JENKINS_Jenkins_buildCallStackV2');
  pCallstk pointer const;
end-pr;

///
// Appends a test case event in text format.
///
dcl-pr Jenkins_writeTestCaseFailureV2 extproc('JENKINS_Jenkins_writeTestCaseFailureV2');
  testFailureEvent likeds(testFailureEvent_t) const;
end-pr;

///
// Appends the log value (expected and actual) to the Json object.
///
dcl-pr Jenkins_appendFailureValues extproc('JENKINS_Jenkins_appendFailureValues');
  testFailureEvent likeds(testFailureEvent_t) const;
end-pr;

///
// Appends a log value (expected or actual) to the Json object.
///
dcl-pr Jenkins_appendLogValue extproc('JENKINS_Jenkins_appendLogValue');
  name     varchar(20) const;
  logValue likeds(logValue_t) const;
end-pr;

