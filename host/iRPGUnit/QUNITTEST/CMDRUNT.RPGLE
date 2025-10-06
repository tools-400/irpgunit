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
//     >>PARM<<  MODULE(&LI/CMDRUN    +
//                      &LI/CALLPRC   +
//                      &LI/CMDRUNLOG +
//                      &LI/CMDRUNPRT +
//                      &LI/CMDRUNSRV +
//                      &LI/CMDRUNV   +
//                      &LI/EXTTST    +
//                      &LI/EXTPRC    +
//                      &LI/JOBLOG    +
//                      &LI/JSONWTR   +
//                      &LI/LIBL      +
//                      &LI/LLIST     +
//                      &LI/OBJECT    +
//                      &LI/OSVERSION +
//                      &LI/PGMMSG    +
//                      &LI/SRCMBR    +
//                      &LI/STMF      +
//                      &LI/STRING    +
//                      &LI/USRSPC    +
//                      &LI/XMLWRITER +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//     >>PARM<<  BOPTION(*DUPPROC);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUN   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNV  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JSONWTR  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STMF     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/XMLWRITER) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
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
/copy qinclude,CMDRUN
/copy qinclude,PGMMSG
/copy qinclude,TEMPLATES
/copy qllist,llist_h

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// TSTPRC option.
dcl-c ALL_PROCS const('*ALL');

// Dummy test program name.
//testPgm         c                   const('MYTSTPGM')


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// In-memory log spool, made of an array and its index.
dcl-ds logLine qualified Dim(2);
  type            like(TestResult_t.outcome);
  procNm          like(ProcNm_t);
  assertionCnt    int(10);
  msg             like(Msg_t.txt);
end-ds;

dcl-s logIdx int(10);

// An array of test cases, for testing purpose.
dcl-ds testCase dim(2) likeds(Proc_t);
// A test suite, for testing purpose.
dcl-ds testSuite likeds(TestSuite_t);
// Procedures to run
dcl-ds procNms likeds(ProcNms_t);
// Test result
dcl-ds result likeds(result_t);

// Spying flag.
dcl-s procWithNoErrorWasCalled ind;

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear logIdx;
  clear logLine;

  clear testCase;
  clear testSuite;
  testSuite.testList = %addr(testCase);
  testSuite.testResults = list_create();

  clear procWithNoErrorWasCalled;
  clear procNms;
  clear result;

end-proc;

dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  list_dispose(testSuite.testResults);

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailBasic export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_1';
  procNms.numE = 1;
  procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_BASIC: RCLRSC_NO);

  // Controls.

  // iEqual( 0 : logIdx );
  iEqual(1 :logIdx);   // logIdx is 1, because now handleSuccess() is
  // called by runTests() regardless of the value
  // of 'detail'.

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailAllAndOneAssertion export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_with_one_assertion';
  testCase(1).procPtr = %paddr(successful_test_with_one_assertion);
  procNms.numE = 1;
  procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);


  // Controls.

  iEqual(1 : logIdx);
  aEqual(TEST_CASE_SUCCESS: logLine(1).type);
  aEqual('successful_test_with_one_assertion': logLine(1).procNm);
  iEqual(1: logLine(1).assertionCnt);

end-proc;


dcl-proc test_runTests_SuccessfulTestWithDetailAllAndTwoAssertions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'successful_test_with_two_assertions';
  testCase(1).procPtr = %paddr(successful_test_with_two_assertions);
  procNms.numE = 1;
  procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  // Controls.

  iEqual(1: logIdx );
  aEqual('successful_test_with_two_assertions': logLine(1).procNm);
  iEqual(2: logLine(1).assertionCnt);

end-proc;


dcl-proc test_runTests_TwoSuccessfulTestsWithDetailAll export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(2).procNm = 'successful_test_2';
  procNms.numE = 1;
  procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  // Controls.

  iEqual(2: logIdx);
  aEqual('successful_test_1': logLine(1).procNm);
  aEqual('successful_test_2': logLine(2).procNm);

end-proc;


dcl-proc test_runTests_TwoSuccessfulTestsWithOrderReverse export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(2).procNm = 'successful_test_2';
  procNms.numE = 1;
  procNms.name(1) = ALL_PROCS;

  // Execution.

  runTests(result: testSuite: procNms: ORDER_REVERSE: DETAIL_ALL: RCLRSC_NO);

  // Controls.

  iEqual(2: logIdx);
  aEqual('successful_test_2': logLine(1).procNm);
  aEqual('successful_test_1': logLine(2).procNm);

