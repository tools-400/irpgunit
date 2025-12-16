**FREE
// ==========================================================================
//  iRPGUnit - Command Line Toolkit.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CMDRUNSRV


//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,CALLPRC
/include qinclude,CALLSTACK
/include qinclude,CMDRUNLOG
/include qinclude,CMDRUNSRV
/include qinclude,CMDRUNV
/include qinclude,EXTPRC
/include qinclude,EXTTST
/include qinclude,LIBL
/include qinclude,MEMMGR
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,RMTRUNSRV
/include qinclude,TEMPLATES
/include qinclude,TESTUTILS
/include qinclude,STRING
/include qinclude,XMLWRITER
/include qllist,llist_h

/include qsysinc,QCMDEXC

//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

/include qinclude,SDS

dcl-ds g_status qualified inz;
  numListsCreated int(10);
  isJUnitStyle ind inz(*on);
end-ds;

//----------------------------------------------------------------------
// Load a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc loadTestSuite export;
  dcl-pi *N likeds(testSuite_t);
    srvPgm const likeds(object_t);
  end-pi;

  dcl-ds testSuite likeds(testSuite_t);
  dcl-s actMark like(actMark_t);
  dcl-s extObjAttr char(10);

  testSuite = crtTestSuite(srvPgm);

  extObjAttr = Object_getAttribute( srvPgm : '*SRVPGM' );
  if (extObjAttr = 'CBLLE' or extObjAttr = 'SQLCBLLE');
    testSuite.isCobol = *on;
  else;
    testSuite.isCobol = *off;
  endif;

  actMark = activateSrvPgm( srvPgm );
  activateTestSuite( testSuite : actMark );

  return testSuite;

end-proc;

//----------------------------------------------------------------------
//  Execute a given unit test suite.
//  Return *ON on success, otherwise *OFF.
//----------------------------------------------------------------------
dcl-proc runTestSuite export;
  dcl-pi *N ind;
    userSpace     likeds(object_t) options(*omit) const;
    qTestSuite    likeds(object_t) const;
    testProcs     likeds(procNms_t) const;
    order         like(order_t) const;
    detail        like(detail_t) const;
    assertMode    like(assertMode_t) const;
    output        like(output_t) const;
    libl          likeds(libl_t) const;
    qJobD         likeds(object_t) const;
    rclRsc        like(rclrsc_t) const;
    xmlStmf       like(stmf_t) const;
    xmlType       like(xmlType_t) const;
    msg           varchar(256); // Completion message.
  end-pi;

  dcl-ds testSuite likeds(testSuite_t);
  dcl-s maxSizeAllocMem like(memSize_t);

  dcl-s xmlStmfMsg char(256);

  // Test event counters.
  dcl-ds testSuiteResult likeds(testSuiteResult_t);

  // Save/set/restore library list
  dcl-ds savedLibl likeds(liblData_t);
  dcl-s mustRestoreLibl ind inz(*off);

  dcl-ds xmlStmfInfo likeds(xmlStmfInfo_t) inz;

  if (assertMode = MODE_ALL);
    g_status.isJUnitStyle = *off;
  else;
    g_status.isJUnitStyle = *on;
  endif;

  registerStartPgm(sds.pgmLib: sds.pgmname: g_status.isJUnitStyle);

  MemMgr_reset();

  if (xmlStmf <> '');
    msg = validateXmlStmf(xmlStmf: qTestSuite);
    if (msg <> '');
      sndEscapeMsgAboveCtlBdy( msg );
    endif;
  endif;

  clear xmlStmfInfo;
  xmlStmfInfo.path = resolvePathVariables(xmlStmf: qTestSuite);
  xmlStmfInfo.type = xmlType;

  clear testSuiteResult;
  setLogContext( qTestSuite : detail : output : xmlStmfInfo);
  clearAssertCounter();

  // Set library list and load test suite
  monitor;
    savedLibl = getLibl();
    mustRestoreLibl = setTestSuiteLibl(libl: qJobD: qTestSuite.lib);
    updateLogContext(getLibl());
    testSuite = loadTestSuite( qTestSuite );
  on-error;
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'Error while loading test suite '
                + Object_qName(qTestSuite) + '.' );
  endmon;

  if (testSuite.testCasesCnt = 0);
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'No test case found in service program '
                + Object_qName(qTestSuite) + '.' );
  endif;

  setupTestSuite( testSuite : testSuiteResult );

  if (testSuiteResult.errorCnt = 0 and testSuiteResult.failureCnt = 0);
    runTests(testSuiteResult: testSuite: testProcs: order: detail: rclRsc);
  endif;

  tearDownTestSuite( testSuite : testSuiteResult );

  testSuiteResult.assertCnt = getAssertCalled();

  // Return result to printer file
  writeTestReport(testSuite: qTestSuite: testSuiteResult);

  // Return result to xml file
  if (xmlStmfInfo.path <> '');
    monitor;
      writeXmlFile(xmlStmfInfo.path:
                   testSuite: qTestSuite: testSuiteResult: xmlStmfInfo.type: g_status.isJUnitStyle);
      xmlStmfMsg = 'Created XML file (' + xmlStmfInfo.type + '): ' + xmlStmfInfo.path;
      sndInfoMsg(xmlStmfMsg);
      xmlStmfMsg = '';
    on-error;
      xmlStmfMsg = rcvMsgTxt('*ESCAPE');
    endmon;
  endif;

  // Return result to plug-in
  if (%parms() >= %parmnum(userSpace) and %addr(userSpace) <> *null);
    fillUserSpace(userSpace : testSuite : qTestSuite : testSuiteResult: g_status.isJUnitStyle);
  endif;

  // Restore library list
  checkAndRestoreLibl(mustRestoreLibl: savedLibl);

  monitor;
    maxSizeAllocMem = MemMgr_getMaxSizeAllocMem();
    rclTestSuite( testSuite );

    sndInfoMsg('iRPGUnit: Dynamic heap space usage: ' + %char(maxSizeAllocMem) + ' kb.');
  on-error;
    raiseRUError( 'Failed to reclaim the test suite''s resources.' );
  endmon;

  msg = fmtCompMsg( testSuiteResult.runsCnt:
                    testSuiteResult.assertCnt:
                    testSuiteResult.failureCnt:
                    testSuiteResult.errorCnt );

  // Internal self-test
  if (sds.pgmLib = 'RPGUNITDVP');
    if (MemMgr_getNumLists() <> 0);
      raiseRUError('Number of allocated linked-list must be 0, but is: '
                    +  %char(MemMgr_getNumLists()));
    endif;

    if (MemMgr_getNumAllocs() <> 0);
      raiseRUError('Number of allocated memory blocks must be 0, but is: '
                    +  %char(MemMgr_getNumAllocs()));
    endif;
  endif;

  if (xmlStmfMsg <> '');
    msg = xmlStmfMsg;
    return *off; // FAILURE
  else;
    if (testSuiteResult.failureCnt = 0 and testSuiteResult.errorCnt = 0);
      return *on; // SUCCESS
    else;
      return *off; // FAILURE
    endif;
  endif;

