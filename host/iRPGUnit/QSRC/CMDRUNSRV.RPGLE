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
/include qinclude,CMDRUNLOG
/include qinclude,CMDRUNSRV
/include qinclude,CMDRUNV
/include qinclude,EXTPRC
/include qinclude,EXTTST
/include qinclude,LIBL
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
    msg           varchar(256); // Completion message.
  end-pi;

  dcl-ds testSuite likeds(testSuite_t);

  dcl-s xmlStmfMsg char(256);

  // Test event counters.
  dcl-ds result likeds(result_t);

  // Save/set/restore library list
  dcl-ds savedLibl likeds(liblData_t);
  dcl-s mustRestoreLibl ind inz(*off);

  dcl-ds xmlStmfInfo likeds(xmlStmfInfo_t) inz;

  if (xmlStmf <> '');
    msg = validateXmlStmf(xmlStmf: qTestSuite);
    if (msg <> '');
      sndEscapeMsgAboveCtlBdy( msg );
    endif;
  endif;

  clear xmlStmfInfo;
  xmlStmfInfo.path = resolvePathVariables(xmlStmf: qTestSuite);
  xmlStmfInfo.type = xmlType;

  clear result;
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

  setupTestSuite( testSuite : result );

  if (result.errorCnt = 0 and result.failureCnt = 0);
    runTests(result: testSuite: testProcs:
             order: detail: rclRsc);
  endif;

  tearDownTestSuite( testSuite : result );

  result.assertCnt = getAssertCalled();

  // Return result to xml file
  if (xmlStmfInfo.path <> '');
    monitor;
      writeXmlFile(xmlStmfInfo.path:
                   testSuite: qTestSuite: result: xmlStmfInfo.type);
      xmlStmfMsg = 'Created XML file (' + xmlStmfInfo.type + '): ' + xmlStmfInfo.path;
      sndInfoMsg(xmlStmfMsg);
      xmlStmfMsg = '';
    on-error;
      xmlStmfMsg = rcvMsgTxt('*ESCAPE');
    endmon;
  endif;

  // Return result to plug-in
  if (%parms() >= %parmnum(userSpace) and %addr(userSpace) <> *null);
    fillUserSpace(userSpace : testSuite : qTestSuite : result);
  endif;

  // Restore library list
  checkAndRestoreLibl(mustRestoreLibl: savedLibl);

  monitor;
    rclTestSuite( testSuite );
  on-error;
    raiseRUError( 'Failed to reclaim the test suite''s resources.' );
  endmon;

  msg = fmtCompMsg( result.runsCnt:
                    result.assertCnt:
                    result.failureCnt:
                    result.errorCnt );

  // ignore any messages here
  monitor;
    // Log completion message to spooled file
    logCompMsg(msg : result.failureCnt : result.errorCnt );
  on-error;
    // nothing
  endmon;

  if (xmlStmfMsg <> '');
    msg = xmlStmfMsg;
    return *off; // FAILURE
  else;
    if (result.failureCnt = 0 and result.errorCnt = 0);
      return *on; // SUCCESS
    else;
      return *off; // FAILURE
    endif;
  endif;

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
  testSuite  = getTestSuite( procNmList );
  testSuite.qName = srvPgm;
  testSuite.testResults = list_create();

  return testSuite;

end-proc;


//----------------------------------------------------------------------
// Reclaim a test suite's allocated ressources. See prototype.
//----------------------------------------------------------------------
dcl-proc rclTestSuite export;
  dcl-pi *N;
    testSuite       likeds(testSuite_t);
  end-pi;

  dealloc(n) testSuite.testList;
  list_dispose(testSuite.testResults);

end-proc;


//----------------------------------------------------------------------
// Run a test case in a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc runTest export;
  dcl-pi *N likeds(testResult_t);
    testSuite       const likeds(testSuite_t);
    testIdx         int(10) const;
  end-pi;

  dcl-ds testCase likeds(proc_t);


  testCase = getTestProc( testSuite : testIdx );

  return runTestProc( testCase :
                      testSuite.setup :
                      testSuite.tearDown );

