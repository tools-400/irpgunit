**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Adapter.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
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
// User space version number 4. Introduced 03.10.2025.
// Added message 'expected' and 'actual' values.
dcl-c version_5 5;

//-------------------------------------------------------------------------
// Prototypes
//-------------------------------------------------------------------------

/include qinclude,CMDRUNSRV
/include qinclude,CALLSTACK
/include qinclude,CMDRUNSRV
/include qinclude,RMTRUNSRV
/include qinclude,ERRORCODE

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
  reserved_1       char(102);
end-ds;

dcl-ds tmpl_testCase_v3 len(1160) qualified template;
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
  // TODO: add qualified source member (information not (yet?) available in callstack)
end-ds;

dcl-ds tmpl_receiver_v4 likeds(tmpl_sender_v4) template;

dcl-ds tmpl_testCase_v5 len(58) qualified template;
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
  offsExpected     int(10); // offset from the start of user space
  offsActual       int(10); // offset from the start of user space
  // logExpected      likeds(tmpl_logValue_v5); // added, is available
  // expectedValue    char(*)
  // logActual        likeds(tmpl_logValue_v5); // added, is available
  // actualValue      char(*)
end-ds;

dcl-ds tmpl_logValue_v5 len(23) qualified template;
  lenEntry         int(5);
  length           int(5);
  originalLength   int(5);
  offsDataType     int(10);
  lenDataType      int(5);
  offsAssertProc   int(10);
  lenAssertProc    int(5);
  isTruncated      char(1);
  offsValue        int(10);
end-ds;

dcl-ds tmpl_callStkEnt_v5 len(122) qualified template;
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

dcl-ds tmpl_sender_v5 len(58) qualified template;
  lenEntry         int(5);
  qPgm             likeds(object_t);
  qMod             likeds(object_t);
  specNb           char(10);
  offsProcNm       int(10);
  lenProcNm        int(5);
  // TODO: add qualified source member (information not (yet?) available in callstack)
end-ds;

dcl-ds tmpl_receiver_v5 likeds(tmpl_sender_v5) template;

/include qinclude,TEMPLATES

//-------------------------------------------------------------------------
// Module Status
//-------------------------------------------------------------------------
dcl-ds g_status qualified;
  version   int(10) inz(version_5);
end-ds;

//-------------------------------------------------------------------------
// Procedures
//-------------------------------------------------------------------------