end-proc;

//----------------------------------------------------------------------
// Logs the test result to a printer file.
//----------------------------------------------------------------------
dcl-proc writeTestReport export;
  dcl-pi *N;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(Object_t) const;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestResult);
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);
  dcl-s msg varchar(256);

  list_resetIteration(testSuite.testResults);
  pTestResult = list_getNext(testSuite.testResults);
  dow (pTestResult <> *null);

    list_resetIteration(testCaseResult.hTestEvents);
    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    dow (pAbstractTestEvent <> *null);

      select;
      when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
        logSuccess(testCaseResult.testName: testCaseResult.assertCnt);

      when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
        // Log confirmed failure events only. Unconfirmed
        // events have been monitored, e.g.:
        //    callp(E) assert()
        if (abstractTestEvent.failure.isConfirmed);
          logFailure(testCaseResult.testName: abstractTestEvent.failure);
        endif;

      when (abstractTestEvent.outcome = TEST_CASE_ERROR);
        logError(testCaseResult.testName: abstractTestEvent.error.msg);

      endsl;

      pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    enddo;

    pTestResult = list_getNext(testSuite.testResults);
  enddo;

  msg = fmtCompMsg( testSuiteResult.runsCnt:
                    testSuiteResult.assertCnt:
                    testSuiteResult.failureCnt:
                    testSuiteResult.errorCnt );

  // ignore any messages here
  monitor;
    // Log completion message to spooled file
    logCompMsg(msg : testSuiteResult.failureCnt : testSuiteResult.errorCnt );
  on-error;
    // nothing
  endmon;

end-proc;

//----------------------------------------------------------------------
// Raise an RPGUnit error. See prototype.
//----------------------------------------------------------------------
dcl-proc raiseRUError export;
  dcl-pi *N;
    msg             varchar(256) const;
  end-pi;

  monitor;
    logRuntimeError( 'Runtime error: ' + msg );
  on-error;
    // ignore errors
  endmon;

  sndEscapeMsgAboveCtlBdy( 'RPGUnit Error. ' + msg );

end-proc;


//----------------------------------------------------------------------
// Create a test suite and allocate resources. See prototype.
//----------------------------------------------------------------------
dcl-proc crtTestSuite export;
  dcl-pi *N likeds(testSuite_t);
    srvPgm const likeds(object_t);
  end-pi;

  dcl-ds procList likeds(procList_t);
  dcl-ds procNmList likeds(procNmList_t);
  dcl-ds testSuite likeds(testSuite_t);

  procList   = loadProcList( srvPgm );
  procNmList = getProcNmList( procList );
  testSuite  = getTestSuite( procNmList ); // allocates: testSuite.testList
  testSuite.qName = srvPgm;
  testSuite.testResults = MemMgr_createList('testSuite.testResults');

  return testSuite;