end-proc;


dcl-proc test_runTests_ChooseOneTestProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 2;
  testCase(1).procNm = 'successful_test_1';
  testCase(2).procNm = 'successful_test_2';
  procNms.numE = 1;
  procNms.name(1) = 'successful_test_2';

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_ALL: RCLRSC_NO);

  // Controls.

  iEqual(1: logIdx);
  aEqual('successful_test_2': logLine(1).procNm);

end-proc;


dcl-proc test_runTests_ChooseNonExistingTestProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  testSuite.testCasesCnt = 1;
  testCase(1).procNm = 'test_1';
  procNms.numE = 1;
  procNms.name(1) = 'test_2';

  // Execution.

  runTests(result: testSuite: procNms: ORDER_API: DETAIL_ALL: RCLrSC_NO);

  // Controls.

  iEqual(1: logIdx);
  aEqual('test_2': logLine(1).procNm);
  aEqual(TEST_CASE_ERROR: logLine(1).type);
  aEqual('Test procedure not found.': logLine(1).msg);

end-proc;


dcl-proc test_fmtObjNm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds object likeds(Object_t);


  object.nm  = 'MYOBJ';
  object.lib = 'MYLIB';

  aEqual('MYLIB/MYOBJ': fmtObjNm(object));
  iEqual(%len('MYLIB/MYOBJ'): %len(fmtObjNm(object)));

end-proc;


dcl-proc test_callWithLogging_withSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procWithNoError likeds(Proc_t);

  procWithNoError.procNm = 'proc_with_no_error';
  procWithNoError.procPtr = %paddr( proc_with_no_error );

  callProcWithErrorHandler(procWithNoError);

  assert(procWithNoErrorWasCalled: 'proc_with_no_error not called');
  iEqual(0: logIdx);    // No logging if success.

end-proc;


dcl-proc test_callWithLogging_withError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procWithError likeds(Proc_t);

  procWithError.procNm = 'proc_with_error';
  procWithError.procPtr = %paddr(proc_with_error);

  monitor;
    callProcWithErrorHandler(procWithError);
  on-error;
     fail('callWithLogging should never raise an error');
  endmon;

  iEqual(1: logIdx);
  aEqual('proc_with_error': logLine(1).procNm);
  aEqual(TEST_CASE_ERROR: logLine(1).type);
  aEqual('Artificial error': logLine(1).msg);

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
    proc likeds(proc_t) const;
  end-pi;

  monitor;
    callProcByPtr( proc.procPtr );
    return 0;
  on-error;
    handleError( proc.procNm : rcvExcpMsgInfo() : result );
    return -1;
  endmon;

end-proc;


//----------------------------------------------------------------------
//   Mock Procedures (mocking CMDRUNLOG)
//----------------------------------------------------------------------

dcl-proc logCompMsg export;
  dcl-pi *n;
    msg             varchar(16384) const  options(*Varsize);
    failures        int(10) const;
    errors          int(10) const;
  end-pi;

  fail('Mock logCompMsg not implemented');

end-proc;


dcl-proc logError export;
  dcl-pi *n;
    testNm          const like(ProcNm_t);
    excpMsgInfo     const likeds(Msg_t);
  end-pi;

  logIdx += 1;
  logLine(logIdx).type = TEST_CASE_ERROR;
  logLine(logIdx).procNm = testNm;
  logLine(logIdx).msg = excpMsgInfo.txt;

end-proc;


dcl-proc logFailure export;
  dcl-pi *n;
    testNm          const like(ProcNm_t);
    failure         const likeds(AssertFailEvtLong_t);
  end-pi;

  fail('Mock logFailure not implemented');

end-proc;


dcl-proc logSuccess export;
  dcl-pi *n;
    testNm          const like(ProcNm_t);
    assertionCnt    int(10) const;
  end-pi;

  logIdx += 1;
  logLine(logIdx).type = TEST_CASE_SUCCESS;
  logLine(logIdx).procNm = testNm;
  logLine(logIdx).assertionCnt = assertionCnt;

end-proc;


dcl-proc setLogContext export;
  dcl-pi *n;
    testPgm         const likeds(Object_t);
    detail          char(10) const;
    output          char(10) const;
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

  procWithNoErrorWasCalled = *on;

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

