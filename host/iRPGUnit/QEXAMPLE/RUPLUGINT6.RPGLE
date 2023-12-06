      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. ON-EXIT op-code.
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

      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     D testOnExitNoError...
     D                 pr                  extproc('testOnExitNoError')
     D testOnExitWithError...
     D                 pr                  extproc('testOnExitWithError')

     D onExitProcNoError...
     D                 pr                  extproc('onExitProcNoError')
     D  io_onExitWasCalled...
     D                                 N

     D onExitProcWithError...
     D                 pr                  extproc('onExitProcWithError')
     D  io_onExitWasCalled...
     D                                 N

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
      //  Test that on-exit is called and that
      //  isAbnormalEnd is set to *OFF.
      // ============================================================
     P testOnExitNoError...
     P                 b                   export
     D                 pi

     D onExitWasCalled...
     D                 S               N
      /free

         onExitProcNoError(onExitWasCalled);

         nEqual(*on: onExitWasCalled: 'onExitWasCalled');

      /end-free
     P                 e

      // ============================================================
      //  Test that on-exit is called and that
      //  isAbnormalEnd is set to *OFF.
      // ============================================================
     P testOnExitWithError...
     P                 b                   export
     D                 pi

     D onExitWasCalled...
     D                 S               N
     D excpWasSeen     S               N
      /free

         monitor;
            onExitProcWithError(onExitWasCalled);
            excpWasSeen = *off;
         on-error;
            excpWasSeen = *on;
         endmon;

         nEqual(*on: excpWasSeen: 'excpWasSeen');
         nEqual(*on: onExitWasCalled: 'onExitWasCalled');

      /end-free
     P                 e

      // ============================================================
      //  Procedure, that is called on-exit.
      // ============================================================
     P onExitProcNoError...
     P                 b                   export
     D                 pi
     D  io_onExitWasCalled...
     D                                 N

     D isAbnormalEnde  s               N
      /free

         on-exit isAbnormalEnde;

            io_onExitWasCalled = *on;

      /end-free
     P                 e

      // ============================================================
      //  Procedure, that is called on-exit.
      // ============================================================
     P onExitProcWithError...
     P                 b                   export
     D                 pi
     D  io_onExitWasCalled...
     D                                 N

     D value1          s             10i 0
     D value2          s             10i 0

     D isAbnormalEnde  s               N
      /free

         value1 = 10;
         value2 = 0;

         // division by zero!
         value2 = value1 / value2;

         on-exit isAbnormalEnde;

            io_onExitWasCalled = *on;

      /end-free
     P                 e