end-proc;


//----------------------------------------------------------------------
// Reclaim a test suite's allocated ressources. See prototype.
//----------------------------------------------------------------------
dcl-proc rclTestSuite export;
  dcl-pi *N;
    testSuite       likeds(testSuite_t);
  end-pi;

  dcl-s numTestResults int(10);
  dcl-s i int(10);
  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestResult);
  dcl-s testName like(testCaseResult.testName);

  // Deallocate list of test case procedures
  // created in EXTTST.getTestSuite
  MemMgr_dealloc(testSuite.testList: 'testSuite.testList');

  // Null-Check for RUNT self-test
  if (testSuite.testResults <> *null);
    numTestResults = list_size(testSuite.testResults);
    for i = 1 to numTestResults; // iterate: testResult
      pTestResult = list_getLast(testSuite.testResults); // iterate: assertFailEventLong
      testName = testCaseResult.testName;
      disposeTestResult(testCaseResult: i);
      list_removeLast(testSuite.testResults);
    endfor;
  endif;

  MemMgr_disposeList(testSuite.testResults: 'testSuite.testResults');

end-proc;


//----------------------------------------------------------------------
// Run a test case in a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc runTestCase export;
  dcl-pi *N likeds(testCaseResult_t);
    testSuite       const likeds(testSuite_t);
    testIdx         int(10) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t);
  dcl-ds testCase likeds(proc_t);


  testCase = getTestProc( testSuite : testIdx );

  testCaseResult = runTestProc(testCase
                           : testSuite.setup
                           : testSuite.tearDown);

  list_add(testSuite.testResults : %addr(testCaseResult) : %size(testCaseResult));

  return testCaseResult;

end-proc;


//----------------------------------------------------------------------
// Run a test case. See prototype.
//----------------------------------------------------------------------
dcl-proc runTestProc export;
  dcl-pi *N likeds(testCaseResult_t);
    testCase likeds(proc_t) const;
    setup    likeds(proc_t) const;
    tearDown likeds(proc_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) inz;

  dcl-s startTime timestamp;
  dcl-s endTime timestamp;

  dcl-ds testSuccessEvent likeds(testSuccessEvent_t) inz;

  testCaseResult = initTestResult(TEST_CASE_SUCCESS: testCase.procnm);

  startTime = %timestamp();

  if (setup.procptr <> *null);
    testCaseResult = runProc(setup.procptr: testCaseResult: 'SETUP');
  endif;

  if (testCaseResult.outcome = TEST_CASE_SUCCESS);
    testCaseResult = runProc(testCase.procPtr: testCaseResult: '');
  endif;

  if (tearDown.procPtr <> *null);
    // As of today errors in 'teardown' are not recorded, if
    // there was an error in 'setup', because 'testResult.outcome'
    // has already been set to 'E' due to the error in 'setup'.
    testCaseResult = runProc(tearDown.procPtr: testCaseResult: 'TEARDOWN');
  endif;

  endTime = %timestamp();

  if (startTime < endTime);
    testCaseResult.exectime = %diff(endTime: startTime: *mseconds);
  endif;

  if (g_status.isJUnitStyle);
    discardUnneededTestEvents(testCaseResult.hTestEvents);
  else;
    updateTestCaseOutcome(testCaseResult);
  endif;

  if (g_status.isJUnitStyle and testCaseResult.outcome = TEST_CASE_SUCCESS);
    // Add success event to satisfy XMLWRITER and RMTRUNSRV.
    // There is no specific assert procedure, as all asserts
    // have been successfully executed.
    testCaseResult.lastSuccessEvent = list_size(testCaseResult.hTestEvents) + 1;

    clear testSuccessEvent;
    testSuccessEvent.outcome = TEST_CASE_SUCCESS;
    testSuccessEvent.assertProc = '';
    testSuccessEvent.pCallstk = *null;

    testCaseResult.lastSuccessEvent =
      addSuccessTestEvent(testCaseResult.hTestEvents: testSuccessEvent);
  endif;

  return testCaseResult;

end-proc;

//----------------------------------------------------------------------
// Removed unneded test events, such as unconfirmed failure events
// and all success events.
//----------------------------------------------------------------------
dcl-proc discardUnneededTestEvents;
  dcl-pi *n extproc(*dclcase);
    hTestEvents pointer const;
  end-pi;

  dcl-s i int(10);
  dcl-s listSize int(10);
  dcl-s idx int(10);

  dcl-ds abstractTestEventDisposed likeds(abstractTestEvent_t) based(pAbstractTestEventDisposed);

  listSize = list_size(hTestEvents);

  idx = listSize;
  for i = 1 to listSize;
    pAbstractTestEventDisposed = list_get(hTestEvents: idx - 1);
    select;
    when (abstractTestEventDisposed.outcome = TEST_CASE_SUCCESS);
      disposeTestEvent(hTestEvents: idx);
    when (abstractTestEventDisposed.outcome = TEST_CASE_FAILURE);
      // dispose failure event and remove it from the list
      if (not abstractTestEventDisposed.failure.isConfirmed);
        disposeTestEvent(hTestEvents: idx);
      endif;
    endsl;
    idx -= 1;
  endfor;