end-proc;


//----------------------------------------------------------------------
// Run a test case. See prototype.
//----------------------------------------------------------------------
dcl-proc runTestProc export;
  dcl-pi *N likeds(testResult_t);
    testCase        const likeds(proc_t);
    setup           const likeds(proc_t);
    tearDown        const likeds(proc_t);
  end-pi;

  dcl-ds testResult likeds(testResult_t);
  dcl-s startTime timestamp;
  dcl-s endTime timestamp;

  testResult = initTestResult(testCase.procnm);

  startTime = %timestamp();

  if (setup.procptr <> *null);
    runProc(setup.procptr: testResult);
  endif;

  if testResult.outcome = TEST_CASE_SUCCESS;
    runProc(testCase.procPtr: testResult);
  endif;

  if tearDown.procPtr <> *null;
    runProc(tearDown.procPtr: testResult);
  endif;

  endTime = %timestamp();

  if (startTime < endTime);
    testResult.exectime = %diff(endTime: startTime: *mseconds);
  endif;

  return testResult;

end-proc;


//----------------------------------------------------------------------
// Run a setup, teardown or test procedure. See prototype.
//----------------------------------------------------------------------
dcl-proc runProc export;
  dcl-pi *N likeds(testResult_t);
    proc            pointer(*proc) const;
    result          likeds(testResult_t);
  end-pi;

  dcl-ds failureEvt likeds(assertFailEvtLong_t);
  dcl-s assertCnt int(10);

  clrAssertFailEvt();
  assertCnt = getAssertCalled() * -1;

  monitor;
    setLowMessageKey(getHighestMsgKey());
    callProcByPtr( proc );
  on-error;
    if (result.outcome = TEST_CASE_SUCCESS);
      if (isRuntimeError());
        // Handle runtime error
        result.outcome = TEST_CASE_ERROR;
        result.error = rcvExcpMsgInfo();
      else;
        // Handle failed assertion
        failureEvt = getAssertFailEvtLong();
        result.outcome = TEST_CASE_FAILURE;
        result.failure = failureEvt;
      endif;
    endif;
  endmon;

  assertCnt += getAssertCalled();
  result.assertCnt += assertCnt;

  return result;

end-proc;


//----------------------------------------------------------------------
// Run a test case. See prototype.
//----------------------------------------------------------------------
dcl-proc initTestResult export;
  dcl-pi *N likeds(testResult_t);
    testName        const like(procNm_t);
  end-pi;

  dcl-ds result likeds(testResult_t);

  clear result;
  result.execTime = 0;
  result.outcome = TEST_CASE_SUCCESS;
  result.testName = testName;

  return result;

end-proc;

//----------------------------------------------------------------------
// Assert that at least one test case has run during execution.
//----------------------------------------------------------------------
dcl-proc assertHasRunAtLeastOneTestCase;
  dcl-pi *N extproc(*dclcase);
    testProcNm const like(procNm_t);
    result     likeds(result_t);
  end-pi;

  dcl-ds excpMsgInfo likeds(msg_t);


  if result.runsCnt = 0;
    clear excpMsgInfo;
    excpMsgInfo.id  = '';
    excpMsgInfo.txt = 'Test procedure not found.';
    handleError( testProcNm : excpMsgInfo : result);
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
dcl-proc handleError export;
  dcl-pi *N;
    testProcNm  const like(procNm_t);
    excpMsgInfo const likeds(msg_t);
    result      likeds(result_t);
  end-pi;

  result.errorCnt += 1;
  logError(testProcNm: excpMsgInfo);

end-proc;


//----------------------------------------------------------------------
// Handle a test failure event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleFailure export;
  dcl-pi *N;
    testProcNm      const like(procNm_t);
    failure         const likeds(assertFailEvtLong_t);
    result          likeds(result_t);
  end-pi;

  result.failureCnt += 1;
  logfailure(testProcNm: failure);

