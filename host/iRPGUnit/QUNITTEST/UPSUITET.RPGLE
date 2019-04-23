      //=====================================================================
      //  Tools/400 STRPREPRC instructions:
      //   >>PRE-COMPILER<<
      //     >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +
      //                             SRCFILE(&SL/&SF);
      //     >>COMPILE<<
      //       >>PARM<< COPTION(*SRCSTMT);
      //       >>PARM<< DBGVIEW(*LIST);
      //       >>PARM<< BNDDIR(*N);
      //     >>END-COMPILE<<
      //     >>EXECUTE<<
      //   >>END-PRE-COMPILER<<
      //=====================================================================

      //
      // Unit tests for ASSERT.
      //

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D testExampleTestProc...
     D                 pr                  extproc('testExampleTestProc')

     D setUpSuite      pr                  extproc('setUpSuite')
     D setUp           pr                  extproc('setUp')
     D tearDown        pr                  extproc('tearDown')
     D tearDownSuite   pr                  extproc('tearDownSuite')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,TEMPLATES
      /include qsrc,TESTCASE

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Setup Suite
      //----------------------------------------------------------------------

     P setUpSuite...
     P                 b                   export
     D                 pi

     D x               s             10i 0
     D y               s             10i 0
      /free

         y = 6 / x;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Setup Test Case
      //----------------------------------------------------------------------

     P setUp...
     P                 b                   export
     D                 pi

     D x               s             10i 0
     D y               s             10i 0
      /free

         // y = 6 / x;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Teardown Test Case
      //----------------------------------------------------------------------

     P tearDown...
     P                 b                   export
     D                 pi

     D x               s             10i 0
     D y               s             10i 0
      /free

         // y = 6 / x;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Teardown Suite
      //----------------------------------------------------------------------

     P tearDownSuite...
     P                 b                   export
     D                 pi

     D x               s             10i 0
     D y               s             10i 0
      /free

         // y = 6 / x;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     P testCase1...
     P                 b                   export
     D                 pi

      /free

         iEqual(1: 0: 'ERROR: testCase1');

      /end-free
     P                 e

     P testCase2...
     P                 b                   export
     D                 pi

      /free

         // iEqual(2: 0: 'ERROR: testCase2');

      /end-free
     P                 e

     P testCase3...
     P                 b                   export
     D                 pi

      /free

         iEqual(3: 0: 'ERROR: testCase3');

      /end-free
     P                 e