end-proc;

//----------------------------------------------------------------------
// Iterates the test events and determines the final outcome.
//----------------------------------------------------------------------
dcl-proc updateTestCaseOutcome;
  dcl-pi *n extproc(*dclcase);
    testCaseResult likeds(testCaseResult_t);
  end-pi;

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  if (testCaseResult.outcome = TEST_CASE_ERROR);
    return;
  endif;

  list_resetIteration(testCaseResult.hTestEvents);
  pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  dow (pAbstractTestEvent <> *null);
    select;
    when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
      testCaseResult.outcome = TEST_CASE_SUCCESS;
      testCaseResult.lastSuccessEvent = abstractTestEvent.index;
    when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
      testCaseResult.outcome = TEST_CASE_FAILURE;
      testCaseResult.lastFailureEvent = abstractTestEvent.index;
    endsl;
    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Run a setup, teardown or test procedure. See prototype.
//----------------------------------------------------------------------
dcl-proc runProc export;
  dcl-pi *N likeds(testCaseResult_t);
    proc            pointer(*proc) const;
    testCaseResult  likeds(testCaseResult_t) value;
    procNamePrefix  like(assertProcNm_t) const;
  end-pi;

  dcl-s assertCnt int(10);
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) inz;
  dcl-ds abstractTestEventUpdated likeds(abstractTestEvent_t) based(pAbstractTestEventUpdated);

  clrAssertFailEvt(testCaseResult.hTestEvents: procNamePrefix);

  assertCnt = getAssertCalled() * -1;

  monitor;
    setLowMessageKey(getHighestMsgKey());
    callProcByPtr(proc);
  on-error;
    if (testCaseResult.outcome = TEST_CASE_SUCCESS);
      if (isRuntimeError());
        // Handle runtime error
        testCaseResult.outcome = TEST_CASE_ERROR;
        testCaseResult.lastErrorEvent = list_size(testCaseResult.hTestEvents) + 1;
        // Create runtime error event
        clear runtimeErrorEvent;
        runtimeErrorEvent.outcome = TEST_CASE_ERROR;
        runtimeErrorEvent.msg = rcvExcpMsgInfo();

        testCaseResult.lastErrorEvent =
          addErrorTestEvent(testCaseResult.hTestEvents: runtimeErrorEvent);
      else;
        // Handle failed assertion
        abstractTestEvent = getAssertEventInternal();
        testCaseResult.lastFailureEvent = abstractTestEvent.index;
        testCaseResult.outcome = TEST_CASE_FAILURE;

        resetAssertionError();

        // Update "isConfirmed" flag
        pAbstractTestEventUpdated = list_get(testCaseResult.hTestEvents
                                            : testCaseResult.lastFailureEvent - 1);
        abstractTestEventUpdated.failure.isConfirmed = *on;
        list_replace(testCaseResult.hTestEvents
                     : %addr(abstractTestEventUpdated)
                     : %size(abstractTestEventUpdated)
                     : testCaseResult.lastFailureEvent - 1);
      endif;
    endif;
  endmon;

  assertCnt += getAssertCalled();
  testCaseResult.assertCnt += assertCnt;

  return testCaseResult;

end-proc;


//----------------------------------------------------------------------
// Initializes a test result.
//----------------------------------------------------------------------
dcl-proc initTestResult export;
  dcl-pi *N likeds(testCaseResult_t);
    outcome  like(outcome_t) const;
    testName like(procNm_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t);

  clear testCaseResult;
  testCaseResult.outcome = TEST_CASE_SUCCESS;
  testCaseResult.testName = testName;
  testCaseResult.execTime = 0;
  testCaseResult.assertCnt = 0;
  testCaseResult.lastErrorEvent = 0;
  testCaseResult.lastFailureEvent = 0;
  testCaseResult.lastSuccessEvent = 0;
  testCaseResult.hTestEvents = MemMgr_createList('result.hTestEvents'); // arry(abstractTestEvent_t)

  return testCaseResult;

end-proc;


//----------------------------------------------------------------------
// Disposes a test result.
//----------------------------------------------------------------------
dcl-proc disposeTestResult export;
  dcl-pi *N;
    testCaseResult likeds(testCaseResult_t);
    idx            int(10) options(*nopass: *omit) const;
  end-pi;

  if (testCaseResult.hTestEvents <> *null);
    disposeTestEvents(testCaseResult.hTestEvents: idx);
  endif;

  clear testCaseResult;

end-proc;

