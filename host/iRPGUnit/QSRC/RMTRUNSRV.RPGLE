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
      // User space version number 4. Introduced 09.04.2024.
      // Added message 'receiver' and program library name.
     D VERSION_4       c                   4

      *-------------------------------------------------------------------------
      * Prototypes
      *-------------------------------------------------------------------------

      /include qinclude,RMTRUNSRV
      /include qinclude,ERRORCODE

     D fillUserspace   PR                  extproc('fillUserspace')
     D   userspace                         likeds(Object_t ) const
     D   testSuite                         likeds(testsuite_t) const
     D   testSuiteName...
     D                                     likeds(Object_t) const
     D   result                            likeds(result_t) const

     D createV3TestCase...
     D                 PR            10i 0 extproc('createV2TestCase')
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   ePtr                          *   value

     D createV4TestCase...
     D                 PR            10i 0 extproc('createV4TestCase')
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value

     D min...
     D                 PR            10i 0 extproc('min')
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
      /include qsysinc,MEMCPY
      /include qllist,llist_h

      *-------------------------------------------------------------------------
      * Type Templates
      *-------------------------------------------------------------------------
     D tmpl_testSuite  DS           256    qualified template
     D  length                       10I 0
     D  version                      10I 0
     D  testSuite                          likeds(Object_t)
     D  numRuns                      10I 0
     D  numAsserts                   10I 0
     D  numFailures                  10I 0
     D  numErrors                    10I 0
     D  offsTestCases                10I 0
     D  numTestCases                 10I 0
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
     D tmpl_testCase_v3...
     D                 DS                  qualified template
     D  length                       10I 0
     D  result                        1A
     D  reserved_1                    1A
     D  specNb                       10A
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
      *
     D  tmpl_execTime_v3...
     D                 S             20I 0 template
      *
     D tmpl_callStkEnt_V3...
     D                 DS           354    qualified template
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
     D tmpl_sender_V3...
     D                 DS           308    qualified template
     D  qPgm                               likeds(Object_t)
     D  qMod                               likeds(Object_t)
     D  specNb                       10a
     D  lenProcNm                     5i 0
     D  procNm                      256A
      *
     D tmpl_receiver_V3...
     D                 DS                  likeds(tmpl_sender_V3) template
      *
     D tmpl_testCase_v4...
     D                 DS            50    qualified template
     D  offsNextEntry                10i 0
     D  lenEntry                      5i 0
     D  result                        1a
     D  reserved_1                    1a
     D  numAsserts                   10i 0
     D  execTime                     20i 0
     D  offsTestCaseText...
     D                               10i 0
     D  lenTestCaseText...
     D                                5i 0
     D  offsExcpMsg                  10i 0
     D  lenExcpMsg                    5i 0
     D  offsSndInf                   10i 0
     D  lenSndInf                     5i 0
     D  offsRcvInf                   10i 0
     D  lenRcvInf                     5i 0
     D  offsCallStkE                 10i 0
     D  numCallStkE                   5i 0
      *
     D tmpl_callStkEnt_V4...
     D                 DS            92    qualified template
     D  offsNextEntry                10i 0
     D  lenEntry                      5i 0
     D  qPgm                               likeds(Object_t)
     D  qMod                               likeds(Object_t)
     D  specNb                       10a
     D  offsProcNm                   10i 0
     D  lenProcNm                     5i 0
     D  qSrcMbr                            likeds(SrcMbr_t)
      *
     D tmpl_sender_V4...
     D                 DS            58    qualified template
     D  lenEntry                      5i 0
     D  qPgm                               likeds(Object_t)
     D  qMod                               likeds(Object_t)
     D  specNb                       10a
     D  offsProcNm                   10i 0
     D  lenProcNm                     5i 0
      *
     D tmpl_receiver_V4...
     D                 DS                  likeds(tmpl_sender_V4) template
      *
      /include qinclude,TEMPLATES

      *-------------------------------------------------------------------------
      * Module Status
      *-------------------------------------------------------------------------
     D g_status        DS                  qualified
     D  version                      10i 0 inz(VERSION_4)

      *-------------------------------------------------------------------------
      * Procedures
      *-------------------------------------------------------------------------

      // ==========================================================================
      //  Execute a given unit test suite.
      // ==========================================================================
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

      // ==========================================================================
      //  Fill user space, all versions.
      // ==========================================================================
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
     D testResult      DS                  likeds(TestResult_t) based(ptr)
     D errorCode       DS                  likeds(errorCode_t) inz(*likeds)
     D oldLength       S             10I 0
     D ePtr            S               *
     D testCaseV3      DS                  likeds(tmpl_testCase_v3)
     D                                     based(ePtr)
     D testCaseV4      DS                  likeds(tmpl_testCase_v4)
     D                                     based(ePtr)
      /free

       clear errorCode;
       errorCode.bytPrv = 0;
       api_retrieveUserspacePointer(userspace : usPtr : errorCode);

       splF = getLogSplF();

       header.length = %size(header);
       header.version = g_status.version;
       header.testSuite = testSuiteName;
       header.numRuns = result.runsCnt;
       header.numAsserts = result.assertCnt;
       header.numFailures = result.failureCnt;
       header.numErrors = result.errorCnt;
       header.offsTestCases = %size(header);
       header.numTestCases = testSuite.testCasesCnt;

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

       ePtr = usPtr + header.offsTestCases;

       dow (ptr <> *null);

         header.numTestCasesRtn += 1;

         oldLength = header.length;

         select;
         when g_status.version >= VERSION_4;
           header.length += createV4TestCase(usPtr: testResult: ePtr);
         other;
           header.length += createV3TestCase(usPtr: testResult: ePtr);
         endsl;

         ptr = list_getNext(testSuite.testResults);
         if (ptr <> *null);
           ePtr = eptr - oldLength + header.length;
         endif;

       enddo;

       select;
       when g_status.version >= VERSION_4;
         testCaseV4.offsNextEntry = 0;
       other;
         testCaseV3.offsNext = 0;
       endsl;

      /end-free
     P                 E

      // ==========================================================================
      //  Create user space with version 2 layout.
      // ==========================================================================
     P createV3TestCase...
     P                 B
     D                 PI            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   ePtr                          *   value
      *
     D entry           DS                  likeds(tmpl_testCase_v3)
     D                                     based(ePtr)
     D execTime        S                   like(tmpl_execTime_v3)
     D                                     based(pExct)
      *
     D e               S             10I 0
     D stackEntry      DS                  likeds(tmpl_callStkEnt_V3)
     D                                     based(sptr)
     D failure         DS                  likeds(AssertFailEvtLong_t)
     D                                     based(fPtr)
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
            if (testResult.error.qSndStmt.specNb <> '');
               entry.specNb = testResult.error.qSndStmt.specNb;
            else;
               entry.specNb = '*N';
            endif;
            pExct = %addr(entry.excpMessage) + entry.lenExcpMessage;
            execTime = -1;
            entry.length = %size(entry) +
                           entry.lenExcpMessage + %size(execTime);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = entry.offsNext;
            entry.numCallStkEnt = 0;

            // Add callstack entry of exception message
            sptr = usPtr + entry.offsNext;

            stackEntry.qPgm = testResult.Error.qSndStmt.qPgm;
            stackEntry.qMod = testResult.Error.qSndStmt.qMod;
            stackEntry.specNb = testResult.Error.qSndStmt.specNb;
            stackEntry.procNm = testResult.Error.qSndStmt.procNm;
            stackEntry.lenProcNm = %len(testResult.Error.qSndStmt.procNm);

            stackEntry.length = %size(stackEntry);
            stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

            entry.length += stackEntry.length;
            entry.offsNext += stackEntry.length;
            entry.numCallStkEnt += 1;

         when (testResult.outcome = TEST_CASE_FAILURE);
            fPtr = %addr(testResult.failure);
            entry.lenExcpMessage =
               min(%len(testResult.failure.msg): %len(entry.excpMessage));
            entry.excpMessage = testResult.failure.msg;
            entry.specNb =
                  failure.callStk.entry(1).qStmt.specNb;

            pExct = %addr(entry.excpMessage) + entry.lenExcpMessage;
            execTime = -1;
            entry.length = %size(entry) +
                           entry.lenExcpMessage + %size(execTime);
            entry.offsNext = (%addr(entry) - usPtr) + entry.length;
            entry.offsCallStkEnt = entry.offsNext;

            for e = 1 to failure.callStk.numE;

               entry.numCallStkEnt += 1;

               sptr = usPtr + entry.offsNext;

               stackEntry.qPgm = failure.callStk.entry(e).qStmt.qPgm;
               stackEntry.qMod = failure.callStk.entry(e).qStmt.qMod;
               stackEntry.lenProcNm =
                              %len(failure.callStk.entry(e).qStmt.procNm);
               stackEntry.procNm = failure.callStk.entry(e).qStmt.procNm;
               stackEntry.specNb = failure.callStk.entry(e).qStmt.specNb;

               stackEntry.qSrcMbr = SrcMbr_getModSrc(
                                          stackEntry.qPgm: stackEntry.qMod);

               stackEntry.length = %size(stackEntry);
               stackEntry.offsNext = (sptr - usPtr) + stackEntry.length;

               entry.length += stackEntry.length;
               entry.offsNext += stackEntry.length;

               if (e = failure.callStk.numE);
                 stackEntry.offsNext = 0;
               endif;
            endfor;

         other; // including:  TEST_CASE_SUCCESS
            entry.lenExcpMessage = 0;
            entry.excpMessage = '';
            entry.specNb = '';
            pExct = %addr(entry.excpMessage) + entry.lenExcpMessage;
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

      // ==========================================================================
      //  Create user space with version 4 layout.
      // ==========================================================================
     P createV4TestCase...
     P                 B
     D                 PI            10i 0
     D   usPtr                         *   value
     D   testResult                        value likeds(TestResult_t)
     D   eptr                          *   value
      *
     D offsEntry       S             10i 0
     D entry           DS                  likeds(tmpl_testCase_v4)
     D                                     based(ePtr)
      *
     D e               S             10i 0
     D stackEntry      DS                  likeds(tmpl_callStkEnt_V4)
     D                                     based(sPtr)
     D sender          DS                  likeds(tmpl_sender_V4)
     D                                     based(pSender)
     D receiver        DS                  likeds(tmpl_receiver_V4)
     D                                     based(pReceiver)
      /free

         offsEntry = eptr - usPtr;

         clear entry;
         entry.offsNextEntry = offsEntry + %size(entry);
         entry.lenEntry = %size(entry);

         entry.result = testResult.outcome;
         entry.reserved_1 = '';
         entry.numAsserts = testResult.assertCnt;
         entry.execTime = testResult.execTime;

         // Test case text:
         entry.offsTestCaseText = offsEntry + %size(entry);
         entry.lenTestCaseText = %len(testResult.testName);
         memcpy(usPtr + entry.offsTestCaseText
                : %addr(testResult.testName: *data)
                : entry.lenTestCaseText);
         entry.offsNextEntry += entry.lenTestCaseText;
         entry.lenEntry += entry.lenTestCaseText;

         // Exception message:
         entry.offsExcpMsg = entry.offsTestCaseText + entry.lenTestCaseText;


         select;
         when (testResult.outcome = TEST_CASE_ERROR);

            // Exception message:
            entry.lenExcpMsg = %len(testResult.error.txt);
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
            sender.qPgm = testResult.error.qSndStmt.qPgm;
            sender.qMod = testResult.error.qSndStmt.qMod;
            sender.specNb = testResult.error.qSndStmt.specNb;
            sender.offsProcNm = entry.offsSndInf + %size(sender);
            sender.lenProcNm = %len(testResult.error.qSndStmt.procNm);
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
            receiver.qPgm = testResult.error.qRcvStmt.qPgm;
            receiver.qMod = testResult.error.qRcvStmt.qMod;
            receiver.specNb = testResult.error.qRcvStmt.specNb;
            receiver.offsProcNm = entry.offsRcvInf + %size(receiver);
            receiver.lenProcNm = %len(testResult.error.qRcvStmt.procNm);
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

         when (testResult.outcome = TEST_CASE_FAILURE);

            // Failure message:
            entry.lenExcpMsg = %len(testResult.failure.msg);
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

            for e = 1 to testResult.failure.callStk.numE;

               entry.numCallStkE += 1;

               clear stackEntry;

               stackEntry.offsNextEntry = (sPtr - usPtr) + %size(stackEntry);
               stackEntry.lenEntry = %size(stackEntry);

               stackEntry.qPgm = testResult.failure.callStk.entry(e).qStmt.qPgm;
               stackEntry.qMod = testResult.failure.callStk.entry(e).qStmt.qMod;
               stackEntry.specNb =
                         testResult.failure.callStk.entry(e).qStmt.specNb;

               stackEntry.qSrcMbr = SrcMbr_getModSrc(
                                          stackEntry.qPgm: stackEntry.qMod);

               stackEntry.offsProcNm = (sPtr - usPtr) + stackEntry.lenEntry;
               stackEntry.lenProcNm =
                         %len(testResult.failure.callStk.entry(e).qStmt.procNm);
               memcpy(
                 usPtr + stackEntry.offsProcNm
                 : %addr(testResult.failure.callStk.entry(e).qStmt.procNm:*data)
                 : stackEntry.lenProcNm);
               stackEntry.offsNextEntry += stackEntry.lenProcNm;
               stackEntry.lenEntry += stackEntry.lenProcNm;

               entry.lenEntry += stackEntry.lenEntry;
               entry.offsNextEntry += stackEntry.lenEntry;

               if (e = testResult.failure.callStk.numE);
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

      /end-free
     P                 E

      // ==========================================================================
      //  Returns the minimum of two integer values.
      // ==========================================================================
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

