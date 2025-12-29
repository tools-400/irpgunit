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
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc testJenkins1Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

dcl-proc testJenkins1Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

dcl-proc testJenkins2Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

dcl-proc testJenkins2Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

dcl-proc testVSCode1Abort export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(xmlTestSuite_t) inz(*likeds);
  dcl-ds testCase likeds(xmlTestCase_t) inz(*likeds);
  dcl-ds assertion likeds(xmlAbstractAssertion_t) inz(*likeds);
  dcl-ds callstackEntry likeds(xmlCallstackEntry_t) inz(*likeds);
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

  SAX_initialize();

  xml-sax %handler(SAX_CallbackHandler: testSuite)
          %XML(g_status.tmpName: 'doc=file');

  // Validate: Test Suite
  assertEqual('1': testSuite.attr_errors);
  assertEqual('1': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1
  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Failure': testcase.attr_outcome);

  assertion = getAssertion(testCase.assertions: 1);
  assertEqual('Failure': assertion.attr_outcome);
  assertEqual('assertEqual_string': assertion.failure.attr_name);
  assertEqual('Expected ''Donald'', but was ''Dagobert''.': assertion.failure.attr_message);
  assertEqual('5400': assertion.failure.attr_line);

  callstackEntry = getCallstackEntry(assertion.failure.callstack: 1);
  assertEqual('TESTPGM23': callstackEntry.attr_program);
  assertEqual('TESTPGM23': callstackEntry.attr_module);
  assertEqual('testFailure': callstackEntry.attr_procedure);
  assertEqual('5400': callstackEntry.attr_line);

  assertEqual(1: testcase.assertions.size);

  // Validate: Test Case #2
  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Error': testcase.attr_outcome);

  assertion = getAssertion(testCase.assertions: 1);
  assertEqual('Error': assertion.attr_outcome);
  assertEqual('Errors occurred in command.': assertion.error.attr_message);
  assertEqual('CPF0006': assertion.error.attr_type);

  assertEqual(1: testcase.assertions.size);

  // Validate: Test Case #3
  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testSuccess': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Success': testcase.attr_outcome);

  assertEqual(0: testcase.assertions.size);

end-proc;

dcl-proc testVSCode1Continue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(xmlTestSuite_t) inz(*likeds);
  dcl-ds testCase likeds(xmlTestCase_t) inz(*likeds);
  dcl-ds assertion likeds(xmlAbstractAssertion_t) inz(*likeds);
  dcl-ds callstackEntry likeds(xmlCallstackEntry_t) inz(*likeds);
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

  SAX_initialize();

  xml-sax %handler(SAX_CallbackHandler: testSuite)
          %XML(g_status.tmpName: 'doc=file');

  // Validate: Test Suite
  assertEqual('1': testSuite.attr_errors);
  assertEqual('1': testSuite.attr_failures);
  assert(testSuite.attr_hostname <> '');
  assertEqual('QTEMP/TESTPGM23': testSuite.attr_name);
  assertEqual('3': testSuite.attr_tests);

  // Validate: Test Case #1
  testCase = getTestcase(testSuite.testcases: 1);
  assertEqual('testFailure': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Failure': testcase.attr_outcome);

  assertion = getAssertion(testCase.assertions: 1);
  assertEqual('Failure': assertion.attr_outcome);
  assertEqual('assertEqual_string': assertion.failure.attr_name);
  assertEqual('Expected ''Donald'', but was ''Dagobert''.': assertion.failure.attr_message);
  assertEqual('5400': assertion.failure.attr_line);

  callstackEntry = getCallstackEntry(assertion.failure.callstack: 1);
  assertEqual('TESTPGM23': callstackEntry.attr_program);
  assertEqual('TESTPGM23': callstackEntry.attr_module);
  assertEqual('testFailure': callstackEntry.attr_procedure);
  assertEqual('5400': callstackEntry.attr_line);

  assertEqual(2: testcase.assertions.size);

  // Validate: Test Case #2
  testCase = getTestcase(testSuite.testcases: 2);
  assertEqual('testRuntimeError': testcase.attr_name);
  assertEqual('1': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Error': testcase.attr_outcome);

  assertion = getAssertion(testCase.assertions: 1);
  assertEqual('Success': assertion.attr_outcome);
  assertEqual('assertEqual_string': assertion.success.attr_name);
  assertEqual('6800': assertion.success.attr_line);

  assertEqual('Dagobert': assertion.success.expected.attr_value);
  assertEqual('string': assertion.success.expected.attr_type);
  assertEqual('8': assertion.success.expected.attr_length);
  assertEqual('8': assertion.success.expected.attr_originalLength);

  assertion = getAssertion(testCase.assertions: 2);
  assertEqual('Error': assertion.attr_outcome);
  assertEqual('Errors occurred in command.': assertion.error.attr_message);
  assertEqual('CPF0006': assertion.error.attr_type);

  assertEqual(2: testcase.assertions.size);

  // Validate: Test Case #3
  testCase = getTestcase(testSuite.testcases: 3);
  assertEqual('testSuccess': testcase.attr_name);
  assertEqual('2': testcase.attr_assertions);
  assertEqual('TESTPGM23': testcase.attr_classname);
  assert(testcase.attr_time <> '');
  assertEqual('Success': testcase.attr_outcome);

  assertEqual(2: testcase.assertions.size);

end-proc;

//----------------------------------------------------------------------
//   Helper Procedures
//----------------------------------------------------------------------

dcl-proc getTestcase;
  dcl-pi *n likeds(xmlTestCase_t) extproc(*dclcase);
    testCases likeds(xmlTestCases_t) const;
    index     int(10) const;
  end-pi;

  return testcases.testcase(index);

end-proc;

dcl-proc getAssertion;
  dcl-pi *n likeds(xmlAbstractAssertion_t) extproc(*dclcase);
    assertions likeds(xmlAssertions_t) const;
    index      int(10) const;
  end-pi;

  return assertions.assertion(index);

end-proc;

dcl-proc getCallstackEntry;
  dcl-pi *n likeds(xmlCallstackEntry_t) extproc(*dclcase);
    callstack likeds(xmlCallstack_t) const;
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