//----------------------------------------------------------------------
// Disposes a list of test events.
//----------------------------------------------------------------------
dcl-proc disposeTestEvents export;
  dcl-pi *N;
    hTestEvents pointer;
    idx         int(10) options(*nopass: *omit) const;
  end-pi;

  dcl-s numAssertEvents int(10);
  dcl-s i int(10);

  dcl-s TESTRESULT_HASSERTEVENTS_TEXT varchar(64);

  if (%parms() >= %parmnum(idx) and %addr(idx) <> *null);
    TESTRESULT_HASSERTEVENTS_TEXT = 'testResult.hTestEvents_' + %char(idx);
  else;
    TESTRESULT_HASSERTEVENTS_TEXT = 'testResult.hTestEvents';
  endif;

  numAssertEvents = list_size(hTestEvents);
  for i = 1 to numAssertEvents;
    disposeTestEvent(hTestEvents: list_size(hTestEvents));
  endfor;

  MemMgr_disposeList(hTestEvents: TESTRESULT_HASSERTEVENTS_TEXT);

end-proc;

//----------------------------------------------------------------------
// Disposes a test event.
//----------------------------------------------------------------------
dcl-proc disposeTestEvent;
  dcl-pi *n;
    hTestEvents pointer const;
    idx         int(10) const;
  end-pi;

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  pAbstractTestEvent = list_get(hTestEvents: idx - 1);

  select;
  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
    disposeCallstack(abstractTestEvent.failure.pCallstk);
  when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
    if (g_status.isJUnitStyle);
      if (abstractTestEvent.success.pCallstk <> *null);
        sndEscapeMsgAboveCtlBdy('Call stack must be *null if using JUnit style.');
      endif;
    else;
      disposeCallstack(abstractTestEvent.success.pCallstk);
    endif;
  endsl;

  list_remove(hTestEvents: idx - 1);

end-proc;

//----------------------------------------------------------------------
// Disposes a callstack.
//----------------------------------------------------------------------
dcl-proc disposeCallstack export;
  dcl-pi *n;
    pCallstack pointer;
    idx         int(10) options(*nopass: *omit) const;
  end-pi;

  dcl-s ASSERT_EVENT_FAILURE_PCALLSTK_TEXT varchar(64);

  if (%parms() >= %parmnum(idx) and %addr(idx) <> *null);
    ASSERT_EVENT_FAILURE_PCALLSTK_TEXT = 'assertEvent.failure.pCallstk_' + %char(idx);
  else;
    ASSERT_EVENT_FAILURE_PCALLSTK_TEXT = 'assertEvent.failure.pCallstk';
  endif;

  Callstack_dealloc(pCallstack: ASSERT_EVENT_FAILURE_PCALLSTK_TEXT);

end-proc;

//----------------------------------------------------------------------
// Assert that at least one test case has run during execution.
//----------------------------------------------------------------------
dcl-proc assertHasRunAtLeastOneTestCase;
  dcl-pi *N extproc(*dclcase);
    testSuite       likeds(testSuite_t) const;
    testProcNm      like(procNm_t) const;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  dcl-ds excpMsgInfo likeds(msg_t);
  dcl-ds testCaseResult likeds(testCaseResult_t) inz;
  dcl-ds errorTestEvent likeds(runtimeErrorEvent_t) inz;

  if testSuiteResult.runsCnt = 0;
    clear excpMsgInfo;
    excpMsgInfo.id  = '';
    excpMsgInfo.txt = 'Test procedure not found.';

    testCaseResult = initTestResult(TEST_CASE_ERROR: testProcNm);

    clear errorTestEvent;
    errorTestEvent.outcome = TEST_CASE_ERROR;
    errorTestEvent.msg = excpMsgInfo;

    testCaseResult.lastErrorEvent =
      addErrorTestEvent(testCaseResult.hTestEvents: errorTestEvent);

    list_add(testSuite.testResults: %addr(testCaseResult): %size(testCaseResult));

    handleError(testSuiteResult);
  endif;

end-proc;


//----------------------------------------------------------------------
// Format a test run completion message. See prototype.
//----------------------------------------------------------------------
dcl-proc fmtCompMsg export;
  dcl-pi *N varchar(256);
    testCaseCnt int(10) const;
    assertCnt   int(10) const;
    failureCnt  int(10) const;
    errorCnt    int(10) const;
  end-pi;

  dcl-s msg varchar(256);


  select;
  when (errorCnt <> 0);
    msg = 'ERROR';
  when (failureCnt <> 0);
    msg = 'FAILURE';
  other;
    msg = 'Success';
  endsl;

  msg += '. ';
  msg += fmtWordWithCnt( testCaseCnt : 'test case' ) + ', ';
  msg += fmtWordWithCnt( assertCnt   : 'assertion' ) + ', ';
  msg += fmtWordWithCnt( failureCnt  : 'failure'   ) + ', ';
  msg += fmtWordWithCnt( errorCnt    : 'error'     ) + '.';

  return msg;

