      //
      // Run tests.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC
      /copy RPGUNITY1,COPYRIGHT

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,RUNNER
      /copy RPGUNITY1,CMDRUNSRV


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,CALLPROC
      /copy RPGUNITY1,EXTPRC
      /copy RPGUNITY1,EXTTST
      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNITY1,LLIST_H


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

      /free

        procList   = loadProcList( srvPgm );
        procNmList = getProcNmList( procList );
        testSuite  = getTestSuite( procNmList );

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

        sndEscapeMsgAboveCtlBdy( 'RPGUnit Error. ' + msg );

      /end-free
     P raiseRUError    e


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

     D failureEvt      ds                  likeds(AssertFailEvtLong_t)
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
