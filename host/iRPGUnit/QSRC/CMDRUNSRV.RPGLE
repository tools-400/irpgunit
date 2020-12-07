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

     H NoMain
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
      /include qinclude,EXTPRC
      /include qinclude,EXTTST
      /include qinclude,OBJECT
      /include qinclude,PGMMSG
      /include qinclude,TEMPLATES
      /include qinclude,TESTUTILS
      /include qllist,llist_h


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       // Load a test suite. See prototype.
       //----------------------------------------------------------------------
     P loadTestSuite...
     P                 b                   export
     D                 pi                  likeds(TestSuite_t)
     D  srvPgm                             const likeds(Object_t)

     D procList        ds                  likeds(ProcList_t)
     D procNmList      ds                  likeds(ProcNmList_t)
     D testSuite       ds                  likeds(TestSuite_t)
     D actMark         s                   like(ActMark_t)

     D extObjAttr      s             10a
      /free

        procList   = loadProcList( srvPgm );
        procNmList = getProcNmList( procList );
        testSuite  = getTestSuite( procNmList );
        testSuite.qName = srvPgm;

        extObjAttr = Object_getAttribute( srvPgm : '*SRVPGM' );
        if (extObjAttr = 'CBLLE' or extObjAttr = 'SQLCBLLE');
          testSuite.isCobol = *on;
        else;
          testSuite.isCobol = *off;
        endif;

        actMark = activateSrvPgm( srvPgm );
        activateTestSuite( testSuite : actMark );

        return testSuite;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Raise an RPGUnit error. See prototype.
       //----------------------------------------------------------------------
     P raiseRUError...
     P                 b                   export
     D                 pi
     D  msg                         256a   const varying
      /free

        monitor;
          logRuntimeError( 'Runtime error: ' + msg );
        on-error;
          // ignore errors
        endmon;

        sndEscapeMsgAboveCtlBdy( 'RPGUnit Error. ' + msg );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Reclaim a test suite's allocated ressources. See prototype.
       //----------------------------------------------------------------------
     P rclTestSuite...
     P                 b                   export
     D                 pi
     D  testSuite                          likeds(TestSuite_t)
      /free

        dealloc(n) testSuite.testList;
        list_dispose(testSuite.testResults);

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Run a test case in a test suite. See prototype.
       //----------------------------------------------------------------------
     P runTest...
     P                 b                   export
     D                 pi                  likeds(TestResult_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D testCase        ds                  likeds(Proc_t)

      /free

        testCase = getTestProc( testSuite : testIdx );

        return runTestProc( testCase :
                            testSuite.setUp :
                            testSuite.tearDown );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Run a test case. See prototype.
       //----------------------------------------------------------------------
     P runTestProc...
     P                 b                   export
     D                 pi                  likeds(TestResult_t)
     D  testCase                           const likeds(Proc_t)
     D  setUp                              const likeds(Proc_t)
     D  tearDown                           const likeds(Proc_t)

     D testResult      ds                  likeds(TestResult_t)
     D startTime       s               z
     D endTime         s               z
      /free

        testResult = initTestResult(testCase.procNm);

        startTime = %timestamp();

        if setUp.procPtr <> *null;
          runProc(setUp.procPtr: testResult);
        endif;

        if testResult.outcome = TEST_CASE_SUCCESS;
          runProc(testCase.procPtr: testResult);
        endif;

        if tearDown.procPtr <> *null;
          runProc(tearDown.procPtr: testResult);
        endif;

        endTime = %timeStamp();

        if (startTime < endTime);
           testResult.execTime = %diff(endTime: startTime: *MSECONDS);
        endif;

        return testResult;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Run a setup, teardown or test procedure. See prototype.
       //----------------------------------------------------------------------
     P runProc...
     P                 b                   export
     D                 pi                  likeds(TestResult_t)
     D  proc                           *   const procptr
     D  result                             likeds(TestResult_t)

     D failureEvt      ds                  likeds(AssertFailEvtLong_t)
     D assertCnt       s             10i 0
      /free

        clrAssertFailEvt();
        assertCnt = getAssertCalled() * -1;

        monitor;
          setLowMessageKey(getHighestMsgKey());
          callProcByPtr( proc );
        on-error;
          if result.outcome = TEST_CASE_SUCCESS;
            failureEvt = getAssertFailEvtLong();
            if failureEvt = EMPTY_ASSERT_FAIL_EVT_LONG;
              result.outcome = TEST_CASE_ERROR;
              result.error = rcvExcpMsgInfo();
            else;
              result.outcome = TEST_CASE_FAILURE;
              result.failure = failureEvt;
            endif;
          endif;
        endmon;

        assertCnt += getAssertCalled();
        result.assertCnt += assertCnt;

        return result;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Run a test case. See prototype.
       //----------------------------------------------------------------------
     P initTestResult...
     P                 b                   export
     D                 pi                  likeds(TestResult_t)
     D  testName                           const like(ProcNm_t)

     D result          ds                  likeds(TestResult_t)
      /free

        clear result;
        result.execTime = 0;
        result.outcome = TEST_CASE_SUCCESS;
        result.testName = testName;

        return result;

      /end-free
     P                 e
