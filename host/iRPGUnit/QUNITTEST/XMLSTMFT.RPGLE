**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test EXTTST.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================
// *VSCODE Notices
// ---------------
// Test case 'testRuntimeError' ends different if executed with *CONTINUE!
//
// If executed with *ABORT, the test case is aborted on the second
// assertEqual(), hence there are 2 test case events.
// But if executed with *CONTINUE, the test case is aborted after the
// second assertEqual() on the runCmd() statement, so there are 3 test
// case events.
//
// *JENKINS Notices
// ================
//
// *ABORT
// ------
// 'Success' events are never added to the XML file.
// Only the events that match the test case result are
// added to the XML output.
//
// *CONTINUE
// ---------
// Produces 1 test case per test event.
// Test case name: [testCase].[assertion]_n
//
// Attributes not used for Jenkins XML:
//   testcase.attr_outcome
//   testCaseEvent.attr_outcome
//   testCaseEvent.failure.attr_name
//   testCaseEvent.failure.attr_line
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,IFSIO_H
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,SDS
/include qinclude,TESTCASE

/include qunittest,SAX_H
/include qsysinc,QCMDEXC

// Constants for the 'run' procedure.
dcl-c ERROR_EXPECTED *on;
dcl-c NO_ERROR *off;

//_C_IFS_tmpnam -- Produce Temporary File Name for the IFS file system
dcl-c L_tmpnam 39;
dcl-pr ifs_tmpnam pointer extproc('_C_IFS_tmpnam');
  fileName char(40);
end-pr;

dcl-ds g_status qualified inz;
  tmpName varchar(L_tmpnam) inz;
end-ds;

//----------------------------------------------------------------------
//   Setup / Teardown
//----------------------------------------------------------------------

dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s tmpName char(40);

  ifs_tmpnam(tmpName);

  g_status.tmpName = %str(%addr(tmpName));

end-proc;

