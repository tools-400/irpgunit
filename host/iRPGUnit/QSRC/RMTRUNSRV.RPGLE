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
// @ignore-unused
dcl-c version_1 1;

// User space version number 2. Introduced 10.10.2016.
// Changed exception message to varsize up to 1024 bytes.
// @ignore-unused
dcl-c version_2 2;

// User space version number 3. Introduced 23.04.2017.
// Added 'tmpl_testSuite.numTestCasesRtn'.
// @ignore-unused
dcl-c version_3 3;

// User space version number 4. Introduced 09.04.2024.
// Added message 'receiver' and program library name.
// @ignore-unused
dcl-c version_4 4;

// User space version number 5. Introduced 03.10.2025.
// Added message 'expected' and 'actual' values.
// Was never in production.
// @ignore-unused
dcl-c version_5 5;

// User space version number 6. Introduced 13.12.2025.
// Added option for processing all assertions. Added
// assertion events as children of test cases.
dcl-c version_6 6;

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
  length            int(10);
  version           int(10);
  testSuite         likeds(object_t);
  numRuns           int(10);
  numAsserts        int(10);
  numFailures       int(10);
  numErrors         int(10);
  offsFirstTestCase int(10);
  numTestCases      int(10);
  system            char(10);
  splf_name         char(10);
  splf_nbr          int(10);
  job_name          char(10);
  job_user          char(10);
  job_nbr           char(6);
  qSrcMbr           likeds(srcMbr_t);
  numTestCasesRtn   int(10);
  // added 15.5.2025
  typeOfSrc         char(10);
  offsSrcStmf       int(10);
  lenSrcStmf        int(10);
  reserved_1        char(102);
end-ds;

dcl-ds tmpl_testCase_v6 len(34) qualified template;
  offsNextEntry          int(10);
  lenEntry               int(5);
  outcome                char(1);
  reserved_1             char(1);
  numAsserts             int(10);
  execTime               int(20);
  offsTestCaseText       int(10);
  lenTestCaseText        int(5);
  numTestCaseEvents      int(10);
  offsFirstTestCaseEvent int(10);
end-ds;

dcl-ds tmpl_testCaseEvent_v6 len(46) qualified template;
  outcome          char(1);
  reserved_2       char(1);
  lenEntry         int(5);
  offsNextEntry    int(10);
  offsAssertProcNm int(10);
  lenAssertProcNm  int(5);
  // runtimeErrorEvent
  offsExcpMsg      int(10);
  lenExcpMsg       int(5);
  offsSndInf       int(10);
  lenSndInf        int(5);
  offsRcvInf       int(10);
  lenRcvInf        int(5);
  // testFailureEvent
  offsCallStkE     int(10);
  numCallStkE      int(5);
  // testFailureEvent & testSuccessEvent
  offsExpected     int(10);
  offsActual       int(10);
  // logExpected      likeds(tmpl_logValue_v6);
  // logActual        likeds(tmpl_logValue_v6);
end-ds;

dcl-ds tmpl_logValue_v6 len(23) qualified template;
  lenEntry         int(5);
  lenValue         int(5);
  originalLength   int(5);
  offsDataType     int(10);
  lenDataType      int(5);
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
  version      int(10) inz(version_6);
  isJUnitStyle Ind;
end-ds;

// ==========================================================================
//  Fill user space, all versions.
// ==========================================================================
dcl-proc fillUserSpace export;
  dcl-pi *N;
    userSpace       likeds(object_t ) const;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(object_t) const;
    testSuiteResult likeds(testSuiteResult_t) const;
    isJUnitStyle    ind const;
  end-pi;

  dcl-s usPtr pointer;
  dcl-ds splf likeds(splf_t);
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-ds header likeds(tmpl_testSuite) based(usPtr);
  dcl-s header_SrcStmf char(1024) based(pHeader_SrcStmf); // varying-length portion of 'header'

  dcl-s offsCurrentTestCase int(10);
  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestCaseResult);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);
  dcl-s lenTestCaseEntry int(10);

  g_status.isJUnitStyle = isJUnitStyle;

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
  else;
     header.qSrcMbr = srcInf.mbr;
     header.offsSrcStmf = 0;
     header.lenSrcStmf = 0;
  endif;

  header.offsFirstTestCase = header.length;

  header.numTestCasesRtn = 0;
  header.reserved_1 = *blank;

  offsCurrentTestCase = header.offsFirstTestCase;

  list_resetIteration(testSuite.testResults);
  pTestCaseResult = list_getnext(testSuite.testResults);
  dow (pTestCaseResult <> *null);

    header.numTestCasesRtn += 1;

    lenTestCaseEntry = createV6TestCase(usPtr: testCaseResult: offsCurrentTestCase);

    header.length += lenTestCaseEntry;
    offsCurrentTestCase = header.length;

    pTestCaseResult = list_getnext(testSuite.testResults);
  enddo;

