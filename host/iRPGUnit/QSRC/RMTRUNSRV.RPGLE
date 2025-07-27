**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Adapter.
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

// User space version number 1. Introduced 22.04.2013.
// Changed because of enhancements for RPGUnit plug-in.
dcl-c version_1 1;
// User space version number 2. Introduced 10.10.2016.
// Changed exception message to varsize up to 1024 bytes.
dcl-c version_2 2;
// User space version number 3. Introduced 23.04.2017.
// Added 'tmpl_testSuite.numTestCasesRtn'.
dcl-c version_3 3;
// User space version number 4. Introduced 09.04.2024.
// Added message 'receiver' and program library name.
dcl-c version_4 4;

//-------------------------------------------------------------------------
// Prototypes
//-------------------------------------------------------------------------

/include qinclude,RMTRUNSRV
/include qinclude,ERRORCODE

dcl-pr fillUserSpace extproc('fillUserspace');
  userSpace       likeds(object_t ) const;
  testsuite       likeds(testSuite_t) const;
  testSuiteName   likeds(object_t) const;
  result          likeds(result_t) const;
end-pr;

dcl-pr createV3TestCase int(10) extproc('createV3TestCase');
  usptr           pointer value;
  testresult      value likeds(testResult_t);
  eptr            pointer value;
end-pr;

dcl-pr createV4TestCase int(10) extproc('createV4TestCase');
  usPtr           pointer value;
  testresult      value likeds(testResult_t);
  ePtr            pointer value;
end-pr;

dcl-pr min int(10) extproc('min');
  int1            int(10) value;
  int2            int(10) value;
end-pr;

/include qinclude,SYSTEMAPI
/include qinclude,ASSERT
/include qinclude,CALLPRC
/include qinclude,CMDRUNLOG
/include qinclude,CMDRUNV
/include qinclude,PGMMSG
/include qinclude,CMDRUNSRV
/include qinclude,CMDRUN
/include qinclude,LIBL
/include qinclude,SRCMBR
/include qinclude,XMLWRITER
/include qsysinc,MEMCPY
/include qllist,llist_h

//-------------------------------------------------------------------------
// Type Templates
//-------------------------------------------------------------------------
dcl-ds tmpl_testSuite len(256) qualified template;
  length          int(10);
  version         int(10);
  testSuite       likeds(object_t);
  numRuns         int(10);
  numAsserts      int(10);
  numFailures     int(10);
  numErrors       int(10);
  offsTestCases   int(10);
  numTestCases    int(10);
  system          char(10);
  splf_name       char(10);
  splf_nbr        int(10);
  job_name        char(10);
  job_user        char(10);
  job_nbr         char(6);
  qSrcMbr         likeds(srcMbr_t);
  numTestCasesRtn int(10);
  // added 15.5.2025
  typeOfSrc       char(10);
  offsSrcStmf     int(10);
  lenSrcStmf      int(10);
  reserved1       char(102);
end-ds;

dcl-ds tmpl_testCase_v3 qualified template;
  length           int(10);
  result           char(1);
  reserved_1       char(1);
  specNb           char(10);
  numberAssertions int(10);
  numCallStkEnt    int(10);
  offsCallStkEnt   int(10);
  offsNext         int(10);
  lenTestCase      int(5);
  lenExcpMessage   int(5);
  testCase         char(100);
  excpMessage      char(1024);
end-ds;

dcl-s tmpl_execTime_v3 int(20) template;

dcl-ds tmpl_callStkEnt_v3 len(354) qualified template;
  qPgm            likeds(object_t);
  qMod            likeds(object_t);
  specNb          char(10);
  length          int(10);
  offsNext        int(10);
  reserved_1      char(8);
  lenProcNm       int(5);
  procNm          char(256);
  qSrcMbr         likeds(srcMbr_t);
end-ds;

dcl-ds tmpl_sender_v3 len(308) qualified template;
  qPgm            likeds(object_t);
  qMod            likeds(object_t);
  specNb          char(10);
  lenProcNm       int(5);
  procNm          char(256);
end-ds;

dcl-ds tmpl_receiver_v3 likeds(tmpl_sender_v3) template;

