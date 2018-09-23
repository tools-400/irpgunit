      // =====================================================================
      //    >>PRE-COMPILER<<
      //      >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +
      //                              SRCFILE(&SL/&SF) SRCMBR(&SM);
      //      >>COMPILE<<
      //        >>PARM<< COPTION(*SRCSTMT *EVENTF);
      //        >>PARM<< DBGVIEW(*LIST);
      //      >>END-COMPILE<<
      //      >>EXECUTE<<
      //    >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D testAllOK_2...
     D                 pr                  extproc('testAllOK_2')

     D testError_1...
     D                 pr                  extproc('testError_1')

     D testError_2...
     D                 pr                  extproc('testError_2')

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P testAllOK_2...
     P                 b                   export
     D                 pi
      /free

        assert(*on : 'OK: 1');
        assert(*on : 'OK: 2');

      /end-free
     P                 e

     P testError_1...
     P                 b                   export
     D                 pi

     D a               s             10i 0
     D b               s             10i 0
      /free

        b = a / b;

        assert(*on :  'NEVER REACHED');

      /end-free
     P                 e

     P testError_2...
     P                 b                   export
     D                 pi

     D a               s             10i 0
     D b               s             10i 0
      /free

        b = a / b;

        assert(*on :  'NEVER REACHED');

      /end-free
     P                 e