end-proc;


//----------------------------------------------------------------------
// Format a word with its counter.
// (e.g., fmtWordWithCnt( 2 : 'apple' ) = '2 apples' )
//----------------------------------------------------------------------
dcl-proc fmtWordWithCnt;
  dcl-pi *N varchar(256) extproc(*dclcase);
    cnt  int(10) const;
    word varchar(256) const;
  end-pi;

  if (cnt < 2);
    return %char(cnt) + ' ' + word;
  else;
    return %char(cnt) + ' ' + word + 's';
  endif;

end-proc;


//----------------------------------------------------------------------
// Handle a test error event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleError;
  dcl-pi *N;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  testSuiteResult.errorCnt += 1;

end-proc;


//----------------------------------------------------------------------
// Handle a test failure event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleFailure;
  dcl-pi *N;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  testSuiteResult.failureCnt += 1;

end-proc;


//----------------------------------------------------------------------
// Set up the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc setupTestSuite;
  dcl-pi *N like(outcome_t) extproc(*dclcase);
    testSuite       likeds(testSuite_t) const;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t);

  testCaseResult = initTestResult(TEST_CASE_SUCCESS: testSuite.setupSuite.procNm);
  testCaseResult = runProc(testSuite.setupSuite.procptr: testCaseResult: 'SETUPSUITE');

  if (testCaseResult.outcome = TEST_CASE_SUCCESS);
    disposeTestResult(testCaseResult);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testSuite.testResults: %addr(testCaseResult): %size(testCaseResult));

  select;
  when testCaseResult.outcome = TEST_CASE_FAILURE;
    handleFailure(testSuiteResult);
    return TEST_CASE_FAILURE;
  when testCaseResult.outcome = TEST_CASE_ERROR;
    handleError(testSuiteResult);
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Tear down the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc tearDownTestSuite;
  dcl-pi *N like(outcome_t) extproc(*dclcase);
    testSuite       likeds(testSuite_t) const;
    testSuiteResult likeds(testSuiteResult_t);
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t);

  testCaseResult = initTestResult(TEST_CASE_SUCCESS: testSuite.tearDownSuite.procNm);
  testCaseResult = runProc(testSuite.tearDownSuite.procPtr: testCaseResult: 'TEARDOWNSUITE');

  if (testCaseResult.outcome = TEST_CASE_SUCCESS);
    disposeTestResult(testCaseResult);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testSuite.testResults : %addr(testCaseResult) : %size(testCaseResult));

  select;
  when testCaseResult.outcome = TEST_CASE_FAILURE;
    handleFailure(testSuiteResult);
    return TEST_CASE_FAILURE;
  when testCaseResult.outcome = TEST_CASE_ERROR;
    handleError(testSuiteResult);
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Run the tests in a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc runTests export;
  dcl-pi *N;
    testSuiteResult likeds(testSuiteResult_t);
    testSuite       likeds(testSuite_t) const;
    testProcsToRun  likeds(procNms_t) const;
    order           char(8) const;
    detail          char(6) const;
    rclrsc          char(10) const;
  end-pi;

  dcl-s step int(10);
  dcl-s testIdx int(10);
  dcl-s testProcNm like(procNm_t);
  dcl-ds testCaseResult likeds(testCaseResult_t);
  dcl-s assertionCntBeforeRun int(10);
  dcl-s assertionCntAfterRun int(10);
  dcl-c CMD_RCLRSC 'RCLRSC LVL(*) OPTION(*NORMAL)';

  setTestRunOrder( testSuite : order : testIdx : step );

  dow (1 <= testIdx and testIdx <= testSuite.testCasesCnt);
    testProcNm = getTestNm( testSuite : testIdx );
    if (testSuite.isCobol and endsWith('_reset': testProcNm));
      testIdx += step;
      iter;
    endif;

    if isInTestProcToRun(testProcNm: testProcsToRun);

      assertionCntBeforeRun = getAssertCalled();
      status( testSuite.qName.nm : testProcNm );

      // Run test case
      testCaseResult = runTestCase( testSuite : testIdx );

      if (rclrsc = RCLRSC_ALWAYS);
        qcmdexc(CMD_RCLRSC: %len(CMD_RCLRSC));
      endif;

      assertionCntAfterRun = getAssertCalled();
      testSuiteResult.assertCnt += (assertionCntAfterRun - assertionCntBeforeRun);
      testSuiteResult.runsCnt += 1;

      select;
      when (testCaseResult.outcome = TEST_CASE_SUCCESS);
        // nothing to do here
      when (testCaseResult.outcome = TEST_CASE_FAILURE);
        handleFailure(testSuiteResult);
      when (testCaseResult.outcome = TEST_CASE_ERROR);
        handleError(testSuiteResult);
      endsl;

    endif;

    testIdx += step;
  enddo;

  assertHasRunAtLeastOneTestCase(testSuite: testProcsToRun.name(1) :testSuiteResult);

  if (rclrsc = RCLRSC_ALWAYS or rclrsc = RCLRSC_ONCE);
    qcmdexc(CMD_RCLRSC: %len(CMD_RCLRSC));
  endif;

