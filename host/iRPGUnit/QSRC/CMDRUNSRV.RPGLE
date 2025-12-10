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
//   Procedure Definitions
//----------------------------------------------------------------------

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
    output        like(output_t) const;
    libl          likeds(libl_t) const;
    qJobD         likeds(object_t) const;
    rclRsc        like(rclrsc_t) const;
    xmlStmf       like(stmf_t) const;
    xmlType       like(xmlType_t) const;
    isJunitStyle  ind const;
    msg           varchar(256); // Completion message.
  end-pi;

  dcl-ds testSuite likeds(testSuite_t);
  dcl-s maxSizeAllocMem like(memSize_t);

  dcl-s xmlStmfMsg char(256);

  // Test event counters.
  dcl-ds testSuiteResult likeds(result_t);

  // Save/set/restore library list
  dcl-ds savedLibl likeds(liblData_t);
  dcl-s mustRestoreLibl ind inz(*off);

  dcl-ds xmlStmfInfo likeds(xmlStmfInfo_t) inz;

  g_status.isJunitStyle = isJunitStyle;

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
  logTestResult(testSuite: qTestSuite: testSuiteResult);

  // Return result to xml file
  if (xmlStmfInfo.path <> '');
    monitor;
      writeXmlFile(xmlStmfInfo.path:
                   testSuite: qTestSuite: testSuiteResult: xmlStmfInfo.type);
      xmlStmfMsg = 'Created XML file (' + xmlStmfInfo.type + '): ' + xmlStmfInfo.path;
      sndInfoMsg(xmlStmfMsg);
      xmlStmfMsg = '';
    on-error;
      xmlStmfMsg = rcvMsgTxt('*ESCAPE');
    endmon;
  endif;

  // Return result to plug-in
  if (%parms() >= %parmnum(userSpace) and %addr(userSpace) <> *null);
    fillUserSpace(userSpace : testSuite : qTestSuite : testSuiteResult);
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
dcl-proc logTestResult export;
  dcl-pi *N;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(Object_t) const;
    testSuiteResult likeds(result_t);
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t) based(pTestResult);
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
        // events had been monitored.
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
  dcl-ds testCaseResult likeds(testResult_t) based(pTestResult);
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
  dcl-pi *N likeds(testResult_t);
    testSuite       const likeds(testSuite_t);
    testIdx         int(10) const;
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t);
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
  dcl-pi *N likeds(testResult_t);
    testCase likeds(proc_t) const;
    setup    likeds(proc_t) const;
    tearDown likeds(proc_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t) inz;

  dcl-s startTime timestamp;
  dcl-s endTime timestamp;

  dcl-s i int(10);
  dcl-s listSize int(10);
  dcl-s idx int(10);
  dcl-ds abstractTestEventDisposed likeds(abstractTestEvent_t) based(pAbstractTestEventDisposed);
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) inz;

  testCaseResult = initTestResult(testCase.procnm);

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

  // Validate the events returned by the test case and
  // remove monitored failure events and success events.
  if (g_status.isJunitStyle and testCaseResult.outcome = TEST_CASE_SUCCESS);
    if (list_size(testCaseResult.hTestEvents) > 0);
      // dispose or flag failed assertions that have been ignored
      listSize = list_size(testCaseResult.hTestEvents);
      for i = 1 to listSize;
        idx = list_size(testCaseResult.hTestEvents);
        pAbstractTestEventDisposed = list_get(testCaseResult.hTestEvents: idx - 1);
        select;
        when (abstractTestEventDisposed.outcome = TEST_CASE_SUCCESS);
          disposeTestEvent(testCaseResult.hTestEvents: idx);
        when (abstractTestEventDisposed.outcome = TEST_CASE_FAILURE);
          // dispose failure event and remove it from the list
          if (not abstractTestEventDisposed.failure.isConfirmed);
            // handleFailure(testSuiteResult); TODO: count unconfirmed failure events
          endif;
          disposeTestEvent(testCaseResult.hTestEvents: idx);
        endsl;
      endfor;
    endif;

    // Add success event to satisfy XMLWRITER and RMTRUNSRV.
    // There is no specific assert procedure, as all asserts
    // have been successfully executed.
    testCaseResult.lastSuccessEvent = list_size(testCaseResult.hTestEvents) + 1;

    clear abstractTestEvent;
    abstractTestEvent.success.outcome = TEST_CASE_SUCCESS;
    abstractTestEvent.success.assertProc = '';
    abstractTestEvent.success.index = testCaseResult.lastSuccessEvent;
    list_add(testCaseResult.hTestEvents
             : %addr(abstractTestEvent.success): %size(abstractTestEvent.success));
  endif;

  return testCaseResult;

