      // =====================================================================
      //
      // Acceptance Tests for RPGUnit.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKACPTST) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKACPTST) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUp           pr                  extproc('setUp')
     D tearDown        pr                  extproc('tearDown')

     D testEmptyTest   pr                  extproc('testEmptyTest')
     D testSuccess     pr                  extproc('testSuccess')
     D testFailures    pr                  extproc('testFailures')
     D testNonTestProc...
     D                 pr                  extproc('testNonTestProc')
     D testSetupAndTearDown...
     D                 pr                  extproc('testSetupAndTearDown')
     D testError       pr                  extproc('testError')
     D testManyTests   pr                  extproc('testManyTests')
     D testStackTrace  pr                  extproc('testStackTrace')
     D testMissingObject...
     D                 pr                  extproc('testMissingObject')
     D testErrorDuringSetup...
     D                 pr                  extproc('testErrorDuringSetup')
     D testErrorDuringTearDown...
     D                 pr                  extproc('testErrorDuringTearDown')
     D testNoTestCase  pr                  extproc('testNoTestCase')
     D testSetupSuiteAndTearDownSuite...
     D                 pr                  extproc('testSetupSuiteAndTearDownSu+
     D                                     ite')
     D testBigInteger  pr                  extproc('testBigInteger')
     D testForceSpoolOnSuccess...
     D                 pr                  extproc('testForceSpoolOnSuccess')
     D testReverseOrder...
     D                 pr                  extproc('testReverseOrder')
     D testChooseTest  pr                  extproc('testChooseTest')
     D testChooseNonExistingTest...
     D                 pr                  extproc('testChooseNonExistingTest')
     D testTestCreationSuccess...
     D                 pr                  extproc('testTestCreationSuccess')
     D testErrorInSetUpSuite...
     D                 pr                  extproc('testErrorInSetUpSuite')
     D testErrorInTearDownSuite...
     D                 pr                  extproc('testErrorInTearDownSuite')
     D testErrorsInBothSetUpSuiteAndTearDownSuite...
     D                 pr                  extproc('testErrorsInBothSetUpSuiteA+
     D                                     ndTearDownSuite')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,QCMDEXC
      /copy RPGUNITY1,JOBLOG
      /copy RPGUNITY1,SPLF
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D run             pr                  extproc('run')
     D  cmd                       32767a   const varying
     D  errorExpected                  n   const options(*NoPass)
     D  msgType                      10a   const options(*NoPass)
     D  msgTxt                      256a   options(*NoPass)


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // Constants for the 'run' procedure.
     D errorExpected   c                   const(*on)
     D noError         c                   const(*off)

     D MARGIN          c                   const(x'34C006')


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Message text.
     D msgTxt          s            256a


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     PsetUp            b                   export
     DsetUp            pi
      /free

        clear msgTxt;

      /end-free
     P                 e


     PtearDown         b                   export
     D                 pi
      /free

        chkAndCloSplf();

      /end-free
     P                 e


     PtestEmptyTest    b                   export
     DtestEmptyTest    pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM01) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM01' : noError : '*COMP' : msgTxt );

        aEqual( 'Success. 1 test case, 0 assertion, 0 failure, 0 error.':
                msgTxt );

      /end-free
     P                 e


     PtestSuccess      b                   export
     DtestSuccess      pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM02) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM02' : noError : '*COMP' : msgTxt );

        aEqual( 'Success. 1 test case, 1 assertion, 0 failure, 0 error.':
                msgTxt );

      /end-free
     P                 e


     PtestFailures     b                   export
     DtestFailures     pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM03) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM03' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM03' );
        splfLineStartsWith( '*** Tests from TESTPGM03 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTFALSE - FAILURE' );
        splfLineStartsWith( 'Expected 5, but was 4.' );
        splfLineStartsWith( 'iEqual' );
        splfLineStartsWith( 'TESTFALSE (TESTPGM03->TESTPGM03:1300)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTFALSE2 - FAILURE' );
        splfLineStartsWith( 'Expected 6, but was 4.' );
        splfLineStartsWith( 'iEqual' );
        splfLineStartsWith( 'TESTFALSE2 (TESTPGM03->TESTPGM03:2200)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 2 test cases, 2 assertions,'
                          + ' 2 failures, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestNonTestProc...
     P                 b                   export
     DtestNonTestProc...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM04) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM04' : noError : '*COMP' : msgTxt );

        aEqual( 'Success. 2 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

      /end-free
     P                 e


     PtestSetupAndTearDown...
     P                 b                   export
     DtestSetupAndTearDown...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM05) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM05' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 0 assertion, 1 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test1'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );    // Raises a failure.
        aEqual( 'teardown'     : rcvMsgData('*INFO') );    // Call 'teardown' anyway.

      /end-free
     P                 e


     PtestError        b                   export
     DtestError        pi

     D testStartTime   s               z

      /free

        testStartTime = getFullTimeStamp();
        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM06) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM06' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        assertJobLogContains( 'MCH1211' : testStartTime );

        opnSplf( 'RPGUNIT' : 'TESTPGM06' );
        splfLineStartsWith( '*** Tests from TESTPGM06 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTERROR - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TESTERROR (TESTPGM06->TESTPGM06:1400)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestManyTests    b                   export
     DtestManyTests    pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM13) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM13' : noError : '*COMP' : msgTxt );

        aEqual( 'Success. 256 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

      /end-free
     P                 e


     PtestStackTrace   b                   export
     DtestStackTrace   pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM07) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM07' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM07' );
        splfLineStartsWith( '*** Tests from TESTPGM07 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTSTACK - FAILURE' );
        splfLineStartsWith( 'Expected 5, but was 4.' );
        splfLineStartsWith( 'iEqual' );
        splfLineStartsWith( 'FAILINGPROC (TESTPGM07->TESTPGM07:1300)' );
        splfLineStartsWith( 'TESTSTACK (TESTPGM07->TESTPGM07:2200)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 1 test case, 1 assertion,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestMissingObject...
     P                 b                   export
     DtestMissingObject...
     D                 pi
      /free

        callp(e) run( 'DLTSRVPGM QTEMP/TESTPGM08' );    // No TESTPGM08.

        run( 'RUCALLTST QTEMP/TESTPGM08' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'RPGUnit Error.'
              + ' Error while loading the test suite in QTEMP/TESTPGM08.' :
                msgTxt );

      /end-free
     P                 e


     PtestErrorDuringSetup...
     P                 b                   export
     DtestErrorDuringSetup...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM09) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM09' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.' :
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );    // Error during setup.
              // Test should not be called.
        aEqual( 'teardown'     : rcvMsgData('*INFO') );    // Teardown should be called anyway

        opnSplf( 'RPGUNIT' : 'TESTPGM09' );
        splfLineStartsWith( '*** Tests from TESTPGM09 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEST - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUP (TESTPGM09->TESTPGM09:2100)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestErrorDuringTearDown...
     P                 b                   export
     DtestErrorDuringTearDown...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM10) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM10' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM10' );
        splfLineStartsWith( '*** Tests from TESTPGM10 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEST - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWN (TESTPGM10->TESTPGM10:1900)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestNoTestCase   b                   export
     DtestNoTestCase   pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM11) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM11' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'RPGUnit Error.'
              + ' No test case found in service program QTEMP/TESTPGM11.' :
                msgTxt );

      /end-free
     P                 e


     PtestSetupSuiteAndTearDownSuite...
     P                 b                   export
     DtestSetupSuiteAndTearDownSuite...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM12) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM12' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 0 assertion, 1 failure, 0 error.':
                msgTxt );

        aEqual( 'setupSuite'   : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test1'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );    // Raises a failure.
        aEqual( 'teardown'     : rcvMsgData('*INFO') );    // Call 'teardown' anyway.
        aEqual( 'teardownSuite': rcvMsgData('*INFO') );    // Call 'teardownsuite' anyway.

      /end-free
     P                 e


     PtestBigInteger   b                   export
     DtestBigInteger   pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM14) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM14' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 2 assertions, 1 failure, 0 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM14' );
        splfLineStartsWith( '*** Tests from TESTPGM14 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEST_DIFFERENT - FAILURE' );
        splfLineStartsWith( 'Expected 123456789012345678901234567890'
                          + '1, but was 12345678901234567890' );
        splfLineStartsWith( '12345678900.' );
        splfLineStartsWith( 'iEqual' );
        splfLineStartsWith( 'TEST_DIFFERENT (TESTPGM14->TESTPGM14:'
                          + '2800)');
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 2 test cases, 2 assertions,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestForceSpoolOnSuccess...
     P                 b                   export
     DtestForceSpoolOnSuccess...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM15) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST TSTPGM(QTEMP/TESTPGM15) DETAIL(*ALL)' :
             noError :
             '*COMP' :
             msgTxt );

        aEqual( 'Success. 2 test cases, 3 assertions, 0 failure, 0 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM15' );
        splfLineStartsWith( '*** Tests from TESTPGM15 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTTRUE - Success' );
        splfLineStartsWith( '1 assertions' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTTRUE2 - Success' );
        splfLineStartsWith( '2 assertions' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'Success. 2 test cases, 3 assertions,'
                          + ' 0 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     P testReverseOrder...
     P                 b                   export
     D testReverseOrder...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM16) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST TSTPGM(QTEMP/TESTPGM16) ORDER(*REVERSE)' :
             noError :
             '*COMP' :
             msgTxt );

        aEqual( 'Success. 2 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test1'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );

      /end-free
     P                 e


     PtestChooseTest   b                   export
     DtestChooseTest   pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM05) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM05 TSTPRC(TEST2)' :
             errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 1 test case, 0 assertion, 1 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );

        opnSplf( 'RPGUNIT' : 'TESTPGM05' );
        splfLineStartsWith( '*** Tests from TESTPGM05 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEST2 - FAILURE' );
        splfLineStartsWith( 'test2' );
        // New, due to new procedure doFail():
        splfLineStartsWith( 'fail (RUTESTCASE' );
        splfLineStartsWith( 'TEST2 (TESTPGM05' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 1 test case, 0 assertion,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestChooseNonExistingTest...
     P                 b                   export
     DtestChooseNonExistingTest...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM05) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM05 TSTPRC(NON_EXISTING_TEST)' :
             errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM05' );
        splfLineStartsWith( '*** Tests from TESTPGM05 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'NON_EXISTING_TEST - ERROR' );
        splfLineStartsWith( 'Test procedure not found.' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 0 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     PtestTestCreationSuccess...
     P                 b                   export
     DtestTestCreationSuccess...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM01) SRCFILE(RPGUNITF1)' :
             noError :
             '*COMP' :
             msgTxt );

        aEqual( 'Test program TESTPGM01 created in library QTEMP.' : msgTxt );

      /end-free
     P                 e


     P testErrorInSetUpSuite...
     P                 b                   export
     D testErrorInSetUpSuite...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM17) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM17' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );    // Error.
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Call 'teardownSuite' anyway.

        opnSplf( 'RPGUNIT' : 'TESTPGM17' );
        splfLineStartsWith( '*** Tests from TESTPGM17 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'SETUPSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUPSUITE (TESTPGM17->TESTPGM17:2100)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 0 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testErrorInTearDownSuite...
     P                 b                   export
     D testErrorInTearDownSuite...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM18) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM18' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );
        aEqual( 'test1'         : rcvMsgData('*INFO') );
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Error.

        opnSplf( 'RPGUNIT' : 'TESTPGM18' );
        splfLineStartsWith( '*** Tests from TESTPGM18 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEARDOWNSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWNSUITE (TESTPGM18->TESTPGM18:3900)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testErrorsInBothSetUpSuiteAndTearDownSuite...
     P                 b                   export
     D testErrorsInBothSetUpSuiteAndTearDownSuite...
     D                 pi
      /free

        run( 'RUCRTTST TSTPGM(QTEMP/TESTPGM19) SRCFILE(RPGUNITF1)' );

        run( 'RUCALLTST QTEMP/TESTPGM19' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );    // Error.
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Another error.

        opnSplf( 'RPGUNIT' : 'TESTPGM19' );
        splfLineStartsWith( '*** Tests from TESTPGM19 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'SETUPSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUPSUITE (TESTPGM19->TESTPGM19:2100)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEARDOWNSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWNSUITE (TESTPGM19->TESTPGM19:4200)' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 0 test case, 0 assertion,'
                          + ' 0 failure, 2 errors.' );
        cloSplf();

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Helper Procedures
      //----------------------------------------------------------------------

     P run             b
     D run             pi
     D  cmd                       32767a   const varying
     D  errorExpected                  n   const options(*NoPass)
     D  msgType                      10a   const options(*NoPass)
     D  msgTxt                      256a   options(*NoPass)

      /free

        if %parms >= 2 and errorExpected;
          callp(e) qcmdexc( cmd: %len(cmd) );
          assert( %error: 'Expected error missing' );
        else;
          qcmdexc( cmd: %len(cmd) );
        endif;

        if %parms >= 4;
          msgTxt = rcvMsgTxt( msgType );
        endif;

      /end-free
     P                 e
