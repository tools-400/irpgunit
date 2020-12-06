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

     D testAssert_v3_oldStyle...
     D                 pr                  extproc('testAssert_v3_oldStyle')
     D testAssert_v3_newStyle...
     D                 pr                  extproc(
     D                                     'testAssert_v3_newStyle')
     D testAssert_v4_varying_length...
     D                 pr                  extproc(
     D                                     'testAssert_v4_varying_length')

     D testAEqual_v3...
     D                 pr                  extproc(
     D                                     'testAEqual_v3')
     D testAEqual_v4_fix_length...
     D                 pr                  extproc(
     D                                     'testAEqual_v4_fix_length')
     D testAEqual_v4_varying_length...
     D                 pr                  extproc(
     D                                     'testAEqual_v4_varying_length')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   v3 and v4 prototypes.
      //----------------------------------------------------------------------

      // assert() prototypes old style, new style
      // and brand new style with 'opdesc' (v4).
     D assert_v3_oldStyle...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D  condition                      n   const
     D  msgIfFalse                         const like(OldMsg_t) options(*nopass)

     D assert_v3_newStyle...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying
     D                                           options(*varsize: *nopass)

     D assert_v4_fix_length...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D                                     opdesc
     D  condition                      n   const
     D  msgIfFalse                16384a   const options(*varsize: *nopass)

     D assert_v4_varying_length...
     D                 pr                  extproc('+
     D                                     assert+
     D                                     ')
     D                                     opdesc
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying
     D                                           options(*varsize: *nopass)

      // aEqual() prototypes with and without 'opdesc'.
     D aEqual_v3       pr                  extproc('+
     D                                     aEqual+
     D                                     ')
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const varying options(*nopass: *omit)

     D aEqual_v4_fix_length...
     D                 pr                  extproc('+
     D                                     aEqual+
     D                                     ')
     D                                     opdesc
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const options(*nopass: *omit)

     D aEqual_varying_length...
     D                 pr                  extproc('+
     D                                     aEqual+
     D                                     ')
     D                                     opdesc
     D  expected                  32565a   const varying
     D  actual                    32565a   const varying
     D  fieldName                    64a   const varying options(*nopass: *omit)


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //  Test the old v3 style of parameter 'msgIfFalse', which was a
      //  128-byte fix-length field.
      //----------------------------------------------------------------------
     P testAssert_v3_oldStyle...
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
           assert_v3_oldStyle(*off:  expectedMsg);
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
      //  The the new v3 style of parameter 'msgIfFalse', which is a
      //  16384-byte varying-length field.
      //----------------------------------------------------------------------
     P testAssert_v3_newStyle...
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
           assert_v3_newStyle(*off:  expectedMsg);
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
      //  Test the new v4 style of parameter 'msgIfFalse' with an
      //  operational descriptor and a fix-length field.
      //  Most likely used by Cobol test cases.
      //----------------------------------------------------------------------
     P testAssert_v4_fix_length...
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
           assert_v4_fix_length(*off:  expectedMsg);
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
      //  Test the new v4 style of parameter 'msgIfFalse' with an
      //  operational descriptor and a varying length field.
      //----------------------------------------------------------------------
     P testAssert_v4_varying_length...
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
           assert_v4_varying_length(*off:  expectedMsg);
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
      //  Test aEqual() with v3 parameter types and without the
      //  'opdesc' keyword.
      //----------------------------------------------------------------------
     P testAEqual_v3...
     P                 b                   export
     D                 pi

     D expectedMsg     s            500a   varying
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Setup.

        expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

        // Execution.

        monitor;
           aEqual_v3('A': 'B':  'aFieldName');
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
      //  Test the new v4 style with an
      //  operational descriptor and a fix-length fields.
      //  Most likely used by Cobol test cases.
      //----------------------------------------------------------------------
     P testAEqual_v4_fix_length...
     P                 b                   export
     D                 pi

     D expectedMsg     s            500a   varying
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Setup.

        expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

        // Execution.

        monitor;
           aEqual_v4_fix_length('A': 'B':  'aFieldName');
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
      //  Test the new v4 style with an
      //  operational descriptor and a varying-length fields.
      //----------------------------------------------------------------------
     P testAEqual_v4_varying_length...
     P                 b                   export
     D                 pi

     D expectedMsg     s            500a   varying
     D assertFailEvtLong...
     D                 ds                  likeds(assertFailEvtLong_t)
      /free

        // Setup.

        expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

        // Execution.

        monitor;
           aEqual_varying_length('A': 'B':  'aFieldName');
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

