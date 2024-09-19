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
     D testAssertEqual_string...
     D                 pr                  extproc('testAssertEqual_string')
     D testAssertEqual_integer...
     D                 pr                  extproc('testAssertEqual_integer')
     D testAssertEqual_numeric...
     D                 pr                  extproc('testAssertEqual_numeric')
     D testAssertThat...
     D                 pr                  extproc('testAssertThat')
     D testAssertEqual_date...
     D                 pr                  extproc('testAssertEqual_date')
     D testAssertEqual_time...
     D                 pr                  extproc('testAssertEqual_time')
     D testAssertEqual_timestamp...
     D                 pr                  extproc('testAssertEqual_timestamp')
     D testAssertEqual_ind...
     D                 pr                  extproc('testAssertEqual_ind')


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
           aEqual( '153'  : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '15300': assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
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
           aEqual( '215'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '21500'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
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
           aEqual( '317'     : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // IFS Compile
        on-error;
           aEqual( '31700'   : assertFailEvt.callStk.Entry(1).qStmt.specNb );  // QSYS Compile
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


      //----------------------------------------------------------------------
      //   Procedure that simulates the test case executor procedure
      //   of module CMDRUNSRV. It must receive the message sent by fail().
      //----------------------------------------------------------------------

     P CMDRUNSRV_runProc...
     P                 b
     D                 pi              n
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


     PtestAssertEqual_string...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test 1-char string
        assertEqual( '1' :
                     '1' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        assertEqual( 'e' :
                     'e' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        monitor;
          assertEqual( 'e' :
                       'u' );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''e'', but was ''u''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test equality
        assertEqual( 'expected' :
                     'expected' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( 'expected' :
                       'unexpected value' );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''expected'', but was ''unexpected value''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( 'expected' :
                       'unexpected value' :
                       'String values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'String values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e


     PtestAssertEqual_integer...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test equality
        assertEqual( 9223372036854775807 :
                     9223372036854775807 );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( -9223372036854775807 :
                       -123 );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''-9223372036854775807'', but was ''-123''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( 9223372036854775807 :
                       123 :
                       'Integer values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Integer values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e


     PtestAssertEqual_numeric...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)

     D actualExact     s             63p20 inz(*hival)
     D expectedExact   s             63p20 inz(*hival)

     D actualLess      s             15p 5 inz(*hival)
     D expectedLess    s             15p 5 inz(*hival)

     D actualLike      s                   like(assertNumeric_t) inz(*hival)
     D expectedLike    s                   like(assertNumeric_t) inz(*hival)

     D actualShort     s              3i 0 inz(*hival)
     D expectedShort   s              3i 0 inz(*hival)

     D actualInt       s              5i 0 inz(*hival)
     D expectedInt     s              5i 0 inz(*hival)

     D actualLong      s             20i 0 inz(*hival)
     D expectedLong    s             20i 0 inz(*hival)

     D actualZoned     s             20s 0 inz(*hival)
     D expectedZoned   s             20s 0 inz(*hival)

     D actualSingle    s              4f   inz(*hival)
     D expectedSingle  s              4f   inz(*hival)

     D actualDouble    s              8f   inz(*hival)
     D expectedDouble  s              8f   inz(*hival)
      /free

        // Test compiler
        assertEqual( actualExact : expectedExact );
        assertEqual( actualLess : expectedLess );
        assertEqual( expectedLike: actualLike );
        assertEqual( expectedInt : actualInt );
        assertEqual( expectedShort : actualShort );
        assertEqual( expectedLong : actualLong );
        assertEqual( expectedZoned : actualZoned );

        assertEqual( expectedSingle : actualSingle );
        assertEqual( expectedDouble : actualDouble );

        // The following assertEqual() statement produces the following compiler error
        // message, if 'actualDecLoss' or 'expectedDecLoss' are defined with too many
        // positions or decimal positions, e.g.:
        //   63s15    too many positions before the comma
        //   63s25    too many positions after the comma
        //   "RNF3245: No prototype in the OVERLOAD keyword of ASSERTEQUAL matches the call."
        // See test case: ACPTSTT.testOptionsExact() and TESTPGM20
        //
        // assertEqual( expectedDecLoss : actualDecLoss );

        // Test equality
        assertEqual( 1234567890,1234 :
                     1234567890,1234 );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( -1234567890,123 :
                       -1234567890,122 );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''-1234567890,123'', but was ''-1234567890,122''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( 1234567890,1234 :
                       1234567890,1233 :
                       'Numeric values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Numeric values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e


     PtestAssertThat...
     P                 b                   export
     D                 pi

     D expected        s            128a   varying
     D actual          s            128a   varying

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test equality
        expected = 'Donald Duck';
        actual = expected;
        assertThat( %addr(expected) :
                    %addr(actual) :
                    %paddr(assertThatMatcherWithMsg));
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message but
        // with a message returned by the matcher
        monitor;
          expected = 'Donald Duck';
          actual = 'Dagobert Duck';
          assertThat( %addr(expected) :
                      %addr(actual) :
                      %paddr(assertThatMatcherWithMsg));
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Matcher: Actual values does not match expected value.'
                 : 'Error messages does not match message from matcher.');
        endmon;

        // Test unequality without any assertion message
        monitor;
          expected = 'Donald Duck';
          actual = 'Dagobert Duck';
          assertThat( %addr(expected) :
                      %addr(actual) :
                      %paddr(assertThatMatcherWithoutMsg));
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 '*N');
        endmon;

        // Test unequality with error message
        monitor;
          expected = 'Donald Duck';
          actual = 'Dagobert Duck';
          assertThat( %addr(expected) :
                      %addr(actual) :
                      %paddr(assertThatMatcherWithoutMsg) :
                      'Matcher did not accept actual value.');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Matcher did not accept actual value.');
        endmon;

      /end-free
     P                 e

     PtestAssertEqual_date...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test equality
        assertEqual( D'2024-09-16' : D'2024-09-16' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( D'2024-09-16' : D'2002-01-02' );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''2024-09-16'', but was ''2002-01-02''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( D'2024-09-16' :
                       D'2002-01-02' :
                       'Date values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Date values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e

     PtestAssertEqual_time...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test equality
        assertEqual( T'11.22.33' : T'11.22.33' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( T'11.22.33' : T'22.33.44' );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''11.22.33'', but was ''22.33.44''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( T'11.22.33' :
                       T'22.33.44' :
                       'Time values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Time values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e

     PtestAssertEqual_timestamp...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Test equality
        assertEqual( Z'2024-09-16-11.22.33.123456789012' :
                     Z'2024-09-16-11.22.33.123456789012' );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          assertEqual( Z'2024-09-16-11.22.33.123456789012' :
                       Z'2023-01-16-22.33.44.654321789012' );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''2024-09-16-11.22.33.123456789012'', but was ' +
                 '''2023-01-16-22.33.44.654321789012''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          assertEqual( Z'2024-09-16-11.22.33.123456789012' :
                       Z'2023-01-16-22.33.44.654321789012' :
                       'Timestamp values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Timestamp values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e

     PtestAssertEqual_ind...
     P                 b                   export
     D                 pi

     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
     D ind1            s               n   inz(*on)
     D ind2            s               n   inz(*on)
      /free

        // Test indicator figurative constant.
        monitor;
        assertEqual( *on :
                     *off );
          fail('Expected the asssertion to fail.');
        on-error;
          // Does not yet work. Opened IBM support case:
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''1'', but was ' +
                 '''0''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test equality
        ind2 = *on;
        ind2 = *on;
        assertEqual( ind1 :
                     ind2 );
        aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

        // Test unequality without assertion message
        monitor;
          ind2 = *on;
          ind2 = *off;
          assertEqual( ind1 :
                       ind2 );
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Expected ''1'', but was ' +
                 '''0''.'
                 : 'Error messages does not match expected value.');
        endmon;

        // Test unequality with assertion message
        monitor;
          ind2 = *on;
          ind2 = *off;
          assertEqual( ind1 :
                       ind2 :
                       'Indicator values do not match');
          fail('Expected the asssertion to fail.');
        on-error;
          assertFailEvtLong = getAssertFailEvtLong();
          assert(assertFailEvtLong.msg =
                 'Indicator values do not match'
                 : 'Error messages does not match expected value.');
        endmon;

      /end-free
     P                 e

     P assertThatMatcherWithMsg...
     P                 b                   export
     D                 pi              n
     D  pExpected                      *   const
     D  pActual                        *   const
     D  message                            like(msgText_t)

     D expected        s            128a   varying based(pExpected)
     D actual          s            128a   varying based(pActual)
      /free

        if (expected = actual);
          message = '';
          return *on;
        else;
          message = 'Matcher: Actual values does not match expected value.';
          return *off;
        endif;

      /end-free
     P                 e


     P assertThatMatcherWithoutMsg...
     P                 b                   export
     D                 pi              n
     D  pExpected                      *   const
     D  pActual                        *   const

     D expected        s            128a   varying based(pExpected)
     D actual          s            128a   varying based(pActual)
      /free

        if (expected = actual);
          return *on;
        else;
          return *off;
        endif;

      /end-free
     P                 e

