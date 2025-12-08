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
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CALLSTACK
/copy qinclude,CMDRUNSRV
/copy qinclude,MEMMGR
/copy qinclude,OBJECT
/copy qinclude,PGMMSG
/copy qinclude,TEMPLATES
/copy qinclude,TESTCASE
/copy qllist,LLIST_H

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

dcl-ds noSetUp likeds(Proc_t) inz;
dcl-ds noTearDown likeds(Proc_t) inz;

//---------------------------------------------------------------------
//   Global Variables
//---------------------------------------------------------------------

// Execution trace (and its current index).
dcl-s g_execTrace char(256) dim(64);
dcl-s g_execTraceIdx int(10);
// Test procedure to call.
dcl-ds g_testProc likeds(Proc_t);
// Setup proc.
dcl-ds g_setupProc likeds(Proc_t);
// Tear down proc.
dcl-ds g_tearDownProc likeds(Proc_t);
// Result of a test case run.
dcl-ds g_result likeds(TestResult_t);

dcl-s setUpSuiteWasCalled ind;

dcl-s g_numListsExpected int(10);
dcl-s g_isValidateNumLists ind;

//----------------------------------------------------------------------
//   Program Status Data Structure
//----------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-ds g_qTestSuite likeds(object_t) inz;

dcl-proc setupSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_qTestSuite.nm = 'TESTPGM02';
  g_qTestSuite.lib = 'QTEMP';

  if (TestSuite_isDirty(g_qTestSuite.nm: g_qTestSuite.lib));
    runCmd('RUCRTRPG TSTPGM(' + %trim(g_qTestSuite.lib) + '/' + %trim(g_qTestSuite.nm) + ') +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  // Used by test_loadTestSuite...

  setUpSuiteWasCalled = *on;

end-proc;


dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Clear global variables.

  clear g_execTrace;
  g_execTraceIdx = 1;
  clear g_result;
  clear setUpSuiteWasCalled;
  clear g_testProc;

  g_isValidateNumLists = *off;

end-proc;


dcl-proc teardown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (g_isValidateNumLists);
    g_isValidateNumLists = *off;
    assertEqual(g_numListsExpected: MemMgr_getNumLists());
  endif;

end-proc;


dcl-proc test_runTestProc_successfulTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);

  // Execution.

  g_testProc.procPtr = %paddr(test_proc);
  g_testProc.procNm = 'test_proc';
  testResult = runTestProc(g_testProc: noSetUp: noTearDown);

  // Controls.

  aEqual('test_proc was called': g_execTrace(1));
  aEqual(TEST_CASE_SUCCESS: testResult.outcome);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_failureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);
  dcl-ds testFailureEvent likeds(testFailureEvent_t);

  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  dcl-ds testResultControl likeds(testResult);

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Execution.

  g_testProc.procPtr = %paddr(test_fail);
  g_testProc.procNm = 'test_fail';

  testResult = runTestProc(g_testProc: noSetUp: noTearDown);

  testFailureEvent = getLastFailureEvent(testResult);

  // save test result before destroying it
  testResultControl = testResult;

  // destroy testResult to have a clean status
  disposeTestResult(testResult);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  Callstack_resetIteration(testFailureEvent.pCallstk);
  Callstack_getNext(testFailureEvent.pCallstk: callstkEnt);

  aEqual('test_fail was called': g_execTrace(1));
  aEqual(TEST_CASE_FAILURE: testResultControl.outcome);
  aEqual('My Failure Message': testFailureEvent.msg);
  iEqual(1: callstkEnt.level);
  aEqual('test_fail': callstkEnt.qStmt.procNm);

end-proc;


