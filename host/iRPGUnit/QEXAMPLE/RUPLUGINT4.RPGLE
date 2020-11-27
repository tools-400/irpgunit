      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. No Test Cases.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      //    >>PRE-COMPILER<<
      //      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
      //                              SRCFILE(&SL/&SF) SRCMBR(&SM);
      //      >>IMPORTANT<<
      //        >>PARM<< COPTION(*SRCSTMT *EVENTF);
      //        >>PARM<< DBGVIEW(*LIST);
      //      >>END-IMPORTANT<<
      //      >>EXECUTE<<
      //    >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,TESTCASE

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

