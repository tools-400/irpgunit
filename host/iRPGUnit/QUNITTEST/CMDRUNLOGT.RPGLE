      // ==========================================================================
      //  iRPGUnit SelfTest - Test CMDRUNLOG.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  MODULE(&LI/CMDRUNLOG +
      //                      &LI/CMDRUNPRT +
      //                      &LI/JOBLOG    +
      //                      &LI/LIBL      +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
      //                      &LI/STRING    +
      //                      );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //     >>PARM<<  BOPTION(*DUPPROC);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,CMDRUNLOG
      /copy qinclude,LIBL
      /copy qinclude,TEMPLATES
      /copy qinclude,STRING

      // CMDRUNPRTY is imported to mock module CMDRUNPRT. That way, we can
      // test what would have been printed in the spool file, without
      // involving the spool file API.
      /copy qinclude,CMDRUNPRT


      //----------------------------------------------------------------------
      //   Test Case Prototypes
      //----------------------------------------------------------------------

     D setUpSuite      pr                  extproc('setUpSuite')
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
     D                 pi
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
     D                 pi
      /free

        logCompMsg( *blank : 0 : 0 );    // Close log in all cases.

      /end-free
     P                 e


     P testLogSuccessWith1Assertion...
     P                 b                   export
     D                 pi

     D oneAssertion    c                   const(1)
     D r               s             10i 0
      /free

        // Setup.

        testNm = 'successful_test_with_one_assertion';

        // Execution.

        logSuccess( testNm : oneAssertion );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***         ' : logLine(1)  );

        r = findRow('successful_test');
        assert(r > 0: 'Row starting with ''successful_test'' not found');

        aEqual( MARGIN + 'successful_test_with_one_asser     ' : logLine(r));
        aEqual( MARGIN + 'tion - Success                     ' : logLine(r+1));
        aEqual( MARGIN + '  1 assertions                     ' : logLine(r+2));
        aEqual( MARGIN + '-----------------------            ' : logLine(r+3));
        iEqual( r+4 : logIdx );

      /end-free
     P                 e


     P testLogSuccessWith2Assertions...
     P                 b                   export
     D                 pi

     D twoAssertions   c                   const(2)
     D r               s             10i 0
      /free

        // Setup.

        testNm = 'successful_test_with_two_assertions';

        // Execution.

        logSuccess( testNm : twoAssertions );

        // Controls.

        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***        ' : logLine(1)  );

        r = findRow('successful_test');
        assert(r > 0: 'Row starting with ''successful_test'' not found');

        aEqual( MARGIN + 'successful_test_with_two_asser    ' : logLine(r ) );
        aEqual( MARGIN + 'tions - Success                   ' : logLine(r+1));
        aEqual( MARGIN + '  2 assertions                    ' : logLine(r+2));
        aEqual( MARGIN + '-----------------------           ' : logLine(r+3));
        iEqual( r+4 : logIdx );

      /end-free
     P                 e


     P testLog2Successes...
     P                 b                   export
     D                 pi

     D testNm2         s                   like(TestNm)
     D r               s             10i 0
      /free

        // Setup.

        testNm  = 'successful_test_1';
        testNm2 = 'successful_test_2';

        // Execution.

        logSuccess( testNm  : 0 );
        logSuccess( testNm2 : 0 );

        // Controls.

        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***    ' : logLine(1)  );

        r = findRow('successful_test');
        assert(r > 0: 'Row starting with ''successful_test'' not found');

        aEqual( MARGIN + 'successful_test_1 - Success   ' : logLine(r ) );
        aEqual( MARGIN + '  0 assertions                ' : logLine(r+1));
        aEqual( MARGIN + '-----------------------       ' : logLine(r+2));
        aEqual( MARGIN + ''                               : logLine(r+3));
        aEqual( MARGIN + 'successful_test_2 - Success   ' : logLine(r+4));
        aEqual( MARGIN + '  0 assertions                ' : logLine(r+5));
        aEqual( MARGIN + '-----------------------       ' : logLine(r+6));
        iEqual( r+7 : logIdx );

      /end-free
     P                 e


     P testLogFailureWithoutSpecNb...
     P                 b                   export
     D                 pi

     D failure         ds                  likeds(AssertFailEvtLong_t) inz
     D r               s             10i 0
      /free

        // Setup.

        testNm = 'failure_without_spec_nb';
        failure.callStk.numE = 1;
        failure.callStk.Entry(1).qStmt.qPgm.nm = 'MY_SRVPGM';
        failure.callStk.Entry(1).qStmt.qMod.nm = 'MY_SRVPGM';
        failure.callStk.Entry(1).qStmt.procNm = testNm;
        failure.callStk.Entry(1).qStmt.specNb = *blank;

        // Execution.

        logFailure( testNm : failure );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***        ' : logLine(1)  );

        r = findRow('failure_without');
        assert(r > 0: 'Row starting with ''failure_without'' not found');

        aEqual( MARGIN + 'failure_without_spec_nb - FAIL    ' : logLine(r ) );
        aEqual( MARGIN + 'URE                               ' : logLine(r+1));
        aEqual( MARGIN + '  failure_without_spec_nb (MY_    ' : logLine(r+2));
        aEqual( MARGIN + 'SRVPGM->MY_SRVPGM:*N)             ' : logLine(r+3));
        aEqual( MARGIN + '-----------------------           ' : logLine(r+4));
        aEqual( MARGIN + '                                  ' : logLine(r+5));
        iEqual( r+5 : logIdx );

      /end-free
     P                 e


     P testLogErrorWithoutMsgId...
     P                 b                   export
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)
     D r               s             10i 0
      /free

        // Setup.

        testNm = 'error_with_missing_msg_id';
        excpMsgInfo.Id = *blank;
        excpMsgInfo.txt = 'Error message.';
        excpMsgInfo.qSndStmt.qPgm.nm = 'ERRORPGM';
        excpMsgInfo.qSndStmt.procNm = 'error_proc';
        excpMsgInfo.qSndStmt.specNb = '1000';

        // Execution.

        logError( testNm : excpMsgInfo );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***        ' : logLine(1)  );

        r = findRow('error_with');
        assert(r > 0: 'Row starting with ''error_with'' not found');

        aEqual( MARGIN + 'error_with_missing_msg_id - ERROR ' : logLine(r ) );
        aEqual( MARGIN + 'Error message.                    ' : logLine(r+1));
        aEqual( MARGIN + '  error_proc (ERRORPGM->:1000)    ' : logLine(r+2));
        aEqual( MARGIN + '-----------------------           ' : logLine(r+3));
        iEqual( r+4 : logIdx );

      /end-free
     P                 e


     P testLogErrorWithoutExcpInfoOrigin...
     P                 b                   export
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)
     D r               s             10i 0
      /free

        // Setup.

        testNm = 'error_without_origin_info';
        excpMsgInfo.Id = 'CPF1234';
        excpMsgInfo.txt = 'Error message.';
        excpMsgInfo.qSndStmt.qPgm.nm = *blank;
        excpMsgInfo.qSndStmt.procNm = *blank;
        excpMsgInfo.qSndStmt.specNb = *blank;

        // Execution.

        logError( testNm : excpMsgInfo );

        // Controls.

        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***        ' : logLine(1)  );

        r = findRow('error_without');
        assert(r > 0: 'Row starting with ''error_without'' not found');

        aEqual( MARGIN + 'error_without_origin_info - ERROR ' : logLine(r ) );
        aEqual( MARGIN + 'CPF1234 - Error message.          ' : logLine(r+1));
        aEqual( MARGIN + '-----------------------           ' : logLine(r+2));
        iEqual( r+3 : logIdx );

      /end-free
     P                 e


     P testLogCompMsg  b                   export
     D                 pi

     D r               s             10i 0
      /free

        // Execution.

        logCompMsg( 'Completion message' : 0 : 0 );

        // Controls.

        assert( logWasOpened : 'Log was not opened' );
        aEqual( MARGIN + '*** Tests of MY_SRVPGM ***        ' : logLine(1)  );

        r = findRow('Library list:');
        assert(r > 0: 'Row starting with ''Library list:'' not found');

        aEqual( MARGIN + 'Completion message                ' : logLine(r+2));
        assert( r+2 = logIdx
               : 'Line with ''Completion message'' must be the last one');
        assert( logWasClosed : 'Log was not closed' );

      /end-free
     P                 e


     P testLogRawLine  b                   export
     D                 pi
      /free

        // Execution.

        logRawLine( 'A short text' );

        // Controls.

        aEqual( MARGIN + 'A short text                      ' : logLine(1)  );
        iEqual( 1  : logIdx );

      /end-free
     P                 e


     P testLogRawLineWithWrapping...
     P                 b                   export
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
        aEqual( MARGIN + 'A very very very very very ver' : logLine(1 ) );
        aEqual( MARGIN + 'y very very long text' : logLine(2 ) );
        iEqual( 2  : logIdx );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Support Procedures
      //----------------------------------------------------------------------

       // Procedure to mock module CMDRUNPRT.
     P clsPrt          b                   export
     D                 pi
      /free

        logWasClosed = *on;

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P getPrtWidth     b                   export
     D                 pi            10i 0
      /free

        return 40;

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P opnPrt          b                   export
     D                 pi
     D  testPgmNm                          const like(Object_t.nm)
      /free

        logWasOpened = *on;
        aEqual( 'MY_SRVPGM' : testPgmNm );

      /end-free
     P                 e


       // Procedure to mock module CMDRUNPRT.
     P getSplf         b                   export
     D                 pi                  likeds(splF_t)

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
     D                 pi
     D  line                         80a   const
      /free

        logIdx += 1;
        logLine( logIdx ) = line;

      /end-free
     P                 e


       // Helper to search a row starting with a given string.
     P findRow         b
     D                 pi            10i 0
     D  value                        80a   const varying
     D  i              s             10i 0
      /free

        for i = 1 to logIdx;
          if (startsWith(value: %trim(logLine(i))));
            return i;
          endif;
        endfor;

        return -1;

      /end-free
     P                 e

