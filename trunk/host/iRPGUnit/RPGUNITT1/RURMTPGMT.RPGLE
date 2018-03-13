      // =====================================================================
      //
      // Unit tests for RURMTPGMT.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CRTCMD<<  RUCRTTST   TSTPGM(&LI/&OB) SRCFILE(&SF);
      //     >>COMPILE<<
      //       >>PARM<< DBGVIEW(*LIST);
      //     >>END-COMPILE<<
      //     >>EXECUTE<<
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D testFailShouldRiseAboveAnEnclosingMonitorBlock...
     D                 pr                  extproc('testFailShouldRiseAboveAnEn+
     D                                     closingMonitorBlock')
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
     D testAssertWithFailure...
     D                 pr                  extproc('testAssertWithFailure')
     D testAssertWithSuccess...
     D                 pr                  extproc('testAssertWithSuccess')
     D testBigIntegerEquality...
     D                 pr                  extproc('testBigIntegerEquality')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D callFailInAMonitorBlock...
     D                 pr              n


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P testFailShouldRiseAboveAnEnclosingMonitorBlock...
     P                 b                   export
     D testFailShouldRiseAboveAnEnclosingMonitorBlock...
     D                 pi

     D excpWasCaught   s               n   inz(*off)
     D success         s               n   inz(*off)

      /free

        monitor;
          excpWasCaught = callFailInAMonitorBlock();
        on-error;
          success = *on;
        endmon;

        select;
          when success;
            // Success.
          when excpWasCaught;
            fail( 'The failure exception'
                + ' should not be caught by the monitor block' );
          other;
            fail( 'fail() should have raised an exception' );
        endsl;

      /end-free
     P testFailShouldRiseAboveAnEnclosingMonitorBlock...
     P                 e


     PtestTwoAndTwoEqualsFour...
     P                 b                   export
     DtestTwoAndTwoEqualsFour...
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
     DtestTwoAndTwoIsNotEqualToFive...
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

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.entry(1).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.entry(1).sender.qMod.nm );
        aEqual( 'DOASSERT'   : assertFailEvt.callStk.entry(1).sender.procNm );
        aEqual( '19300'      : assertFailEvt.callStk.entry(1).sender.specNb );

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.entry(2).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.entry(2).sender.qMod.nm );
        aEqual( 'iEqual'     : assertFailEvt.callStk.entry(2).sender.procNm );

        aEqual( 'RURMTPGMT'  : assertFailEvt.callStk.entry(3).sender.qPgm.nm );
        aEqual( 'RURMTPGMT'  : assertFailEvt.callStk.entry(3).sender.qMod.nm );
        aEqual( 'testTwoAndTwoIsNotEqualToFive' :
                               assertFailEvt.callStk.entry(3).sender.procNm );

      /end-free
     P                 e


     PtestHelloEqualsHello...
     P                 b                   export
     DtestHelloEqualsHello...
     D                 pi
      /free

        // Execution.

        aEqual( 'Hello' : 'Hello' );

        // Control.

        // No exception message => OK.

        aEqual( EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt() );

      /end-free
     P                 e


     PtestGoodByeIsNotHello...
     P                 b                   export
     DtestGoodByeIsNotHello...
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

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.entry(1).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.entry(1).sender.qMod.nm );
        aEqual( 'DOASSERT'   : assertFailEvt.callStk.entry(1).sender.procNm );

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.entry(2).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.entry(2).sender.qMod.nm );
        aEqual( 'aEqual'     : assertFailEvt.callStk.entry(2).sender.procNm );

        aEqual( 'RURMTPGMT'  : assertFailEvt.callStk.entry(3).sender.qPgm.nm );
        aEqual( 'RURMTPGMT'  : assertFailEvt.callStk.entry(3).sender.qMod.nm );
        aEqual( 'testGoodByeIsNotHello' :
                               assertFailEvt.callStk.entry(3).sender.procNm );

      /end-free
     P                 e


     PtestAssertCount...
     P                 b                   export
     DtestAssertCount...
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

        aEqual( EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt() );

      /end-free
     P                 e


     PtestAssertWithFailure...
     P                 b                   export
     DtestAssertWithFailure...
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

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.entry(1).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.entry(1).sender.qMod.nm );
        aEqual( 'DOASSERT'   : assertFailEvt.callStk.entry(1).sender.procNm );
        aEqual( '19300'      : assertFailEvt.callStk.entry(1).sender.specNb );

        aEqual( 'RUTESTCASE' : assertFailEvt.callStk.Entry(2).sender.qPgm.nm );
        aEqual( 'ASSERT'     : assertFailEvt.callStk.Entry(2).sender.qMod.nm );
        aEqual( 'assert'     : assertFailEvt.callStk.entry(2).sender.procNm );


      /end-free
     P                 e


     PtestBigIntegerEquality...
     P                 b                   export
     DtestBigIntegerEquality...
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

      //----------------------------------------------------------------------
      //   Helper Procedures
      //----------------------------------------------------------------------

     P callFailInAMonitorBlock...
     P                 b
     D callFailInAMonitorBlock...
     D                 pi              n
      /free

          monitor;
            fail( 'Failure message' );
            return *off;
          on-error;
            return *on;
          endmon;

      /end-free
     P                 e