dcl-proc teardown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds st_stat likeds(statds) inz;
  dcl-s rc int(10);

  if (g_status.tmpName <> '');
    rc = stat(g_status.tmpName: st_stat);
    if (rc = 0);
      rc = unlink(g_status.tmpName);
    endif;
  endif;

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *JENKINS1 / *ABORT
//----------------------------------------------------------------------
dcl-proc testJenkins1Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz;
  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-s msgTxt char(256);

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*ABORT) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*JENKINS1)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  validateJenkinsAbort(testSuite);

  // Additional validations of 'testFailure'
  testCase = getTestcase(testSuite.testcases: 1);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('testFailure (TESTPGM23->TESTPGM23:4400)': testCaseEvent.failure.elementText);

  // Additional validations of 'testRuntimeError'
  testCase = getTestcase(testSuite.testcases: 2);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('testRuntimeError (TESTPGM23->TESTPGM23:6600)': testCaseEvent.failure.elementText);

  // Additional validations of 'Success'
  // not applicable

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *JENKINS1 / *CONTINUE
//----------------------------------------------------------------------
dcl-proc testJenkins1Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz;
  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-s msgTxt char(256);

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*CONTINUE) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*JENKINS1)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  validateJenkinsContinue(testSuite);

  // Additional validations of 'testFailure'
  testCase = getTestcase(testSuite.testcases: 1);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('testFailure (TESTPGM23->TESTPGM23:4400)': testCaseEvent.failure.elementText);

  // Additional validations of 'testRuntimeError'
  testCase = getTestcase(testSuite.testcases: 4);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('testRuntimeError (TESTPGM23->TESTPGM23:6600)': testCaseEvent.failure.elementText);

  testCase = getTestcase(testSuite.testcases: 5);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('*N (QCMDEXC->*N:0277)': testCaseEvent.error.elementText);

  // Additional validations of 'Success'
  // not applicable

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *JENKINS2 / *ABORT
//----------------------------------------------------------------------
dcl-proc testJenkins2Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz;
  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-s msgTxt char(256);
  dcl-ds lines likeds(saxElementLines_t) Inz;

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*ABORT) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*JENKINS2)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  validateJenkinsAbort(testSuite);

  // Additional validations of 'testFailure'
  testCase = getTestcase(testSuite.testcases: 1);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);

  lines = SAX_getElementTextLines(testCaseEvent.failure.elementText);
  assertEqual(8: lines.size);
  assertEqual('Callstack:': lines.line(1));
  assertEqual('  testFailure (TESTPGM23->TESTPGM23:4400)': lines.line(2));
  assertEqual('': lines.line(3));
  assertEqual('Expected:': lines.line(4));
  assertEqual('  Donald Duck': lines.line(5));
  assertEqual('': lines.line(6));
  assertEqual('Actual:': lines.line(7));
  assertEqual('  Dagobert Duck': lines.line(8));

  // Additional validations of 'testRuntimeError'
  testCase = getTestcase(testSuite.testcases: 2);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);

  lines = SAX_getElementTextLines(testCaseEvent.failure.elementText);
  assertEqual(8: lines.size);
  assertEqual('Callstack:': lines.line(1));
  assertEqual('  testRuntimeError (TESTPGM23->TESTPGM23:6600)': lines.line(2));
  assertEqual('': lines.line(3));
  assertEqual('Expected:': lines.line(4));
  assertEqual('  Daisy Duck': lines.line(5));
  assertEqual('': lines.line(6));
  assertEqual('Actual:': lines.line(7));
  assertEqual('  Gustav Gans': lines.line(8));

  // Additional validations of 'Success'
  // not applicable

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *JENKINS2 / *CONTINUE
//----------------------------------------------------------------------
dcl-proc testJenkins2Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-ds testSuite likeds(saxTestSuite_t) inz;
  dcl-s msgTxt char(256);
  dcl-ds lines likeds(saxElementLines_t) Inz;

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*CONTINUE) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*JENKINS2)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  validateJenkinsContinue(testSuite);

  // Additional validations of 'testFailure'
  testCase = getTestcase(testSuite.testcases: 1);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);

  lines = SAX_getElementTextLines(testCaseEvent.failure.elementText);
  assertEqual(8: lines.size);
  assertEqual('Callstack:': lines.line(1));
  assertEqual('  testFailure (TESTPGM23->TESTPGM23:4400)': lines.line(2));
  assertEqual('': lines.line(3));
  assertEqual('Expected:': lines.line(4));
  assertEqual('  Donald Duck': lines.line(5));
  assertEqual('': lines.line(6));
  assertEqual('Actual:': lines.line(7));
  assertEqual('  Dagobert Duck': lines.line(8));

  // Additional validations of 'testRuntimeError'
  testCase = getTestcase(testSuite.testcases: 4);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);

  testCase = getTestcase(testSuite.testcases: 5);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);
  assertEqual('*N (QCMDEXC->*N:0277)': testCaseEvent.error.elementText);

  lines = SAX_getElementTextLines(testCaseEvent.error.elementText);
  assertEqual(2: lines.size);
  assertEqual('*N': lines.line(1));
  assertEqual('(QCMDEXC->*N:0277)': lines.line(2));

  // Additional validations of 'Success'
  testCase = getTestcase(testSuite.testcases: 8);
  testCaseEvent = getTestCaseEvent(testCase.events: 1);

  lines = SAX_getElementTextLines(testCaseEvent.failure.elementText);
  assertEqual(6: lines.size);
  assertEqual('Callstack:': lines.line(1));
  assertEqual('  testSuccess (TESTPGM23->TESTPGM23:9600)': lines.line(2));
  assertEqual('': lines.line(3));
  assertEqual('Diagnostic messages:': lines.line(4));
  assertEqual('  No ''expected'' value. Procedure assert() does not provide this information.'
             : lines.line(5));
  assertEqual('  No ''actual'' value. Procedure assert() does not provide this information.'
             : lines.line(6));

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *VSCODE1 / *ABORT
//----------------------------------------------------------------------
dcl-proc testVSCode1Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz(*likeds);
  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-ds callstackEntry likeds(saxCallstackEntry_t) inz(*likeds);
  dcl-s msgTxt char(256);

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*ABORT) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*VSCODE1)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  // Validate: Test Suite

  assertEqual('0': testSuite.attr_errors);
  assertEqual('2': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1: testFailure

  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Failure': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('Failure': testCaseEvent.attr_outcome);
  assertEqual('assertEqual_string': testCaseEvent.failure.attr_name);
  assertEqual('Expected ''Donald Duck'', but was ''Dagobert Duck''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('4400': testCaseEvent.failure.attr_line);

  callstackEntry = getCallstackEntry(testCaseEvent.failure.callstack: 1);
  assertEqual('TESTPGM23': callstackEntry.attr_program);
  assertEqual('TESTPGM23': callstackEntry.attr_module);
  assertEqual('testFailure': callstackEntry.attr_procedure);
  assertEqual('4400': callstackEntry.attr_line);

  assertEqual(1: testcase.events.size);

  // Validate: Test Case #2: testRuntimeError

  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Failure': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 2);
//  assertEqual('Failure': testCaseEvent.attr_outcome);
  assertEqual('Expected ''Daisy Duck'', but was ''Gustav Gans''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('6600': testCaseEvent.failure.attr_line);
  assertEqual('Daisy Duck': testCaseEvent.failure.expected.attr_value);
  assertEqual('string': testCaseEvent.failure.expected.attr_type);
  assertEqual('10': testCaseEvent.failure.expected.attr_length);
  assertEqual('10': testCaseEvent.failure.expected.attr_originalLength);
  assertEqual('Gustav Gans': testCaseEvent.failure.actual.attr_value);
  assertEqual('string': testCaseEvent.failure.actual.attr_type);
  assertEqual('11': testCaseEvent.failure.actual.attr_length);
  assertEqual('11': testCaseEvent.failure.actual.attr_originalLength);

  assertEqual(2: testcase.events.size);

  // Validate: Test Case #3: testSuccess

  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testSuccess': testcase.attr_name);
  assertEqual('3': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Success': testcase.attr_outcome);

  assertEqual(3: testcase.events.size);

end-proc;

//----------------------------------------------------------------------
// Tests the XML output of: *VSCODE1 / *CONTINUE
//----------------------------------------------------------------------
dcl-proc testVSCode1Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz(*likeds);
  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);
  dcl-ds callstackEntry likeds(saxCallstackEntry_t) inz(*likeds);
  dcl-s msgTxt char(256);

  if (TestSuite_isDirty('TESTPGM23': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM23) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  saveAssertStatus();

  run('RUCALLTST TSTPGM(QTEMP/TESTPGM23) ONFAILURE(*CONTINUE) '
      + ' XMLSTMF(''' + g_status.tmpName + ''') XMLTYPE(*VSCODE1)'
      : ERROR_EXPECTED: '*ESCAPE': msgTxt);

  restoreAssertStatus();

  testSuite = parseXml(g_status.tmpName);

  // Validate: Test Suite

  assertEqual('1': testSuite.attr_errors);
  assertEqual('2': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1: testFailure

  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Failure': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('Failure': testCaseEvent.attr_outcome);
  assertEqual('assertEqual_string': testCaseEvent.failure.attr_name);
  assertEqual('Expected ''Donald Duck'', but was ''Dagobert Duck''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('4400': testCaseEvent.failure.attr_line);

  callstackEntry = getCallstackEntry(testCaseEvent.failure.callstack: 1);
  assertEqual('TESTPGM23': callstackEntry.attr_program);
  assertEqual('TESTPGM23': callstackEntry.attr_module);
  assertEqual('testFailure': callstackEntry.attr_procedure);
  assertEqual('4400': callstackEntry.attr_line);

  assertEqual(2: testcase.events.size);

  // Validate: Test Case #2: testRuntimeError

  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Error': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('Success': testCaseEvent.attr_outcome);
  assertEqual('assertEqual_string': testCaseEvent.success.attr_name);
  assertEqual('6300': testCaseEvent.success.attr_line);
  assertEqual('Tick': testCaseEvent.success.expected.attr_value);
  assertEqual('string': testCaseEvent.success.expected.attr_type);
  assertEqual('4': testCaseEvent.success.expected.attr_length);
  assertEqual('4': testCaseEvent.success.expected.attr_originalLength);

  testCaseEvent = getTestCaseEvent(testCase.events: 2);
//  assertEqual('Failure': testCaseEvent.attr_outcome);
  assertEqual('assertEqual_string': testCaseEvent.failure.attr_name);
  assertEqual('Expected ''Daisy Duck'', but was ''Gustav Gans''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('6600': testCaseEvent.failure.attr_line);
  assertEqual('Daisy Duck': testCaseEvent.failure.expected.attr_value);
  assertEqual('string': testCaseEvent.failure.expected.attr_type);
  assertEqual('10': testCaseEvent.failure.expected.attr_length);
  assertEqual('10': testCaseEvent.failure.expected.attr_originalLength);
  assertEqual('Gustav Gans': testCaseEvent.failure.actual.attr_value);
  assertEqual('string': testCaseEvent.failure.actual.attr_type);
  assertEqual('11': testCaseEvent.failure.actual.attr_length);
  assertEqual('11': testCaseEvent.failure.actual.attr_originalLength);

  testCaseEvent = getTestCaseEvent(testCase.events: 3);
//  assertEqual('Error': testCaseEvent.attr_outcome);
  assertEqual('Errors occurred in command.': testCaseEvent.error.attr_message);
  assertEqual('CPF0006': testCaseEvent.error.attr_type);

  assertEqual(3: testcase.events.size);

  // Validate: Test Case #3: testSuccess

  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testSuccess': testcase.attr_name);
  assertEqual('3': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('ms': testcase.attr_timeUnit);
  assertEqual('Failure': testcase.attr_outcome);

  assertEqual(3: testcase.events.size);

end-proc;

//----------------------------------------------------------------------
// Validates the test results of *JENKINS1 and *JENKINS2 (*ABORT)
//----------------------------------------------------------------------
dcl-proc validateJenkinsAbort;
  dcl-pi *n extproc(*dclcase);
    testSuite likeds(saxTestSuite_t);
  end-pi;

  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);

  // Validate: Test Suite

  assertEqual('0': testSuite.attr_errors);
  assertEqual('2': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1: testFailure

  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('': testCaseEvent.attr_outcome);
  assertEqual('': testCaseEvent.failure.attr_name);
  assertEqual('Expected ''Donald Duck'', but was ''Dagobert Duck''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('': testCaseEvent.failure.attr_line);

  assertEqual(0: testCaseEvent.failure.callstack.size);

  assertEqual(1: testcase.events.size);

  // Validate: Test Case #2: testRuntimeError

  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('': testCaseEvent.attr_outcome);
  assertEqual('Expected ''Daisy Duck'', but was ''Gustav Gans''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('': testCaseEvent.failure.attr_line);

  assertEqual(*on: testCaseEvent.failure.expected.isNull);

  assertEqual(1: testcase.events.size);

  // Validate: Test Case #3: testSuccess

  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testSuccess': testcase.attr_name);
  assertEqual('3': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  assertEqual(0: testcase.events.size);

end-proc;

//----------------------------------------------------------------------
// Validates the test results of *JENKINS1 and *JENKINS2 (*CONTINUE)
//----------------------------------------------------------------------
dcl-proc validateJenkinsContinue;
  dcl-pi *n extproc(*dclcase);
    testSuite likeds(saxTestSuite_t);
  end-pi;

  dcl-ds testCase likeds(saxTestCase_t) inz(*likeds);
  dcl-ds testCaseEvent likeds(saxAbstractTestCaseEvent_t) inz(*likeds);

  // Validate: Test Suite

  assertEqual('1': testSuite.attr_errors);
  assertEqual('2': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1: testFailure

  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure.assertEqual_string_1': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('': testCaseEvent.attr_outcome);
  assertEqual('': testCaseEvent.failure.attr_name);
  assertEqual('Expected ''Donald Duck'', but was ''Dagobert Duck''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('': testCaseEvent.failure.attr_line);
  assertEqual(0: testCaseEvent.failure.callstack.size);

  assertEqual(1: testcase.events.size);

  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testFailure.aEqual_2': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  assertEqual(0: testcase.events.size);

  // Validate: Test Case #2: testRuntimeError

  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testRuntimeError.assertEqual_string_1': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  assertEqual(0: testcase.events.size);

  testCase = getTestcase(testSuite.testcases: 4);
  assertEqual('testRuntimeError.assertEqual_string_2': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('': testCaseEvent.attr_outcome);
  assertEqual('Expected ''Daisy Duck'', but was ''Gustav Gans''.'
              : testCaseEvent.failure.attr_message);
  assertEqual('': testCaseEvent.failure.attr_line);

  assertEqual(1: testcase.events.size);

  testCase = getTestcase(testSuite.testcases: 5);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  testCaseEvent = getTestCaseEvent(testCase.events: 1);
//  assertEqual('': testCaseEvent.attr_outcome);
  assertEqual('Errors occurred in command.': testCaseEvent.error.attr_message);
  assertEqual('CPF0006': testCaseEvent.error.attr_type);

  assertEqual(1: testcase.events.size);

  // Validate: Test Case #3: testSuccess

  testCase = getTestcase(testSuite.testcases: 6);
  assertEqual('testSuccess.assertEqual_string_1': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('s': testcase.attr_timeUnit);
  assertEqual('': testcase.attr_outcome);

  assertEqual(0: testcase.events.size);

end-proc;

//----------------------------------------------------------------------
//   Helper Procedures
//----------------------------------------------------------------------

dcl-proc getTestcase;
  dcl-pi *n likeds(saxTestCase_t) extproc(*dclcase);
    testCases likeds(saxTestCases_t) const;
    index     int(10) const;
  end-pi;

  return testcases.testcase(index);

end-proc;

dcl-proc getTestCaseEvent;
  dcl-pi *n likeds(saxAbstractTestCaseEvent_t) extproc(*dclcase);
    testCaseEvents likeds(saxTestCaseEvents_t) const;
    index          int(10) const;
  end-pi;

  return testCaseEvents.testCaseEvent(index);

end-proc;

dcl-proc getCallstackEntry;
  dcl-pi *n likeds(saxCallstackEntry_t) extproc(*dclcase);
    callstack likeds(saxCallstack_t) const;
    index     int(10) const;
  end-pi;

  return callstack.stackEntry(index);

end-proc;

dcl-proc run;
  dcl-pi *n extproc(*dclcase);
    cmd             varchar(32767) const;
    errorExpected   ind const options(*NoPass);
    msgType         char(10) const options(*NoPass);
    msgTxt          char(256) options(*NoPass);
  end-pi;


  if %parms >= 2 and errorExpected;
    callp(e) qcmdexc( cmd: %len(cmd) );
    assert( %error: 'Expected error missing');
  else;
    qcmdexc( cmd: %len(cmd) );
  endif;

  if %parms >= 4;
    msgTxt = rcvMsgTxt( msgType );
  endif;

end-proc;

dcl-proc parseXml;
  dcl-pi *n likeds(saxTestSuite_t) extproc(*dclcase);
    path varchar(1024) options(*varsize);
  end-pi;

  dcl-ds testSuite likeds(saxTestSuite_t) inz;

  SAX_initialize();

  xml-sax %handler(SAX_CallbackHandler: testSuite) %XML(path: 'doc=file');

  return testSuite;

end-proc;
