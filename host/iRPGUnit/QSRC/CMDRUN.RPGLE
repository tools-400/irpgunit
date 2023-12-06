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

     D isInTestProcToRun...
     D                 pr              n
     D  testProcNm                         const like(ProcNm_t)
     D  testProcsToRun...
     D                                     const likeds(ProcNms_t)

       // Assert that at least one test case has run during execution.
     D assertHasRunAtLeastOneTestCase...
     D                 pr
     D  testProcNm                         const like(ProcNm_t)
     D  result                             likeds(result_t)

       // Format a word with its counter.
       // (e.g., fmtWordWithCnt( 2 : 'apple' ) = '2 apples' )
     D fmtWordWithCnt  pr           256a   varying
     D  cnt                          10i 0 const
     D  word                        256a   const varying

       // Handle a test case error.
     D handleError     pr
     D  testProcNm                         const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)
     D  result                             likeds(result_t)

       // Handle a test case failure.
     D handleFailure   pr
     D  testProcNm                         const like(ProcNm_t)
     D  failure                            const
     D                                     likeds(AssertFailEvtLong_t)
     D  result                             likeds(result_t)

       // Handle a test case success.
     D handleSuccess   pr
     D  testProcNm                         const like(ProcNm_t)
     D  assertionCnt                 10i 0 const

       // Set the starting index and the index step to run the test cases.
     D setTestRunOrder...
     D                 pr
     D  testSuite                          const likeds(TestSuite_t)
     D  order                         8a   const
        // (Output) Starting index.
     D  startIdx                     10i 0
        // (Output) Step from one test index to the next.
     D  step                         10i 0

       // Give a status message to the user.
     D status          pr
     D  testSuiteNm                        const like(Object_t.nm)
     D  testProcNm                         const like(ProcNm_t)

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Test case suite.
     D testSuite       ds                  likeds(TestSuite_t)

       // Completion message.
     D msg             s            256a   varying

       // Error message when writing the XML file.
     D errMsg          s            256a   varying

       // Save/set/restore library list
     D savedLibl       ds                  likeds(LiblData_t)
     D mustRestoreLibl...
     D                 s               n   inz(*OFF)

      // Over all test result.
     D result          ds                  likeds(result_t) inz

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D cmdRun...
     D                 pi
     D  testSuiteName                      const likeds(Object_t)
     D  testProcs                          const likeds(ProcNms_t)
     D  order                              const like(order_t)
     D  detail                             const like(detail_t)
     D  output                             const like(output_t)
     D  libl                               const likeds(LibL_t)
     D  jobd                               const likeds(Object_t)
     D  rclRsc                             const like(rclrsc_t)
     D  xmlStmf                            const like(stmf_t)
      /free

       registerStartPgm(sds.pgmLib: sds.pgmName);

       clear result;
       setLogContext( testSuiteName : detail : output );
       clearAssertCounter();

       // Set library list and load test suite
       monitor;
         savedLibl = getLibl();
         mustRestoreLibl = setTestSuiteLibl(libl: jobd: testSuiteName.lib);
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
           writeXmlFile(resolvePathVariables(xmlStmf: testSuiteName)
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

       if result.failureCnt = 0 and result.errorCnt = 0;
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

      /end-free


       //----------------------------------------------------------------------
       //   Procedures
       //----------------------------------------------------------------------

     P assertHasRunAtLeastOneTestCase...
     P                 b
     D                 pi
     D  testProcNm                         const like(ProcNm_t)
     D  result                             likeds(result_t)

     D excpMsgInfo     ds                  likeds(Msg_t)

      /free

        if result.runsCnt = 0;
          Clear excpMsgInfo;
          excpMsgInfo.id  = '';
          excpMsgInfo.txt = 'Test procedure not found.';
          handleError( testProcNm : excpMsgInfo : result);
        endif;

      /end-free
     P                 e


     P callWithLogging...
     P                 b                   export
     D                 pi            10i 0
     D  proc                               const likeds(Proc_t)
      /free

        monitor;
          callProcByPtr( proc.procPtr );
          return 0;
        on-error;
          handleError( proc.procNm : rcvExcpMsgInfo() : result );
          return -1;
        endmon;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Format a test run completion message. See prototype.
       //----------------------------------------------------------------------
     P fmtCompMsg...
     P                 b                   export
     D                 pi           256a   varying
     D  testCaseCnt                  10i 0 const
     D  assertCnt                    10i 0 const
     D  failureCnt                   10i 0 const
     D  errorCnt                     10i 0 const

     D msg             s            256a   varying

      /free

        select;
          when errorCnt <> 0;
            msg = 'ERROR';
          when failureCnt <> 0;
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

      /end-free
     P                 e


     P fmtObjNm...
     P                 b                   export
     D                 pi            21a   varying
     D  obj                                const likeds(Object_t)
      /free

        return %trimr(obj.lib) + '/' + %trimr(obj.nm);

      /end-free
     P                 e


     P fmtWordWithCnt...
     P                 b
     D                 pi           256a   varying
     D  cnt                          10i 0 const
     D  word                        256a   const varying
      /free

        if cnt < 2;
          return %char(cnt) + ' ' + word;
        else;
          return %char(cnt) + ' ' + word + 's';
        endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Handle a test error event. See prototype.
       //----------------------------------------------------------------------
     P handleError...
     P                 b
     D                 pi
     D  testProcNm                         const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)
     D  result                             likeds(result_t)
      /free

        result.errorCnt += 1;
        logError( testProcNm : excpMsgInfo );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Handle a test failure event. See prototype.
       //----------------------------------------------------------------------
     P handleFailure...
     P                 b
     D                 pi
     D  testProcNm                         const like(ProcNm_t)
     D  failure                            const
     D                                     likeds(AssertFailEvtLong_t)
     D  result                             likeds(result_t)
      /free

        result.failureCnt += 1;
        logFailure( testProcNm : failure );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Handle a test success event. See prototype.
       //----------------------------------------------------------------------
     P handleSuccess...
     P                 b
     D                 pi
     D  testProcNm                         const like(ProcNm_t)
     D  assertionCnt                 10i 0 const
      /free

        logSuccess( testProcNm : assertionCnt );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Set up the test suite. See prototype.
       //----------------------------------------------------------------------
     P setupTestSuite...
     P                 b                   export
     D                 pi             1a
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

     D testResult      ds                  likeds(TestResult_t)
      /free

         // return callWithLogging( testSuite.setUpSuite );
         testResult = initTestResult(testSuite.setUpSuite.procNm);
         testResult = runProc( testSuite.setUpSuite.procPtr : testResult );

         if (testResult.outcome = TEST_CASE_SUCCESS);
           return TEST_CASE_SUCCESS;
         endif;

         list_add(testSuite.testResults : %addr(testResult) :
                  %size(testResult));

         select;
         when testResult.outcome = TEST_CASE_FAILURE;
           handleFailure(
             testSuite.setUpSuite.procNm : testResult.failure : result );
           return TEST_CASE_FAILURE;
         when testResult.outcome = TEST_CASE_ERROR;
           handleError(
             testSuite.setUpSuite.procNm : testResult.error : result );
           return TEST_CASE_ERROR;
         endsl;

      /end-free
     p                 e


       //----------------------------------------------------------------------
       // Tear down the test suite. See prototype.
       //----------------------------------------------------------------------
     P tearDownTestSuite...
     P                 b                   export
     D                 pi             1a
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

     D testResult      ds                  likeds(TestResult_t)
      /free

         //return callWithLogging( testSuite.teardownSuite );
         testResult = initTestResult(testSuite.teardownSuite.procNm);
         testResult = runProc( testSuite.teardownSuite.procPtr : testResult );

         if (testResult.outcome = TEST_CASE_SUCCESS);
           return TEST_CASE_SUCCESS;
         endif;

         list_add(testSuite.testResults : %addr(testResult) :
                  %size(testResult));

         select;
         when testResult.outcome = TEST_CASE_FAILURE;
           handleFailure(
             testSuite.teardownSuite.procNm : testResult.failure : result );
           return TEST_CASE_FAILURE;
         when testResult.outcome = TEST_CASE_ERROR;
           handleError(
             testSuite.teardownSuite.procNm : testResult.error : result );
           return TEST_CASE_ERROR;
         endsl;

      /end-free
     p                 e


       //----------------------------------------------------------------------
       // Run the tests in a test suite. See prototype.
       //----------------------------------------------------------------------
     P runTests...
     P                 b                   export
     D                 pi
     D  result                                   likeds(result_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testProcsToRun...
     D                                     const likeds(ProcNms_t)
     D  order                         8a   const
     D  detail                        6a   const
     D  rclRsc                       10a   const

     D step            s             10i 0
     D testIdx         s             10i 0
     D testProcNm      s                   like(ProcNm_t)
     D testResult      ds                  likeds(TestResult_t)
     D assertionCntBeforeRun...
     D                 s             10i 0
     D assertionCntAfterRun...
     D                 s             10i 0
     D CMD_RCLRSC      c                   'RCLRSC LVL(*) OPTION(*NORMAL)'

      /free

        setTestRunOrder( testSuite : order : testIdx : step );

        dow 1 <= testIdx and testIdx <= testSuite.testCasesCnt;
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

            list_add(testSuite.testResults : %addr(testResult) :
                     %size(testResult));

            if (rclRsc = RCLRSC_ALWAYS);
              QCMDEXC(CMD_RCLRSC: %len(CMD_RCLRSC));
            endif;

            assertionCntAfterRun = getAssertCalled();
            result.assertCnt += (assertionCntAfterRun - assertionCntBeforeRun);
            result.runsCnt += 1;

            select;
              when testResult.outcome= TEST_CASE_SUCCESS;
                handleSuccess(
                    testProcNm : assertionCntAfterRun - assertionCntBeforeRun );
              when testResult.outcome = TEST_CASE_FAILURE;
                handleFailure( testProcNm : testResult.failure : result );
              when testResult.outcome = TEST_CASE_ERROR;
                handleError( testProcNm : testResult.error : result );
            endsl;

          endif;

          testIdx += step;
        enddo;

        assertHasRunAtLeastOneTestCase(testProcsToRun.name(1) :result);

        if (rclRsc = RCLRSC_ALWAYS or rclRsc = RCLRSC_ONCE);
          QCMDEXC(CMD_RCLRSC: %len(CMD_RCLRSC));
        endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns *ON when the array of selected test procedures
       // contains a given name.
       //----------------------------------------------------------------------
     P isInTestProcToRun...
     P                 b
     D                 pi              n
     D  testProcNm                         const like(ProcNm_t)
     D  testProcsToRun...
     D                                     const likeds(ProcNms_t)

     D i               s             10i 0
     D testProc        s                   like(testProcNm)
      /free

          if (testProcsToRun.numE = 1 and testProcsToRun.name(1) = TSTPRC_ALL);
             return *ON;
          endif;

          testProc = uCase(testProcNm);

          for i = 1 to testProcsToRun.numE;
             if (testProc = uCase(testProcsToRun.name(i)));
                return *ON;
             endif;
          endfor;

          return *OFF;

      /end-free
     P                 e


     P setTestRunOrder...
     P                 b
     D                 pi
     D  testSuite                          const likeds(TestSuite_t)
     D  order                         8a   const
     D  startIdx                     10i 0
     D  step                         10i 0

     D firstTestIdx    s             10i 0
     D lastTestIdx     s             10i 0
     D increasingOrder...
     D                 c                   const(1)
     D decreasingOrder...
     D                 c                   const(-1)

      /free

        firstTestIdx = 1;
        lastTestIdx  = testSuite.testCasesCnt;

        if order = ORDER_REVERSE;
          startIdx = lastTestIdx;
          step = decreasingOrder;
        else;
          startIdx = firstTestIdx;
          step = increasingOrder;
        endif;

      /end-free
     P                 e


     P status...
     P                 b
     D                 pi
     D  testSuiteNm                        const like(Object_t.nm)
     D  testProcNm                         const like(ProcNm_t)
      /free

        sndStsMsg( 'Running ' + %trimr(testSuiteNm) + ' - ' + testProcNm );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Check and restore library list.
       //----------------------------------------------------------------------
     P checkAndRestoreLibl...
     P                 b                   export
     D                 pi
     D  mustRestoreLibl...
     D                                 n   const
     D  savedLibl                          const  likeds(LiblData_t)
      /free

          if (mustRestoreLibl);
             restoreLibl(savedLibl);
          endif;

      /end-free
     P                 E

