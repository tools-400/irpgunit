20251214-10:03 (OK)

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

// User space version number 5. Introduced 03.10.2025.
// Added message 'expected' and 'actual' values.
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

dcl-ds tmpl_testCase_v5 len(58) qualified template;
  offsNextEntry    int(10);
  lenEntry         int(5);
  result           char(1);
  reserved_1       char(1);
  numAsserts       int(10);
  execTime         int(20);
  offsTestCaseText int(10);
  lenTestCaseText  int(5);
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
  offsExpected     int(10); // offset from the start of user space
  offsActual       int(10); // offset from the start of user space
  // logExpected      likeds(tmpl_logValue_v5); // added, is available
  // logActual        likeds(tmpl_logValue_v5); // added, is available
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
  version   int(10) inz(version_6);
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
// @ignore-unused
  dcl-ds testCaseV5 likeds(tmpl_testCase_v5) based(pTestCase);
  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestCaseResult);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);
  dcl-s lenTestCaseEntry int(10);
  dcl-ds tmpTestCaseResult likeds(testCaseResult_t) inz;

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

  pTestCase = usPtr + header.offsTestCases;

  list_resetIteration(testSuite.testResults);
  pTestCaseResult = list_getnext(testSuite.testResults);
  dow (pTestCaseResult <> *null);

    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    dow (pAbstractTestEvent <> *null);

      header.numTestCasesRtn += 1;

      tmpTestCaseResult = testCaseResult;
      tmpTestCaseResult.execTime = getReportExecutionTimeTestCase(testCaseResult);
      tmpTestCaseResult.testName = buildReportTestCaseName(testCaseResult: abstractTestEvent);
      tmpTestCaseResult.assertCnt = getReportNumAsserts(testCaseResult);

      lenTestCaseEntry = createV6TestCase(usPtr: tmpTestCaseResult: pTestCase: abstractTestEvent);
      header.length += lenTestCaseEntry;
      pTestCase += lenTestCaseEntry;

      pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    enddo;

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
    pEntry            pointer value;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s offsEntry int(10);
  dcl-ds entry likeds(tmpl_testCase_v5) based(pEntry);
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
  dcl-ds testSuccessEvent likeds(testSuccessEvent_t) inz;

  offsEntry = pEntry - usPtr;

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
  when (abstractTestEvent.outcome = TEST_CASE_ERROR);

    runtimeErrorEvent = abstractTestEvent.error;

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

  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);

    testFailureEvent = abstractTestEvent.failure;

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
    entry.offsExpected = addLogValue(usPtr: entry: testFailureEvent.logExpected);

    // add 'actual' value
    entry.offsActual = addLogValue(usPtr: entry: testFailureEvent.logActual);

  other; // including:  TEST_CASE_SUCCESS

    testSuccessEvent = abstractTestEvent.success;

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
//  Adds a log value (actual or expected) to a user space
//  with version 5 layout.
// ==========================================================================
dcl-proc addLogValue;
  dcl-pi *n int(10) extproc(*dclcase);
    usPtr       pointer const;
    entry       likeds(tmpl_testCase_v5);
    logValue likeds(logValue_t);
  end-pi;

  dcl-s offsEntry int(10);
  dcl-ds entryLogValue likeds(tmpl_logValue_v5) based(pEntryLogValue);
// @ignore-unused
  dcl-s valueExpected char(2048) based(pValueExpected);
// @ignore-unused
  dcl-s dataTypeExpected char(20) based(pDataTypeExpected);
// @ignore-unused
  dcl-s assertProcExpected char(32) based(pAssertProcExpected);

  dcl-s offsLogValue int(10);

  offsEntry = %addr(entry) - usPtr;

  pEntryLogValue = usPtr + offsEntry + entry.lenEntry;

//  entry.offsExpected = offsEntry + entry.lenEntry;
  offsLogValue = offsEntry + entry.lenEntry;

  entry.lenEntry += %size(entryLogValue);
  entry.offsNextEntry += %size(entryLogValue);
  pValueExpected = usPtr + offsEntry + entry.lenEntry;
  entry.lenEntry += logValue.length;
  entry.offsNextEntry += logValue.length;

  entryLogValue.lenEntry = %size(tmpl_logValue_v5)
                              + logValue.length;
  entryLogValue.length = logValue.length;
  entryLogValue.originalLength = logValue.originalLength;
  entryLogValue.offsValue = pValueExpected - usPtr;

  entryLogValue.offsDataType = offsEntry + entry.lenEntry;
  entryLogValue.lenDataType = %len(logValue.type);
  pDataTypeExpected = usPtr + offsEntry  + entryLogValue.offsDataType;
  entry.lenEntry += entryLogValue.lenDataType;
  entry.offsNextEntry += entryLogValue.lenDataType;

  entryLogValue.offsAssertProc = offsEntry + entry.lenEntry;
  entryLogValue.lenAssertProc = %len(logValue.assertProc);
  pAssertProcExpected = usPtr + offsEntry  + entryLogValue.offsAssertProc;
  entry.lenEntry += entryLogValue.lenAssertProc;
  entry.offsNextEntry += entryLogValue.lenAssertProc;

  memcpy(
    usPtr + entryLogValue.offsValue
    : %addr(logValue.value: *data)
    : entryLogValue.length);

  memcpy(
    usPtr + entryLogValue.offsDataType
    : %addr(logValue.type: *data)
    : entryLogValue.lenDataType);

  memcpy(
    usPtr + entryLogValue.offsAssertProc
    : %addr(logValue.assertProc: *data)
    : entryLogValue.lenAssertProc);

  return offsLogValue;

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