end-proc;

// ==========================================================================
//  Create user space with version 6 layout.
// ==========================================================================
dcl-proc createV6TestCase;
  dcl-pi *N int(10) extproc(*dclcase);
    usPtr             pointer value;
    testCaseResult    likeds(testCaseResult_t) value;
    offsTestCase      int(10) const;
  end-pi;

  dcl-ds testCase likeds(tmpl_testCase_v6) based(pTestCase);
  dcl-s offsTestCaseEvent int(10);
  dcl-ds testCaseEvent likeds(tmpl_testCaseEvent_v6) based(pTestCaseEvent);
  dcl-ds logValueExpected likeds(tmpl_logValue_v6) based(pLogValueExpected);
  dcl-ds logValueActual likeds(tmpl_logValue_v6) based(pLogValueActual);

  dcl-ds sender likeds(tmpl_sender_v5) based(pSender);
  dcl-ds receiver likeds(tmpl_receiver_v5) based(pReceiver);

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);
  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;
  dcl-ds testSuccessEvent likeds(testSuccessEvent_t) inz;

  pTestCase = usPtr + offsTestCase;

  clear testCase;
  testCase.lenEntry = %size(testCase);

  testCase.outcome = testCaseResult.outcome;
  testCase.reserved_1 = '';
  testCase.numAsserts = testCaseResult.assertCnt;
  testCase.execTime = testCaseResult.exectime;

  // Test case text:
  testCase.offsTestCaseText = offsTestCase + %size(testCase);
  testCase.lenTestCaseText = %len(testCaseResult.testname);
  memcpy(usPtr + testCase.offsTestCaseText
         : %addr(testCaseResult.testName: *data)
         : testCase.lenTestCaseText);

  testCase.lenEntry += testCase.lenTestCaseText;

  testCase.numTestCaseEvents = 0;
  testCase.offsFirstTestCaseEvent = offsTestCase + testCase.lenEntry;

  offsTestCaseEvent = testCase.offsFirstTestCaseEvent;

  pTestCaseEvent = usPtr + offsTestCaseEvent;

  pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  dow (pAbstractTestEvent <> *null);

    testCase.numTestCaseEvents += 1;

    select;
    when (abstractTestEvent.outcome = TEST_CASE_ERROR);

      runtimeErrorEvent = abstractTestEvent.error;

      testCaseEvent.lenEntry = %size(testCaseEvent);

      testCaseEvent.outcome = abstractTestEvent.outcome;

      // Assert procedure name:
      testCaseEvent.offsAssertProcNm = 0;
      testCaseEvent.lenAssertProcNm = 0;

      // Exception message:
      testCaseEvent.offsExcpMsg = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenExcpMsg = %len(runtimeErrorEvent.msg.txt);
      memcpy(usPtr + testCaseEvent.offsExcpMsg
             : %addr(runtimeErrorEvent.msg.txt: *data)
             : testCaseEvent.lenExcpMsg);

      testCaseEvent.lenEntry += testCaseEvent.lenExcpMsg;

      // Execution time:
      testCase.execTime = -1;

      // Sender information:
      testCaseEvent.offsSndInf = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenSndInf = %size(sender);

      pSender = usPtr + testCaseEvent.offsSndInf;
      clear sender;
      sender.lenEntry = %size(sender);
      sender.qPgm = runtimeErrorEvent.msg.qSndStmt.qPgm;
      sender.qMod = runtimeErrorEvent.msg.qSndStmt.qMod;
      sender.specNb = runtimeErrorEvent.msg.qSndStmt.specNb;
      sender.offsProcNm = testCaseEvent.offsSndInf + %size(sender);
      sender.lenProcNm = %len(runtimeErrorEvent.msg.qSndStmt.procNm);
      memcpy(usPtr + sender.offsProcNm
             : %addr(runtimeErrorEvent.msg.qSndStmt.procNm: *data)
             : testCaseEvent.lenExcpMsg);

      sender.lenEntry += sender.lenProcNm;

      testCaseEvent.lenSndInf += sender.lenProcNm;
      testCaseEvent.lenEntry += sender.lenEntry;

      // Receiver information:
      testCaseEvent.offsRcvInf = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenRcvInf = %size(receiver);

      pReceiver = usPtr + testCaseEvent.offsRcvInf;
      clear receiver;
      receiver.lenEntry = %size(receiver);
      receiver.qPgm = runtimeErrorEvent.msg.qRcvStmt.qpgm;
      receiver.qMod = runtimeErrorEvent.msg.qRcvStmt.qmod;
      receiver.specNb = runtimeErrorEvent.msg.qRcvStmt.specnb;
      receiver.offsProcNm = testCaseEvent.offsRcvInf + %size(receiver);
      receiver.lenProcNm = %len(runtimeErrorEvent.msg.qRcvStmt.procnm);
      memcpy(usPtr + receiver.offsProcNm
             : %addr(runtimeErrorEvent.msg.qRcvStmt.procNm: *data)
             : testCaseEvent.lenExcpMsg);

      receiver.lenEntry += receiver.lenProcNm;

      testCaseEvent.lenRcvInf += receiver.lenProcNm;
      testCaseEvent.lenEntry += receiver.lenEntry;

      // Call stack entries:
      testCaseEvent.offsCallStkE = 0;
      testCaseEvent.numCallStkE = 0;

      // 'expected' and 'actual' values:
      testCaseEvent.offsExpected = 0;
      testCaseEvent.offsActual = 0;

    when (abstractTestEvent.outcome = TEST_CASE_FAILURE);

      testFailureEvent = abstractTestEvent.failure;

      testCaseEvent.lenEntry = %size(testCaseEvent);

      testCaseEvent.outcome = abstractTestEvent.outcome;

      // Assert procedure name:
      testCaseEvent.offsAssertProcNm = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenAssertProcNm = %len(testFailureEvent.assertProc);
      memcpy(usPtr + testCaseEvent.offsAssertProcNm
             : %addr(testFailureEvent.assertProc: *data)
             : testCaseEvent.lenAssertProcNm);

      testCaseEvent.lenEntry += testCaseEvent.lenAssertProcNm;

      // Failure message:
      testCaseEvent.offsExcpMsg = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenExcpMsg = %len(testFailureEvent.msg);
      memcpy(usPtr + testCaseEvent.offsExcpMsg
             : %addr(testFailureEvent.msg: *data)
             : testCaseEvent.lenExcpMsg);

      testCaseEvent.lenEntry += testCaseEvent.lenExcpMsg;

      // Execution time:
      testCase.execTime = -1;

      // Sender information:
      testCaseEvent.offsSndInf = 0;
      testCaseEvent.lenSndInf = 0;

      // Receiver information:
      testCaseEvent.offsRcvInf = 0;
      testCaseEvent.lenRcvInf = 0;

      // Call stack entries:
      addCallstack(usPtr: testCaseEvent: testFailureEvent.pCallstk);

      // add 'expected' value
      testCaseEvent.offsExpected = addLogValue(usPtr: testCaseEvent: testFailureEvent.logExpected);
      pLogValueExpected = usPtr + testCaseEvent.offsExpected;
      testCaseEvent.lenEntry += logValueExpected.lenEntry;

      // add 'actual' value
      testCaseEvent.offsActual = addLogValue(usPtr: testCaseEvent: testFailureEvent.logActual);
      pLogValueActual = usPtr + testCaseEvent.offsActual;
      testCaseEvent.lenEntry += logValueActual.lenEntry;

    other; // including:  TEST_CASE_SUCCESS

      testSuccessEvent = abstractTestEvent.success;

      testCaseEvent.lenEntry = %size(testCaseEvent);

      testCaseEvent.outcome = abstractTestEvent.outcome;

      // Assert procedure name:
      testCaseEvent.offsAssertProcNm = offsTestCaseEvent + testCaseEvent.lenEntry;
      testCaseEvent.lenAssertProcNm = %len(testSuccessEvent.assertProc);
      memcpy(usPtr + testCaseEvent.offsAssertProcNm
             : %addr(testSuccessEvent.assertProc: *data)
             : testCaseEvent.lenAssertProcNm);

      testCaseEvent.lenEntry += testCaseEvent.lenAssertProcNm;

      testCaseEvent.offsExcpMsg = 0;
      testCaseEvent.lenExcpMsg = 0;

      testCaseEvent.lenSndInf = 0;
      testCaseEvent.offsSndInf = 0;

      testCaseEvent.lenRcvInf = 0;
      testCaseEvent.offsRcvInf = 0;

      if (g_status.isJUnitStyle);
        testCaseEvent.offsCallStkE = 0;
        testCaseEvent.numCallStkE = 0;
      else;
        addCallstack(usPtr: testCaseEvent: testSuccessEvent.pCallstk);
      endif;

      testCaseEvent.offsExpected = 0;
      testCaseEvent.offsActual = 0;

    endsl;

    testCaseEvent.offsNextEntry = offsTestCaseEvent + testCaseEvent.lenEntry;
    offsTestCaseEvent = testCaseEvent.offsNextEntry;

    testCase.lenEntry += testCaseEvent.lenEntry;

    pTestCaseEvent = usPtr + offsTestCaseEvent;
    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  enddo;


  testCase.offsNextEntry = offsTestCase + testCase.lenEntry;

  return testCase.lenEntry;

