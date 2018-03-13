      // =====================================================================
      //
      // Tests CMDRUNLOG.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKCMDRUNLT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKCMDRUNLT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,CMDRUNLOG
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE

      // CMDRUNPRTY is imported to mock module CMDRUNPRT. That way, we can
      // test what would have been printed in the spool file, without
      // involving the spool file API.
      /copy RPGUNITY1,CMDRUNPRT


      //----------------------------------------------------------------------
      //   Test Case Prototypes
      //----------------------------------------------------------------------

     D setUp           pr                  extproc('setUp')
     D tearDown        pr                  extproc('tearDown')

     D testLogSuccessWith1Assertion...
     D                 pr                  extproc('testLogSuccessWith1Assertio+
     D                                     n')
     D testLogSuccessWith2Assertions...
     D                 pr                  extproc('testLogSuccessWith2Assertio+
     D                                     ns')
     D testLog2Successes...
     D                 pr                  extproc('testLog2Successes')
     D testLogFailureWithoutSpecNb...
     D                 pr                  extproc('testLogFailureWithoutSpecNb+
     D                                     ')
     D testLogErrorWithoutMsgId...
     D                 pr                  extproc('testLogErrorWithoutMsgId')
     D testLogErrorWithoutExcpInfoOrigin...
     D                 pr                  extproc('testLogErrorWithoutExcpInfo+
     D                                     Origin')
     D testLogCompMsg  pr                  extproc('testLogCompMsg')
     D testLogRawLine  pr                  extproc('testLogRawLine')
     D testLogRawLineWithWrapping...
     D                 pr                  extproc('testLogRawLineWithWrapping')


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

      // Left margin of the log. Must match CMDRUNLOG.LEFT_MARGIN.
     D MARGIN          c                   '     '

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // The mock log lines and state.
     D logIdx          s             10i 0
     D logLine         s             80a   Dim(100)
     D logWasOpened    s               n
     D logWasClosed    s               n
       // The (dummy) service program containing the tests.
     D testSrvPgm      ds                  likeds(Object_t)
       // The (dummy) test case name.
     D testNm          s                   like(ProcNm_t)


      //----------------------------------------------------------------------
      //   Test Definitions
      //----------------------------------------------------------------------

     P setUp           b                   export
     D setUp           pi
      /free

        clear logIdx;
        clear logLine;
        clear logWasOpened;
        clear logWasClosed;
        clear testSrvPgm;
        clear testNm;

        testSrvPgm.nm = 'MY_SRVPGM';
        setLogContext( testSrvPgm : DETAIL_ALL : OUTPUT_ALLWAYS );

      /end-free
     P                 e


     P tearDown        b                   export
     D tearDown        pi
      /free

        logCompMsg( *blank : 0 : 0 );    // Close log in all cases.

      /end-free
     P                 e


     P testLogSuccessWith1Assertion...
     P                 b                   export
     D testLogSuccessWith1Assertion...
     D                 pi

     D oneAssertion    c                   const(1)

      /free

        // Setup.

        testNm = 'successful_test_with_one_assertion';

        // Execution.

        logSuccess( testNm : oneAssertion );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***       ' : logLine(1) );
        aEqual( MARGIN + 'successful_test_with_one_asser     ' : logLine(7) );
        aEqual( MARGIN + 'tion - Success                     ' : logLine(8) );
        aEqual( MARGIN + '  1 assertions                     ' : logLine(9) );
        aEqual( MARGIN + '-----------------------            ' : logLine(10) );
        iEqual( 11 : logIdx );

      /end-free
     P                 e


     P testLogSuccessWith2Assertions...
     P                 b                   export
     D testLogSuccessWith2Assertions...
     D                 pi

     D twoAssertions   c                   const(2)

      /free

        // Setup.

        testNm = 'successful_test_with_two_assertions';

        // Execution.

        logSuccess( testNm : twoAssertions );

        // Controls.

        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***      ' : logLine(1) );
        aEqual( MARGIN + 'successful_test_with_two_asser    ' : logLine(7) );
        aEqual( MARGIN + 'tions - Success                   ' : logLine(8) );
        aEqual( MARGIN + '  2 assertions                    ' : logLine(9) );
        aEqual( MARGIN + '-----------------------           ' : logLine(10) );
        iEqual( 11 : logIdx );

      /end-free
     P                 e


     P testLog2Successes...
     P                 b                   export
     D testLog2Successes...
     D                 pi

     D testNm2         s                   like(TestNm)

      /free

        // Setup.

        testNm  = 'successful_test_1';
        testNm2 = 'successful_test_2';

        // Execution.

        logSuccess( testNm  : 0 );
        logSuccess( testNm2 : 0 );

        // Controls.

        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***' : logLine(1)  );
        aEqual( MARGIN + 'successful_test_1 - Success ' : logLine(7)  );
        aEqual( MARGIN + '  0 assertions              ' : logLine(8)  );
        aEqual( MARGIN + '-----------------------     ' : logLine(9)  );
        aEqual( MARGIN + ''                             : logLine(10) );
        aEqual( MARGIN + 'successful_test_2 - Success ' : logLine(11) );
        aEqual( MARGIN + '  0 assertions              ' : logLine(12) );
        aEqual( MARGIN + '-----------------------     ' : logLine(13) );
        iEqual( 14 : logIdx );

      /end-free
     P                 e


     P testLogFailureWithoutSpecNb...
     P                 b                   export
     D testLogFailureWithoutSpecNb...
     D                 pi

     D failure         ds                  likeds(AssertFailEvtLong_t) inz

      /free

        // Setup.

        testNm = 'failure_without_spec_nb';
        failure.callStk.numE = 1;
        failure.callStk.Entry(1).sender.qPgm.nm = 'MY_SRVPGM';
        failure.callStk.Entry(1).sender.qMod.nm = 'MY_SRVPGM';
        failure.callStk.Entry(1).sender.procNm = testNm;
        failure.callStk.Entry(1).sender.specNb = *blank;

        // Execution.

        logFailure( testNm : failure );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***      ' : logLine(1) );
        aEqual( MARGIN + 'failure_without_spec_nb - FAIL    ' : logLine(7) );
        aEqual( MARGIN + 'URE                               ' : logLine(8) );
        aEqual( MARGIN + '  failure_without_spec_nb (MY_    ' : logLine(9) );
        aEqual( MARGIN + 'SRVPGM->MY_SRVPGM:*N)             ' : logLine(10));
        aEqual( MARGIN + '-----------------------           ' : logLine(11));
        aEqual( MARGIN + '                                  ' : logLine(12));
        iEqual( 12 : logIdx );

      /end-free
     P                 e


     P testLogErrorWithoutMsgId...
     P                 b                   export
     D testLogErrorWithoutMsgId...
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)

      /free

        // Setup.

        testNm = 'error_with_missing_msg_id';
        excpMsgInfo.Id = *blank;
        excpMsgInfo.txt = 'Error message.';
        excpMsgInfo.sender.qPgm.nm = 'ERRORPGM';
        excpMsgInfo.sender.procNm = 'error_proc';
        excpMsgInfo.sender.specNb = '1000';

        // Execution.

        logError( testNm : excpMsgInfo );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***      ' : logLine(1) );
        aEqual( MARGIN + 'error_with_missing_msg_id - ERROR ' : logLine(7) );
        aEqual( MARGIN + 'Error message.                    ' : logLine(8) );
        aEqual( MARGIN + '  error_proc (ERRORPGM->:1000)    ' : logLine(9) );
        aEqual( MARGIN + '-----------------------           ' : logLine(10) );
        iEqual( 11 : logIdx );

      /end-free
     P                 e


     P testLogErrorWithoutExcpInfoOrigin...
     P                 b                   export
     D testLogErrorWithoutExcpInfoOrigin...
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)

      /free

        // Setup.

        testNm = 'error_without_origin_info';
        excpMsgInfo.Id = 'CPF1234';
        excpMsgInfo.txt = 'Error message.';
        excpMsgInfo.sender.qPgm.nm = *blank;
        excpMsgInfo.sender.procNm = *blank;
        excpMsgInfo.sender.specNb = *blank;

        // Execution.

        logError( testNm : excpMsgInfo );

        // Controls.

        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***      ' : logLine(1) );
        aEqual( MARGIN + 'error_without_origin_info - ERROR ' : logLine(7) );
        aEqual( MARGIN + 'CPF1234 - Error message.          ' : logLine(8) );
        aEqual( MARGIN + '-----------------------           ' : logLine(9) );
        iEqual( 10 : logIdx );

      /end-free
     P                 e


     P testLogCompMsg  b                   export
     D testLogCompMsg  pi
      /free

        // Execution.

        logCompMsg( 'Completion message' : 0 : 0 );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests from MY_SRVPGM ***      ' : logLine(1) );
        aEqual( MARGIN + 'Completion message                ' : logLine(7) );
        iEqual( 7 : logIdx );
        assert( logWasClosed : 'Log was not closed' );

      /end-free
     P                 e


     P testLogRawLine  b                   export
     D testLogRawLine  pi
      /free

        // Execution.

        logRawLine( 'A short text' );

        // Controls.

        aEqual( MARGIN + 'A short text                      ' : logLine(7) );
        iEqual( 7 : logIdx );

      /end-free
     P                 e


     P testLogRawLineWithWrapping...
     P                 b                   export
     D testLogRawLineWithWrapping...
     D                 pi

     D longText        s            256a

      /free

        // Setup.

                 //          111111111122222222223333333333444444444455
                 // 123456789012345678901234567890123456789012345678901
        longText = 'A very very very very very very very very long text';

        // Execution.

        logRawLine( longText );

        // Controls.

              //          1111111111222222222233333333334
              // 1234567890123456789012345678901234567890
        aEqual( MARGIN + 'A very very very very very ver' : logLine(7) );
        aEqual( MARGIN + 'y very very long text' : logLine(8) );
        iEqual( 8 : logIdx );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Support Procedures
      //----------------------------------------------------------------------

       // Procedure to mock module CMDRUNPRT.
     P clsPrt          b                   export
     D clsPrt          pi
      /free

        logWasClosed = *on;

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P getPrtWidth     b                   export
     D getPrtWidth     pi            10i 0
      /free

        return 40;

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P opnPrt          b                   export
     D opnPrt          pi
     D  testPgmNm                          const like(Object_t.nm)
      /free

        logWasOpened = *on;
        aEqual( 'MY_SRVPGM' : testPgmNm );

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P getSplf         b                   export
     D getSplf         pi                  likeds(splF_t)

     D splF            ds                  likeds(splF_t)
      /free

        splF.system = 'SYSTEM';
        splF.nm = 'QSYSPRT';
        splF.nbr = 1;
        splF.job = 'RPGUNIT';

        return splF;

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P prtLine         b                   export
     D prtLine         pi
     D  line                         80a   const
      /free

        logIdx += 1;
        logLine( logIdx ) = line;

      /end-free
     P                 e


