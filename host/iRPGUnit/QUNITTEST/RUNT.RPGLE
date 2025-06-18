**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test RUN.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/CALLPRC   +
//                      &LI/CMDRUNLOG +
//                      &LI/CMDRUNPRT +
//                      &LI/CMDRUNSRV +
//                      &LI/EXTPRC    +
//                      &LI/EXTTST    +
//                      &LI/JOBLOG    +
//                      &LI/LLIST     +
//                      &LI/OBJECT    +
//                      &LI/OSVERSION +
//                      &LI/PGMMSG    +
//                      &LI/SRCMBR    +
//                      &LI/STMF      +
//                      &LI/STRING    +
//                      &LI/USRSPC    +
//                     );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STMF     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,PGMMSG
/copy qinclude,CMDRUNSRV
/copy qinclude,TEMPLATES
/copy qinclude,ASSERT

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

dcl-ds noSetUp likeds(Proc_t) inz;
dcl-ds noTearDown likeds(Proc_t) inz;

//---------------------------------------------------------------------
//   Global Variables
//---------------------------------------------------------------------

// Execution trace (and its current index).
dcl-s execTrace char(256) dim(64);
dcl-s execTraceIdx int(10);
// Test procedure to call.
dcl-ds testProc likeds(Proc_t);
// Setup proc.
dcl-ds setupProc likeds(Proc_t);
// Tear down proc.
dcl-ds tearDownProc likeds(Proc_t);
// Result of a test case run.
dcl-ds result likeds(TestResult_t);

dcl-s setUpSuiteWasCalled ind;

//----------------------------------------------------------------------
//   Program Status Data Structure
//----------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc setupSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Used by test_loadTestSuite...

  setUpSuiteWasCalled = *on;

end-proc;


dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Clear global variables.

  clear execTrace;
  execTraceIdx = 1;
  clear result;
  clear setUpSuiteWasCalled;
  clear testProc;

end-proc;


dcl-proc test_runTestProc_successfulTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_proc);
  testProc.procNm = 'test_proc';
  result = runTestProc(testProc: noSetUp: noTearDown);

  // Controls.

  aEqual('test_proc was called': execTrace(1));
  aEqual(TEST_CASE_SUCCESS: result.outcome);

end-proc;


dcl-proc test_runTestProc_failureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_fail);
  testProc.procNm = 'test_fail';
  result = runTestProc(testProc: noSetUp: noTearDown);

  // Controls.

  aEqual('test_fail was called': execTrace(1));
  aEqual(TEST_CASE_FAILURE: result.outcome);
  aEqual('My Failure Message': result.failure.msg);
  // New, due to new procedure doFail():
  // aEqual('fail': result.failure.callStk.entry(1).sender.procNm);
  aEqual('test_fail': result.failure.callStk.entry(1).qStmt.procNm);

end-proc;


dcl-proc test_runTestProc_errorInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_error);
  testProc.procNm = 'test_error';
  result = runTestProc(testProc: noSetUp: noTearDown);

  // Controls.

  aEqual('test_error was called': execTrace(1));
  aEqual(TEST_CASE_ERROR: result.outcome);
  aEqual('raiseError': result.error.qSndStmt.procNm);

end-proc;


dcl-proc test_runTestProc_withSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_proc);
  testProc.procNm = 'test_proc';

  setupProc.procPtr = %paddr( setup_proc);
  setupProc.procNm = 'setup_proc';

  result = runTestProc(testProc: setupProc: noTearDown);

  // Controls.

  aEqual('setup_proc was called': execTrace(1));
  aEqual('test_proc was called': execTrace(2));
  aEqual(TEST_CASE_SUCCESS: result.outcome);

end-proc;


dcl-proc test_runTestProc_errorInSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  monitor;

    testProc.procPtr = %paddr( test_proc);
    testProc.procNm = 'test_proc';

    setupProc.procPtr = %paddr( setup_with_error);
    setupProc.procNm = 'setup_with_error';

    result = runTestProc(testProc: setupProc: noTearDown);
  on-error;
    fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('setup_with_error was called': execTrace(1));
  aEqual(*blank: execTrace(2)); // test_proc not called.
  aEqual(TEST_CASE_ERROR: result.outcome);
  aEqual('raiseError': result.error.qSndStmt.procNm);

end-proc;


dcl-proc test_runTestProc_withTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_proc);
  testProc.procNm = 'test_proc';

  tearDownProc.procPtr = %paddr( teardown_proc);
  tearDownProc.procNm = 'teardown_proc';

  result = runTestProc(testProc: noSetUp: tearDownProc);

  // Controls.

  aEqual('test_proc was called': execTrace(1));
  aEqual('teardown_proc was called': execTrace(2));
  aEqual(TEST_CASE_SUCCESS: result.outcome);

end-proc;


dcl-proc test_runTestProc_errorInTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  monitor;

    testProc.procPtr = %paddr( test_proc);
    testProc.procNm = 'test_proc';

    tearDownProc.procPtr = %paddr( teardown_with_error);
    tearDownProc.procNm = 'teardown_with_error';

    result = runTestProc(testProc: noSetUp: tearDownProc);
  on-error;
    fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('test_proc was called': execTrace(1));
  aEqual('teardown_with_error was called': execTrace(2));
  aEqual(TEST_CASE_ERROR: result.outcome);
  aEqual('raiseError': result.error.qSndStmt.procNm);

end-proc;


dcl-proc test_runTestProc_tearDownAfterFailureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  testProc.procPtr = %paddr( test_fail);
  testProc.procNm = 'test_fail';

  tearDownProc.procPtr = %paddr( teardown_proc);
  tearDownProc.procNm = 'teardown_proc';

  result = runTestProc(testProc: noSetUp: tearDownProc);

  // Controls.

  aEqual('test_fail was called': execTrace(1));
  aEqual('teardown_proc was called': execTrace(2));
  aEqual(TEST_CASE_FAILURE: result.outcome);

