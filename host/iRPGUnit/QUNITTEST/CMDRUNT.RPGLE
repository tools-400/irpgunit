**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/CMDRUNT);
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//     >>PARM<<  BOPTION(*DUPPROC);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

// This module mocks the CMDRUNLOG procedures.
/copy qinclude,CMDRUNLOG

/copy qinclude,ASSERT
/copy qinclude,CALLPRC
/copy qinclude,CMDRUNSRV
/copy qinclude,OBJECT
/copy qinclude,PGMMSG
/copy qinclude,TYPES_H
/copy qllist,llist_h

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// TSTPRC option.
dcl-c ALL_PROCS const('*ALL');


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// In-memory log spool, made of an array and its index.
dcl-ds g_logLine qualified Dim(2);
  type            like(testCaseResult_t.outcome);
  procNm          like(ProcNm_t);
  assertionCnt    int(10);
  msg             like(Msg_t.txt);
end-ds;

dcl-s g_logIdx int(10);

// Procedures to run
dcl-ds g_procNms likeds(ProcNms_t);

// Spying flag.
dcl-s g_procWithNoErrorWasCalled ind;

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-ds g_qTestSuite likeds(object_t) inz;

dcl-proc setupSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_qTestSuite.nm = 'TESTPGM03';
  g_qTestSuite.lib = 'QTEMP';

  if (TestSuite_isDirty(g_qTestSuite.nm: g_qTestSuite.lib));
    runCmd('RUCRTRPG TSTPGM(' + %trim(g_qTestSuite.lib) + '/' + %trim(g_qTestSuite.nm) + ') +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

end-proc;

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear g_logIdx;
  clear g_logLine;

  clear g_procWithNoErrorWasCalled;
  clear g_procNms;

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailBasic export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_1';
  testCase(1).procptr = %paddr(successful_test_1);
  g_procNms.numE = 1;
  g_procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_BASIC: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_BASIC);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(0: g_logIdx);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailAllAndOneAssertion export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

// -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_with_one_assertion';
  testCase(1).procPtr = %paddr(successful_test_with_one_assertion);
  g_procNms.numE = 1;
  g_procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

// --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(1 : g_logIdx);
  aEqual(TEST_CASE_SUCCESS: g_logLine(1).type);
  aEqual('successful_test_with_one_assertion': g_logLine(1).procNm);
  iEqual(1: g_logLine(1).assertionCnt);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailAllAndTwoAssertions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_with_two_assertions';
  testCase(1).procPtr = %paddr(successful_test_with_two_assertions);
  g_procNms.numE = 1;
  g_procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(1: g_logIdx );
  aEqual('successful_test_with_two_assertions': g_logLine(1).procNm);
  iEqual(2: g_logLine(1).assertionCnt);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_TwoSuccessfulTestsWithDetailAll export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(2) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 2));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case

  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(1).procptr = %paddr(successful_test_1);
  testCase(2).procNm = 'successful_test_2';
  testCase(2).procptr = %paddr(successful_test_2);
  g_procNms.numE = 1;
  g_procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(2: g_logIdx);
  aEqual('successful_test_1': g_logLine(1).procNm);
  aEqual('successful_test_2': g_logLine(2).procNm);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_TwoSuccessfulTestsWithOrderReverse export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(2) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 2 test procedures
  if (not (testSuite.testCasesCnt >= 2));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 2 and override the test case
  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(1).procptr = %paddr(successful_test_1);
  testCase(2).procNm = 'successful_test_2';
  testCase(2).procptr = %paddr(successful_test_2);
  g_procNms.numE = 1;
  g_procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_REVERSE: DETAIL_ALL: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(2: g_logIdx);
  aEqual('successful_test_2': g_logLine(1).procNm);
  aEqual('successful_test_1': g_logLine(2).procNm);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_ChooseOneTestProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(2) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 2 test procedures
  if (not (testSuite.testCasesCnt >= 2));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 2 and override the test case
  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(1).procptr = %paddr(successful_test_1);
  testCase(2).procNm = 'successful_test_2';
  testCase(2).procptr = %paddr(successful_test_2);
  g_procNms.numE = 1;
  g_procNms.name(1) = 'successful_test_2';

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(1: g_logIdx);
  aEqual('successful_test_2': g_logLine(1).procNm);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTests_ChooseNonExistingTestProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedures
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_1';
  testCase(1).procptr = %paddr(successful_test_1);
  g_procNms.numE = 1;
  g_procNms.name(1) = 'test_2';

  // Execution.

  runTests(result: testSuite: g_procNms: ORDER_API: DETAIL_ALL: RCLrSC_NO);

  writeTestReport(testSuite: g_qTestSuite: result: DETAIL_ALL);

  // Controls.

  iEqual(1: g_logIdx);
  aEqual('test_2': g_logLine(1).procNm);
  aEqual(TEST_CASE_ERROR: g_logLine(1).type);
  aEqual('Test procedure not found.': g_logLine(1).msg);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_Object_qName export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds object likeds(Object_t);


  object.nm  = 'MYOBJ';
  object.lib = 'MYLIB';

  aEqual('MYLIB/MYOBJ': Object_qName(object));
  iEqual(%len('MYLIB/MYOBJ'): %len(Object_qName(object)));

