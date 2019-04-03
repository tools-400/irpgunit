      // =====================================================================
      //
      // Tests RUN.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKRUNT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKRUNT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,RUNNER
      /copy RPGUNITY1,CMDRUNSRV
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite      pr
     D setup           pr

     D test_runTestProc_successfulTest...
     D                 pr
     D test_runTestProc_failureInTest...
     D                 pr
     D test_runTestProc_errorInTest...
     D                 pr
     D test_runTestProc_withSetup...
     D                 pr
     D test_runTestProc_errorInSetup...
     D                 pr
     D test_runTestProc_withTearDown...
     D                 pr
     D test_runTestProc_errorInTearDown...
     D                 pr
     D test_runTestProc_tearDownAfterFailureInTest...
     D                 pr
     D test_runTestProc_tearDownAfterErrorInSetup...
     D                 pr
     D test_loadTestSuite...
     D                 pr
     D test_runTest_successfulTest...
     D                 pr
     D test_runTest_failureInTest...
     D                 pr
     D test_runTest_withSetupAndTearDown...
     D                 pr
     D test_rclTestSuite_blankTestSuite...
     D                 pr
     D test_rclTestSuite...
     D                 pr
     D test_rclTestSuite_withTearDownSuite...
     D                 pr


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D raiseError      pr
     D setup_proc      pr
     D setup_with_error...
     D                 pr
     D teardown_proc   pr
     D teardown_with_error...
     D                 pr
     D tearDownSuite_success...
     D                 pr
     D test_error      pr
     D test_fail       pr
     D test_proc       pr
     D traceCall       pr
     D  procNm                       64a   const varying


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

     D noSetUp         ds                  likeds(Proc_t) inz
     D noTearDown      ds                  likeds(Proc_t) inz


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D pgmStatusDS    sds                  qualified
     D  lib                          10a   Overlay(pgmStatusDS:81)
     D  pgmNm                        10a   Overlay(pgmStatusDS:334)

       // Execution trace (and its current index).
     D execTrace       s            256a   Dim(64)
     D execTraceIdx    s             10i 0
       // Test procedure to call.
     D testProc        ds                  likeds(Proc_t)
       // Setup proc.
     D setupProc       ds                  likeds(Proc_t)
       // Tear down proc.
     D tearDownProc    ds                  likeds(Proc_t)
       // Result of a test case run.
     D result          ds                  likeds(TestResult_t)

     D setUpSuiteWasCalled...
     D                 s               n


      //----------------------------------------------------------------------
      //   Test Definitions
      //----------------------------------------------------------------------

     P setUpSuite      b                   export
     D setUpSuite      pi
      /free

        // Used by test_loadTestSuite...

        setUpSuiteWasCalled = *on;

      /end-free
     P                 e


     P setUp           b                   export
     D setUp           pi
      /free

        // Clear global variables.

        clear execTrace;
        execTraceIdx = 1;
        clear result;
        clear setUpSuiteWasCalled;
        clear testProc;

      /end-free
     P                 e


     P test_runTestProc_successfulTest...
     P                 b                   export
     D test_runTestProc_successfulTest...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_proc );
        testProc.procNm = 'test_proc';
        result = runTestProc( testProc : noSetUp : noTearDown );

        // Controls.

        aEqual( 'test_proc was called' : execTrace(1) );
        aEqual( TEST_CASE_SUCCESS : result.outcome );

      /end-free
     P                 e


     P test_runTestProc_failureInTest...
     P                 b                   export
     D test_runTestProc_failureInTest...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_fail );
        testProc.procNm = 'test_fail';
        result = runTestProc( testProc : noSetUp : noTearDown );

        // Controls.

        aEqual( 'test_fail was called' : execTrace(1) );
        aEqual( TEST_CASE_FAILURE : result.outcome );
        aEqual( 'My Failure Message' : result.failure.msg );
        // New, due to new procedure doFail():
        aEqual( 'fail' : result.failure.callStk.entry(1).sender.procNm );
        aEqual( 'TEST_FAIL' : result.failure.callStk.entry(2).sender.procNm );

      /end-free
     P                 e


     P test_runTestProc_errorInTest...
     P                 b                   export
     D test_runTestProc_errorInTest...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_error );
        testProc.procNm = 'test_error';
        result = runTestProc( testProc : noSetUp : noTearDown );

        // Controls.

        aEqual( 'test_error was called' : execTrace(1) );
        aEqual( TEST_CASE_ERROR : result.outcome );
        aEqual( 'RAISEERROR' : result.error.sender.procNm );

      /end-free
     P                 e


     P test_runTestProc_withSetup...
     P                 b                   export
     D test_runTestProc_withSetup...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_proc );
        testProc.procNm = 'test_proc';

        setupProc.procPtr = %paddr( setup_proc );
        setupProc.procNm = 'setup_proc';

        result = runTestProc( testProc :
                              setupProc :
                              noTearDown );

        // Controls.

        aEqual( 'setup_proc was called' : execTrace(1) );
        aEqual( 'test_proc was called'  : execTrace(2) );
        aEqual( TEST_CASE_SUCCESS : result.outcome );

      /end-free
     P                 e


     P test_runTestProc_errorInSetup...
     P                 b                   export
     D test_runTestProc_errorInSetup...
     D                 pi
      /free

        // Execution.

        monitor;

          testProc.procPtr = %paddr( test_proc );
          testProc.procNm = 'test_proc';

          setupProc.procPtr = %paddr( setup_with_error );
          setupProc.procNm = 'setup_with_error';

          result = runTestProc( testProc :
                                setupProc :
                                noTearDown );
        on-error;
          fail( 'runTestProc should not raise an error' );
        endmon;

        // Controls.

        aEqual( 'setup_with_error was called' : execTrace(1) );
        aEqual( *blank                        : execTrace(2) );    // test_proc not called.
        aEqual( TEST_CASE_ERROR : result.outcome );
        aEqual( 'RAISEERROR' : result.error.sender.procNm );

      /end-free
     P                 e


     P test_runTestProc_withTearDown...
     P                 b                   export
     D test_runTestProc_withTearDown...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_proc );
        testProc.procNm = 'test_proc';

        tearDownProc.procPtr = %paddr( teardown_proc );
        tearDownProc.procNm = 'teardown_proc';

        result = runTestProc( testProc :
                              noSetUp :
                              tearDownProc );

        // Controls.

        aEqual( 'test_proc was called'     : execTrace(1) );
        aEqual( 'teardown_proc was called' : execTrace(2) );
        aEqual( TEST_CASE_SUCCESS : result.outcome );

      /end-free
     P                 e


     P test_runTestProc_errorInTearDown...
     P                 b                   export
     D test_runTestProc_errorInTearDown...
     D                 pi
      /free

        // Execution.

        monitor;

        testProc.procPtr = %paddr( test_proc );
        testProc.procNm = 'test_proc';

        tearDownProc.procPtr = %paddr( teardown_with_error );
        tearDownProc.procNm = 'teardown_with_error';

          result = runTestProc( testProc :
                                noSetUp :
                                tearDownProc );
        on-error;
          fail( 'runTestProc should not raise an error' );
        endmon;

        // Controls.

        aEqual( 'test_proc was called'           : execTrace(1) );
        aEqual( 'teardown_with_error was called' : execTrace(2) );
        aEqual( TEST_CASE_ERROR : result.outcome );
        aEqual( 'RAISEERROR' : result.error.sender.procNm );

      /end-free
     P                 e


     P test_runTestProc_tearDownAfterFailureInTest...
     P                 b                   export
     D test_runTestProc_tearDownAfterFailureInTest...
     D                 pi
      /free

        // Execution.

        testProc.procPtr = %paddr( test_fail );
        testProc.procNm = 'test_fail';

        tearDownProc.procPtr = %paddr( teardown_proc );
        tearDownProc.procNm = 'teardown_proc';

        result = runTestProc( testProc :
                              noSetUp :
                              tearDownProc );

        // Controls.

        aEqual( 'test_fail was called'     : execTrace(1) );
        aEqual( 'teardown_proc was called' : execTrace(2) );
        aEqual( TEST_CASE_FAILURE : result.outcome );

      /end-free
     P                 e


     P test_runTestProc_tearDownAfterErrorInSetup...
     P                 b                   export
     D test_runTestProc_tearDownAfterErrorInSetup...
     D                 pi
      /free

        // Execution.

        monitor;

        testProc.procPtr = %paddr( test_proc );
        testProc.procNm = 'test_proc';

        setupProc.procPtr = %paddr( setup_with_error );
        setupProc.procNm = 'setup_with_error';

        tearDownProc.procPtr = %paddr( teardown_proc );
        tearDownProc.procNm = 'teardown_proc';

          result = runTestProc( testProc :
                                setupProc :
                                tearDownProc    );
        on-error;
          fail( 'runTestProc should not raise an error' );
        endmon;

        // Controls.

        aEqual( 'setup_with_error was called' : execTrace(1) );
        // test_proc not called.
        aEqual( 'teardown_proc was called'    : execTrace(2) );
        aEqual( TEST_CASE_ERROR : result.outcome );
        aEqual( 'RAISEERROR' : result.error.sender.procNm );

      /end-free
     P                 e


     P test_loadTestSuite...
     P                 b                   export
     D test_loadTestSuite...
     D                 pi

     D srvPgm          ds                  likeds(Object_t)
     D testSuite       ds                  likeds(TestSuite_t)

      /free

        // Setup.

        setUpSuiteWasCalled = *off;
        srvPgm.nm  = pgmStatusDS.pgmNm;
        srvPgm.lib = pgmStatusDS.lib;

        // Execution.

        testSuite = loadTestSuite( srvPgm );

        // Controls.

        assert( setUpSuiteWasCalled = *off :
                'setUpSuite called by loadTestSuite' );
        aEqual( 'SETUPSUITE' : testSuite.setUpSuite.procNm );
        assert( %paddr(setUpSuite) = testSuite.setUpSuite.procPtr :
                'Wrong SetUpSuite procedure pointer' );
        aEqual( 'SETUP' : testSuite.setUp.procNm );
        assert( %paddr(setUp) = testSuite.setUp.procPtr :
                'Wrong SetUp procedure pointer' );

      /end-free
     P                 e


     P test_runTest_successfulTest...
     P                 b                   export
     D test_runTest_successfulTest...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)
     D testCase        ds                  Dim(1) likeds(Proc_t)
     D testResult      ds                  likeds(TestResult_t)

      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testSuite.testList = %addr( testCase );
        testCase(1).procNm  =        'test_proc' ;
        testCase(1).procPtr = %paddr( test_proc );

        // Execution.

        testResult = runTest( testSuite : 1 );

        // Controls.

        aEqual( TEST_CASE_SUCCESS : testResult.outcome );

      /end-free
     P                 e


     P test_runTest_failureInTest...
     P                 b                   export
     D test_runTest_failureInTest...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)
     D testCase        ds                  Dim(1) likeds(Proc_t)
     D testResult      ds                  likeds(TestResult_t)
      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testSuite.testList = %addr( testCase );
        testCase(1).procNm  =        'test_fail' ;
        testCase(1).procPtr = %paddr( test_fail );

        // Execution.

        testResult = runTest( testSuite : 1 );

        // Controls.

        aEqual( TEST_CASE_FAILURE : testResult.outcome );

      /end-free
     P                 e


     P test_runTest_withSetupAndTearDown...
     P                 b                   export
     D test_runTest_withSetupAndTearDown...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)
     D testCase        ds                  Dim(1) likeds(Proc_t)
      /free

        // Setup.

        testSuite.setUp.procNm  =        'setup_proc';
        testSuite.setUp.procPtr = %paddr( setup_proc );

        testSuite.testCasesCnt = 1;
        testSuite.testList = %addr( testCase );
        testCase(1).procNm  =        'test_proc' ;
        testCase(1).procPtr = %paddr( test_proc );

        testSuite.tearDown.procNm  =        'teardown_proc' ;
        testSuite.tearDown.procPtr = %paddr( teardown_proc );

        // Execution.

        runTest( testSuite : 1 );

        // Controls.

        aEqual( 'setup_proc was called'    : execTrace(1) );
        aEqual( 'test_proc was called'     : execTrace(2) );
        aEqual( 'teardown_proc was called' : execTrace(3) );

      /end-free
     P                 e


     P test_rclTestSuite_blankTestSuite...
     P                 b                   export
     D test_rclTestSuite_blankTestSuite...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)

      /free

        clear testSuite;

        monitor;
          rclTestSuite( testSuite );
        on-error;
          fail( 'rclTestSuite should tolerate a blank test suite' );
        endmon;

      /end-free
     P                 e


     P test_rclTestSuite...
     P                 b                   export
     D test_rclTestSuite...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)

      /free

        clear testSuite;
        testSuite.testList = %alloc(10);

        rclTestSuite( testSuite );

        assert( testSuite.testList = *null : 'Test list not deallocated' );

      /end-free
     P                 e


     P test_rclTestSuite_withTearDownSuite...
     P                 b                   export
     D test_rclTestSuite_withTearDownSuite...
     D                 pi

     D testSuite       ds                  likeds(TestSuite_t)

      /free

        clear testSuite;
        testSuite.tearDownSuite.procPtr = %paddr( tearDownSuite_success );

        rclTestSuite( testSuite );

        assert( *blank = execTrace(1) :
                'Should not have called tearDownSuite' );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Support Procedure Definitions
      //----------------------------------------------------------------------

     P raiseError      b
     D raiseError      pi

     D zero            s             10i 0 inz(0)

      /free

        zero = 1 / zero;

      /end-free
     P                 e


     P setup_proc      b
     D setup_proc      pi
      /free

        traceCall( 'setup_proc' );

      /end-free
     P                 e


     P setup_with_error...
     P                 b
     D setup_with_error...
     D                 pi

     D x               s             10i 0 inz(0)
      /free

        traceCall( 'setup_with_error' );
        raiseError();

      /end-free
     P                 e


     P teardown_proc   b
     D teardown_proc   pi
      /free

        traceCall( 'teardown_proc' );

      /end-free
     P                 e


     P teardown_with_error...
     P                 b
     D teardown_with_error...
     D                 pi

     D x               s             10i 0 inz(0)
      /free

        traceCall( 'teardown_with_error' );
        raiseError();

      /end-free
     P                 e


     P tearDownSuite_success...
     P                 b
     D tearDownSuite_success...
     D                 pi
      /free

        traceCall( 'tearDownSuite_success' );

      /end-free
     P                 e


     P test_error      b
     D test_error      pi

     D x               s             10i 0 inz(0)
      /free

        traceCall( 'test_error' );
        raiseError();

      /end-free
     P                 e


     P test_fail       b
     D test_fail       pi
      /free

        traceCall( 'test_fail' );
        fail( 'My Failure Message' );

      /end-free
     P                 e


     P test_proc       b
     D test_proc       pi
      /free

        traceCall( 'test_proc' );

      /end-free
     P                 e

     P traceCall       b
     D traceCall       pi
     D  procNm                       64a   const varying
      /free

        execTrace(execTraceIdx) = procNm + ' was called';
        execTraceIdx += 1;

      /end-free
     P                 e

