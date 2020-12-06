      // ==========================================================================
      //  iRPGUnit SelfTest - Operational Desc. for Cobol.
      // ==========================================================================
      //  Copyright (c) 2013-2020 iRPGUnit Project Team
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

     D testAssert_oldStyle...
     D                 pr                  extproc('testAssert_oldStyle')
     D testAssert_newStyle_without_OPDESC...
     D                 pr                  extproc(
     D                                     'testAssert_newStyle_without_OPDESC')
     D testAssert_newStyle_with_OPDESC...
     D                 pr                  extproc(
     D                                     'testAssert_newStyle_with_OPDESC')


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

     D assert_newStyle_with_opdesc...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D                                     opdesc
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying
     D                                           options(*varsize: *nopass)

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D callFailInAMonitorBlock...
     D                 pr              n   extproc('callFailInAMonitorBlock')


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //  The the old style of parameter 'msgIfFalse', which was a
      //  128-byte fix-length field.
      //----------------------------------------------------------------------
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


      //----------------------------------------------------------------------
      //  The the new style of parameter 'msgIfFalse', which is a
      //  16384-byte varying-length field.
      //----------------------------------------------------------------------
     P testAssert_newStyle_without_OPDESC...
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


      //----------------------------------------------------------------------
      //  The the new style of parameter 'msgIfFalse', which is a
      //  16384-byte varying-length field with an operational descriptor.
      //  Since: 4.0 due to the Cobol enhancements.
      //----------------------------------------------------------------------
     P testAssert_newStyle_with_OPDESC...
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
           assert_newStyle_with_opdesc(*off:  expectedMsg);
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

      //----------------------------------------------------------------------
      //   Helper Procedures
      //----------------------------------------------------------------------

     P callFailInAMonitorBlock...
     P                 b
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