end-proc;


dcl-proc test_callWithLogging_withSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procWithNoError likeds(Proc_t);
  dcl-ds result likeds(testSuiteResult_t) inz;

  procWithNoError.procNm = 'proc_with_no_error';
  procWithNoError.procPtr = %paddr( proc_with_no_error );

  callProcWithErrorHandler(procWithNoError: result);

  assert(g_procWithNoErrorWasCalled: 'proc_with_no_error not called');
  iEqual(0: g_logIdx);  // No logging if success.

end-proc;


dcl-proc test_callWithLogging_withError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procWithError likeds(Proc_t);
  dcl-ds result likeds(testSuiteResult_t) inz;

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  procWithError.procNm = 'proc_with_error';
  procWithError.procPtr = %paddr(proc_with_error);

  monitor;
    callProcWithErrorHandler(procWithError: result);
  on-error;
     fail('callWithLogging should never raise an error');
  endmon;

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  iEqual(1: g_logIdx);
  aEqual('proc_with_error': g_logLine(1).procNm);
  aEqual(TEST_CASE_ERROR: g_logLine(1).type);
  aEqual('Artificial error': g_logLine(1).msg);

end-proc;


dcl-proc test_fmtCompMsg export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  aEqual('Success. 0 test case, 0 assertion, 0 failure, 0 error.': fmtCompMsg(0: 0: 0: 0));

  aEqual('Success. 2 test cases, 0 assertion, 0 failure, 0 error.': fmtCompMsg(2: 0: 0: 0));

  aEqual('Success. 0 test case, 2 assertions, 0 failure, 0 error.': fmtCompMsg(0: 2: 0: 0));

  aEqual('FAILURE. 0 test case, 0 assertion, 2 failures, 0 error.': fmtCompMsg(0: 0: 2: 0));

  aEqual('ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.': fmtCompMsg(0: 0: 0: 2));

  // Errors have priority over failures.
  aEqual('ERROR. 0 test case, 0 assertion, 2 failures, 1 error.': fmtCompMsg(0: 0: 2: 1));

end-proc;


dcl-proc callProcWithErrorHandler;
  dcl-pi *N int(10) extproc(*dclcase);
    proc   likeds(proc_t) const;
    result likeds(testSuiteResult_t);
  end-pi;

  monitor;
    callProcByPtr( proc.procPtr );
    return 0;
  on-error;
    logError( proc.procNm : rcvExcpMsgInfo() );
    return -1;
  endmon;

end-proc;


//----------------------------------------------------------------------
//   Mock Procedures (mocking CMDRUNLOG)
//----------------------------------------------------------------------

dcl-proc logCompMsg export;
  dcl-pi *n;
    msg      varchar(16384) options(*Varsize) const;
    failures int(10) const;
    errors   int(10) const;
  end-pi;

//  fail('Mock logCompMsg not implemented');

end-proc;


dcl-proc logError export;
  dcl-pi *n;
    testNm      like(ProcNm_t) const;
    excpMsgInfo likeds(Msg_t) const;
  end-pi;

  g_logIdx += 1;
  g_logLine(g_logIdx).type = TEST_CASE_ERROR;
  g_logLine(g_logIdx).procNm = testNm;
  g_logLine(g_logIdx).msg = excpMsgInfo.txt;

end-proc;


dcl-proc logFailure export;
  dcl-pi *n;
    testNm           like(ProcNm_t) const;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  fail('Mock logFailure not implemented');

end-proc;


dcl-proc logSuccess export;
  dcl-pi *n;
    testNm       like(ProcNm_t) const;
    specNb       char(10) const;
    assertionCnt int(10) const;
  end-pi;

  g_logIdx += 1;
  g_logLine(g_logIdx).type = TEST_CASE_SUCCESS;
  g_logLine(g_logIdx).procNm = testNm;
  g_logLine(g_logIdx).assertionCnt = assertionCnt;

end-proc;


dcl-proc setLogContext export;
  dcl-pi *n;
    testPgm     likeds(Object_t) const;
    detail      char(10) const;
    output      char(10) const;
    xmlStmfInfo likeds(xmlStmfInfo_t) const;
  end-pi;

  fail('Mock setLogContext not implemented');

end-proc;


//----------------------------------------------------------------------
//   Support Procedures
//----------------------------------------------------------------------

// Dummy procedure with error.
dcl-proc proc_with_error export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  sndEscapeMsgToCaller('Artificial error');

end-proc;


// Dummy procedure with no error.
dcl-proc proc_with_no_error export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_procWithNoErrorWasCalled = *on;

end-proc;


// Dummy test procedure.
dcl-proc successful_test_1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(4: 2+2);

end-proc;


// Dummy test procedure.
dcl-proc successful_test_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(4: 2+2);

end-proc;


// Dummy test procedure.
dcl-proc successful_test_with_one_assertion export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(4: 2+2);

end-proc;

// Dummy test procedure.
dcl-proc successful_test_with_two_assertions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(4: 2+2);
  iEqual(4: 2+2);

end-proc;

