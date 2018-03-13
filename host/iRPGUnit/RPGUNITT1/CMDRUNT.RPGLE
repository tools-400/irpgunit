      // =====================================================================
      //
      // Tests CMDRUN.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKCMDRUNT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKCMDRUNT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      // This module mocks the CMDRUNLOG procedures.
      /copy RPGUNITY1,CMDRUNLOG

      /copy RPGUNITY1,CMDRUN
      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,LLIST_H


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUp           pr                  extproc('setUp')

     D tearDown        pr                  extproc('tearDown')

       // Test runTests with a one-test test suite, with DETAIL(*BASIC) option.
     D test_runTests_SuccessfulTestWithDetailBasic...
     D                 pr                  extproc('test_runTests_SuccessfulTes+
     D                                     tWithDetailBasic')
       // Test runTests with a one-test test suite, with DETAIL(*ALL) option.
     D test_runTests_SuccessfulTestWithDetailAllAndOneAssertion...
     D                 pr                  extproc('test_runTests_SuccessfulTes+
     D                                     tWithDetailAllAndOneAssertion')
     D test_runTests_SuccessfulTestWithDetailAllAndTwoAssertions...
     D                 pr                  extproc('test_runTests_SuccessfulTes+
     D                                     tWithDetailAllAndTwoAssertions')
       // Test runTests with a two-test test suite, with DETAIL(*ALL) option.
     D test_runTests_TwoSuccessfulTestsWithDetailAll...
     D                 pr                  extproc('test_runTests_TwoSuccessful+
     D                                     TestsWithDetailAll')
       // Test runTests with a two-test test suite, with ORDER(*REVERSE) option.
     D test_runTests_TwoSuccessfulTestsWithOrderReverse...
     D                 pr                  extproc('test_runTests_TwoSuccessful+
     D                                     TestsWithOrderReverse')
       // Test runTests with TSTPRC option.
     D test_runTests_ChooseOneTestProc...
     D                 pr                  extproc('test_runTests_ChooseOneTest+
     D                                     Proc')
       // Test runTests, choosing a non existing TSTPRC option.
     D test_runTests_ChooseNonExistingTestProc...
     D                 pr                  extproc('test_runTests_ChooseNonExis+
     D                                     tingTestProc')
       // Test fmtObjNm.
     D test_fmtObjNm   pr                  extproc('test_fmtObjNm')
       // Test callWithLogging when the call is successful.
     D test_callWithLogging_withSuccess...
     D                 pr                  extproc('test_callWithLogging_withSu+
     D                                     ccess')
       // Test callWithLogging when the call raises an error.
     D test_callWithLogging_withError...
     D                 pr                  extproc('test_callWithLogging_withEr+
     D                                     ror')
       // Test fmtCompMsg.
     D test_fmtCompMsg...
     D                 pr                  extproc('test_fmtCompMsg')


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D successful_test_1...
     D                 pr                  extproc('successful_test_1')
     D successful_test_2...
     D                 pr                  extproc('successful_test_2')
     D successful_test_with_one_assertion...
     D                 pr                  extproc('successful_test_with_one_as+
     D                                     sertion')
     D successful_test_with_two_assertions...
     D                 pr                  extproc('successful_test_with_two_as+
     D                                     sertions')
     D proc_with_no_error...
     D                 pr                  extproc('proc_with_no_error')
     D proc_with_error...
     D                 pr                  extproc('proc_with_error')


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // TSTPRC option.
     D ALL_PROCS       c                   const('*ALL')

       // Dummy test program name.
     D testPgm         c                   const('MYTSTPGM')


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // In-memory log spool, made of an array and its index.
     D logLine         ds                  qualified Dim(2)
     D  type                               like(TestResult_t.outcome)
     D  procNm                             like(ProcNm_t)
     D  assertionCnt                 10i 0
     D  msg                                like(Msg_t.txt)
     D logIdx          s             10i 0

       // An array of test cases, for testing purpose.
     D testCase        ds                  Dim(2) likeds(Proc_t)
       // A test suite, for testing purpose.
     D testSuite       ds                  likeds(TestSuite_t)
       // Procedures to run
     D procNms         ds                  likeds(ProcNms_t)
       // Test result
     D result          ds                  likeds(result_t)

       // Spying flag.
     D procWithNoErrorWasCalled...
     D                 s               n


      //----------------------------------------------------------------------
      //   Test Definitions
      //----------------------------------------------------------------------

     P setUp           b                   export
     D setUp           pi
      /free

        clear logIdx;
        clear logLine;

        clear testCase;
        clear testSuite;
        testSuite.testList = %addr(testCase);
        testSuite.testResults = list_create();

        clear procWithNoErrorWasCalled;
        clear procNms;
        clear result;

      /end-free
     P                 e

     P tearDown        b                   export
     D tearDown        pi
      /free

        list_dispose(testSuite.testResults);

      /end-free
     P                 e


     P test_runTests_SuccessfulTestWithDetailBasic...
     P                 b                   export
     D test_runTests_SuccessfulTestWithDetailBasic...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testCase(1).procNm = 'successful_test_1';
        procNms.numE = 1;
        procNms.name(1) = ALL_PROCS;

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_BASIC : RCLRSC_NO);

        // Controls.

        // iEqual( 0 : logIdx );
        iEqual( 1 : logIdx );   // logIdx is 1, because now handleSuccess() is
                                // called by runTests() regardless of the value
                                // of 'detail'.

      /end-free
     P                 e


     P test_runTests_SuccessfulTestWithDetailAllAndOneAssertion...
     P                 b                   export
     D test_runTests_SuccessfulTestWithDetailAllAndOneAssertion...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testCase(1).procNm = 'successful_test_with_one_assertion';
        testCase(1).procPtr = %paddr(successful_test_with_one_assertion);
        procNms.numE = 1;
        procNms.name(1) = ALL_PROCS;

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_ALL : RCLRSC_NO);


        // Controls.

        iEqual( 1 : logIdx );
        aEqual( TEST_CASE_SUCCESS : logLine(1).type );
        aEqual( 'successful_test_with_one_assertion' : logLine(1).procNm );
        iEqual( 1 : logLine(1).assertionCnt );

      /end-free
     P                 e


     P test_runTests_SuccessfulTestWithDetailAllAndTwoAssertions...
     P                 b                   export
     D test_runTests_SuccessfulTestWithDetailAllAndTwoAssertions...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testCase(1).procNm = 'successful_test_with_two_assertions';
        testCase(1).procPtr = %paddr(successful_test_with_two_assertions);
        procNms.numE = 1;
        procNms.name(1) = ALL_PROCS;

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_ALL : RCLRSC_NO);

        // Controls.

        iEqual( 1 : logIdx );
        aEqual( 'successful_test_with_two_assertions' : logLine(1).procNm );
        iEqual( 2 : logLine(1).assertionCnt );

      /end-free
     P                 e


     P test_runTests_TwoSuccessfulTestsWithDetailAll...
     P                 b                   export
     D test_runTests_TwoSuccessfulTestsWithDetailAll...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 2;
        testCase(1).procNm = 'successful_test_1';
        testCase(2).procNm = 'successful_test_2';
        procNms.numE = 1;
        procNms.name(1) = ALL_PROCS;

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_ALL : RCLRSC_NO);

        // Controls.

        iEqual( 2 : logIdx );
        aEqual( 'successful_test_1' : logLine(1).procNm );
        aEqual( 'successful_test_2' : logLine(2).procNm );

      /end-free
     P                 e


     P test_runTests_TwoSuccessfulTestsWithOrderReverse...
     P                 b                   export
     D test_runTests_TwoSuccessfulTestsWithOrderReverse...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 2;
        testCase(1).procNm = 'successful_test_1';
        testCase(2).procNm = 'successful_test_2';
        procNms.numE = 1;
        procNms.name(1) = ALL_PROCS;

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_REVERSE : DETAIL_ALL : RCLRSC_NO);

        // Controls.

        iEqual( 2 : logIdx );
        aEqual( 'successful_test_2' : logLine(1).procNm );
        aEqual( 'successful_test_1' : logLine(2).procNm );

      /end-free
     P                 e


     P test_runTests_ChooseOneTestProc...
     P                 b                   export
     D test_runTests_ChooseOneTestProc...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 2;
        testCase(1).procNm = 'successful_test_1';
        testCase(2).procNm = 'successful_test_2';
        procNms.numE = 1;
        procNms.name(1) = 'successful_test_2';

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_ALL : RCLRSC_NO );

        // Controls.

        iEqual( 1 : logIdx );
        aEqual( 'successful_test_2' : logLine(1).procNm );

      /end-free
     P                 e


     P test_runTests_ChooseNonExistingTestProc...
     P                 b                   export
     D test_runTests_ChooseNonExistingTestProc...
     D                 pi
      /free

        // Setup.

        testSuite.testCasesCnt = 1;
        testCase(1).procNm = 'test_1';
        procNms.numE = 1;
        procNms.name(1) = 'test_2';

        // Execution.

        runTests( result : testPgm : testSuite : procNms :
                  ORDER_API : DETAIL_ALL : RCLrSC_NO );

        // Controls.

        iEqual( 1 : logIdx );
        aEqual( 'test_2' : logLine(1).procNm );
        aEqual( TEST_CASE_ERROR : logLine(1).type );
        aEqual( 'Test procedure not found.' : logLine(1).msg );

      /end-free
     P                 e


     P test_fmtObjNm   b                   export
     D test_fmtObjNm   pi

     D object          ds                  likeds(Object_t)

      /free

        object.nm  = 'MYOBJ';
        object.lib = 'MYLIB';

        aEqual( 'MYLIB/MYOBJ' : fmtObjNm( object ) );
        iEqual( %len( 'MYLIB/MYOBJ' ) : %len( fmtObjNm( object ) ) );

      /end-free
     P                 e


     P test_callWithLogging_withSuccess...
     P                 b                   export
     D test_callWithLogging_withSuccess...
     D                 pi

     D procWithNoError...
     D                 ds                  likeds(Proc_t)

      /free

        procWithNoError.procNm  =        'proc_with_no_error';
        procWithNoError.procPtr = %paddr( proc_with_no_error );

        callWithLogging( procWithNoError );

        assert( procWithNoErrorWasCalled : 'proc_with_no_error not called' );
        iEqual( 0 : logIdx );    // No logging if success.

      /end-free
     P                 e


     P test_callWithLogging_withError...
     P                 b                   export
     D test_callWithLogging_withError...
     D                 pi

     D procWithError   ds                  likeds(Proc_t)

      /free

        procWithError.procNm  =        'proc_with_error';
        procWithError.procPtr = %paddr( proc_with_error );

        monitor;
          callWithLogging( procWithError );
        on-error;
          fail( 'callWithLogging should never raise an error' );
        endmon;

        iEqual( 1 : logIdx );
        aEqual( 'proc_with_error'  : logLine(1).procNm );
        aEqual( TEST_CASE_ERROR    : logLine(1).type );
        aEqual( 'Artificial error' : logLine(1).msg );

      /end-free
     P                 e


     P test_fmtCompMsg...
     P                 b                   export
     D test_fmtCompMsg...
     D                 pi
      /free

        aEqual( 'Success. 0 test case, 0 assertion, 0 failure, 0 error.' :
                fmtCompMsg( 0 : 0 : 0 : 0 ) );

        aEqual( 'Success. 2 test cases, 0 assertion, 0 failure, 0 error.' :
                fmtCompMsg( 2 : 0 : 0 : 0 ) );

        aEqual( 'Success. 0 test case, 2 assertions, 0 failure, 0 error.' :
                fmtCompMsg( 0 : 2 : 0 : 0 ) );

        aEqual( 'FAILURE. 0 test case, 0 assertion, 2 failures, 0 error.' :
                fmtCompMsg( 0 : 0 : 2 : 0 ) );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.' :
                fmtCompMsg( 0 : 0 : 0 : 2 ) );

        // Errors have priority over failures.
        aEqual( 'ERROR. 0 test case, 0 assertion, 2 failures, 1 error.' :
                fmtCompMsg( 0 : 0 : 2 : 1 ) );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Mock Procedures (mocking CMDRUNLOG)
      //----------------------------------------------------------------------

     P logCompMsg      b                   export
     D logCompMsg      pi
     D  msg                       16384a   const varying options(*Varsize)
     D  failures                     10i 0 const
     D  errors                       10i 0 const
      /free
        fail( 'Mock logCompMsg not implemented' );
      /end-free
     P                 e


     P logError        b                   export
     D logError        pi
     D  testNm                             const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)
      /free

        logIdx += 1;
        logLine(logIdx).type = TEST_CASE_ERROR;
        logLine(logIdx).procNm = testNm;
        logLine(logIdx).msg = excpMsgInfo.txt;

      /end-free
     P                 e


     P logFailure      b                   export
     D logFailure      pi
     D  testNm                             const like(ProcNm_t)
     D  failure                            const likeds(AssertFailEvtLong_t)
      /free
        fail( 'Mock logFailure not implemented' );
      /end-free
     P                 e


     P logSuccess      b                   export
     D logSuccess      pi
     D  testNm                             const like(ProcNm_t)
     D  assertionCnt                 10i 0 const
      /free

        logIdx += 1;
        logLine(logIdx).type = TEST_CASE_SUCCESS;
        logLine(logIdx).procNm = testNm;
        logLine(logIdx).assertionCnt = assertionCnt;

      /end-free
     P                 e


     P setLogContext   b                   export
     D setLogContext   pi
     D  testPgm                            const likeds(Object_t)
     D  detail                       10a   const
     D  output                       10a   const
      /free
        fail( 'Mock setLogContext not implemented' );
      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Support Procedures
      //----------------------------------------------------------------------

       // Dummy procedure with error.
     P proc_with_error...
     P                 b                   export
     D proc_with_error...
     D                 pi
      /free

        sndEscapeMsgToCaller( 'Artificial error' );

      /end-free
     P                 e


       // Dummy procedure with no error.
     P proc_with_no_error...
     P                 b                   export
     D proc_with_no_error...
     D                 pi
      /free

        procWithNoErrorWasCalled = *on;

      /end-free
     P                 e


       // Dummy test procedure.
     P successful_test_1...
     P                 b                   export
     D                 pi
      /free
        iEqual( 4 : 2+2 );
      /end-free
     P                 e


       // Dummy test procedure.
     P successful_test_2...
     P                 b                   export
     D                 pi
      /free
        iEqual( 4 : 2+2 );
      /end-free
     P                 e


       // Dummy test procedure.
     P successful_test_with_one_assertion...
     P                 b                   export
     D successful_test_with_one_assertion...
     D                 pi
      /free
        iEqual( 4 : 2+2 );
      /end-free
     P                 e

       // Dummy test procedure.
     P successful_test_with_two_assertions...
     P                 b                   export
     D successful_test_with_two_assertions...
     D                 pi
      /free
        iEqual( 4 : 2+2 );
        iEqual( 4 : 2+2 );
      /end-free
     P                 e

