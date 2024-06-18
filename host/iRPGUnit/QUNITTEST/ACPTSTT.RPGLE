      // ==========================================================================
      //  iRPGUnit SelfTest - Acceptance tests.
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
      //     >>PARM<<  MODULE(&LI/JOBLOG    +
      //                      &LI/LIBL      +
      //                      &LI/LSTSPLF   +
      //                      &LI/OBJECT    +
      //                      &LI/PGMMSG    +
      //                      &LI/SRCMBR    +
      //                      &LI/USRSPC    +
      //                      &LI/SPLF      +
      //                      );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //     >>PARM<<  BOPTION(*DUPPROC);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LSTSPLF  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SPLF     ) SRCFILE(&SL/QUNITTEST) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite      pr                  extproc('setUpSuite')
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

      // Output *NONE

     D testSuccessNoOutput...
     D                 pr                  extproc('testSuccessNoOutput')
     D testFailuresNoOutput...
     D                 pr                  extproc('testFailuresNoOutput')
     D testErrorNoOutput...
     D                 pr                  extproc('testErrorNoOutput')
     D testMissingObjectNoOutput...
     D                 pr                  extproc('testMissingObjectNoOutput')
     D testNoTestCaseNoOutput...
     D                 pr                  extproc('testNoTestCaseNoOutput')

     D testDltSplFs...
     D                 pr                  extproc('testDltSplFs')

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,LIBL
      /include qinclude,OBJECT
      /include qinclude,PGMMSG
      /include qinclude,SYSTEMAPI
      /include qunittest,SPLF_H
      /include qinclude,TEMPLATES
      /include qinclude,TESTUTILS


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D run...
     D                 pr                  extproc('run')
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
     D numRows         s             10i 0


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P setUpSuite...
     P                 b                   export
     D                 pi

     D libraryList     ds                  likeds(LiblData_t) inz
     D MIN_NUM_ROWS    c                   5
      /free

        libraryList = getLibl();

        numRows = %div(libraryList.libL.numE: 3);
        if (numRows * 3 <> libraryList.libL.numE);
           numRows += 1;
        endif;

        if (numRows < MIN_NUM_ROWS);
           numRows = MIN_NUM_ROWS;
           if (numRows > libraryList.libL.numE);
             numRows = libraryList.libL.numE;
           endif;
        endif;

      /end-free
     P                 e

     P setUp...
     P                 b                   export
     D                 pi
      /free

        clear msgTxt;

      /end-free
     P                 e


     P tearDown...
     P                 b                   export
     D                 pi
      /free

        chkAndCloSplf();

      /end-free
     P                 e


     P testEmptyTest...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM01': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM01) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM01' : noError : '*COMP' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM01' );

        aEqual( 'Success. 1 test case, 0 assertion, 0 failure, 0 error.':
                msgTxt );

        cloSplf();

      /end-free
     P                 e


     P testSuccess...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM02' : noError : '*COMP' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM02' );

        aEqual( 'Success. 1 test case, 1 assertion, 0 failure, 0 error.':
                msgTxt );

        cloSplf();

      /end-free
     P                 e


     P testFailures...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM03': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM03) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM03' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM03' );
        splfLineStartsWith( '*** Tests of TESTPGM03 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TESTFALSE - FAILURE' );
        splfLineStartsWith( 'Expected 5, but was 4.' );
        splfLineStartsWith( 'TESTFALSE (TESTPGM03->TESTPGM03:22' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TESTFALSE2 - FAILURE' );
        splfLineStartsWith( 'Expected 6, but was 4.' );
        splfLineStartsWith( 'TESTFALSE2 (TESTPGM03->TESTPGM03:31' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 2 test cases, 2 assertions,'
                          + ' 2 failures, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     P testNonTestProc...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM04': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM04) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM04' : noError : '*COMP' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM04' );

        aEqual( 'Success. 2 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

       cloSplf();

      /end-free
     P                 e


     P testSetupAndTearDown...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM05' : errorExpected : '*ESCAPE' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM05' );

        aEqual( 'FAILURE. 2 test cases, 0 assertion, 1 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test1'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );    // Raises a failure.
        aEqual( 'teardown'     : rcvMsgData('*INFO') );    // Call 'teardown' anyway.

        cloSplf();

      /end-free
     P                 e


     P testError...
     P                 b                   export
     D                 pi

     D testStartTime   s               z
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM06': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM06) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        testStartTime = getFullTimeStamp();
        run( 'RUCALLTST TESTPGM06' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        assertJobLogContains( 'MCH1211' : testStartTime );

        opnSplf( 'RPGUNIT' : 'TESTPGM06' );
        splfLineStartsWith( '*** Tests of TESTPGM06 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TESTERROR - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TESTERROR (TESTPGM06->TESTPGM06:23' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testStackTrace...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM07': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM07) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM07' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM07' );
        splfLineStartsWith( '*** Tests of TESTPGM07 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TESTSTACK - FAILURE' );
        splfLineStartsWith( 'Expected 5, but was 4.' );
        splfLineStartsWith( 'FAILINGPROC (TESTPGM07->TESTPGM07:22' );
        splfLineStartsWith( 'TESTSTACK (TESTPGM07->TESTPGM07:31' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 1 test case, 1 assertion,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     P testMissingObject...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_exists('TESTPGM08': 'QTEMP'));
           runcmd( 'DLTSRVPGM SRVPGM(QTEMP/TESTPGM08)' ); // Must not exists!
        endif;

        callp(e) run( 'DLTSRVPGM TESTPGM08' );    // No TESTPGM08.

        run( 'RUCALLTST TESTPGM08' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'RPGUnit Error.'
              + ' Error while loading test suite *LIBL/TESTPGM08.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM08' );
        splfLineStartsWith( '*** Tests of TESTPGM08 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'Runtime error: +
                             Error while loading test suite *LIBL/TESTPGM08.' );

        cloSplf();

      /end-free
     P                 e


     P testErrorDuringSetup...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM09': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM09) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM09' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.' :
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );    // Error during setup.
              // Test should not be called.
        aEqual( 'teardown'     : rcvMsgData('*INFO') );    // Teardown should be called anyway

        opnSplf( 'RPGUNIT' : 'TESTPGM09' );
        splfLineStartsWith( '*** Tests of TESTPGM09 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TEST - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUP (TESTPGM09->TESTPGM09:30' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testErrorDuringTearDown...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM10': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM10) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM10' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM10' );
        splfLineStartsWith( '*** Tests of TESTPGM10 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TEST - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWN (TESTPGM10->TESTPGM10:28' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testNoTestCase...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM11': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM11) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM11' : errorExpected : '*ESCAPE' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM11' );

        aEqual( 'RPGUnit Error.'
              + ' No test case found in service program *LIBL/TESTPGM11.' :
                msgTxt );

        cloSplf();

      /end-free
     P                 e


     P testSetupSuiteAndTearDownSuite...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM12': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM12) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM12' : errorExpected : '*ESCAPE' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM12' );

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

        cloSplf();

      /end-free
     P                 e


     P testManyTests...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM13': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM13) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM13' : noError : '*COMP' : msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM13' );

        aEqual( 'Success. 256 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

        cloSplf();

      /end-free
     P                 e


     P testBigInteger...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM14': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM14) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM14' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 2 test cases, 2 assertions, 1 failure, 0 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM14' );
        splfLineStartsWith( '*** Tests of TESTPGM14 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit    : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TEST_DIFFERENT - FAILURE' );
        splfLineStartsWith( 'Expected 123456789012345678901234567890'
                          + '1, but was 12345678901234567890' );
        splfLineStartsWith( '12345678900.' );
        splfLineStartsWith( 'TEST_DIFFERENT (TESTPGM14->TESTPGM14:31');
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 2 test cases, 2 assertions,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     P testForceSpoolOnSuccess...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM15': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM15) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TSTPGM(TESTPGM15) DETAIL(*ALL)' :
             noError :
             '*COMP' :
             msgTxt );

        aEqual( 'Success. 2 test cases, 3 assertions, 0 failure, 0 error.' :
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM15' );
        splfLineStartsWith( '*** Tests of TESTPGM15 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
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
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM16': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM16) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TSTPGM(TESTPGM16) ORDER(*REVERSE)' :
             noError :
             '*COMP' :
             msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM16' );

        aEqual( 'Success. 2 test cases, 0 assertion, 0 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );
        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test1'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );

        cloSplf();

      /end-free
     P                 e


     P testChooseTest...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM05 TSTPRC(TEST2)' :
             errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'FAILURE. 1 test case, 0 assertion, 1 failure, 0 error.':
                msgTxt );

        aEqual( 'setup'        : rcvMsgData('*INFO') );
        aEqual( 'test2'        : rcvMsgData('*INFO') );
        aEqual( 'teardown'     : rcvMsgData('*INFO') );

        opnSplf( 'RPGUNIT' : 'TESTPGM05' );
        splfLineStartsWith( '*** Tests of TESTPGM05 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TEST2 - FAILURE' );
        splfLineStartsWith( 'test2' );
        splfLineStartsWith( 'TEST2 (TESTPGM05' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'FAILURE. 1 test case, 0 assertion,'
                          + ' 1 failure, 0 error.' );
        cloSplf();

      /end-free
     P                 e


     P testChooseNonExistingTest...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM05 TSTPRC(NON_EXISTING_TEST)' :
             errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        opnSplf( 'RPGUNIT' : 'TESTPGM05' );
        splfLineStartsWith( '*** Tests of TESTPGM05 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
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


     P testErrorInSetUpSuite...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM17': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM17) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM17' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );    // Error.
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Call 'teardownSuite' anyway.

        opnSplf( 'RPGUNIT' : 'TESTPGM17' );
        splfLineStartsWith( '*** Tests of TESTPGM17 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'SETUPSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUPSUITE (TESTPGM17->TESTPGM17:30' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 0 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testErrorInTearDownSuite...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM18': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM18) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM18' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );
        aEqual( 'test1'         : rcvMsgData('*INFO') );
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Error.

        opnSplf( 'RPGUNIT' : 'TESTPGM18' );
        splfLineStartsWith( '*** Tests of TESTPGM18 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'TEARDOWNSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWNSUITE (TESTPGM18->TESTPGM18:48' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 1 test case, 0 assertion,'
                          + ' 0 failure, 1 error.' );
        cloSplf();

      /end-free
     P                 e


     P testErrorsInBothSetUpSuiteAndTearDownSuite...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM19': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM19) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        run( 'RUCALLTST TESTPGM19' : errorExpected : '*ESCAPE' : msgTxt );

        aEqual( 'ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.':
                msgTxt );

        aEqual( 'setupSuite'    : rcvMsgData('*INFO') );    // Error.
        aEqual( 'teardownSuite' : rcvMsgData('*INFO') );    // Another error.

        opnSplf( 'RPGUNIT' : 'TESTPGM19' );
        splfLineStartsWith( '*** Tests of TESTPGM19 ***' );
        splfSkipLine();  // Skip "Date"
        splfSkipLine();  // Skip "Job"
        splfSkipLine();  // Skip "User"
        splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
        splfSkipLine();  // Skip "IBM i       : V7R3M0"
        splfSkipLine();  // Skip [blank line]

        splfSkipLine();  // Skip "Cur. library: *CRTDFT"
        i = numRows;
        dow (i > 0);
          splfSkipLine();  // Skip lines of library list
          i -= 1;
        enddo;
        splfSkipLine();  // Skip [blank line]

        splfLineStartsWith( 'SETUPSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'SETUPSUITE (TESTPGM19->TESTPGM19:30' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'TEARDOWNSUITE - ERROR' );
        splfLineStartsWith( 'MCH1211 - ' );
        splfLineStartsWith( 'TEARDOWNSUITE (TESTPGM19->TESTPGM19:51' );
        splfLineStartsWith( '-----------------------' );
        splfSkipLine();  // Skip [blank line]
        splfLineStartsWith( 'ERROR. 0 test case, 0 assertion,'
                          + ' 0 failure, 2 errors.' );
        cloSplf();

      /end-free
     P                 e


     P testSuccessNoOutput...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM02' );

        run( 'RUCALLTST TESTPGM02 OUTPUT(*NONE)' : noError : '*COMP' : msgTxt );

        aEqual( 'Success. 1 test case, 1 assertion, 0 failure, 0 error.':
                msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM02' ) = 0 :
                'Unexpected spooled file' );

      /end-free
     P                 e


     P testFailuresNoOutput...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_isDirty('TESTPGM03': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM03) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM03' );

        run( 'RUCALLTST TESTPGM03 OUTPUT(*NONE)' : errorExpected : '*ESCAPE' :
             msgTxt );

        aEqual( 'FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.':
                msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM03' ) = 0 :
                'Unexpected spooled file' );

      /end-free
     P                 e


     P testErrorNoOutput...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM06': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM06) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM06' );

        run( 'RUCALLTST TESTPGM06 OUTPUT(*NONE)' : errorExpected : '*ESCAPE' :
             msgTxt );

        aEqual( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.':
                msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM06' ) = 0 :
                'Unexpected spooled file' );

      /end-free
     P                 e


     P testMissingObjectNoOutput...
     P                 b                   export
     D                 pi
     D i               s             10i 0
      /free

        if (TestSuite_exists('TESTPGM08': 'QTEMP'));
           runcmd( 'DLTSRVPGM SRVPGM(QTEMP/TESTPGM08)' ); // Must not exists!
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM08' );

        run( 'RUCALLTST TESTPGM08 OUTPUT(*NONE)' : errorExpected : '*ESCAPE' :
             msgTxt );

        aEqual( 'RPGUnit Error.'
              + ' Error while loading test suite *LIBL/TESTPGM08.' :
                msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM08' ) = 0 :
                'Unexpected spooled file' );

      /end-free
     P                 e


     P testNoTestCaseNoOutput...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM11': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM11) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM11' );

        run( 'RUCALLTST TESTPGM11 OUTPUT(*NONE)' : errorExpected : '*ESCAPE' :
             msgTxt );

        aEqual( 'RPGUnit Error.'
              + ' No test case found in service program *LIBL/TESTPGM11.' :
                msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM11' ) = 0 :
                'Unexpected spooled file' );

      /end-free
     P                 e


     P testDltSplFs...
     P                 b                   export
     D                 pi
      /free

        if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
           runcmd( 'RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
                      SRCFILE(QTESTCASES) DLTSPLF(*YES)' );
        endif;

        dltSplFs( 'RPGUNIT' : 'TESTPGM02' );

        run( 'RUCALLTST TESTPGM02' : noError : '*COMP' : msgTxt );
        run( 'RUCALLTST TESTPGM02' : noError : '*COMP' : msgTxt );
        run( 'RUCALLTST TESTPGM02' : noError : '*COMP' : msgTxt );

        assert( dltSplFs( 'RPGUNIT' : 'TESTPGM02' ) = 3 :
                'Spooled file not found' );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Helper Procedures
      //----------------------------------------------------------------------

     P run...
     P                 b
     D                 pi
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