end-proc;


//----------------------------------------------------------------------
// Run a setup, teardown or test procedure. See prototype.
//----------------------------------------------------------------------
dcl-proc runProc export;
  dcl-pi *N likeds(testResult_t);
    proc            pointer(*proc) const;
    testCaseResult  likeds(testResult_t) value;
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
        runtimeErrorEvent.outcome = TEST_CASE_ERROR;
        runtimeErrorEvent.msg = rcvExcpMsgInfo();
        runtimeErrorEvent.index = testCaseResult.lastErrorEvent;
        list_add(testCaseResult.hTestEvents: %addr(runtimeErrorEvent): %size(runtimeErrorEvent));
      else;
        // Handle failed assertion
        abstractTestEvent = getAssertEventInternal();
        testCaseResult.lastFailureEvent = abstractTestEvent.index;
        testCaseResult.outcome = TEST_CASE_FAILURE;
        resetAssertionError();
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
  dcl-pi *N likeds(testResult_t);
    testName        const like(procNm_t);
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t);

  clear testCaseResult;
  testCaseResult.execTime = 0;
  testCaseResult.outcome = TEST_CASE_SUCCESS;
  testCaseResult.testName = testName;
  testCaseResult.hTestEvents = MemMgr_createList('result.hTestEvents')
  ;                                                             // arry(abstractTestEvent_t)

  return testCaseResult;

end-proc;


//----------------------------------------------------------------------
// Disposes a test result.
//----------------------------------------------------------------------
dcl-proc disposeTestResult export;
  dcl-pi *N;
    testCaseResult likeds(testResult_t);
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

  if (abstractTestEvent.outcome = TEST_CASE_FAILURE);
    disposeCallstack(abstractTestEvent.failure.pCallstk);
  endif;

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
    testSuiteResult likeds(result_t);
  end-pi;

  dcl-ds excpMsgInfo likeds(msg_t);
  dcl-ds testResult likeds(testResult_t) inz;
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) inz;

  if testSuiteResult.runsCnt = 0;
    clear excpMsgInfo;
    excpMsgInfo.id  = '';
    excpMsgInfo.txt = 'Test procedure not found.';

    // TODO: add error event
    clear testResult;
    testResult.outcome = TEST_CASE_ERROR;
    testResult.testName = testProcNm;
    testResult.execTime = 0;
    testResult.srcFile = '';
    testResult.srcLib = '';
    testResult.srcFile = '';
    testResult.assertCnt = 0;
    testResult.lastErrorEvent = 1;
    testResult.lastFailureEvent = 0;
    testResult.lastSuccessEvent = 0;
    testResult.hTestEvents = MemMgr_createList('testResult.hTestEvents');

    clear abstractTestEvent.error;
    abstractTestEvent.error.outcome = TEST_CASE_ERROR;
    abstractTestEvent.error.index = 0;
    abstractTestEvent.error.msg = excpMsgInfo;

    list_add(testResult.hTestEvents
             : %addr(abstractTestEvent.error): %size(abstractTestEvent.error));

    list_add(testSuite.testResults: %addr(testResult): %size(testResult));

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
    testSuiteResult likeds(result_t);
  end-pi;

  testSuiteResult.errorCnt += 1;

end-proc;


//----------------------------------------------------------------------
// Handle a test failure event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleFailure;
  dcl-pi *N;
    testSuiteResult likeds(result_t);
  end-pi;

  testSuiteResult.failureCnt += 1;

end-proc;


