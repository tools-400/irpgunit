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

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')

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

     D testLongFailureAEqual...
     D                 pr                  extproc('testLongFailureAEqual')
     D testLongFailureAssert...
     D                 pr                  extproc('testLongFailureAssert')
     D testLongError...
     D                 pr                  extproc('testLongError')

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
     P setUpSuite...
     P                 b                   export
     D                 pi

     D rc              S              1A
      /free


      /end-free
     P                 e

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
     P testLongFailureAEqual...
     P                 b                   export
     D                 pi

     D url1            S            200A   varying
     D url2            S            200A   varying
      /free

         url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
                 004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
                 roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
                 rview';

         url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
                 c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
                 VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
                 rview/joe.street';

         aEqual(url1: url2:  'URL');

      /end-free
     P                 e

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
     P testLongFailureAssert...
     P                 b                   export
     D                 pi

     D url1            S            200A   varying
     D url2            S            200A   varying
      /free

         url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
                 004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
                 roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
                 rview';

         url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
                 c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
                 VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
                 rview/joe.street';

         assert(url1 = url2:  'URL: Expected"' +
                              url1 + '" but was "' + url2 + '"');

      /end-free
     P                 e