end-proc;

// ==========================================================================
//  Adds a log value (actual or expected) to a user space
//  with version 5 layout.
// ==========================================================================
dcl-proc addCallstack;
  dcl-pi *n int(10) extproc(*dclcase);
    usPtr         pointer const;
    testCaseEvent likeds(tmpl_testCaseEvent_v6);
    pCallstk      pointer const;
  end-pi;

  dcl-s offsTestCaseEvent int(10);

  dcl-s offsStackEntry int(10);
  dcl-ds stackEntry likeds(tmpl_callStkEnt_v5) based(pStackEntry);

  dcl-ds callstkEnt likeds(callstkEnt_t) inz;
  dcl-ds srcInf likeds(srcInf_t) inz;
  dcl-s stackEntry_SrcStmf char(1024) based(pStackEntry_SrcStmf);

  offsTestCaseEvent = %addr(testCaseEvent) - usPtr;

  pStackEntry = usPtr + offsTestCaseEvent + testCaseEvent.lenEntry;

  testCaseEvent.offsCallStkE = pStackEntry - usPtr;

  offsStackEntry = testCaseEvent.offsCallStkE;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));

    testCaseEvent.numCallStkE += 1;

    clear stackEntry;

    stackEntry.offsNextEntry = offsStackEntry + %size(stackEntry);
    stackEntry.lenEntry = %size(stackEntry);

    stackEntry.qPgm = callstkEnt.qstmt.qpgm;
    stackEntry.qMod = callstkEnt.qstmt.qmod;
    stackEntry.specNb = callstkEnt.qstmt.specnb;

    // TODO: add source stream file path to 'stackEntry'
    srcInf = SrcMbr_getModSrc(stackEntry.qPgm: stackEntry.qMod);

    stackEntry.typeOfSrc = srcInf.type;
    if (stackEntry.typeOfSrc = TYPE_STMF);
       clear stackEntry.qSrcMbr;
       stackEntry.offsSrcStmf = offsStackEntry + stackEntry.lenEntry;
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

    stackEntry.offsProcNm = offsStackEntry + stackEntry.lenEntry;
    stackEntry.lenProcNm = %len(callstkEnt.qstmt.procnm);
    memcpy(usPtr + stackEntry.offsProcNm
           : %addr(callstkEnt.qStmt.procNm:*data)
           : stackEntry.lenProcNm);

    stackEntry.offsNextEntry += stackEntry.lenProcNm;
    stackEntry.lenEntry += stackEntry.lenProcNm;

    testCaseEvent.lenEntry += stackEntry.lenEntry;

    pStackEntry = usPtr + stackEntry.offsNextEntry;
    offsStackEntry = pStackEntry - usPtr;

  enddo;

  return offsStackEntry;

