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

     H nomain
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

      // User space version number 1. Introduced 22.04.2013.
      // Changed because of enhancements for RPGUnit plug-in.
     D VERSION_1       c                   1
      // User space version number 2. Introduced 10.10.2016.
      // Changed exception message to varsize up to 1024 bytes.
     D VERSION_2       c                   2
      // User space version number 3. Introduced 23.04.2017.
      // Added 'tmpl_testSuite.numTestCasesRtn'.
     D VERSION_3       c                   3

      *-------------------------------------------------------------------------
      * Prototypes
      *-------------------------------------------------------------------------

      /include qinclude,RMTRUNSRV
      /include qinclude,ERRORCODE

     D fillUserspace   PR
     D   userspace                         likeds(Object_t ) const
     D   testSuite                         likeds(testsuite_t) const
     D   testSuiteName...
     D                                     likeds(Object_t) const
     D   result                            likeds(result_t) const

     D createV1TestCase...
     D                 PR            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value

     D createV2TestCase...
     D                 PR            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value

     D min...
     D                 PR            10i 0
     D   int1                        10i 0 value
     D   int2                        10i 0 value

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
      /include qllist,llist_h

      *-------------------------------------------------------------------------
      * Type Templates
      *-------------------------------------------------------------------------
     D tmpl_testSuite  DS           256    qualified based(nullPointer)
     D  length                       10I 0
     D  version...
     D                               10I 0
     D  testSuite                          likeds(Object_t)
     D  numberRuns...
     D                               10I 0
     D  numberAssertions...
     D                               10I 0
     D  numberFailures...
     D                               10I 0
     D  numberErrors...
     D                               10I 0
     D  offsetTestCases...
     D                               10I 0
     D  numberTestCases...
     D                               10I 0
     D  system                       10A
     D  splF_name                    10A
     D  splF_nbr                     10I 0
     D  job_name                     10A
     D  job_user                     10A
     D  job_nbr                       6A
     D  qSrcMbr                            likeds(SrcMbr_t)
     D  numTestCasesRtn...
     D                               10I 0
     D  reserved1                   120A
      *
     D tmpl_testCase_v1...
     D                 DS           384    qualified based(nullPointer)
     D  length                       10I 0
     D  result                        1A
     D  reserved_1                    1A
     D  specNB                       10A
     D  numberAssertions...
     D                               10I 0
     D  numCallStkEnt                10I 0
     D  offsCallStkEnt...
     D                               10I 0
     D  offsNext                     10I 0
     D  lenTestCase                   5I 0
     D  lenExcpMessage...
     D                                5I 0
     D  testCase                    100A
     D  excpMessage                 200A
     D  execTime                     20I 0
     D  reserved_2                   40A
      *
     D tmpl_testCase_v2...
     D                 DS                  qualified based(nullPointer)
     D  length                       10I 0
     D  result                        1A
     D  reserved_1                    1A
     D  specNB                       10A
     D  numberAssertions...
     D                               10I 0
     D  numCallStkEnt                10I 0
     D  offsCallStkEnt...
     D                               10I 0
     D  offsNext                     10I 0
     D  lenTestCase                   5I 0
     D  lenExcpMessage...
     D                                5I 0
     D  testCase                    100A
     D  excpMessage                1024A

     D  tmpl_execTime_v2...
     D                 S             20I 0 based(nullPointer)
      *
     D tmpl_callStkEnt...
     D                 DS           354    qualified based(nullPointer)
     D  qPgm                               likeds(Object_t)
     D  qMod                               likeds(Object_t)
     D  specNb                       10a
     D  length                       10I 0
     D  offsNext                     10I 0
     D  reserved_1                    8A
     D  lenProcNm                     5I 0
     D  procNm                      256a
     D  qSrcMbr                            likeds(SrcMbr_t)
      *
      /include qinclude,TEMPLATES

      *-------------------------------------------------------------------------
      * Module Status
      *-------------------------------------------------------------------------
     D g_status        DS                  qualified
     D  version                      10i 0 inz(VERSION_3)

      *-------------------------------------------------------------------------
      * Procedures
      *-------------------------------------------------------------------------


     P rpgunit_runTestSuite...
     P                 B                   export
     D                 PI            10I 0
     D  userspace                          likeds(Object_t ) const
     D  testSuiteName                      likeds(Object_t ) const
     D  testProcs                          likeds(ProcNms_t) const
     D  order                              like(order_t    ) const
     D  detail                             like(detail_t   ) const
     D  output                             like(output_t   ) const
     D  libl                               likeDs(libL_t   ) const
     D  qJobD                              likeDs(Object_t ) const
     D  rclrsc                             like(rclrsc_t   ) const
     D  xmlStmf                            like(stmf_t     ) const
      *
     D returnValue     S             10I 0
      *
     D usPtr           S               *
     D testSuite       DS                  likeds(testSuite_t)
      *
       // Completion message.
     D msg             S            256A

       // Generic return code.
     D rc              S             10i 0

       // Error message when writing the XML file.
     D errMsg          s            256a

       // Test event counters.
     D result          DS                  likeds(result_t)

       // Save/set/restore library list
     D savedLibl       ds                  likeds(LiblData_t)
     D mustRestoreLibl...
     D                 s               n   inz(*OFF)

       // Return values
     D SUCCESS         c                   0
     D FAILURE         c                   -1
      /free

       clear result;
       setLogContext( testSuiteName : detail : output );
       clearAssertCounter();

        // Set library list and load test suite
        monitor;
          savedLibl = getLibl();
          mustRestoreLibl = setTestSuiteLibl(libl: qJobD: testSuiteName.lib);
          logLibraryList(getLibl());
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
          runTests(result: testSuite: testProcs
                   : order :detail: rclrsc);
        endif;

        tearDownTestSuite( testSuite : result );

        result.assertCnt = getAssertCalled();

        // Return result to xml file
        if (xmlStmf <> '');
          monitor;
            writeXmlFile(resolvePathVariables(xmlStmf: testSuiteName)
                         : testSuite : testSuiteName : result);
          on-error;
            errMsg = rcvMsgTxt('*ESCAPE');
          endmon;
        endif;

        // Return result to plug-in
        fillUserspace(userspace : testSuite : testSuiteName : result);

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

      /end-free
     P                 E


     P fillUserspace...
     P                 B
     D                 PI
     D   userspace                         likeds(Object_t ) const
     D   testSuite                         likeds(testsuite_t) const
     D   testSuiteName...
     D                                     likeds(Object_t) const
     D   result                            likeds(result_t) const
      *
     D usPtr           S               *
     D splF            DS                  likeds(SplF_t)
     D header          DS                  likeds(tmpl_testSuite) based(usPtr)
     D entry           DS                  likeds(tmpl_testCase_v1) based(eptr)
     D testResult      DS                  likeds(TestResult_t) based(ptr)
     D errorCode       DS                  likeds(errorCode_t) inz(*likeds)
      /free

       clear errorCode;
       errorCode.bytPrv = 0;
       api_retrieveUserspacePointer(userspace : usPtr : errorCode);

       splF = getLogSplF();

       header.length = %size(header);
       header.version = g_status.version;
       header.testSuite = testSuiteName;
       header.numberRuns = result.runsCnt;
       header.numberAssertions = result.assertCnt;
       header.numberFailures = result.failureCnt;
       header.numberErrors = result.errorCnt;
       header.offsetTestCases = %size(header);
       header.numberTestCases = testSuite.testCasesCnt;

       header.system = splF.system;
       header.splF_name = splF.nm;
       header.splF_nbr = splF.nbr;
       header.job_name = splF.job.name;
       header.job_user = splF.job.user;
       header.job_nbr = splF.job.nbr;

       SrcMbr_initialize();
       header.qSrcMbr = SrcMbr_getTestSuiteSrc(testSuiteName);

       header.numTestCasesRtn = 0;
       header.reserved1 = *blank;

       list_abortIteration(testSuite.testResults);
       ptr = list_getNext(testSuite.testResults);

       dow (ptr <> *null);
         if (header.numTestCasesRtn = 0);
            eptr = usPtr + header.offsetTestCases;
         else;
            eptr = usPtr + entry.offsNext;
         endif;

         select;
         when g_status.version >= VERSION_2;
            header.length += createV2TestCase(usPtr: testResult: eptr);
         other;
            header.length += createV1TestCase(usPtr: testResult: eptr);
         endsl;

         ptr = list_getNext(testSuite.testResults);
         header.numTestCasesRtn += 1;
       enddo;

       if (header.numTestCasesRtn > 0);
         entry.offsNext = 0;  // Clear offsNext of last entry.
       endif;

      /end-free
     P                 E


     P createV1TestCase...
     P                 B
     D                 PI            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value
      *
     D entry           DS                  likeds(tmpl_testCase_v1) based(eptr)
      *
     D e               S             10I 0
     D stackEntry      DS                  likeds(tmpl_callStkEnt) based(sptr)
     D failure         DS                  likeds(AssertFailEvtLong_t)
     D                                     based(fptr)
      /free

         clear entry;
         entry.lenTestCase = %len(testResult.testName);
         entry.testCase = testResult.testName;
         entry.result = testResult.outcome;
         entry.numberAssertions = testResult.assertCnt;

         select;
         when (testResult.outcome = TEST_CASE_ERROR);
            entry.lenExcpMessage = %len(testResult.error.txt);
            entry.excpMessage = testResult.error.txt;
            if (testResult.error.sender.specNb <> '');
               entry.specNb = testResult.error.sender.specNb;
            else;
               entry.specNb = '*N';
            endif;
            entry.execTime = -1;
            entry.length = %size(entry);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = 0;
            entry.numCallStkEnt = 0;

            // Add callstack entry of exception message
            sptr = usPtr + entry.offsNext;

            stackEntry.qPgm = testResult.Error.Sender.qPgm;
            stackEntry.qMod = testResult.Error.Sender.qMod;
            stackEntry.specNb = testResult.Error.Sender.specNb;
            stackEntry.procNm = testResult.Error.Sender.procNm;
            stackEntry.lenProcNm = %len(testResult.Error.Sender.procNm);

            stackEntry.length = %size(stackEntry);
            stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

            entry.length += stackEntry.length;
            entry.offsNext += stackEntry.length;
            entry.numCallStkEnt += 1;

         when (testResult.outcome = TEST_CASE_FAILURE);
            fptr = %addr(testResult.failure);
            entry.lenExcpMessage = %len(testResult.failure.msg);
            entry.excpMessage = testResult.failure.msg;
            entry.specNb =
                  failure.callStk.entry(1).sender.specNb;

            entry.execTime = -1;
            entry.length = %size(entry);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = entry.offsNext;

            for e = 1 to failure.callStk.numE;
               sptr = usPtr + entry.offsNext;

               stackEntry.qPgm = failure.callStk.entry(e).sender.qPgm;
               stackEntry.qMod = failure.callStk.entry(e).sender.qMod;
               stackEntry.lenProcNm =
                              %len(failure.callStk.entry(e).sender.procNm);
               stackEntry.procNm = failure.callStk.entry(e).sender.procNm;
               stackEntry.specNb = failure.callStk.entry(e).sender.specNb;

               stackEntry.qSrcMbr = SrcMbr_getModSrc(
                                          stackEntry.qPgm: stackEntry.qMod);

               stackEntry.length = %size(stackEntry);
               stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

               entry.length += stackEntry.length;
               entry.offsNext += stackEntry.length;
               entry.numCallStkEnt += 1;
            endfor;

         other; // including:  TEST_CASE_SUCCESS
            entry.lenExcpMessage = 0;
            entry.excpMessage = '';
            entry.specNb = '';
            entry.execTime = testResult.execTime;
            entry.length = %size(entry);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = 0;
            entry.numCallStkEnt = 0;

         endsl;

         return entry.length;

      /end-free
     P                 E


     P createV2TestCase...
     P                 B
     D                 PI            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value
      *
     D entry           DS                  likeds(tmpl_testCase_v2) based(eptr)
     D execTime        S                   like(tmpl_execTime_v2) based(pexct)
      *
     D e               S             10I 0
     D stackEntry      DS                  likeds(tmpl_callStkEnt) based(sptr)
     D failure         DS                  likeds(AssertFailEvtLong_t)
     D                                     based(fptr)
      /free

         clear entry;
         entry.lenTestCase = %len(testResult.testName);
         entry.testCase = testResult.testName;
         entry.result = testResult.outcome;
         entry.numberAssertions = testResult.assertCnt;

         select;
         when (testResult.outcome = TEST_CASE_ERROR);
            entry.lenExcpMessage =
               min(%len(testResult.error.txt): %len(entry.excpMessage));
            entry.excpMessage = testResult.error.txt;
            if (testResult.error.sender.specNb <> '');
               entry.specNb = testResult.error.sender.specNb;
            else;
               entry.specNb = '*N';
            endif;
            pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
            execTime = -1;
            entry.length = %size(entry) +
                           entry.lenExcpMessage + %size(execTime);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = entry.offsNext;
            entry.numCallStkEnt = 0;

            // Add callstack entry of exception message
            sptr = usPtr + entry.offsNext;

            stackEntry.qPgm = testResult.Error.Sender.qPgm;
            stackEntry.qMod = testResult.Error.Sender.qMod;
            stackEntry.specNb = testResult.Error.Sender.specNb;
            stackEntry.procNm = testResult.Error.Sender.procNm;
            stackEntry.lenProcNm = %len(testResult.Error.Sender.procNm);

            stackEntry.length = %size(stackEntry);
            stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

            entry.length += stackEntry.length;
            entry.offsNext += stackEntry.length;
            entry.numCallStkEnt += 1;

         when (testResult.outcome = TEST_CASE_FAILURE);
            fptr = %addr(testResult.failure);
            entry.lenExcpMessage =
               min(%len(testResult.failure.msg): %len(entry.excpMessage));
            entry.excpMessage = testResult.failure.msg;
            entry.specNb =
                  failure.callStk.entry(1).sender.specNb;

            pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
            execTime = -1;
            entry.length = %size(entry) +
                           entry.lenExcpMessage + %size(execTime);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = entry.offsNext;

            for e = 1 to failure.callStk.numE;
               sptr = usPtr + entry.offsNext;

               stackEntry.qPgm = failure.callStk.entry(e).sender.qPgm;
               stackEntry.qMod = failure.callStk.entry(e).sender.qMod;
               stackEntry.lenProcNm =
                              %len(failure.callStk.entry(e).sender.procNm);
               stackEntry.procNm = failure.callStk.entry(e).sender.procNm;
               stackEntry.specNb = failure.callStk.entry(e).sender.specNb;

               stackEntry.qSrcMbr = SrcMbr_getModSrc(
                                          stackEntry.qPgm: stackEntry.qMod);

               stackEntry.length = %size(stackEntry);
               stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

               entry.length += stackEntry.length;
               entry.offsNext += stackEntry.length;
               entry.numCallStkEnt += 1;
            endfor;

         other; // including:  TEST_CASE_SUCCESS
            entry.lenExcpMessage = 0;
            entry.excpMessage = '';
            entry.specNb = '';
            pexct = %addr(entry.excpMessage) + entry.lenExcpMessage;
            execTime = testResult.execTime;
            entry.length = %size(entry) +
                           entry.lenExcpMessage + %size(execTime);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = 0;
            entry.numCallStkEnt = 0;

         endsl;

         return entry.length;

      /end-free
     P                 E


     P min...
     P                 B
     D                 PI            10i 0
     D   int1                        10i 0 value
     D   int2                        10i 0 value
      /free

         if (int1 < int2);
            return int1;
         else;
            return int2;
         endif;

      /end-free
     P                 E