end-proc;


dcl-proc test_runTestProc_tearDownAfterErrorInSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  monitor;
    testProc.procPtr = %paddr( test_proc);
    testProc.procNm = 'test_proc';

    setupProc.procPtr = %paddr( setup_with_error);
    setupProc.procNm = 'setup_with_error';

    tearDownProc.procPtr = %paddr( teardown_proc);
    tearDownProc.procNm = 'teardown_proc';

    result = runTestProc(testProc: setupProc: tearDownProc);
  on-error;
     fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('setup_with_error was called': execTrace(1));
  // test_proc not called.
  aEqual('teardown_proc was called': execTrace(2));
  aEqual(TEST_CASE_ERROR: result.outcome);
  aEqual('raiseError': result.error.qSndStmt.procNm);

end-proc;


dcl-proc test_loadTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds srvPgm likeds(Object_t);
  dcl-ds testSuite likeds(TestSuite_t);


  // Setup.

  setUpSuiteWasCalled = *off;
  srvPgm.nm  = sds.pgmName;
  srvPgm.lib = sds.pgmLib;

  // Execution.

  testSuite = loadTestSuite( srvPgm);

  // Controls.

  assert(setUpSuiteWasCalled = *off: 'setUpSuite called by loadTestSuite');
  aEqual('setupSuite': testSuite.setUpSuite.procNm);
  assert(%paddr(setUpSuite) = testSuite.setUpSuite.procPtr: 'Wrong SetUpSuite procedure pointer');
  aEqual('setup': testSuite.setUp.procNm);
  assert(%paddr(setUp) = testSuite.setUp.procPtr: 'Wrong SetUp procedure pointer');

end-proc;


dcl-proc test_runTest_successfulTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);
  dcl-ds testCase dim(1) likeds(Proc_t);
  dcl-ds testResult likeds(TestResult_t);


  // Setup.

  testSuite.testCasesCnt = 1;
  testSuite.testList = %addr( testCase);
  testCase(1).procNm  = 'test_proc' ;
  testCase(1).procPtr = %paddr( test_proc);

  // Execution.

  testResult = runTest(testSuite: 1);

  // Controls.

  aEqual(TEST_CASE_SUCCESS: testResult.outcome);

end-proc;


dcl-proc test_runTest_failureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);
  dcl-ds testCase dim(1) likeds(Proc_t);
  dcl-ds testResult likeds(TestResult_t);

  // Setup.

  testSuite.testCasesCnt = 1;
  testSuite.testList = %addr( testCase);
  testCase(1).procNm = 'test_fail' ;
  testCase(1).procPtr = %paddr( test_fail);

  // Execution.

  testResult = runTest(testSuite: 1);

  // Controls.

  aEqual(TEST_CASE_FAILURE: testResult.outcome);

end-proc;


dcl-proc test_runTest_withSetupAndTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);
  dcl-ds testCase dim(1) likeds(Proc_t);

  // Setup.

  testSuite.setUp.procNm = 'setup_proc';
  testSuite.setUp.procPtr = %paddr( setup_proc);

  testSuite.testCasesCnt = 1;
  testSuite.testList = %addr( testCase);
  testCase(1).procNm  = 'test_proc' ;
  testCase(1).procPtr = %paddr( test_proc);

  testSuite.tearDown.procNm = 'teardown_proc' ;
  testSuite.tearDown.procPtr = %paddr( teardown_proc);

  // Execution.

  runTest(testSuite: 1);

  // Controls.

  aEqual('setup_proc was called': execTrace(1));
  aEqual('test_proc was called': execTrace(2));
  aEqual('teardown_proc was called': execTrace(3));

end-proc;


dcl-proc test_rclTestSuite_blankTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);


  clear testSuite;

  monitor;
    rclTestSuite( testSuite);
  on-error;
    fail('rclTestSuite should tolerate a blank test suite');
  endmon;

end-proc;


dcl-proc test_rclTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);

  clear testSuite;
  testSuite.testList = %alloc(10);

  rclTestSuite( testSuite);

  assert(testSuite.testList = *null: 'Test list not deallocated');

end-proc;


dcl-proc test_rclTestSuite_withTearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t);

  clear testSuite;
  testSuite.tearDownSuite.procPtr = %paddr( tearDownSuite_success);

  rclTestSuite( testSuite);

  assert(*blank = execTrace(1): 'Should not have called tearDownSuite');

end-proc;


//----------------------------------------------------------------------
//   Support Procedure Definitions
//----------------------------------------------------------------------

dcl-proc raiseError;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s zero int(10) inz(0);


  zero = 1 / zero;

  end-proc;


  dcl-proc setup_proc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('setup_proc');

end-proc;


dcl-proc setup_with_error;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('setup_with_error');
  raiseError();

end-proc;


dcl-proc teardown_proc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('teardown_proc');

end-proc;


dcl-proc teardown_with_error;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('teardown_with_error');
  raiseError();

end-proc;


dcl-proc tearDownSuite_success;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('tearDownSuite_success');

end-proc;


dcl-proc test_error;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('test_error');
  raiseError();

end-proc;


dcl-proc test_fail;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('test_fail');
  fail('My Failure Message');

end-proc;


dcl-proc test_proc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('test_proc');

end-proc;

dcl-proc traceCall;
  dcl-pi *n extproc(*dclcase);
    procNm   varchar(64) const;
  end-pi;

  execTrace(execTraceIdx) = procNm + ' was called';
  execTraceIdx += 1;

end-proc;

