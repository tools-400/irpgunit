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

     H NoMain Option(*SrcStmt : *NoDebugIO)

     D g_dtaara        s             21a   inz

     D dataStore       ds            50    dtaara(*var:g_dtaara) qualified
     D  toggle1                       1n   inz
     D  toggle2                       1n   inz
     D  reserved                     48a   inz

     D sds            sds                  qualified
     D  pgmName                1     10a
     D  pgmLib                81     90a

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')

     D testAllOK_1...
     D                 pr                  extproc('testAllOK_1')

     D testAllOK_2...
     D                 pr                  extproc('testAllOK_2')

     D testToggleOK_1...
     D                 pr                  extproc('testToggleOK_1')

     D testToggleOK_2...
     D                 pr                  extproc('testToggleOK_2')

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

      //  Internal procedure to toggle the boolean flag 2.
     D internalToggleOK_2...
     D                 pr                  extproc('internalToggleOK_2')

      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
     P setUpSuite...
     P                 b                   export
     D                 pi

     D rc              S              1A
      /free

         monitor;
            g_dtaara = %trim(sds.pgmLib) + '/' + %trim(sds.pgmName);
            runCmd(
               'CRTDTAARA DTAARA(' + %trim(g_dtaara) + ') TYPE(*CHAR) LEN(50) +
                  TEXT(''RPGUnit Data Store of ' + %trim(sds.pgmName) + ''')');
         on-error;
            // ignore errors ...
         endmon;

      /end-free
     P                 e

      // ============================================================
      //  Contains 1 assertion, all TRUE.
      // ============================================================
     P testAllOK_1...
     P                 b                   export
     D                 pi
      /free

        assert(*on : 'OK: 1');

      /end-free
     P                 e

      // ============================================================
      //  Contains 2 assertions, all TRUE.
      // ============================================================
     P testAllOK_2...
     P                 b                   export
     D                 pi
      /free

        assert(*on : 'OK: 1');
        assert(*on : 'OK: 2');

      /end-free
     P                 e

      // ============================================================
      //  Toggles the boolean flag 1. Checks the flag for *ON.
      // ============================================================
     P testToggleOK_1...
     P                 b                   export
     D                 pi

     D seconds         s             10i 0 inz
      /free

        in *lock dataStore;
        dataStore.toggle1 = not dataStore.toggle1;
        out dataStore;

        assert(dataStore.toggle1: 'Toggle flag 1 must be *ON');

      /end-free
     P                 e

      // ============================================================
      //  Toggles the boolean flag 2. Checks the flag for *OFF.
      // ============================================================
     P testToggleOK_2...
     P                 b                   export
     D                 pi

     D seconds         s             10i 0 inz
      /free

        internalToggleOK_2();

      /end-free
     P                 e

      // ============================================================
      //  Internal procedure to toggle the boolean flag 2.
      // ============================================================
     P internalToggleOK_2...
     P                 b                   export
     D                 pi

     D seconds         s             10i 0 inz
      /free

        in *lock dataStore;
        dataStore.toggle2 = not dataStore.toggle2;
        out dataStore;

        assert(not dataStore.toggle2: 'Toggle flag 2 must be *OFF');

      /end-free
     P                 e