end-proc;


//----------------------------------------------------------------------
// Returns *ON when the array of selected test procedures
// contains a given name.
//----------------------------------------------------------------------
dcl-proc isInTestProcToRun;
  dcl-pi *N ind extproc(*dclcase);
    testProcNm      const like(procNm_t);
    testProcsToRun  const likeds(procNms_t);
  end-pi;

  dcl-s i int(10);
  dcl-s testProc like(testProcNm);

  if (testProcsToRun.nume = 1 and testProcsToRun.name(1) = TSTPRC_ALL);
    return *on;
  endif;

  testProc = uCase(testProcNm);

  for i = 1 to testProcsToRun.nume;
    if (testProc = uCase(testProcsToRun.name(i)));
      return *on;
    endif;
  endfor;

  return *off;

end-proc;


//----------------------------------------------------------------------
//  Sets the execution order of the test cases.
//----------------------------------------------------------------------
dcl-proc setTestRunOrder;
  dcl-pi *N extproc(*dclcase);
    testSuite       const likeds(testSuite_t);
    order           char(8) const;
    startIdx        int(10);
    step            int(10);
  end-pi;

  dcl-s firstTestIdx int(10);
  dcl-s lastTestIdx int(10);

  dcl-c INCREASING_ORDER 1;
  dcl-c DECREASING_ORDER -1;

  firstTestIdx = 1;
  lastTestIdx  = testSuite.testCasesCnt;

  if (order = ORDER_REVERSE);
    startIdx = lastTestIdx;
    step = DECREASING_ORDER;
  else;
    startIdx = firstTestIdx;
    step = INCREASING_ORDER;
  endif;

end-proc;


//----------------------------------------------------------------------
//  Sends a message of the execution status to the command line.
//----------------------------------------------------------------------
dcl-proc status;
  dcl-pi *N extproc(*dclcase);
    testSuiteNm     const like(object_t.nm);
    testProcNm      const like(procNm_t);
  end-pi;

  sndStsMsg( 'Running ' + %trimr(testSuiteNm) + ' - ' + testProcNm );

end-proc;


//----------------------------------------------------------------------
// Check and restore library list.
//----------------------------------------------------------------------
dcl-proc checkAndRestoreLibl;
  dcl-pi *N extproc(*dclcase);
    mustRestoreLibl ind const;
    savedLibl       const  likeds(liblData_t);
  end-pi;

  if (mustRestoreLibl);
    restoreLibl(savedLibl);
  endif;

end-proc;


//----------------------------------------------------------------------
// Returns the last recorded error event.
//----------------------------------------------------------------------
dcl-proc getLastErrorEvent export;
  dcl-pi *n likeds(runtimeErrorEvent_t);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  errorEvent = getLastEvent(testCaseResult: TEST_CASE_ERROR);

  if (testCaseResult.lastErrorEvent <> errorEvent.index);
    sndEscapeMsgAboveCtlBdy(
      'Index of ''lastErrorEvent'' does not match event index: ' + %char(errorEvent.index));
  endif;

  return errorEvent;

end-proc;

//----------------------------------------------------------------------
// Returns the last recorded failure event.
//----------------------------------------------------------------------
dcl-proc getLastFailureEvent export;
  dcl-pi *n likeds(testFailureEvent_t);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;

  testFailureEvent = getLastEvent(testCaseResult: TEST_CASE_FAILURE);

  if (testCaseResult.lastFailureEvent <> testFailureEvent.index);
    sndEscapeMsgAboveCtlBdy(
      'Index of ''lastFailureEvent'' does not match event index: ' + %char(testFailureEvent.index));
  endif;

  return testFailureEvent;

end-proc;