dcl-ds tmpl_testCase_v4 len(50) qualified template;
  offsNextEntry    int(10);
  lenEntry         int(5);
  result           char(1);
  reserved_1       char(1);
  numAsserts       int(10);
  execTime         int(20);
  offsTestCaseText int(10);
  lenTestCaseText  int(5);
  offsExcpMsg      int(10);
  lenExcpMsg       int(5);
  offsSndInf       int(10);
  lenSndInf        int(5);
  offsRcvInf       int(10);
  lenRcvInf        int(5);
  offsCallStkE     int(10);
  numCallStkE      int(5);
end-ds;

dcl-ds tmpl_callStkEnt_v4 len(122) qualified template;
  offsNextEntry    int(10);
  lenEntry         int(5);
  qPgm             likeds(object_t);
  qMod             likeds(object_t);
  specNb           char(10);
  offsProcNm       int(10);
  lenProcNm        int(5);
  qSrcMbr          likeds(srcMbr_t);
  // added 15.5.2025
  typeOfSrc       char(10);
  offsSrcStmf     int(10);
  lenSrcStmf      int(10);
end-ds;

dcl-ds tmpl_sender_v4 len(58) qualified template;
  lenEntry         int(5);
  qPgm             likeds(object_t);
  qMod             likeds(object_t);
  specNb           char(10);
  offsProcNm       int(10);
  lenProcNm        int(5);
  // TODO: add qualified source member
end-ds;

dcl-ds tmpl_receiver_v4 likeds(tmpl_sender_v4) template;

/include qinclude,TEMPLATES

//-------------------------------------------------------------------------
// Module Status
//-------------------------------------------------------------------------
dcl-ds g_status qualified;
  version   int(10) inz(version_4);
end-ds;

//-------------------------------------------------------------------------
// Procedures
//-------------------------------------------------------------------------

// ==========================================================================
//  Execute a given unit test suite.
// ==========================================================================
dcl-proc rpgunit_runTestSuite export;
  dcl-pi *N              int(10);
    userSpace       likeds(object_t) const;
    testSuiteName   likeds(object_t) const;
    testProcs       likeds(procNms_t) const;
    order           like(order_t) const;
    detail          like(detail_t) const;
    output          like(output_t) const;
    libl            likeds(libl_t) const;
    qJobD           likeds(object_t) const;
    rclRsc          like(rclrsc_t) const;
    xmlStmf         like(stmf_t) const;
  end-pi;

  dcl-s returnValue int(10);

  dcl-ds testSuite likeds(testSuite_t);

  // Completion message.
  dcl-s msg char(256);

  // Error message when writing the XML file.
  dcl-s errMsg char(256);

  // Test event counters.
  dcl-ds result likeds(result_t);

  // Save/set/restore library list
  dcl-ds savedLibl likeds(liblData_t);
  dcl-s mustRestoreLibl ind inz(*off);

  // Return values
  dcl-c SUCCESS 0;
  dcl-c FAILURE -1;

  clear result;
  setLogContext( testSuiteName : detail : output );
  clearAssertCounter();

  // Set library list and load test suite
  monitor;
    savedLibl = getLibl();
    mustRestoreLibl = setTestSuiteLibl(libl: qJobD: testSuiteName.lib);
    updateLogContext(getLibl());
    testSuite = loadTestSuite( testSuiteName );
  on-error;
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'Error while loading test suite '
                + fmtObjNm(testSuiteName) + '.' );
  endmon;

  if (testSuite.testcasescnt = 0);
    checkAndRestoreLibl(mustRestoreLibl: savedLibl);
    raiseRUError( 'No test case found in service program '
                + fmtObjNm(testSuiteName) + '.' );
  endif;

  setupTestSuite( testSuite : result );

  if (result.errorCnt = 0 and result.failureCnt = 0);
    runTests(result: testSuite: testProcs
             : order :detail: rclRsc);
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

  // Return result to plug-in
  fillUserSpace(userSpace : testSuite : testSuiteName : result);

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

  if result.failureCnt = 0 and result.errorCnt = 0;
    returnValue = SUCCESS;
    sndCompMsg( msg );
  else;
    returnValue = FAILURE;
    sndCompMsg( msg );
  endif;

  return returnValue;

