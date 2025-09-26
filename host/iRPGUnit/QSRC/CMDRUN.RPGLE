**FREE
// ==========================================================================
//  iRPGUnit - Command line runner.
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

ctl-opt main(cmdRun);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CMDRUN


//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,CALLPRC
/include qinclude,CMDRUNLOG
/include qinclude,CMDRUNSRV
/include qinclude,CMDRUNV
/include qinclude,EXTTST
/include qinclude,TEMPLATES
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,STRING
/include qinclude,LIBL
/include qinclude,SRCMBR
/include qinclude,XMLWRITER
/include qllist,llist_h

/include qsysinc,QCMDEXC

/include qinclude,SDS

//----------------------------------------------------------------------
//   Private Prototypes
//----------------------------------------------------------------------

dcl-pr isinTestProcToRun ind;
  testProcNm      const like(procNm_t);
  testProcsToRun  const likeds(procNms_t);
end-pr;

// Assert that at least one test case has run during execution.
dcl-pr assertHasRunAtLeastOneTestCase;
  testProcNm      const like(procNm_t);
  result          likeds(result_t);
end-pr;

// Format a word with its counter.
// (e.g., fmtWordWithCnt( 2 : 'apple' ) = '2 apples' )
dcl-pr fmtWordWithCnt  varchar(256);
  cnt             int(10) const;
  word            varchar(256) const;
end-pr;

// Handle a test case error.
dcl-pr handleError;
  testProcNm      const like(procNm_t);
  excpMsgInfo     const likeds(msg_t);
  result          likeds(result_t);
end-pr;

// Handle a test case failure.
dcl-pr handleFailure;
  testProcNm      const like(procNm_t);
  failure         const likeds(assertFailEvtLong_t);
  result          likeds(result_t);
end-pr;

// Handle a test case success.
dcl-pr handleSuccess;
  testProcNm      const like(procNm_t);
  assertionCnt    int(10) const;
end-pr;

// Set the starting index and the index step to run the test cases.
dcl-pr setTestRunOrder;
  testSuite       const likeds(testSuite_t);
  order           char(8) const;
  // (Output) Starting index.
  startIdx        int(10);
  // (Output) Step from one test index to the next.
  step            int(10);
end-pr;

// Give a status message to the user.
dcl-pr status;
  testSuiteNm     const like(object_t.nm);
  testProcNm      const like(procNm_t);
end-pr;

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Test case suite.
dcl-ds testSuite likeds(testSuite_t);

// Completion message.
dcl-s msg varchar(256);

// Error message when writing the XML file.
dcl-s errMsg varchar(256);

// Save/set/restore library list
dcl-ds savedLibl likeds(liblData_t);
dcl-s mustRestoreLibl ind inz(*off);

// Over all test result.
dcl-ds result likeds(result_t) inz;

//---------------------------------------------------------------------
//   Main Procedure
//---------------------------------------------------------------------

dcl-proc cmdrun;
  dcl-pi *n;
    testSuiteName   const likeds(object_t);
    testProcs       const likeds(procNms_t);
    order           const like(order_t);
    detail          const like(detail_t);
    output          const like(output_t);
    libl            const likeds(libl_t);
    jobD            const likeds(object_t);
    rclRsc          const like(rclrsc_t);
    xmlStmf         const like(stmf_t);
  end-pi;

  registerStartPgm(sds.pgmLib: sds.pgmname);

  clear result;
  setLogContext( testSuiteName : detail : output );
  clearAssertCounter();

  // Set library list and load test suite
  monitor;
    savedLibl = getLibl();
    mustRestoreLibl = setTestSuiteLibl(libl: jobD: testSuiteName.lib);
    updateLogContext(getLibl());
    testSuite = loadTestSuite( testSuiteName );
  on-error;
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'Error while loading test suite '
                + fmtObjNm(testSuiteName) + '.' );
  endmon;

  if testSuite.testCasesCnt = 0;
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'No test case found in service program '
                + fmtObjNm(testSuiteName) + '.' );
  endif;

  setupTestSuite( testSuite : result );

  if (result.errorCnt = 0 and result.failureCnt = 0);
    runTests(result: testSuite : testProcs
             : order : detail: rclRsc);
  endif;

  tearDownTestSuite( testSuite : result );

  result.assertCnt = getAssertCalled();

  // Return result to xml file
  if (xmlStmf <> '');
    monitor;
      writexmlfile(resolvePathVariables(xmlStmf: testSuiteName)
                   : testSuite : testSuiteName : result);
    on-error;
      errMsg = rcvMsgTxt('*ESCAPE');
    endmon;
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
    logCompMsg(msg : result.failureCnt : result.errorCnt );
  on-error;
  // nothing
  endmon;

  if (result.failureCnt = 0 and result.errorCnt = 0);
    sndCompMsg( msg );
  else;
    if (errMsg <> '');
      sndCompMsg( msg );
      sndEscapeMsgAboveCtlBdy( errMsg );
    else;
      sndEscapeMsgAboveCtlBdy( msg );
    endif;
  endif;

  *inlr = *on;

  return;

