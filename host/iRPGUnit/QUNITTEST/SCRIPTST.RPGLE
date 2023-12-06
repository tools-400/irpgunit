      // ==========================================================================
      //  iRPGUnit SelfTest - Test MK* Scripts.
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
      //     >>PARM<<  COPTION(*EVENTF);
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
     D tearDownSuite...
     D                 pr                  extproc('tearDownSuite')
     D testMKACPTSTT...
     D                 pr                  extproc('testMKACPTSTT')
     D testMKASSERTT...
     D                 pr                  extproc('testMKASSERTT')
     D testMKCALLPRCT...
     D                 pr                  extproc('testMKCALLPRCT')
     D testMKCMDRUNLT...
     D                 pr                  extproc('testMKCMDRUNLT')
     D testMKCMDRUNT...
     D                 pr                  extproc('testMKCMDRUNT')
     D testMKCRTTSTT...
     D                 pr                  extproc('testMKCRTTSTT')
     D testMKEXTPRCT...
     D                 pr                  extproc('testMKEXTPRCT')
     D testMKEXTTSTT...
     D                 pr                  extproc('testMKEXTTSTT')
     D testMKJOBLOGT...
     D                 pr                  extproc('testMKJOBLOGT')
     D testMKLIBLT...
     D                 pr                  extproc('testMKLIBLT')
     D testMKMSGQT...
     D                 pr                  extproc('testMKMSGQT')
     D testMKPGMMSGT...
     D                 pr                  extproc('testMKPGMMSGT')
     D testMKRUNT...
     D                 pr                  extproc('testMKRUNT')
     D testMKSTRINGT...
     D                 pr                  extproc('testMKSTRINGT')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     d executeScript...
     d                 pr                  extproc('executeScript')
     d  script                       10a   const varying options(*trim)

     d deleteTestSuite...
     d                 pr                  extproc('deleteTestSuite')
     d  srvPgm                       10a   const varying options(*trim)

     d checkTestSuite...
     d                 pr              n   extproc('checkTestSuite')
     d  srvPgm                       10a   const varying options(*trim)

     d cleanup...
     d                 pr                  extproc('cleanup')


      //----------------------------------------------------------------------
      //   Program Status Data Structure
      //----------------------------------------------------------------------

      /copy qinclude,SDS


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P setUp           b                   export
     D                 pi
      /free

        cleanup();

      /end-free
     P                 e


     P tearDownSuite   b                   export
     D                 pi
      /free

        cleanup();

      /end-free
     P                 e


     P testMKACPTSTT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'ACPTSTT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKACPTSTT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKASSERTT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'ASSERTT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKASSERTT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKCALLPRCT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'CALLPRCT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKCALLPRCT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKCMDRUNLT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'CMDRUNLOGT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKCMDRUNLT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKCMDRUNT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'CMDRUNT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKCMDRUNT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKCRTTSTT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'CRTTSTT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKCRTTSTT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKEXTPRCT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'EXTPRCT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKEXTPRCT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKEXTTSTT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'EXTTSTT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKEXTTSTT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKJOBLOGT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'JOBLOGT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKJOBLOGT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKLIBLT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'LIBLT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKLIBLT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKMSGQT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'MSGQT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKMSGQT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKPGMMSGT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'PGMMSGT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKPGMMSGT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKRUNT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'RUNT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKRUNT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     P testMKSTRINGT...
     P                 b                   export
     D                 pi

     D TEST_SUITE      c                   'STRINGT'
      /free

        // Setup.

        deleteTestSuite(TEST_SUITE);

        // Run.

        executeScript('MKSTRINGT');

        // Check.

        assert(checkTestSuite(TEST_SUITE)
               : 'Service program ' + TEST_SUITE + ' not found.');

      /end-free
     P                 e


     p executeScript...
     p                 b
     d                 pi
     d  script                       10a   const varying options(*trim)
     D params          s            100a   varying
      /free

        params = %trim(sds.pgmLib) + ' NONE';

        runCmd('STRREXPRC SRCMBR(' + script + ') +
                SRCFILE(' + %trim(sds.pgmLib) + '/QUNITTEST) +
                PARM(''' + params + ''')');

      /end-free
     p                 e


     p deleteTestSuite...
     p                 b
     d                 pi
     d  srvPgm                       10a   const varying options(*trim)
      /free

        monitor;
          runCmd('DLTSRVPGM SRVPGM(' + %trim(sds.pgmLib) + '/' + srvPgm + ')');
        on-error;
          // Ignore not found error
        endmon;

      /end-free
     p                 e


     p checkTestSuite...
     p                 b
     d                 pi              n
     d  srvPgm                       10a   const varying options(*trim)
      /free

        monitor;
          runCmd('CHKOBJ OBJ(' + %trim(sds.pgmLib) + '/' + srvPgm + ') +
                  OBJTYPE(*SRVPGM)');
          return *on;
        on-error;
          return *off;
        endmon;

      /end-free
     p                 e


     P cleanup         b                   export
     D                 pi
     D params          s            100a   varying
      /free

        params = 'CLEAN ' + %trim(sds.pgmLib);

        runCmd('STRREXPRC SRCMBR(A_INSTALL) +
                SRCFILE(' + %trim(sds.pgmLib) + '/QBUILD) +
                PARM(''' + params + ''')');

      /end-free
     P                 e