end-proc;

// ==========================================================================
//  Fill user space, all versions.
// ==========================================================================
dcl-proc fillUserSpace;
  dcl-pi *N;
    userSpace       likeds(object_t ) const;
    testsuite       likeds(testSuite_t) const;
    testSuiteName   likeds(object_t) const;
    result          likeds(result_t) const;
  end-pi;

  dcl-s usPtr pointer;
  dcl-ds splf likeds(splf_t);
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds header likeds(tmpl_testSuite) based(usPtr);
  dcl-s header_SrcStmf char(1024) based(pHeader_SrcStmf); // varying-length portion of 'header'
  dcl-ds testResult likeds(testResult_t) based(ptr);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);
  dcl-s oldlength int(10);
  dcl-s ePtr pointer;
  dcl-ds testCaseV3 likeds(tmpl_testCase_v3) based(ePtr);
  dcl-ds testCaseV4 likeds(tmpl_testCase_v4) based(ePtr);

  clear errorCode;
  errorCode.bytPrv = 0;
  qusptrus(userSpace : usPtr : errorCode);

  splf = getLogSplF();

  SrcMbr_initialize();
  srcInf = SrcMbr_getTestSuiteSrc(testSuiteName);
  header.typeOfSrc = srcInf.type;
  if (header.typeOfSrc = TYPE_STMF);
     clear header.qSrcMbr;
     header.offsSrcStmf = %size(header);    // fix-length portion of the header
     header.lenSrcStmf = %len(srcInf.stmf); // varying-length portion of header
     pHeader_SrcStmf = %addr(header) + %size(header);
     header_SrcStmf = %subst(srcInf.stmf: 1: %len(srcInf.stmf));
  else;
     header.qSrcMbr = srcInf.mbr;
     header.offsSrcStmf = 0;
     header.lenSrcStmf = 0;
  endif;

  header.length = %size(header) + header.lenSrcStmf;
  header.version = g_status.version;
  header.testSuite = testSuiteName;
  header.numRuns = result.runsCnt;
  header.numAsserts = result.assertCnt;
  header.numFailures = result.failureCnt;
  header.numErrors = result.errorCnt;
  header.offsTestCases = header.length;
  header.numTestCases = testsuite.testcasescnt;

  header.system = splf.system;
  header.splf_name = splf.nm;
  header.splf_nbr = splf.nbr;
  header.job_name = splf.job.name;
  header.job_user = splf.job.user;
  header.job_nbr = splf.job.nbr;

  // TODO: add source stream file path to 'header'
  header.typeOfSrc = srcInf.type;
  if (header.typeOfSrc = TYPE_STMF);
     clear header.qSrcMbr;
     header.offsSrcStmf = %size(header);    // fix-length portion of the header
     header.lenSrcStmf = %len(srcInf.stmf); // varying-length portion of header
     pHeader_SrcStmf = %addr(header) + %size(header);
     header_SrcStmf = %subst(srcInf.stmf: 1: %len(srcInf.stmf));
     header.length += header.lenSrcStmf;
     header.offsTestCases += header.lenSrcStmf;
  else;
     header.qSrcMbr = srcInf.mbr;
     header.offsSrcStmf = 0;
     header.lenSrcStmf = 0;
  endif;

  header.numTestCasesRtn = 0;
  header.reserved1 = *blank;

  list_abortiteration(testsuite.testResults);
  ptr = list_getnext(testsuite.testResults);

  ePtr = usPtr + header.offsTestCases;

  dow (ptr <> *null);

    header.numTestCasesRtn += 1;

    oldlength = header.length;

    select;
    when g_status.version >= version_4;
      header.length += createV4TestCase(usPtr: testResult: ePtr);
    other;
      header.length += createV3TestCase(usPtr: testResult: ePtr);
    endsl;

    ptr = list_getnext(testsuite.testResults);
    if (ptr <> *null);
      ePtr = ePtr - oldlength + header.length;
    endif;

  enddo;

  select;
  when g_status.version >= version_4;
    testCaseV4.offsNextEntry = 0;
  other;
    testCaseV3.offsNext = 0;
  endsl;