end-proc;

// ==========================================================================
//  Adds a log value (actual or expected) to a user space
//  with version 5 layout.
// ==========================================================================
dcl-proc addLogValue;
  dcl-pi *n int(10) extproc(*dclcase);
    usPtr         pointer const;
    testCaseEvent likeds(tmpl_testCaseEvent_v6);
    logValue      likeds(logValue_t);
  end-pi;

  dcl-s offsTestCaseEvent int(10);
  dcl-ds entryLogValue likeds(tmpl_logValue_v6) based(pEntryLogValue);
// @ignore-unused
  dcl-s value char(2048) based(pValue);
// @ignore-unused
  dcl-s dataType char(20) based(pDataType);

  dcl-s offsEntryLogValue int(10);

  offsTestCaseEvent = %addr(testCaseEvent) - usPtr;

  pEntryLogValue = usPtr + offsTestCaseEvent + testCaseEvent.lenEntry;
  offsEntryLogValue = pEntryLogValue - usPtr;

  entryLogValue.lenEntry = %size(entryLogValue);

  // Value
  entryLogValue.originalLength = logValue.originalLength;

  entryLogValue.offsValue = offsEntryLogValue + entryLogValue.lenEntry;
  entryLogValue.lenValue = logValue.length;

  entryLogValue.lenEntry += entryLogValue.lenValue;

  // Data Type
  entryLogValue.offsDataType = offsEntryLogValue + entryLogValue.lenEntry;
  entryLogValue.lenDataType = %len(logValue.type);

  entryLogValue.lenEntry += entryLogValue.lenDataType;

  memcpy(
    usPtr + entryLogValue.offsValue
    : %addr(logValue.value: *data)
    : entryLogValue.lenValue);

  memcpy(
    usPtr + entryLogValue.offsDataType
    : %addr(logValue.type: *data)
    : entryLogValue.lenDataType);

  // For debugging
  pValue = usPtr + entryLogValue.offsValue;
  pDataType = usPtr + entryLogValue.offsDataType;

  return offsEntryLogValue;

end-proc;

