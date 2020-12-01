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
      //     >>PARM<<  MODULE(&LI/PGMMSG);
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

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
     D testAssert_oldStyle...
     D                 pr                  extproc('testAssert_oldStyle')
     D testAssert_newStyle...
     D                 pr                  extproc('testAssert_newStyle')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,TEMPLATES

      // assert() prototypes without 'opdesc' keyword.
     D assert_oldStyle...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D  condition                      n   const
     D  msgIfFalse                         const like(OldMsg_t) options(*nopass)

     D assert_newStyle...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying
     D                                           options(*varsize: *nopass)

     D fail_oldStyle   pr                  extproc('+
     D                                     fail+
     D                                     ')
     D  msg                                const like(OldMsg_t) options(*nopass)

     D fail_newStyle   pr                  extproc('+
     D                                     fail+
     D                                     ')
     D  msg                       16384a   const varying
     D                                           options(*varsize: *nopass)

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D callFailInAMonitorBlock...
     D                 pr              n   extproc('callFailInAMonitorBlock')


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P testFailShouldRiseAboveAnEnclosingMonitorBlock...
     P                 b                   export
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

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qMod.nm );
        aEqual( 'testTwoAndTwoIsNotEqualToFive' :
                               assertFailEvt.callStk.Entry(1).sender.procNm );

        monitor;
           aEqual( '164'     : assertFailEvt.callStk.Entry(1).sender.specNb );  // IFS Compile
        on-error;
           aEqual( '16400'   : assertFailEvt.callStk.Entry(1).sender.specNb );  // QSYS Compile
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

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qMod.nm );
        aEqual( 'testGoodByeIsNotHello' :
                               assertFailEvt.callStk.Entry(1).sender.procNm );

        monitor;
           aEqual( '226'     : assertFailEvt.callStk.Entry(1).sender.specNb );  // IFS Compile
        on-error;
           aEqual( '22600'   : assertFailEvt.callStk.Entry(1).sender.specNb );  // QSYS Compile
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

        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qPgm.nm );
        aEqual( 'ASSERTT'    : assertFailEvt.callStk.Entry(1).sender.qMod.nm );
        aEqual( 'testAssertWithFailure'
                             : assertFailEvt.callStk.Entry(1).sender.procNm );

        monitor;
           aEqual( '328'     : assertFailEvt.callStk.Entry(1).sender.specNb );  // IFS Compile
        on-error;
           aEqual( '32800'   : assertFailEvt.callStk.Entry(1).sender.specNb );  // QSYS Compile
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


     P testAssert_oldStyle...
     P                 b                   export
     D                 pi

     D expectedMsg     s            500a   varying
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Setup.

        expectedMsg = 'Successfully called old style assert()';

        // Execution.

        monitor;
           assert_oldStyle(*off:  expectedMsg);
           fail('Should have thrown an error');
        on-error;
        endmon;

        // Controls.

        assertFailEvtLong = getAssertFailEvtLong();

        assert(assertFailEvtLong.msg = expectedMsg
               : 'Message does not match the expected value');
        assert(%len(assertFailEvtLong.msg) = %len(expectedMsg)
               : 'Message lengths do not match');

      /end-free
     P                 e


     P testAssert_newStyle...
     P                 b                   export
     D                 pi

     D expectedMsg     s            500a   varying
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Setup.

        expectedMsg = 'Successfully called new style assert()';

        // Execution.

        monitor;
           assert_newStyle(*off:  expectedMsg);
           fail('Should have thrown an error');
        on-error;
        endmon;

        // Controls.

        assertFailEvtLong = getAssertFailEvtLong();

        assert(assertFailEvtLong.msg = expectedMsg
               : 'Message does not match the expected value');
        assert(%len(assertFailEvtLong.msg) = %len(expectedMsg)
               : 'Message lengths do not match');

      /end-free
     P                 e