//----------------------------------------------------------------------
// Returns the last recorded event.
//----------------------------------------------------------------------
dcl-proc getLastEvent;
  dcl-pi *n likeds(abstractTestEvent_t) extproc(*dclcase);
    testCaseResult likeds(testCaseResult_t) const;
    outcome        like(outcome_t) const;
  end-pi;

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  pAbstractTestEvent = list_getLast(testCaseResult.hTestEvents);

  checkEventType(abstractTestEvent.outcome);

  if (abstractTestEvent.outcome <> outcome);
    sndEscapeMsgAboveCtlBdy(
      'Event type ''' + abstractTestEvent.outcome + ''' does not match type: ' + outcome);
  endif;

  select;
  when (abstractTestEvent.outcome = TEST_CASE_ERROR);
    return abstractTestEvent.error;
  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
    return  abstractTestEvent.failure;
  when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
    return abstractTestEvent.success;
  endsl;

end-proc;

dcl-proc checkEventType;
  dcl-pi *n extproc(*dclcase);
    outcome like(outcome_t) const;
  end-pi;

  if (outcome <> TEST_CASE_ERROR
      and outcome <> TEST_CASE_FAILURE
      and outcome <> TEST_CASE_SUCCESS);
    sndEscapeMsgAboveCtlBdy('Unknown event type: ''' + outcome + '''');
  endif;

end-proc;


//----------------------------------------------------------------------
// Adds a "success" test event.
//----------------------------------------------------------------------
dcl-proc addSuccessTestEvent export;
  dcl-pi *n int(10);
    hTestEvents      pointer const;
    successTestEvent likeds(testSuccessEvent_t);
  end-pi;

  dcl-ds successTestEventUpdated likeds(successTestEvent) based(pSuccessTestEventUpdated);

  list_add(hTestEvents: %addr(successTestEvent): %size(successTestEvent));

  pSuccessTestEventUpdated = list_getLast(hTestEvents);
  successTestEventUpdated.index = list_size(hTestEvents);
  list_replace(hTestEvents
               : %addr(successTestEventUpdated)
               : %size(successTestEventUpdated)
               : successTestEventUpdated.index - 1);

  return successTestEventUpdated.index;

end-proc;


//----------------------------------------------------------------------
// Adds a "failure" test event.
//----------------------------------------------------------------------
dcl-proc addFailureTestEvent export;
  dcl-pi *n int(10);
    hTestEvents      pointer const;
    failureTestEvent likeds(testFailureEvent_t);
  end-pi;

  dcl-ds failureTestEventUpdated likeds(failureTestEvent) based(pFailureTestEventUpdated);

  list_add(hTestEvents: %addr(failureTestEvent): %size(failureTestEvent));

  pFailureTestEventUpdated = list_getLast(hTestEvents);
  failureTestEventUpdated.index = list_size(hTestEvents);
  list_replace(hTestEvents
               : %addr(failureTestEventUpdated)
               : %size(failureTestEventUpdated)
               : failureTestEventUpdated.index - 1);

  return failureTestEventUpdated.index;

end-proc;


//----------------------------------------------------------------------
// Adds a "error" test event.
//----------------------------------------------------------------------
dcl-proc addErrorTestEvent export;
  dcl-pi *n int(10);
    hTestEvents    pointer const;
    errorTestEvent likeds(runtimeErrorEvent_t);
  end-pi;

  dcl-ds errorTestEventUpdated likeds(errorTestEvent) based(pErrorTestEventUpdated);

  list_add(hTestEvents: %addr(errorTestEvent): %size(errorTestEvent));

  pErrorTestEventUpdated = list_getLast(hTestEvents);
  errorTestEventUpdated.index = list_size(hTestEvents);
  list_replace(hTestEvents
               : %addr(errorTestEventUpdated)
               : %size(errorTestEventUpdated)
               : errorTestEventUpdated.index - 1);

  return errorTestEventUpdated.index;

end-proc;

//----------------------------------------------------------------------
// Builds the name of the test case as it is displayed in the XML.
// Uses the test case name for assertion mode *FAILFIRST, otherwise
// builds the names with template 'testName.assertProcName'.
//----------------------------------------------------------------------
dcl-proc buildReportTestCaseName export;
  dcl-pi *n like(string_t);
    testCaseResult likeds(testCaseResult_t) const;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s assertProcName like(assertProcNm_t);

  select;
  when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
    assertProcName = abstractTestEvent.success.assertProc;
  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
    assertProcName = abstractTestEvent.failure.assertProc;
  other;
    assertProcName = '';
  endsl;

  if (g_status.isJUnitStyle or assertProcName = '');
    return %trimr(testCaseResult.testName);
  else;
    return %trimr(testCaseResult.testName) + '.' + abstractTestEvent.failure.assertProc
                                           + '_' + %char(abstractTestEvent.failure.index);
  endif;

end-proc;

//----------------------------------------------------------------------
// Returns the number of assertions as displayed in the XML.
// Returns the total number of assertions for assertion mode *FAILFIRST,
// otherwise 1.
//----------------------------------------------------------------------
dcl-proc getReportNumAsserts export;
  dcl-pi *n int(10);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-s numAssertions int(10);

  if (g_status.isJUnitStyle);
    numAssertions = testCaseResult.assertCnt;
  else;
    numAssertions = 1;
  endif;

  return numAssertions;

end-proc;

//----------------------------------------------------------------------
// Returns the number of assertions as displayed in the XML.
// Returns the total number of assertions for assertion mode *FAILFIRST,
// otherwise 1.
//----------------------------------------------------------------------
dcl-proc getReportExecutionTimeTestCase export;
  dcl-pi *n int(10);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-s numAssertions int(10);

  if (g_status.isJUnitStyle);
    numAssertions = testCaseResult.assertCnt;
  else;
    numAssertions = 1;
  endif;

  return numAssertions;

end-proc;

