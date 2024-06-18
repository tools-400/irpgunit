      // ==========================================================================
      //  iRPGUnit SelfTest - Test JOBLOG.
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

     D setUp...
     D                 pr                  extproc('setUp')
     D testNoMsgInJobLog...
     D                 pr                  extproc('testNoMsgInJobLog')
     D testMsgInJobLog...
     D                 pr                  extproc('testMsgInJobLog')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,TESTUTILS
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

     D sndMCH1211Msg...
     D                 pr                  extproc('sndMCH1211Msg')


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D testStartTime   s               z
     D assertCntBefore...
     D                 s             10i 0
     D assertCntAfter  s             10i 0


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P setUp           b                   export
     D                 pi
      /free

        testStartTime = getFullTimeStamp();
        clear assertCntBefore;
        clear assertCntAfter;

      /end-free
     P                 e


     P testNoMsgInJobLog...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Setup.

        assertCntBefore = getAssertCalled();

        // Run.

        monitor;
          assertJobLogContains( 'MCH1211' : testStartTime );
          fail( 'assertJobLogContains(...) should have raised a failure.' );
        on-error;
          // Exception message, as expected.
          assertFailEvt  = getAssertFailEvt();
          assertCntAfter = getAssertCalled();
        endmon;

        // Check.

        iEqual( assertCntBefore + 1 : assertCntAfter );
        aEqual( 'Message MCH1211 not found in the job log.' :
                assertFailEvt.msg );

      /end-free
     P                 e


     P testMsgInJobLog...
     P                 b                   export
     D                 pi
      /free

        // Setup.

        sndMCH1211Msg();
        assertCntBefore = getAssertCalled();

        // Run.

        assertJobLogContains( 'MCH1211' : testStartTime );

        // Check.

        assertCntAfter = getAssertCalled();
        iEqual( assertCntBefore + 1 : assertCntAfter );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Private Helper Procedures
      //----------------------------------------------------------------------

     P sndMCH1211Msg   b
     D                 pi

     D zero            s             10i 0 inz(0)
     D x               s             10i 0 inz(1)

      /free

        monitor;
          x = 1 / zero;
        on-error;
        endmon;

      /end-free
     P                 e