end-proc;

// ==========================================================================
//  Create user space with version 2 layout.
// ==========================================================================
dcl-proc createV3TestCase;
  dcl-pi *N int(10);
    usptr           pointer value;
    testresult      value likeds(testResult_t);
    eptr            pointer value;
  end-pi;

  dcl-ds entry likeds(tmpl_testCase_v3) based(eptr);
  dcl-s exectime like(tmpl_execTime_v3) based(pexct);

  dcl-s e int(10);
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v3) based(sPtr);
  dcl-ds failure likeds(assertFailEvtLong_t) based(fPtr);

  clear entry;
  entry.lenTestCase = %len(testresult.testname);
  entry.testCase = testresult.testname;
  entry.result = testresult.outcome;
  entry.numberAssertions = testresult.assertCnt;

  select;
  when (testresult.outcome = TEST_CASE_ERROR);
    entry.lenExcpMessage = min(%len(testresult.error.txt): %len(entry.excpMessage));
    entry.excpMessage = testresult.error.txt;
    if (testresult.error.qsndstmt.specnb <> '');
      entry.specNb = testresult.error.qsndstmt.specnb;
    else;
      entry.specNb = '*N';
    endif;
    pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
    exectime = -1;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(exectime);
    entry.offsNext = (%addr(entry) - usptr) + entry.length;
    entry.offsCallStkEnt = entry.offsNext;
    entry.numCallStkEnt = 0;

    // Add callstack entry of exception message
    sPtr = usptr + entry.offsNext;

    stackEntry.qPgm = testresult.error.qsndstmt.qpgm;
    stackEntry.qMod = testresult.error.qsndstmt.qmod;
    stackEntry.specNb = testresult.error.qsndstmt.specnb;
    stackEntry.procNm = testresult.error.qsndstmt.procnm;
    stackEntry.lenProcNm = %len(testresult.error.qsndstmt.procnm);

    stackEntry.length = %size(stackEntry);
    stackEntry.offsNext = (sPtr - usptr) + stackEntry.length;

    entry.length += stackEntry.length;
    entry.offsNext += stackEntry.length;
    entry.numCallStkEnt += 1;

  when (testresult.outcome = TEST_CASE_FAILURE);
    fPtr = %addr(testresult.failure);
    entry.lenExcpMessage = min(%len(testresult.failure.msg): %len(entry.excpMessage));
    entry.excpMessage = testresult.failure.msg;
    entry.specNb =
          failure.callstk.entry(1).qstmt.specnb;

    pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
    exectime = -1;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(exectime);
    entry.offsNext = (%addr(entry) - usptr) + entry.length;
    entry.offsCallStkEnt = entry.offsNext;

    for e = 1 to failure.callstk.nume;

      entry.numCallStkEnt += 1;

      sPtr = usptr + entry.offsNext;

      stackEntry.qPgm = failure.callstk.entry(e).qstmt.qpgm;
      stackEntry.qMod = failure.callstk.entry(e).qstmt.qmod;
      stackEntry.lenProcNm = %len(failure.callstk.entry(e).qstmt.procnm);
      stackEntry.procNm = failure.callstk.entry(e).qstmt.procnm;
      stackEntry.specNb = failure.callstk.entry(e).qstmt.specnb;

      // TODO: add source stream file path to 'stackEntry'
      srcInf = SrcMbr_getModSrc(stackEntry.qPgm: stackEntry.qMod);
      stackEntry.qSrcMbr = srcInf.mbr;

      stackEntry.length = %size(stackEntry);
      stackEntry.offsNext = (sPtr - usptr) + stackEntry.length;

      entry.length += stackEntry.length;
      entry.offsNext += stackEntry.length;

      if (e = failure.callstk.nume);
        stackEntry.offsNext = 0;
      endif;
    endfor;

  other; // including:  TEST_CASE_SUCCESS
    entry.lenExcpMessage = 0;
    entry.excpMessage = '';
    entry.specNb = '';
    pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
    exectime = testresult.exectime;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(exectime);
    entry.offsNext = (%addr(entry) - usptr) + entry.length;
    entry.offsCallStkEnt = 0;
    entry.numCallStkEnt = 0;

  endsl;

  return entry.length;