end-proc;


//----------------------------------------------------------------------
//   Procedures
//----------------------------------------------------------------------

dcl-proc assertHasRunAtLeastOneTestCase;
  dcl-pi *N;
    testProcNm      const like(procNm_t);
    result          likeds(result_t);
  end-pi;

  dcl-ds excpMsgInfo likeds(msg_t);


  if result.runsCnt = 0;
    clear excpMsgInfo;
    excpMsgInfo.id  = '';
    excpMsgInfo.txt = 'Test procedure not found.';
    handleError( testProcNm : excpMsgInfo : result);
  endif;

end-proc;


dcl-proc callWithLogging export;
  dcl-pi *N int(10);
    proc            const likeds(proc_t);
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
// Format a test run completion message. See prototype.
//----------------------------------------------------------------------
dcl-proc fmtCompMsg export;
  dcl-pi *N varchar(256);
    testCaseCnt     int(10) const;
    assertCnt       int(10) const;
    failureCnt      int(10) const;
    errorCnt        int(10) const;
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


dcl-proc fmtObjNm export;
  dcl-pi *N varchar(21);
    obj             const likeds(object_t);
  end-pi;

  return %trimr(obj.lib) + '/' + %trimr(obj.nm);

end-proc;


dcl-proc fmtWordWithCnt;
  dcl-pi *N varchar(256);
    cnt             int(10) const;
    word            varchar(256) const;
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
    testProcNm      const like(procNm_t);
    excpMsgInfo     const likeds(msg_t);
    result          likeds(result_t);
  end-pi;

  result.errorCnt += 1;
  logError( testProcNm : excpMsgInfo );

end-proc;


//----------------------------------------------------------------------
// Handle a test failure event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleFailure;
  dcl-pi *N;
    testProcNm      const like(procNm_t);
    failure         const likeds(assertFailEvtLong_t);
    result          likeds(result_t);
  end-pi;

  result.failureCnt += 1;
  logfailure( testProcNm : failure );

end-proc;


//----------------------------------------------------------------------
// Handle a test success event. See prototype.
//----------------------------------------------------------------------
dcl-proc handleSuccess;
  dcl-pi *N;
    testProcNm      const like(procNm_t);
    assertionCnt    int(10) const;
  end-pi;

  logSuccess( testProcNm : assertionCnt );

end-proc;


//----------------------------------------------------------------------
// Set up the test suite. See prototype.
//----------------------------------------------------------------------
dcl-proc setupTestSuite export;
  dcl-pi *N char(1);
    testSuite       const likeds(testSuite_t);
    result          likeds(result_t);
  end-pi;

  dcl-ds testResult likeds(testResult_t);

  // return callWithLogging( testSuite.setUpSuite );
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
dcl-proc tearDownTestSuite export;
  dcl-pi *N char(1);
    testsuite       const likeds(testSuite_t);
    result          likeds(result_t);
  end-pi;

  dcl-ds testResult likeds(testResult_t);

  //return callWithLogging( testSuite.tearDownSuite );
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

    if isinTestProcToRun(testProcNm: testProcsToRun);

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
dcl-proc isinTestProcToRun;
  dcl-pi *N ind;
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


dcl-proc setTestRunOrder;
  dcl-pi *N;
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


dcl-proc status;
  dcl-pi *N;
    testSuiteNm     const like(object_t.nm);
    testProcNm      const like(procNm_t);
  end-pi;

  sndStsMsg( 'Running ' + %trimr(testSuiteNm) + ' - ' + testProcNm );

end-proc;


//----------------------------------------------------------------------
// Check and restore library list.
//----------------------------------------------------------------------
dcl-proc checkAndRestoreLibl export;
  dcl-pi *N;
    mustRestoreLibl ind const;
    savedLibl       const  likeds(liblData_t);
  end-pi;

  if (mustRestoreLibl);
    restoreLibl(savedLibl);
  endif;

end-proc;

