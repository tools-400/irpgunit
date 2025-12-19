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

///
// Builds and returns a callstack version 1 item.
///
dcl-pr Jenkins_appendTestCaseFailureV1 like(xmlBufferLarge_t) extproc('JENKINS_+
                                                        Jenkins_appendTestCaseFailureV1');
  pCallstack  pointer const;
end-pr;

///
// Builds and returns a callstack version 2 item.
///
dcl-pr Jenkins_buildCallStackV2 extproc('JENKINS_Jenkins_buildCallStackV2');
  pCallstk pointer const;
end-pr;

///
// Produces a Json object with the following format:
//
// {
//     "callstack": [
//         "callstack-items"
//     ],
//     "expected": {
//         "value": "theValue",
//         "type": "theType",
//         "length": 0,
//         "originalLength": 0
//     },
//     "actual": {
//         "value": "theValue",
//         "type": "theType",
//         "length": 0,
//         "originalLength": 0
//     },
//     "diagnosticMessages": [
//         "diagnostic-messages"
//     ]
// }
///
dcl-pr Jenkins_appendTestCaseAsJson like(xmlBufferLarge_t) extproc('JENKINS_+
                                                                Jenkins_appendTestCaseAsJson');
  testFailureEvent likeds(testFailureEvent_t) const;
end-pr;

///
// Appends a test case event in text format.
///
dcl-pr Jenkins_appendTestCaseFailureAsText extproc('JENKINS_Jenkins_appendTestCaseFailureAsText');
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