dcl-proc test_runTestProc_errorInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);
  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  // Execution.

  g_testProc.procPtr = %paddr(test_error);
  g_testProc.procNm = 'test_error';
  testResult = runTestProc(g_testProc: noSetUp: noTearDown);

  // Controls.

  aEqual('test_error was called': g_execTrace(1));
  aEqual(TEST_CASE_ERROR: testResult.outcome);

  errorEvent = getErrorEvent(testResult.hTestEvents);
  aEqual('raiseError': errorEvent.msg.qSndStmt.procNm);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_withSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);

  // Execution.

  g_testProc.procPtr = %paddr(test_proc);
  g_testProc.procNm = 'test_proc';

  g_setupProc.procPtr = %paddr(setup_proc);
  g_setupProc.procNm = 'setup_proc';

  testResult = runTestProc(g_testProc: g_setupProc: noTearDown);

  // Controls.

  aEqual('setup_proc was called': g_execTrace(1));
  aEqual('test_proc was called': g_execTrace(2));
  aEqual(TEST_CASE_SUCCESS: testResult.outcome);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_errorInSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);
  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  // Execution.

  monitor;

    g_testProc.procPtr = %paddr(test_proc);
    g_testProc.procNm = 'test_proc';

    g_setupProc.procPtr = %paddr(setup_with_error);
    g_setupProc.procNm = 'setup_with_error';

    testResult = runTestProc(g_testProc: g_setupProc: noTearDown);
  on-error;
    fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('setup_with_error was called': g_execTrace(1));
  aEqual(*blank: g_execTrace(2)); // test_proc not called.
  aEqual(TEST_CASE_ERROR: testResult.outcome);

  errorEvent = getErrorEvent(testResult.hTestEvents);
  aEqual('raiseError': errorEvent.msg.qSndStmt.procNm);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_withTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);

  // Execution.

  g_testProc.procPtr = %paddr(test_proc);
  g_testProc.procNm = 'test_proc';

  g_tearDownProc.procPtr = %paddr(tearDown_proc);
  g_tearDownProc.procNm = 'tearDown_proc';

  testResult = runTestProc(g_testProc: noSetUp: g_tearDownProc);

  // Controls.

  aEqual('test_proc was called': g_execTrace(1));
  aEqual('tearDown_proc was called': g_execTrace(2));
  aEqual(TEST_CASE_SUCCESS: testResult.outcome);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_errorInTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);
  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  // Execution.

  monitor;

    g_testProc.procPtr = %paddr(test_proc);
    g_testProc.procNm = 'test_proc';

    g_tearDownProc.procPtr = %paddr(tearDown_with_error);
    g_tearDownProc.procNm = 'tearDown_with_error';

    testResult = runTestProc(g_testProc: noSetUp: g_tearDownProc);
  on-error;
    fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('test_proc was called': g_execTrace(1));
  aEqual('tearDown_with_error was called': g_execTrace(2));
  aEqual(TEST_CASE_ERROR: testResult.outcome);

  errorEvent = getErrorEvent(testResult.hTestEvents);
  aEqual('raiseError': errorEvent.msg.qSndStmt.procNm);

on-exit;
  disposeTestResult(testResult);

end-proc;


dcl-proc test_runTestProc_tearDownAfterFailureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);

  dcl-ds testResultControl likeds(testResult);

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Execution.

  g_testProc.procPtr = %paddr(test_fail);
  g_testProc.procNm = 'test_fail';

  g_tearDownProc.procPtr = %paddr(tearDown_proc);
  g_tearDownProc.procNm = 'tearDown_proc';

  testResult = runTestProc(g_testProc: noSetUp: g_tearDownProc);

  // save test result before destroying it
  testResultControl = testResult;

  // destroy testResult to have a clean status
  disposeTestResult(testResult);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  aEqual('test_fail was called': g_execTrace(1));
  aEqual('tearDown_proc was called': g_execTrace(2));
  aEqual(TEST_CASE_FAILURE: testResultControl.outcome);

end-proc;

// TODO: fix "Unexpected failure event type: E"
dcl-proc test_runTestProc_tearDownAfterErrorInSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testResult likeds(TestResult_t);
  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  // Execution.

  monitor;
    g_testProc.procPtr = %paddr(test_proc);
    g_testProc.procNm = 'test_proc';

    g_setupProc.procPtr = %paddr(setup_with_error);
    g_setupProc.procNm = 'setup_with_error';

    g_tearDownProc.procPtr = %paddr(tearDown_proc);
    g_tearDownProc.procNm = 'tearDown_proc';

    testResult = runTestProc(g_testProc: g_setupProc: g_tearDownProc);
  on-error;
     fail('runTestProc should not raise an error');
  endmon;

  // Controls.

  aEqual('setup_with_error was called': g_execTrace(1));
  // test_proc not called.
  aEqual('tearDown_proc was called': g_execTrace(2));
  aEqual(TEST_CASE_ERROR: testResult.outcome);

  errorEvent = getErrorEvent(testResult.hTestEvents);
  aEqual('raiseError': errorEvent.msg.qSndStmt.procNm);

on-exit;
  disposeTestResult(testResult);

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

  testSuite = loadTestSuite(srvPgm);

  // Controls.

  assert(setUpSuiteWasCalled = *off: 'setUpSuite called by loadTestSuite');
  aEqual('setupSuite': testSuite.setUpSuite.procNm);
  assert(%paddr(setUpSuite) = testSuite.setUpSuite.procPtr: 'Wrong SetUpSuite procedure pointer');
  aEqual('setup': testSuite.setUp.procNm);
  assert(%paddr(setUp) = testSuite.setUp.procPtr: 'Wrong SetUp procedure pointer');

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTest_successfulTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds testResult likeds(TestResult_t);


  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;


  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm  = 'test_proc' ;
  testCase(1).procPtr = %paddr(test_proc);

  // Execution.

  testResult = runTestCase(testSuite: 1);

  // Controls.

  aEqual(TEST_CASE_SUCCESS: testResult.outcome);

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_runTest_failureInTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds testResult likeds(TestResult_t);

  dcl-ds testResultControl likeds(testResult);

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
  testCase(1).procNm = 'test_fail' ;
  testCase(1).procPtr = %paddr(test_fail);

  // Execution.

  testResult = runTestCase(testSuite: 1);

  // save test result before destroying it
  testResultControl = testResult;

  // destroy testResult to have a clean status
  rclTestSuite(testSuite); // includes calling disposeTestResult()

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  aEqual(TEST_CASE_FAILURE: testResultControl.outcome);

