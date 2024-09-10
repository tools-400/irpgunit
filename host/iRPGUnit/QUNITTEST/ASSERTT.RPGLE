      // ==========================================================================
      //  iRPGUnit SelfTest - Test ASSERT.
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
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D testFailInsideMonitorBlock...
     D                 pr                  extproc('testFailInsideMonitorBlock')
     D testHelloEqualsHello...
     D                 pr                  extproc('testHelloEqualsHello')
     D testGoodByeIsNotHello...
     D                 pr                  extproc('testGoodByeIsNotHello')
     D testTwoAndTwoEqualsFour...
     D                 pr                  extproc('testTwoAndTwoEqualsFour')
     D testTwoAndTwoIsNotEqualToFive...
     D                 pr                  extproc('testTwoAndTwoIsNotEqualToFi+
     D                                     ve')
     D testAssertCount...
     D                 pr                  extproc('testAssertCount')
     D testAssertClear...
     D                 pr                  extproc('testAssertClear')
     D testGetAssertFailEvt...
     D                 pr                  extproc('testGetAssertFailEvt')
     D testAssertWithFailure...
     D                 pr                  extproc('testAssertWithFailure')
     D testAssertWithSuccess...
     D                 pr                  extproc('testAssertWithSuccess')
     D testBigIntegerEquality...
     D                 pr                  extproc('testBigIntegerEquality')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,TEMPLATES

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D CMDRUNSRV_runProc...
     D                 pr              n   extproc('CMDRUNSRV_runProc')
     D failInsideMonitorBlock...
     D                 pr              n   extproc('failInsideMonitorBlock')


      //----------------------------------------------------------------------
      //   Global Constants
      //----------------------------------------------------------------------
     D FAILURE_MESSAGE...
     D                 c                   'Failure message'


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P testFailInsideMonitorBlock...
     P                 b                   export
     D                 pi

     D excpWasCaught   s               n   inz(*off)
     D success         s               n   inz(*off)

     D msgInfo         ds                  likeds(MsgInfo_t)
      /free

        success = CMDRUNSRV_runProc();

        select;
          when success;
            // Success.
            msgInfo = getMonitoredMessage(*off);
            assert( msgInfo.txt = FAILURE_MESSAGE );
          when excpWasCaught;
            fail( 'The failure exception'
                + ' should not be caught by the monitor block' );
          other;
            fail( 'fail() should have raised an exception' );
        endsl;

      /end-free
     P                 e


     PtestTwoAndTwoEqualsFour...
     P                 b                   export
     D                 pi
      /free

        // Execution.

        iEqual(4: 2 + 2);

        // Controls.

        // No exception message => OK.

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

      /end-free
     P                 e


     PtestTwoAndTwoIsNotEqualToFive...
     P                 b                   export
     D                 pi

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Execution.

        monitor;
          iEqual(5: 2 + 2);
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'iEqual(5: 2 + 2) should have raised an error message.' );

        aEqual( 'Expected 5, but was 4.' : assertFailEvt.msg );

        aEqual( 'ASSERTT' : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT' : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( 'testTwoAndTwoIsNotEqualToFive'
               : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
           aEqual( '137'  : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '13700': assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e


     PtestHelloEqualsHello...
     P                 b                   export
     D                 pi
      /free

        // Execution.

        aEqual( 'Hello' : 'Hello' );

        // Control.

        // No exception message => OK.

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

      /end-free
     P                 e


     PtestGoodByeIsNotHello...
     P                 b                   export
     D                 pi

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Execution.

        monitor;
          aEqual( 'Hello' : 'Good bye' );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'aEqual( Hello : Good bye )'
              + ' should have raised an error message.' );

        aEqual( 'Expected ''Hello'', but was ''Good bye''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( 'testGoodByeIsNotHello' :
                               assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
           aEqual( '199'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '19900'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e


     PtestAssertCount...
     P                 b                   export
     D                 pi

     D assertCallCntAtBeg...
     D                 s             10i 0
     D assertCallCnt   s             10i 0 Dim(4)
      /free

        // Setup.

        assertCallCntAtBeg = getAssertCalled();

        // Execution.

        assert( *on: *blank );
        assertCallCnt(1) = getAssertCalled();

        iEqual( 4: 2+2 );
        assertCallCnt(2) = getAssertCalled();

        aEqual( 'Hello': 'Hello' );
        assertCallCnt(3) = getAssertCalled();

        callp(e) assert( *off : *blank );
        assertCallCnt(4) = getAssertCalled();

        // Controls.

        iEqual( assertCallCntAtBeg + 1 : assertCallCnt(1) );
        iEqual( assertCallCntAtBeg + 2 : assertCallCnt(2) );
        iEqual( assertCallCntAtBeg + 3 : assertCallCnt(3) );
        iEqual( assertCallCntAtBeg + 4 : assertCallCnt(4) );

      /end-free
     P                 e


     PtestAssertWithSuccess...
     P                 b                   export
     DtestAssertWithSuccess...
     D                 pi
      /free

        // Execution.

        assert( *on : 'Should not raise an error' );

        // Controls.

        // No exception message => OK.

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

      /end-free
     P                 e


     PtestAssertWithFailure...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Execution.

        monitor;
          assert( *off : 'Failure message.' );
          fail( 'assert( *off : ...) should have raised an error.' );

        on-error;
          // Success. Failure exception was seen.
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        aEqual( 'Failure message.' : assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( 'testAssertWithFailure'
                             : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
           aEqual( '301'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '30100'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e


     PtestBigIntegerEquality...
     P                 b                   export
     D                 pi
      /free

             // 0000000001111111111222222222233
             // 1234567890123456789012345678901
        iEqual( 9999999999999999999999999999999 :
                9999999999999999999999999999999 );

        // Control.

        // No exception message => OK.

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

      /end-free
     P                 e


     P testAssertClear...
     P                 b                   export
     D                 pi

     D assertCallCnt   s             10i 0
      /free

        // Setup.

        assertCallCnt = getAssertCalled();

        // Execution.

        assert( *on: *blank );
        iEqual( 4: 2+2 );
        aEqual( 'Hello': 'Hello' );
        callp(e) assert( *off : *blank );

        // Controls.

        iEqual( assertCallCnt + 4 : getAssertCalled() );
        clearAssertCounter();
        iEqual( 0 : getAssertCalled() );

      /end-free
     P                 e


     P testGetAssertFailEvt...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(assertFailEvt_t)
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)

     D url1            s            200a   varying
     D url2            s            200a   varying
     D expectedMsg     s            500a   varying
      /free

        // Setup.

         url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
                 004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
                 roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
                 rview';

         url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
                 c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
                 VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
                 rview/joe.street';

         expectedMsg =
                'URL: Expected ''https://portal.azure.com/#resource/subscrip+
                 tions/07ac1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/R+
                 G-VM-AXDEVTR01/providers/Microsoft.Compute/virtualMachines/+
                 VM-AXDEVTR01/overview'', but was ''https://foobaa.portal.az+
                 ure.com/#resource/subscriptions/07ac1a17-d004-4d62-8d1b-0e2+
                 ec9809770/resourceGroups/RG-VM-AXDEVTR01/providers/Microsof+
                 t.Compute/virtualMachines/VM-AXDEVTrview/joe.street''.';

        // Execution.

        monitor;
           aEqual(url1: url2:  'URL');
           fail('Should have thrown an error');
        on-error;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();
        assertFailEvtLong = getAssertFailEvtLong();

        assert(assertFailEvtLong.msg = expectedMsg
               : 'Message does not match the expected value');
        assert(assertFailEvt.msg =
               %subst(assertFailEvtLong.msg : 1: %len(assertFailEvt.msg))
               : 'Message texts must match');

      /end-free
     P                 e

      /if defined(*V7R4M0)
     P testUniversalStringComparisonWithSuccess...
     P                 b                   export
      /free
        uEqual('abc' : 'abc');

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e

     P testUniversalNumericComparisonWithSuccess...
     P                 b                   export
      /free
        uEqual(123 : 123);

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e

     P testUniversalTimestampComparisonWithSuccess...
     P                 b                   export
     D tstmp1          s               z   inz(z'2024-09-02-11.22.33.123456')
     D tstmp2          s               z   inz(z'2024-09-02-11.22.33.123456')
      /free
        uEqual(tstmp1 : tstmp2);

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e

     P testUniversalTimeComparisonWithSuccess...
     P                 b                   export
     D tm1             s               t   inz(t'11.22.33')
     D tm2             S               t   inz(t'11.22.33')
      /free
        uEqual(tm1 : tm2);

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e

     P testUniversalDateComparisonWithSuccess...
     P                 b                   export
     D dt1             s               d   inz(d'2024-09-02')
     D dt2             s               d   inz(d'2024-09-02')
      /free
        uEqual(dt1 : dt2);

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e

     PtestUniversalStringComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalStringComparis-
     D                                     onWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Execution.

        monitor;
          uEqual( 'Hello' : 'Good bye' );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( Hello : Good bye )'
              + ' should have raised an error message.' );

        aEqual( 'Expected ''Hello'', but was ''Good bye''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '499'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '49900'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e

     PtestUniversalNumberComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalNumberComparis-
     D                                     onWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Execution.

        monitor;
          uEqual( 123 : 321 );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( 123 : 321 ) should have raised an error message.' );

        aEqual( 'Expected ''123'', but was ''321''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '544'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '54400'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e

     PtestUniversalTimestampComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalTimestampCompa-
     D                                     risonWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
     D tstmp1          s               z   inz(z'2024-09-02-11.22.33.123456')
     D tstmp2          s               z   inz(z'2024-11-03-22.11.00.654321')
      /free

        // Execution.

        monitor;
          uEqual( tstmp1: tstmp2 );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( ''2024-09-02-11.22.33.123456'' : +
                ''2024-11-03-22.11.00.654321'' )' +
                ' should have raised an error message.' );

        aEqual( 'Expected ''2024-09-02-11.22.33.123456'', ' +
                'but was ''2024-11-03-22.11.00.654321''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '589'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '58900'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e

     PtestUniversalDateComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalDateCompa-
     D                                     risonWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
     D dt1             s               d   inz(d'2024-11-02')
     D dt2             s               d   inz(d'2011-09-02')
      /free

        // Execution.

        monitor;
          uEqual( dt1 : dt2 );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( ''2024-11-02'' : + ''2011-09-02'' )' +
                ' should have raised an error message.' );

        aEqual( 'Expected ''2024-11-02'', but was ''2011-09-02''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '637'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '63700'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e

     PtestUniversalTimeComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalTimeCompa-
     D                                     risonWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
     D tm1             s               t   inz(t'11.22.33')
     D tm2             S               t   inz(t'22.33.11')
      /free

        // Execution.

        monitor;
          uEqual( tm1 : tm2 );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( ''11.22.33'' : + ''22.33.11'' )' +
                ' should have raised an error message.' );

        aEqual( 'Expected ''11.22.33'', but was ''22.33.11''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '683'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '68300'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e
     P testUniversaBooleanComparisonWithSuccess...
     P                 b                   export
     D n1              s               n   inz(*on)
     D n2              s               n   inz(*on)
      /free
        uEqual(n1: n2);

        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );
      /end-free
     P                 e
     P testUniversaBooleanComparisonWithFailure...
     P                 b                   export
     D                 pi
     D                                     extproc('testUniversalBooleanCompa-
     D                                     risonWithFailure')

     D excpWasSeen     s               n
     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
     D n1              s               n   inz(*off)
     D n2              s               n   inz(*on)
      /free

        // Execution.

        monitor;
          uEqual( n1 : n2 );
          excpWasSeen = *off;

        on-error;
          excpWasSeen = *on;
        endmon;

        // Controls.

        assertFailEvt = getAssertFailEvt();

        assert( excpWasSeen :
                'uEqual( ''0'' : + ''1'' )' +
                ' should have raised an error message.' );

        aEqual( 'Expected ''0'', but was ''1''.' :
                assertFailEvt.msg );

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).qStmt.qMod.nm );
        aEqual( %proc        : assertFailEvt.callStk.Entry(1).qStmt.procNm );

        monitor;
          aEqual( '738'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
          aEqual( '73800'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
        endmon;

      /end-free
     P                 e
      /endif
      //----------------------------------------------------------------------
      //   Procedure that simulates the test case executor procedure
      //   of module CMDRUNSRV. It must receive the message sent by fail().
      //----------------------------------------------------------------------

     P CMDRUNSRV_runProc...
     P                 b
     D                 pi              n

     D msgInfo         ds                  likeds(MsgInfo_t)
      /free

          monitor;
            if (failInsideMonitorBlock());
              return *off; // Let the caller report the error.
            endif;
          on-error;
            // Success, exception seen.
            return *on;
          endmon;

      /end-free
     P                 e


     P failInsideMonitorBlock...
     P                 b
     D                 pi              n
      /free

          monitor;
            fail( FAILURE_MESSAGE );
            return *off;
          on-error;
            return *on; // Bad. Message was captured.
          endmon;

      /end-free
     P                 e

