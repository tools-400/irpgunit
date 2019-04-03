      // =====================================================================
      //
      // Unit tests for JOBLOG.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKJOBLOGT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKJOBLOGT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

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

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,JOBLOG
      /copy RPGUNITY1,TEMPLATES


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
     D setUp           pi
      /free

        testStartTime = getFullTimeStamp();
        clear assertCntBefore;
        clear assertCntAfter;

      /end-free
     P setUp           e


     P testNoMsgInJobLog...
     P                 b                   export
     D testNoMsgInJobLog...
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
     P testNoMsgInJobLog...
     P                 e


     P testMsgInJobLog...
     P                 b                   export
     D testMsgInJobLog...
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
     P testMsgInJobLog...
     P                 e


      //----------------------------------------------------------------------
      //   Private Helper Procedures
      //----------------------------------------------------------------------

     P sndMCH1211Msg   b
     D sndMCH1211Msg   pi

     D zero            s             10i 0 inz(0)
     D x               s             10i 0 inz(1)

      /free

        monitor;
          x = 1 / zero;
        on-error;
        endmon;

      /end-free
     P sndMCH1211Msg   e