end-proc;


dcl-proc test_runTest_withSetupAndTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testResult likeds(testResult_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);

  dcl-ds testResultControl likeds(testResult);

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Setup.

  testSuite = crtTestSuite(g_qTestSuite);

  testSuite.setUp.procNm = 'setup_proc';
  testSuite.setUp.procPtr = %paddr(setup_proc);

  // ensure the test suite has at least 1 test procedure
  if (not (testSuite.testCasesCnt >= 1));
    snd-msg *escape 'Test suite must have at least 1 test case.';
  endif;

  // set number of test cases to 1 and override the test case
  testSuite.testCasesCnt = 1;
  testCase(1).procNm  = 'test_proc' ;
  testCase(1).procPtr = %paddr(test_proc);

  testSuite.tearDown.procNm = 'tearDown_proc';
  testSuite.tearDown.procPtr = %paddr(tearDown_proc);

  // Execution.

  testResult = runTestCase(testSuite: 1);

  // save test result before destroying it
  testResultControl = testResult;

  // destroy testResult to have a clean status
  rclTestSuite(testSuite); // includes calling disposeTestResult()

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  // Should return 2 lists created.
  // Validate that in teardown().
  g_numListsExpected = MemMgr_getNumLists();
  g_isValidateNumLists = *on;

  aEqual('setup_proc was called': g_execTrace(1));
  aEqual('test_proc was called': g_execTrace(2));
  aEqual('tearDown_proc was called': g_execTrace(3));

end-proc;


dcl-proc test_runTest_ignoreAssertFailure export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;
  dcl-ds testCase dim(1) likeds(Proc_t) based(testSuite.testList);
  dcl-ds testResult likeds(TestResult_t);

  dcl-ds testResultControl likeds(testResult);

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
  testCase(1).procNm  = 'test_ignore_assert_error' ;
  testCase(1).procPtr = %paddr(test_ignore_assert_error);


  testResult = runTestCase(testSuite: 1);

  // save test result before destroying it
  testResultControl = testResult;

  // destroy testResult to have a clean status
  rclTestSuite(testSuite); // includes calling disposeTestResult()

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Controls.

  aEqual(TEST_CASE_SUCCESS: testResultControl.outcome);

end-proc;


dcl-proc test_crtTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;

  testSuite = crtTestSuite(g_qTestSuite);

  assertEqual('TESTPGM02': testSuite.qName.nm);
  assertEqual('QTEMP': testSuite.qName.lib);

  assert(testSuite.setupSuite.procPtr = *null);
  assert(testSuite.setup.procPtr = *null);
  assert(testSuite.tearDownSuite.procPtr = *null);
  assert(testSuite.tearDown.procPtr = *null);

  assertEqual(0: list_size(testSuite.testResults));

on-exit;
  rclTestSuite(testSuite);

end-proc;


dcl-proc test_rclTestSuite_blankTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;

  testSuite = crtTestSuite(g_qTestSuite);

  monitor;
    rclTestSuite(testSuite);
  on-error;
    fail('rclTestSuite should tolerate a blank test suite');
  endmon;

end-proc;


dcl-proc test_rclTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuit4 likeds(TestSuite_t) inz;

  clear testSuit4;

  testSuit4 = crtTestSuite(g_qTestSuite);
  rclTestSuite(testSuit4);

  assert(testSuit4.testList = *null: 'Test list not deallocated');

end-proc;


dcl-proc test_rclTestSuite_withTearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testSuite likeds(TestSuite_t) inz;

  testSuite = crtTestSuite(g_qTestSuite);

  testSuite.tearDownSuite.procPtr = %paddr(tearDownSuite_success);

  assert(*blank = g_execTrace(1): 'Should not have called tearDownSuite');

on-exit;
  rclTestSuite(testSuite);

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


dcl-proc tearDown_proc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('tearDown_proc');

end-proc;


dcl-proc tearDown_with_error;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('tearDown_with_error');
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


dcl-proc test_ignore_assert_error;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  traceCall('test_ignore_assert_error');

  callp(E) assert(*off : 'FAILURE: ignored');  // continue on error

end-proc;


dcl-proc traceCall;
  dcl-pi *n extproc(*dclcase);
    procNm   varchar(64) const;
  end-pi;

  g_execTrace(g_execTraceIdx) = procNm + ' was called';
  g_execTraceIdx += 1;

end-proc;

dcl-proc getErrorEvent;
  dcl-pi *n likeds(runtimeErrorEvent_t) extproc('*dclcase');
    hTestEvents pointer const;
  end-pi;

  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) based(pRuntimeErrorEvent);

  list_abortIteration(hTestEvents);
  pRuntimeErrorEvent = list_getNext(hTestEvents);

  return runtimeErrorEvent;

end-proc;