end-proc;

// ==========================================================================
//  Create user space with version 4 layout.
// ==========================================================================
dcl-proc createV4TestCase;
  dcl-pi *N int(10);
    usPtr        pointer value;
    testresult   value likeds(testResult_t);
    ePtr         pointer value;
  end-pi;

  dcl-s offsEntry int(10);
  dcl-ds entry likeds(tmpl_testCase_v4) based(ePtr);

  dcl-s e int(10);
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v4) based(sPtr);
  dcl-s stackEntry_SrcStmf char(1024) based(pStackEntry_SrcStmf)
  ;                                                       // varying-length portion of 'header'
  dcl-ds sender likeds(tmpl_sender_v4) based(pSender);
  dcl-ds receiver likeds(tmpl_receiver_v4) based(pReceiver);

  offsEntry = ePtr - usPtr;

  clear entry;
  entry.offsNextEntry = offsEntry + %size(entry);
  entry.lenEntry = %size(entry);

  entry.result = testresult.outcome;
  entry.reserved_1 = '';
  entry.numAsserts = testresult.assertCnt;
  entry.execTime = testresult.exectime;

  // Test case text:
  entry.offsTestCaseText = offsEntry + %size(entry);
  entry.lenTestCaseText = %len(testresult.testname);
  memcpy(usPtr + entry.offsTestCaseText
         : %addr(testResult.testName: *data)
         : entry.lenTestCaseText);

  entry.offsNextEntry += entry.lenTestCaseText;
  entry.lenEntry += entry.lenTestCaseText;

  // Exception message:
  entry.offsExcpMsg = entry.offsTestCaseText + entry.lenTestCaseText;


  select;
  when (testresult.outcome = TEST_CASE_ERROR);

    // Exception message:
    entry.lenExcpMsg = %len(testresult.error.txt);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(testResult.error.txt: *data)
           : entry.lenExcpMsg);

    entry.offsNextEntry += entry.lenExcpMsg;
    entry.lenEntry += entry.lenExcpMsg;

    // Execution time:
    entry.execTime = -1;

    // Sender information:
    entry.offsSndInf = offsEntry + entry.lenEntry;
    entry.lenSndInf = %size(sender);

    pSender = usPtr + entry.offsSndInf;
    clear sender;
    sender.lenEntry = %size(sender);
    sender.qPgm = testresult.error.qsndstmt.qpgm;
    sender.qMod = testresult.error.qsndstmt.qmod;
    sender.specNb = testresult.error.qsndstmt.specnb;
    sender.offsProcNm = entry.offsSndInf + %size(sender);
    sender.lenProcNm = %len(testresult.error.qsndstmt.procnm);
    memcpy(usPtr + sender.offsProcNm
           : %addr(testResult.error.qSndStmt.procNm: *data)
           : entry.lenExcpMsg);
    sender.lenEntry += sender.lenProcNm;

    entry.lenSndInf += sender.lenProcNm;

    entry.offsNextEntry += sender.lenEntry;
    entry.lenEntry += sender.lenEntry;

    // Receiver information:
    entry.offsRcvInf = offsEntry + entry.lenEntry;
    entry.lenRcvInf = %size(receiver);

    pReceiver = usPtr + entry.offsRcvInf;
    clear receiver;
    receiver.lenEntry = %size(receiver);
    receiver.qPgm = testresult.error.qrcvstmt.qpgm;
    receiver.qMod = testresult.error.qrcvstmt.qmod;
    receiver.specNb = testresult.error.qrcvstmt.specnb;
    receiver.offsProcNm = entry.offsRcvInf + %size(receiver);
    receiver.lenProcNm = %len(testresult.error.qrcvstmt.procnm);
    memcpy(usPtr + receiver.offsProcNm
           : %addr(testResult.error.qRcvStmt.procNm: *data)
           : entry.lenExcpMsg);

    receiver.lenEntry += receiver.lenProcNm;
    entry.lenRcvInf += receiver.lenProcNm;

    entry.offsNextEntry += receiver.lenEntry;
    entry.lenEntry += receiver.lenEntry;

    // Call stack entries:
    entry.offsCallStkE = 0;
    entry.numCallStkE = 0;

  when (testresult.outcome = TEST_CASE_FAILURE);

    // Failure message:
    entry.lenExcpMsg = %len(testresult.failure.msg);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(testResult.failure.msg: *data)
           : entry.lenExcpMsg);

    entry.offsNextEntry += entry.lenExcpMsg;
    entry.lenEntry += entry.lenExcpMsg;

    // Execution time:
    entry.execTime = -1;

    // Sender information:
    entry.offsSndInf = 0;
    entry.lenSndInf = 0;

    // Receiver information:
    entry.offsRcvInf = 0;
    entry.lenRcvInf = 0;

    // Call stack entries:
    entry.offsCallStkE = offsEntry + entry.lenEntry;
    sPtr = usPtr + entry.offsCallStkE;

    for e = 1 to testresult.failure.callstk.nume;

      entry.numCallStkE += 1;

      clear stackEntry;

      stackEntry.offsNextEntry = (sPtr - usPtr) + %size(stackEntry);
      stackEntry.lenEntry = %size(stackEntry);

      stackEntry.qPgm = testresult.failure.callstk.entry(e).qstmt.qpgm;
      stackEntry.qMod = testresult.failure.callstk.entry(e).qstmt.qmod;
      stackEntry.specNb = testresult.failure.callstk.entry(e).qstmt.specnb;

      // TODO: add source stream file path to 'stackEntry'
      srcInf = SrcMbr_getModSrc(stackEntry.qPgm: stackEntry.qMod);

      stackEntry.typeOfSrc = srcInf.type;
      if (stackEntry.typeOfSrc = TYPE_STMF);
         clear stackEntry.qSrcMbr;
         stackEntry.offsSrcStmf = (sPtr - usPtr) + stackEntry.lenEntry;
         stackEntry.lenSrcStmf = %len(srcInf.stmf);
         pStackEntry_SrcStmf = %addr(stackEntry) + %size(stackEntry);
         stackEntry_SrcStmf = %subst(srcInf.stmf: 1: %len(srcInf.stmf));

         stackEntry.offsNextEntry += stackEntry.lenSrcStmf;
         stackEntry.lenEntry += stackEntry.lenSrcStmf;
      else;
         stackEntry.qSrcMbr = srcInf.mbr;
         stackEntry.offsSrcStmf = 0;
         stackEntry.lenSrcStmf = 0;
      endif;

      stackEntry.offsProcNm = (sPtr - usPtr) + stackEntry.lenEntry;
      stackEntry.lenProcNm = %len(testresult.failure.callstk.entry(e).qstmt.procnm);
      memcpy(
        usPtr + stackEntry.offsProcNm
        : %addr(testResult.failure.callStk.entry(e).qStmt.procNm:*data)
        : stackEntry.lenProcNm);

      stackEntry.offsNextEntry += stackEntry.lenProcNm;
      stackEntry.lenEntry += stackEntry.lenProcNm;

      entry.lenEntry += stackEntry.lenEntry;
      entry.offsNextEntry += stackEntry.lenEntry;

      if (e = testresult.failure.callstk.nume);
        stackEntry.offsNextEntry = 0;
      else;
        sPtr = usPtr + stackEntry.offsNextEntry;
      endif;
    endfor;

  other; // including:  TEST_CASE_SUCCESS

    entry.offsExcpMsg = 0;
    entry.lenExcpMsg = 0;

    entry.lenSndInf = 0;
    entry.offsSndInf = 0;

    entry.lenRcvInf = 0;
    entry.offsRcvInf = 0;

    entry.offsCallStkE = 0;
    entry.numCallStkE = 0;

  endsl;

  return entry.lenEntry;

end-proc;

// ==========================================================================
//  Returns the minimum of two integer values.
// ==========================================================================
dcl-proc min;
  dcl-pi *N int(10);
    int1   int(10) value;
    int2   int(10) value;
  end-pi;

  if (int1 < int2);
    return int1;
  else;
    return int2;
  endif;

end-proc;