// ==========================================================================
//  Fill user space, all versions.
// ==========================================================================
dcl-proc fillUserSpace export;
  dcl-pi *N;
    userSpace       likeds(object_t ) const;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(object_t) const;
    testSuiteResult likeds(testSuiteResult_t) const;
  end-pi;

  dcl-s usPtr pointer;
  dcl-ds splf likeds(splf_t);
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds header likeds(tmpl_testSuite) based(usPtr);
  dcl-s header_SrcStmf char(1024) based(pHeader_SrcStmf); // varying-length portion of 'header'
  dcl-ds testCaseResult likeds(testCaseResult_t) based(ptr);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);
  dcl-s oldlength int(10);
  dcl-ds testCaseV3 likeds(tmpl_testCase_v3) based(pTestCase);
  dcl-ds testCaseV4 likeds(tmpl_testCase_v4) based(pTestCase);
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);
  dcl-s maxNumEvents int(10);
  dcl-s countEvents int(10);

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
  header.numRuns = testSuiteResult.runsCnt;
  header.numAsserts = testSuiteResult.assertCnt;
  header.numFailures = testSuiteResult.failureCnt;
  header.numErrors = testSuiteResult.errorCnt;
  header.offsTestCases = header.length;
  header.numTestCases = testSuite.testCasesCnt;

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
  header.reserved_1 = *blank;

  list_resetIteration(testSuite.testResults);
  ptr = list_getnext(testSuite.testResults);

  pTestCase = usPtr + header.offsTestCases;

  dow (ptr <> *null);

    header.numTestCasesRtn += 1;

    oldlength = header.length;

    maxNumEvents = 1; // TODO: legacy beaviour like JUnit
    countEvents = 0;

    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    dow (pAbstractTestEvent <> *null);

      countEvents += 1;

      select;
      when g_status.version >= version_5;
        header.length += createV5TestCase(usPtr: testCaseResult: pTestCase: abstractTestEvent);
      when g_status.version >= version_4;
        header.length += createV4TestCase(usPtr: testCaseResult: pTestCase: abstractTestEvent);
      other;
        header.length += createV3TestCase(usPtr: testCaseResult: pTestCase: abstractTestEvent);
      endsl;

      pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    enddo;

    ptr = list_getnext(testSuite.testResults);
    if (ptr <> *null);
      pTestCase = pTestCase - oldlength + header.length;
    endif;

  enddo;

  select;
  when g_status.version >= version_5;
    testCaseV4.offsNextEntry = 0;
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
  dcl-pi *N int(10) extproc(*dclcase);
    usPtr             pointer value;
    testCaseResult    likeds(testCaseResult_t) value;
    ePtr              pointer value;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-ds entry likeds(tmpl_testCase_v3) based(ePtr);
  dcl-s execTime like(tmpl_execTime_v3) based(pExecTime);

  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v3) based(sPtr);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;

  clear entry;
  entry.lenTestCase = %len(testCaseResult.testname);
  entry.testCase = testCaseResult.testname;
  entry.result = testCaseResult.outcome;
  entry.numberAssertions = testCaseResult.assertCnt;

  select;
  when (testCaseResult.outcome = TEST_CASE_ERROR);

    runtimeErrorEvent = getLastErrorEvent(testCaseResult);

    entry.lenExcpMessage = min(%len(runtimeErrorEvent.msg.txt): %len(entry.excpMessage));
    entry.excpMessage = runtimeErrorEvent.msg.txt;
    if (runtimeErrorEvent.msg.qSndStmt.specnb <> '');
      entry.specNb = runtimeErrorEvent.msg.qSndStmt.specnb;
    else;
      entry.specNb = NO_VALUE;
    endif;
    pExecTime = %addr(entry.excpMessage) + entry.lenExcpMessage;
    execTime = -1;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(execTime);
    entry.offsNext = (%addr(entry) - usPtr) + entry.length;
    entry.offsCallStkEnt = entry.offsNext;
    entry.numCallStkEnt = 0;

    // Add callstack entry of exception message
    sPtr = usPtr + entry.offsNext;

    stackEntry.qPgm = runtimeErrorEvent.msg.qSndStmt.qpgm;
    stackEntry.qMod = runtimeErrorEvent.msg.qSndStmt.qmod;
    stackEntry.specNb = runtimeErrorEvent.msg.qSndStmt.specnb;
    stackEntry.procNm = runtimeErrorEvent.msg.qSndStmt.procnm;
    stackEntry.lenProcNm = %len(runtimeErrorEvent.msg.qSndStmt.procnm);

    stackEntry.length = %size(stackEntry);
    stackEntry.offsNext = (sPtr - usPtr) + stackEntry.length;

    entry.length += stackEntry.length;
    entry.offsNext += stackEntry.length;
    entry.numCallStkEnt += 1;

  when (testCaseResult.outcome = TEST_CASE_FAILURE);

    testFailureEvent = getLastFailureEvent(testCaseResult);

    entry.lenExcpMessage = min(%len(testFailureEvent.msg): %len(entry.excpMessage));
    entry.excpMessage = testFailureEvent.msg;

    callstkEnt = Callstack_get(testFailureEvent.pCallstk: 1);
    entry.specNb = callstkEnt.qstmt.specNb;

    pExecTime = %addr(entry.excpMessage) + entry.lenExcpMessage;
    execTime = -1;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(execTime);
    entry.offsNext = (%addr(entry) - usPtr) + entry.length;
    entry.offsCallStkEnt = entry.offsNext;

    Callstack_resetIteration(testFailureEvent.pCallstk);
    dow (Callstack_getNext(testFailureEvent.pCallstk: callstkEnt));

      entry.numCallStkEnt += 1;

      sPtr = usPtr + entry.offsNext;

      stackEntry.qPgm = callstkEnt.qstmt.qPgm;
      stackEntry.qMod = callstkEnt.qstmt.qMod;
      stackEntry.lenProcNm = %len(callstkEnt.qstmt.procNm);
      stackEntry.procNm = callstkEnt.qstmt.procNm;
      stackEntry.specNb = callstkEnt.qstmt.specNb;

      // TODO: add source stream file path to 'stackEntry'
      srcInf = SrcMbr_getModSrc(stackEntry.qPgm: stackEntry.qMod);
      stackEntry.qSrcMbr = srcInf.mbr;

      stackEntry.length = %size(stackEntry);
      stackEntry.offsNext = (sPtr - usPtr) + stackEntry.length;

      entry.length += stackEntry.length;
      entry.offsNext += stackEntry.length;

    enddo;

  other; // including:  TEST_CASE_SUCCESS
    entry.lenExcpMessage = 0;
    entry.excpMessage = '';
    entry.specNb = '';
    pExecTime = %addr(entry.excpMessage) + entry.lenExcpMessage;
    execTime = testCaseResult.exectime;
    entry.length = %size(entry) + entry.lenExcpMessage + %size(execTime);
    entry.offsNext = (%addr(entry) - usPtr) + entry.length;
    entry.offsCallStkEnt = 0;
    entry.numCallStkEnt = 0;

  endsl;

  return entry.length;

