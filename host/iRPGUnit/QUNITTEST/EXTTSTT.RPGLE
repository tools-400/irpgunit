      // ==========================================================================
      //  iRPGUnit SelfTest - Test EXTTST.
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
      //     >>PARM<<  MODULE(&LI/CALLPRC   +
      //                      &LI/CMDRUNLOG +
      //                      &LI/CMDRUNPRT +
      //                      &LI/CMDRUNSRV +
      //                      &LI/EXTPRC    +
      //                      &LI/EXTTST    +
      //                      &LI/JOBLOG    +
      //                      &LI/LLIST     +
      //                      &LI/OBJECT    +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
      //                      &LI/SRCMBR    +
      //                      &LI/STRING    +
      //                      &LI/USRSPC    +
      //                      );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,CALLPRC
      /copy qinclude,EXTTST
      /copy qinclude,EXTPRC
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setup           pr                  extproc('setup')

     D testOneProcOneTestCase...
     D                 pr                  extproc('testOneProcOneTestCase')
     D testOneProcNoTestCase...
     D                 pr                  extproc('testOneProcNoTestCase')
     D testTwoProcsTwoTestCases...
     D                 pr                  extproc('testTwoProcsTwoTestCases')
     D testSetupProc   pr                  extproc('testSetupProc')
     D testTearDownProc...
     D                 pr                  extproc('testTearDownProc')
     D testSetupSuite  pr                  extproc('testSetupSuite')
     D testTeardownSuite...
     D                 pr                  extproc('testTeardownSuite')
     D testActivateTestSuite...
     D                 pr                  extproc('testActivateTestSuite')

     D ET_setUp        pr                  extproc('ET_setUp')
     D ET_setUpSuite   pr                  extproc('ET_setUpSuite')
     D ET_tearDown     pr                  extproc('ET_tearDown')
     D ET_tearDownSuite...
     D                 pr                  extproc('ET_tearDownSuite')
     D ET_testProc_1   pr                  extproc('ET_testProc_1')
     D ET_testProc_2   pr                  extproc('ET_testProc_2')
      * Test procedure with trailing spaces
     D ET_testProc_3   pr                  extproc('ET_testProc_3   ')


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D getMockProcNm   pr                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const

     D goToNext        pr
     D  mockProcNmListHandle...
     D                                5a   const

     D getMockProcCnt  pr            10i 0
     D  mockProcNmListHandle...
     D                                5a   const

     D testProcEqual   pr
     D  expTestProc                        const likeds(Proc_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D return_NOT_A_TEST_1...
     D                 pr                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const

     D return_SETUP_then_TEST_1...
     D                 pr                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const

     D return_TEST_n   pr                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const


      //----------------------------------------------------------------------
      //   Global DS
      //----------------------------------------------------------------------

     D testSuite       ds                  likeds(TestSuite_t)

     D mockProcArray   s                   Dim(2) like(ProcNm_t)
     D mockProcNmList  ds                  likeds(ProcNmList_t)

      //----------------------------------------------------------------------
      //   Global Variable
      //----------------------------------------------------------------------

     D dummyHandle     s              5a   inz('dummy')
     D mockProcIdx     s             10i 0
     D mockProcCnt     s             10i 0
       // Expected test procedure.
     D expTestProc     ds                  likeds(Proc_t)

      //----------------------------------------------------------------------
      //   Program Status Data Structure
      //----------------------------------------------------------------------

      /copy qinclude,SDS


      //----------------------------------------------------------------------
      //   Test Definitions
      //----------------------------------------------------------------------

     P setup           b                   export
     D setup           pi
      /free

        clear expTestProc;

        clear mockProcArray;
        mockProcIdx = 1;
        mockProcCnt = 0;

        mockProcNmList.handle = %addr( dummyHandle );
        mockProcNmList.cnt = %paddr( getMockProcCnt );
        mockProcNmList.getNm = %paddr( getMockProcNm );
        mockProcNmList.goToNext = %paddr( goToNext );

      /end-free
     P                 e


     P testOneProcOneTestCase...
     P                 b                   export
     D testOneProcOneTestCase...
     D                 pi
      /free

        // Setup.

        mockProcCnt = 1;
        mockProcArray(1) = 'TEST_1';

        // Execution.

        testSuite = getTestSuite( mockProcNmList );

        // Controls.

        iEqual( 1 : testSuite.testCasesCnt );
        aEqual( *blank : testSuite.setUp.procNm );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

        aEqual( *blank : testSuite.tearDown.procNm );

      /end-free
     P                 e


     P testOneProcNoTestCase...
     P                 b                   export
     D testOneProcNoTestCase...
     D                 pi
      /free

        mockProcCnt = 1;
        mockProcArray(1) = 'NOT_A_TEST_1';

        testSuite = getTestSuite( mockProcNmList );

        iEqual( 0 : testSuite.testCasesCnt );

      /end-free
     P                 e


     P testTwoProcsTwoTestCases...
     P                 b                   export
     D testTwoProcsTwoTestCases...
     D                 pi
      /free

        mockProcCnt = 2;
        mockProcArray(1) = 'TEST_1';
        mockProcArray(2) = 'TEST_2';

        testSuite = getTestSuite( mockProcNmList );

        iEqual( 2: testSuite.testCasesCnt );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

        expTestProc.procNm = 'TEST_2';
        testProcEqual( expTestProc : testSuite : 2 );

      /end-free
     P                 e


     P testSetupProc   b                   export
     D testSetupProc   pi
      /free

        mockProcCnt = 2;
        mockProcArray(1) = 'SETUP';
        mockProcArray(2) = 'TEST_1';

        testSuite = getTestSuite( mockProcNmList );

        iEqual( 1 : testSuite.testCasesCnt );
        aEqual( 'SETUP' : testSuite.setUp.procNm );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

      /end-free
     P                 e


     P testTearDownProc...
     P                 b                   export
     D testTearDownProc...
     D                 pi
      /free

        // Setup.

        mockProcCnt = 2;
        mockProcArray(1) = 'TEARDOWN';
        mockProcArray(2) = 'TEST_1';

        // Execution.

        testSuite = getTestSuite( mockProcNmList );

        // Controls.

        iEqual( 1 : testSuite.testCasesCnt );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

        aEqual( 'TEARDOWN' : testSuite.tearDown.procNm );

      /end-free
     P                 e


     P testSetupSuite...
     P                 b                   export
     D testSetupSuite...
     D                 pi
      /free

        // Setup.

        mockProcCnt = 2;
        mockProcArray(1) = 'SETUPSUITE';
        mockProcArray(2) = 'TEST_1';

        // Execution.

        testSuite = getTestSuite( mockProcNmList );

        // Controls.

        iEqual( 1: testSuite.testCasesCnt );
        aEqual( 'SETUPSUITE': testSuite.setupSuite.procNm );
        aEqual( *blank      : testSuite.setup.procNm );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

      /end-free
     P                 e


     P testTeardownSuite...
     P                 b                   export
     D testTeardownSuite...
     D                 pi
      /free

        // Setup.

        mockProcCnt = 2;
        mockProcArray(1) = 'TEARDOWNSUITE';
        mockProcArray(2) = 'TEST_1';

        // Execution.

        testSuite = getTestSuite( mockProcNmList );

        // Controls.

        iEqual( 1 : testSuite.testCasesCnt );
        aEqual( *blank          : testSuite.setupSuite.procNm );
        aEqual( *blank          : testSuite.setup.procNm );

        expTestProc.procNm = 'TEST_1';
        testProcEqual( expTestProc : testSuite : 1 );

        aEqual( *blank          : testSuite.teardown.procNm );
        aEqual( 'TEARDOWNSUITE' : testSuite.teardownSuite.procNm );

      /end-free
     P                 e


     P testActivateTestSuite...
     P                 b                   export
     D testActivateTestSuite...
     D                 pi

     D actMark         s                   like(ActMark_t)
     D srvPgm          ds                  likeds(Object_t)
     D testCase        ds                  Dim(3) likeds(Proc_t)

      /free

        // Set up Activation Mark.
        // I use the 'self-shunt' pattern here. The test program tries to activate itself to g
        // own Activation Mark.

        srvPgm.nm = sds.pgmName;
        srvPgm.lib = sds.pgmLib;
        actMark = activateSrvPgm( srvPgm );

        // Set up TestSuite.

        testSuite.setUpSuite.procNm = 'ET_setUpSuite';
        testSuite.setUp.procNm = 'ET_setUp';
        testSuite.testCasesCnt = 3;
        testSuite.testList = %addr(testCase);
        testCase(1).procNm = 'ET_testProc_1';
        testCase(2).procNm = 'ET_testProc_2';
        testCase(3).procNm = 'ET_testProc_3   ';
        testSuite.tearDown.procNm = 'ET_tearDown';
        testSuite.tearDownSuite.procNm = 'ET_tearDownSuite';

        // Execution.

        activateTestSuite( testSuite : actMark );

        // Controls.

        assert( testSuite.setUpSuite.procPtr = %paddr( ET_setUpSuite ) :
                'Resolution of ET_setUpSuite failed' );
        assert( testSuite.setUp.procPtr = %paddr( ET_setUp ) :
                'Resolution of ET_setUp failed' );

        expTestProc.procNm = 'ET_testProc_1';
        expTestProc.procPtr = %paddr( ET_testProc_1 );
        testProcEqual( expTestProc : testSuite : 1 );

        expTestProc.procNm = 'ET_testProc_2';
        expTestProc.procPtr = %paddr( ET_testProc_2 );
        testProcEqual( expTestProc : testSuite : 2 );

        expTestProc.procNm = 'ET_testProc_3   ';
        expTestProc.procPtr = %paddr( ET_testProc_3 );
        testProcEqual( expTestProc : testSuite : 3 );

        assert( testSuite.tearDown.procPtr = %paddr( ET_tearDown ) :
                'Resolution of ET_tearDown failed' );
        assert( testSuite.tearDownSuite.procPtr = %paddr( ET_tearDownSuite ) :
                'Resolution of ET_tearDownSuite failed' );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Exported Procedure Definitions
      //----------------------------------------------------------------------

     P ET_setUp        b                   export
     D ET_setUp        pi
     P                 e

     P ET_setUpSuite   b                   export
     D ET_setUpSuite   pi
     P                 e

     P ET_tearDown     b                   export
     D ET_tearDown     pi
     P                 e

     P ET_tearDownSuite...
     P                 b                   export
     D ET_tearDownSuite...
     D                 pi
     P                 e

     P ET_testProc_1   b                   export
     D ET_testProc_1   pi
     P                 e

     P ET_testProc_2   b                   export
     D ET_testProc_2   pi
     P                 e

     P ET_testProc_3   b                   export
     D ET_testProc_3   pi
     P                 e


      //----------------------------------------------------------------------
      //   Private Procedure Definitions
      //----------------------------------------------------------------------

       // Mock implementation of mockProcNmList_t.getNm.
     P getMockProcNm   b
     D getMockProcNm   pi                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );
        return mockProcArray( mockProcIdx );

      /end-free
     P                 e


       // Mock implementation of mockProcNmList_t.goToNext.
     P goToNext        b
     D goToNext        pi
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );
        mockProcIdx += 1;

      /end-free
     P                 e


       // Mock implementation of mockProcNmList_t.cnt.
     P getMockProcCnt  b
     D getMockProcCnt  pi            10i 0
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );
        return mockProcCnt;

      /end-free
     P                 e


      // High-level assertion.
     PtestProcEqual    b
     DtestProcEqual    pi
       // Expected test procedure.
     D expTestProc                         const likeds(Proc_t)
       // Actual test suite.
     D testSuite                           const likeds(TestSuite_t)
       // Test case index.
     D testIdx                       10i 0 const

       // Actual test procedure.
     D actTestProc     ds                  likeds(Proc_t)

      /free

        actTestProc = getTestProc( testSuite : testIdx );

        aEqual( expTestProc.procNm :  actTestProc.procNm );
        assert( expTestProc.procPtr = actTestProc.procPtr :
                'Wrong test procedure pointer' );

      /end-free
     P                 e


       // Mock implementation of mockProcNmList_t.getNm.
     P return_NOT_A_TEST_1...
     P                 b
     D return_NOT_A_TEST_1...
     D                 pi                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );
        return 'NOT_A_TEST_1';

      /end-free
     P                 e


       // Mock implementation of mockProcNmList_t.getNm.
     P return_SETUP_then_TEST_1...
     P                 b
     D return_SETUP_then_TEST_1...
     D                 pi                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );

        select;
          when mockProcIdx = 1;
            return 'SETUP';
          when mockProcIdx = 2;
            return 'TEST_1';
          other;
            fail( 'Unreachable code' );
        endsl;

      /end-free
     P                 e


       // Mock implementation of mockProcNmList_t.getNm.
     P return_TEST_n   b
     D return_TEST_n   pi                  like(ProcNm_t)
     D  mockProcNmListHandle...
     D                                5a   const
      /free

        assert( 'dummy' = mockProcNmListHandle : 'Wrong ProcNmList handle' );
        return 'TEST_' + %char( mockProcIdx );

      /end-free
     P                 e