end-proc;


//----------------------------------------------------------------------
// Handle a test success event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleSuccess export;
  dcl-pi *N;
    testProcNm      const like(procNm_t);
    assertionCnt    int(10) const;
  end-pi;

  logSuccess(testProcNm: assertionCnt);

end-proc;


//----------------------------------------------------------------------
// Set up the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc setupTestSuite;
  dcl-pi *N char(1) extproc(*dclcase);
    testSuite likeds(testSuite_t) const;
    result    likeds(result_t);
  end-pi;

  dcl-ds testResult likeds(testResult_t);

  testResult = initTestResult(testSuite.setupSuite.procNm);
  testResult = runProc( testSuite.setupSuite.procptr : testResult );

  if (testResult.outcome = TEST_CASE_SUCCESS);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testSuite.testResults : %addr(testResult) :
           %size(testResult));

  select;
  when testResult.outcome = TEST_CASE_FAILURE;
    handleFailure(
      testSuite.setupSuite.procNm : testResult.failure : result );
    return TEST_CASE_FAILURE;
  when testResult.outcome = TEST_CASE_ERROR;
    handleError(
      testSuite.setupSuite.procNm : testResult.error : result );
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Tear down the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc tearDownTestSuite;
  dcl-pi *N char(1) extproc(*dclcase);
    testsuite       const likeds(testSuite_t);
    result          likeds(result_t);
  end-pi;

  dcl-ds testResult likeds(testResult_t);

  testResult = initTestResult(testsuite.tearDownSuite.procNm);
  testResult = runProc( testsuite.tearDownSuite.procPtr : testResult );

  if (testResult.outcome = TEST_CASE_SUCCESS);
    return TEST_CASE_SUCCESS;
  endif;

  list_add(testsuite.testResults : %addr(testResult) : %size(testResult));

  select;
  when testResult.outcome = TEST_CASE_FAILURE;
    handleFailure(
      testsuite.tearDownSuite.procNm : testResult.failure : result );
    return TEST_CASE_FAILURE;
  when testResult.outcome = TEST_CASE_ERROR;
    handleError(
      testsuite.tearDownSuite.procNm : testResult.error : result );
    return TEST_CASE_ERROR;
  endsl;

end-proc;


//----------------------------------------------------------------------
// Run the tests in a test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc runTests export;
  dcl-pi *N;
    result          likeds(result_t);
    testSuite       const likeds(testSuite_t);
    testProcsToRun  const likeds(procNms_t);
    order           char(8) const;
    detail          char(6) const;
    rclrsc          char(10) const;
  end-pi;

  dcl-s step int(10);
  dcl-s testIdx int(10);
  dcl-s testProcNm like(procNm_t);
  dcl-ds testResult likeds(testResult_t);
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
      testResult = runTest( testSuite : testIdx );

      list_add(testSuite.testResults : %addr(testResult) : %size(testResult));

      if (rclrsc = RCLRSC_ALWAYS);
        qcmdexc(CMD_RCLRSC: %len(CMD_RCLRSC));
      endif;

      assertionCntAfterRun = getAssertCalled();
      result.assertCnt += (assertionCntAfterRun - assertionCntBeforeRun);
      result.runsCnt += 1;

      select;
      when (testResult.outcome= TEST_CASE_SUCCESS);
        handleSuccess(
            testProcNm : assertionCntAfterRun - assertionCntBeforeRun );
      when (testResult.outcome = TEST_CASE_FAILURE);
        handleFailure( testProcNm : testResult.failure : result );
      when (testResult.outcome = TEST_CASE_ERROR);
        handleError( testProcNm : testResult.error : result );
      endsl;

    endif;

    testIdx += step;
  enddo;

  assertHasRunAtLeastOneTestCase(testProcsToRun.name(1) :result);

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