end-proc;

// ==========================================================================
//  Create user space with version 4 layout.
// ==========================================================================
dcl-proc createV4TestCase;
  dcl-pi *N int(10) extproc(*dclcase);
    usPtr             pointer value;
    testCaseResult    likeds(testCaseResult_t) value;
    ePtr              pointer value;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s offsEntry int(10);
  dcl-ds entry likeds(tmpl_testCase_v4) based(ePtr);

  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v4) based(sPtr);
  dcl-s stackEntry_SrcStmf char(1024) based(pStackEntry_SrcStmf); // var-len portion of 'header'
  dcl-ds sender likeds(tmpl_sender_v4) based(pSender);
  dcl-ds receiver likeds(tmpl_receiver_v4) based(pReceiver);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimErrorEvent likeds(runtimeErrorEvent_t) inz;

  offsEntry = ePtr - usPtr;

  clear entry;
  entry.offsNextEntry = offsEntry + %size(entry);
  entry.lenEntry = %size(entry);

  entry.result = testCaseResult.outcome;
  entry.reserved_1 = '';
  entry.numAsserts = testCaseResult.assertCnt;
  entry.execTime = testCaseResult.exectime;

  // Test case text:
  entry.offsTestCaseText = offsEntry + %size(entry);
  entry.lenTestCaseText = %len(testCaseResult.testname);
  memcpy(usPtr + entry.offsTestCaseText
         : %addr(testCaseResult.testName: *data)
         : entry.lenTestCaseText);

  entry.offsNextEntry += entry.lenTestCaseText;
  entry.lenEntry += entry.lenTestCaseText;

  // Exception message:
  entry.offsExcpMsg = entry.offsTestCaseText + entry.lenTestCaseText;


  select;
  when (testCaseResult.outcome = TEST_CASE_ERROR);

    runtimErrorEvent = getLastErrorEvent(testCaseResult);

    // Exception message:
    entry.lenExcpMsg = %len(runtimErrorEvent.msg.txt);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(runtimErrorEvent.msg.txt: *data)
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
    sender.qPgm = runtimErrorEvent.msg.qSndStmt.qPgm;
    sender.qMod = runtimErrorEvent.msg.qSndStmt.qMod;
    sender.specNb = runtimErrorEvent.msg.qSndStmt.specNb;
    sender.offsProcNm = entry.offsSndInf + %size(sender);
    sender.lenProcNm = %len(runtimErrorEvent.msg.qSndStmt.procNm);
    memcpy(usPtr + sender.offsProcNm
           : %addr(runtimErrorEvent.msg.qSndStmt.procNm: *data)
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
    receiver.qPgm = runtimErrorEvent.msg.qRcvStmt.qpgm;
    receiver.qMod = runtimErrorEvent.msg.qRcvStmt.qmod;
    receiver.specNb = runtimErrorEvent.msg.qRcvStmt.specnb;
    receiver.offsProcNm = entry.offsRcvInf + %size(receiver);
    receiver.lenProcNm = %len(runtimErrorEvent.msg.qRcvStmt.procnm);
    memcpy(usPtr + receiver.offsProcNm
           : %addr(runtimErrorEvent.msg.qRcvStmt.procNm: *data)
           : entry.lenExcpMsg);

    receiver.lenEntry += receiver.lenProcNm;
    entry.lenRcvInf += receiver.lenProcNm;

    entry.offsNextEntry += receiver.lenEntry;
    entry.lenEntry += receiver.lenEntry;

    // Call stack entries:
    entry.offsCallStkE = 0;
    entry.numCallStkE = 0;

  when (testCaseResult.outcome = TEST_CASE_FAILURE);

    testFailureEvent = getLastFailureEvent(testCaseResult);

    // Failure message:
    entry.lenExcpMsg = %len(testFailureEvent.msg);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(testFailureEvent.msg: *data)
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

    Callstack_resetIteration(testFailureEvent.pCallstk);
    dow (Callstack_getNext(testFailureEvent.pCallstk: callstkEnt));

      entry.numCallStkE += 1;

      clear stackEntry;

      stackEntry.offsNextEntry = (sPtr - usPtr) + %size(stackEntry);
      stackEntry.lenEntry = %size(stackEntry);

      stackEntry.qPgm = callstkEnt.qstmt.qpgm;
      stackEntry.qMod = callstkEnt.qstmt.qmod;
      stackEntry.specNb = callstkEnt.qstmt.specnb;

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
      stackEntry.lenProcNm = %len(callstkEnt.qstmt.procnm);
      memcpy(usPtr + stackEntry.offsProcNm
             : %addr(callstkEnt.qStmt.procNm:*data)
             : stackEntry.lenProcNm);

      stackEntry.offsNextEntry += stackEntry.lenProcNm;
      stackEntry.lenEntry += stackEntry.lenProcNm;

      entry.lenEntry += stackEntry.lenEntry;
      entry.offsNextEntry += stackEntry.lenEntry;

      sPtr = usPtr + stackEntry.offsNextEntry;

    enddo;

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
//  Create user space with version 5 layout.
// ==========================================================================
dcl-proc createV5TestCase;
  dcl-pi *N int(10) extproc(*dclcase);
    usPtr             pointer value;
    testCaseResult    likeds(testCaseResult_t) value;
    ePtr              pointer value;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s offsEntry int(10);
  dcl-ds entry likeds(tmpl_testCase_v5) based(ePtr);
  dcl-ds logValueExpected likeds(tmpl_logValue_v5) based(pLogValueExpected);
// @ignore-unused
  dcl-s valueExpected char(2048) based(pValueExpected);
  dcl-ds logValueActual likeds(tmpl_logValue_v5) based(pLogValueActual);
// @ignore-unused
  dcl-s valueActual char(2048) based(pValueActual);
// @ignore-unused
  dcl-s dataTypeExpected char(20) based(pDataTypeExpected);
// @ignore-unused
  dcl-s assertProcExpected char(32) based(pAssertProcExpected);
// @ignore-unused
  dcl-s dataTypeActual char(20) based(pDataTypeActual);
// @ignore-unused
  dcl-s assertProcActual char(32) based(pAssertProcActual);

  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v5) based(sPtr);
  dcl-s stackEntry_SrcStmf char(1024) based(pStackEntry_SrcStmf);
  dcl-ds sender likeds(tmpl_sender_v5) based(pSender);
  dcl-ds receiver likeds(tmpl_receiver_v5) based(pReceiver);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;

  offsEntry = ePtr - usPtr;

  clear entry;
  entry.offsNextEntry = offsEntry + %size(entry);
  entry.lenEntry = %size(entry);

  entry.result = testCaseResult.outcome;
  entry.reserved_1 = '';
  entry.numAsserts = testCaseResult.assertCnt;
  entry.execTime = testCaseResult.exectime;

  // Test case text:
  entry.offsTestCaseText = offsEntry + %size(entry);
  entry.lenTestCaseText = %len(testCaseResult.testname);
  memcpy(usPtr + entry.offsTestCaseText
         : %addr(testCaseResult.testName: *data)
         : entry.lenTestCaseText);

  entry.offsNextEntry += entry.lenTestCaseText;
  entry.lenEntry += entry.lenTestCaseText;

  // Exception message:
  entry.offsExcpMsg = entry.offsTestCaseText + entry.lenTestCaseText;


  select;
  when (testCaseResult.outcome = TEST_CASE_ERROR);

    runtimeErrorEvent = getLastErrorEvent(testCaseResult);

    // Exception message:
    entry.lenExcpMsg = %len(runtimeErrorEvent.msg.txt);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(runtimeErrorEvent.msg.txt: *data)
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
    sender.qPgm = runtimeErrorEvent.msg.qSndStmt.qPgm;
    sender.qMod = runtimeErrorEvent.msg.qSndStmt.qMod;
    sender.specNb = runtimeErrorEvent.msg.qSndStmt.specNb;
    sender.offsProcNm = entry.offsSndInf + %size(sender);
    sender.lenProcNm = %len(runtimeErrorEvent.msg.qSndStmt.procNm);
    memcpy(usPtr + sender.offsProcNm
           : %addr(runtimeErrorEvent.msg.qSndStmt.procNm: *data)
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
    receiver.qPgm = runtimeErrorEvent.msg.qRcvStmt.qpgm;
    receiver.qMod = runtimeErrorEvent.msg.qRcvStmt.qmod;
    receiver.specNb = runtimeErrorEvent.msg.qRcvStmt.specnb;
    receiver.offsProcNm = entry.offsRcvInf + %size(receiver);
    receiver.lenProcNm = %len(runtimeErrorEvent.msg.qRcvStmt.procnm);
    memcpy(usPtr + receiver.offsProcNm
           : %addr(runtimeErrorEvent.msg.qRcvStmt.procNm: *data)
           : entry.lenExcpMsg);

    receiver.lenEntry += receiver.lenProcNm;
    entry.lenRcvInf += receiver.lenProcNm;

    entry.offsNextEntry += receiver.lenEntry;
    entry.lenEntry += receiver.lenEntry;

    // Call stack entries:
    entry.offsCallStkE = 0;
    entry.numCallStkE = 0;

    // 'expected' and 'actual' values:
    entry.offsExpected = 0;
    entry.offsActual = 0;

  when (testCaseResult.outcome = TEST_CASE_FAILURE);

    testFailureEvent = getLastFailureEvent(testCaseResult);

    // Failure message:
    entry.lenExcpMsg = %len(testFailureEvent.msg);
    memcpy(usPtr + entry.offsExcpMsg
           : %addr(testFailureEvent.msg: *data)
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

    Callstack_resetIteration(testFailureEvent.pCallstk);
    dow (Callstack_getNext(testFailureEvent.pCallstk: callstkEnt));

      entry.numCallStkE += 1;

      clear stackEntry;

      stackEntry.offsNextEntry = (sPtr - usPtr) + %size(stackEntry);
      stackEntry.lenEntry = %size(stackEntry);

      stackEntry.qPgm = callstkEnt.qstmt.qpgm;
      stackEntry.qMod = callstkEnt.qstmt.qmod;
      stackEntry.specNb = callstkEnt.qstmt.specnb;

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
      stackEntry.lenProcNm = %len(callstkEnt.qstmt.procnm);
      memcpy(usPtr + stackEntry.offsProcNm
             : %addr(callstkEnt.qStmt.procNm:*data)
             : stackEntry.lenProcNm);

      stackEntry.offsNextEntry += stackEntry.lenProcNm;
      stackEntry.lenEntry += stackEntry.lenProcNm;

      entry.lenEntry += stackEntry.lenEntry;
      entry.offsNextEntry += stackEntry.lenEntry;

      sPtr = usPtr + stackEntry.offsNextEntry;

    enddo;

    // add 'expected' value
    pLogValueExpected = usPtr + offsEntry + entry.lenEntry;
    entry.offsExpected = offsEntry + entry.lenEntry;
    entry.lenEntry += %size(logValueExpected);
    entry.offsNextEntry += %size(logValueExpected);
    pValueExpected = usPtr + offsEntry + entry.lenEntry;
    entry.lenEntry += testFailureEvent.logExpected.length;
    entry.offsNextEntry += testFailureEvent.logExpected.length;

    logValueExpected.lenEntry = %size(tmpl_logValue_v5)
                                + testFailureEvent.logExpected.length;
    logValueExpected.length = testFailureEvent.logExpected.length;
    logValueExpected.originalLength = testFailureEvent.logExpected.originalLength;
    logValueExpected.offsValue = pValueExpected - usPtr;

    logValueExpected.offsDataType = offsEntry + entry.lenEntry;
    logValueExpected.lenDataType = %len(testFailureEvent.logExpected.type);
    pDataTypeExpected = usPtr + offsEntry  + logValueExpected.offsDataType;
    entry.lenEntry += logValueExpected.lenDataType;
    entry.offsNextEntry += logValueExpected.lenDataType;

    logValueExpected.offsAssertProc = offsEntry + entry.lenEntry;
    logValueExpected.lenAssertProc = %len(testFailureEvent.logExpected.assertProc);
    pAssertProcExpected = usPtr + offsEntry  + logValueExpected.offsAssertProc;
    entry.lenEntry += logValueExpected.lenAssertProc;
    entry.offsNextEntry += logValueExpected.lenAssertProc;

    memcpy(
      usPtr + logValueExpected.offsValue
      : %addr(testFailureEvent.logExpected.value: *data)
      : logValueExpected.length);

    memcpy(
      usPtr + logValueExpected.offsDataType
      : %addr(testFailureEvent.logExpected.type: *data)
      : logValueExpected.lenDataType);

    memcpy(
      usPtr + logValueExpected.offsAssertProc
      : %addr(testFailureEvent.logExpected.assertProc: *data)
      : logValueExpected.lenAssertProc);

    // add 'actual' value
    pLogValueActual = usPtr + offsEntry + entry.lenEntry;
    entry.offsActual = offsEntry + entry.lenEntry;
    entry.lenEntry += %size(logValueActual);
    entry.offsNextEntry += %size(logValueActual);
    pValueActual = usPtr + offsEntry + entry.lenEntry;
    entry.lenEntry += testFailureEvent.logActual.length;
    entry.offsNextEntry += testFailureEvent.logActual.length;

    logValueActual.lenEntry = %size(tmpl_logValue_v5)
                              + testFailureEvent.logActual.length;
    logValueActual.length = testFailureEvent.logActual.length;
    logValueActual.originalLength = testFailureEvent.logActual.originalLength;
    logValueActual.offsValue = pValueActual - usPtr;

    logValueActual.offsDataType = offsEntry + entry.lenEntry;
    logValueActual.lenDataType = %len(testFailureEvent.logActual.type);
    pDataTypeActual = usPtr + offsEntry + logValueActual.offsDataType;
    entry.lenEntry += logValueActual.lenDataType;
    entry.offsNextEntry += logValueActual.lenDataType;

    logValueActual.offsAssertProc = offsEntry + entry.lenEntry;
    logValueActual.lenAssertProc = %len(testFailureEvent.logActual.assertProc);
    pAssertProcActual = usPtr + offsEntry  + logValueActual.offsAssertProc;
    entry.lenEntry += logValueActual.lenAssertProc;
    entry.offsNextEntry += logValueActual.lenAssertProc;

    memcpy(
      usPtr + logValueActual.offsValue
      : %addr(testFailureEvent.logActual.value: *data)
      : logValueActual.length);

    memcpy(
      usPtr + logValueActual.offsDataType
      : %addr(testFailureEvent.logActual.type: *data)
      : logValueActual.lenDataType);

    memcpy(
      usPtr + logValueActual.offsAssertProc
      : %addr(testFailureEvent.logActual.assertProc: *data)
      : logValueActual.lenAssertProc);

  other; // including:  TEST_CASE_SUCCESS

    entry.offsExcpMsg = 0;
    entry.lenExcpMsg = 0;

    entry.lenSndInf = 0;
    entry.offsSndInf = 0;

    entry.lenRcvInf = 0;
    entry.offsRcvInf = 0;

    entry.offsCallStkE = 0;
    entry.numCallStkE = 0;

    entry.offsExpected = 0;
    entry.offsActual = 0;

  endsl;

  return entry.lenEntry;

end-proc;

// ==========================================================================
//  Returns the minimum of two integer values.
// ==========================================================================
dcl-proc min;
  dcl-pi *N int(10) extproc(*dclcase);
    int1   int(10) value;
    int2   int(10) value;
  end-pi;

  if (int1 < int2);
    return int1;
  else;
    return int2;
  endif;

end-proc;