//----------------------------------------------------------------------
// Set up the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc setupTestSuite;
  dcl-pi *N char(1) extproc(*dclcase);
    testSuite       likeds(testSuite_t) const;
    testSuiteResult likeds(result_t);
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t);
  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;

  testCaseResult = initTestResult(testSuite.setupSuite.procNm);
  testCaseResult = runProc(testSuite.setupSuite.procptr: testCaseResult: 'SETUPSUITE');

  if (testCaseResult.outcome = TEST_CASE_SUCCESS);
    disposeTestResult(testCaseResult);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testSuite.testResults: %addr(testCaseResult): %size(testCaseResult));

  select;
  when testCaseResult.outcome = TEST_CASE_FAILURE;
    testFailureEvent = getLastFailureEvent(testCaseResult);
    handleFailure(testSuiteResult);
    return TEST_CASE_FAILURE;
  when testCaseResult.outcome = TEST_CASE_ERROR;
    runtimeErrorEvent = getLastErrorEvent(testCaseResult);
    handleError(testSuiteResult);
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Tear down the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc tearDownTestSuite;
  dcl-pi *N char(1) extproc(*dclcase);
    testSuite       likeds(testSuite_t) const;
    testSuiteResult likeds(result_t);
  end-pi;

  dcl-ds testCaseResult likeds(testResult_t);
  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;

  testCaseResult = initTestResult(testSuite.tearDownSuite.procNm);
  testCaseResult = runProc(testSuite.tearDownSuite.procPtr: testCaseResult: 'TEARDOWNSUITE');

  if (testCaseResult.outcome = TEST_CASE_SUCCESS);
    disposeTestResult(testCaseResult);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testSuite.testResults : %addr(testCaseResult) : %size(testCaseResult));

  select;
  when testCaseResult.outcome = TEST_CASE_FAILURE;
    testFailureEvent = getLastFailureEvent(testCaseResult);
    handleFailure(testSuiteResult);
    return TEST_CASE_FAILURE;
  when testCaseResult.outcome = TEST_CASE_ERROR;
    runtimeErrorEvent = getLastErrorEvent(testCaseResult);
    handleError(testSuiteResult);
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Run the tests in a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc runTests export;
  dcl-pi *N;
    testSuiteResult likeds(result_t);
    testSuite       likeds(testSuite_t) const;
    testProcsToRun  likeds(procNms_t) const;
    order           char(8) const;
    detail          char(6) const;
    rclrsc          char(10) const;
  end-pi;

  dcl-s step int(10);
  dcl-s testIdx int(10);
  dcl-s testProcNm like(procNm_t);
  dcl-ds testCaseResult likeds(testResult_t);
  dcl-s assertionCntBeforeRun int(10);
  dcl-s assertionCntAfterRun int(10);
  dcl-c CMD_RCLRSC 'RCLRSC LVL(*) OPTION(*NORMAL)';

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;

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
        testFailureEvent = getLastFailureEvent(testCaseResult);
        handleFailure(testSuiteResult);
      when (testCaseResult.outcome = TEST_CASE_ERROR);
        runtimeErrorEvent = getLastErrorEvent(testCaseResult);
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
// Returns the next matching test event.
//----------------------------------------------------------------------
dcl-proc getFilteredTestEvents export;
  dcl-pi *n pointer;
    testCaseResult likeds(testResult_t) const;
    maxNumEvents   int(10) const;
    countEvents    int(10);
  end-pi;

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  if (countEvents >= maxNumEvents);
    return *null;
  endif;

  pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  dow (pAbstractTestEvent <> *null);

    // Only the last failure or error events is returned.
    // The event must match the overall test result.
    if (testCaseResult.outcome = abstractTestEvent.outcome);
      select;
      when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
        return pAbstractTestEvent;
      when (testCaseResult.outcome = TEST_CASE_ERROR
            and testCaseResult.lastErrorEvent = abstractTestEvent.index);
        return pAbstractTestEvent;
      when (testCaseResult.outcome = TEST_CASE_FAILURE
            and testCaseResult.lastFailureEvent = abstractTestEvent.index);
        return pAbstractTestEvent;
      endsl;
    endif;

    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  enddo;

  return *null;

end-proc;

//----------------------------------------------------------------------
// Returns the last recorded error event.
//----------------------------------------------------------------------
dcl-proc getLastErrorEvent export;
  dcl-pi *n likeds(runtimeErrorEvent_t);
    testCaseResult likeds(testResult_t) const;
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
    testCaseResult likeds(testResult_t) const;
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
    testCaseResult likeds(testResult_t) const;
    outcome        char(1) const;
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
    outcome char(1) const;
  end-pi;

  if (outcome <> TEST_CASE_ERROR
      and outcome <> TEST_CASE_FAILURE
      and outcome <> TEST_CASE_SUCCESS);
    sndEscapeMsgAboveCtlBdy('Unknown event type: ''' + outcome + '''');
  endif;

end-proc;

