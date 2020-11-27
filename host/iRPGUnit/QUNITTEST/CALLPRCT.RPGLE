      // ==========================================================================
      //  iRPGUnit SelfTest - Test CALLPRC.
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
      //     >>PARM<<  MODULE(&LI/CALLPRC   +
      //                      &LI/CMDRUNLOG +
      //                      &LI/CMDRUNPRT +
      //                      &LI/CMDRUNSRV +
      //                      &LI/EXTPRC    +
      //                      &LI/EXTTST    +
      //                      &LI/LLIST     +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
      //                      &LI/STRING    +
      //                      &LI/USRSPC    +
      //                      );
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     DtestCallProcByPtr...
     D                 pr                  extproc('testCallProcByPtr')
     DtestCallProcByPtr_NullPtr...
     D                 pr                  extproc('testCallProcByPtr_NullPtr')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,CALLPRC
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D mockProc        pr


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D mockProcWasCalled...
     D                 s               n


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     PtestCallProcByPtr...
     P                 b                   export
     DtestCallProcByPtr...
     D                 pi
      /free

        mockProcWasCalled = *off;

        callProcByPtr( %paddr( mockProc ) );

        assert( mockProcWasCalled : 'mockProc not called' );

      /end-free
     P                 e


     PtestCallProcByPtr_NullPtr...
     P                 b                   export
     DtestCallProcByPtr_NullPtr...
     D                 pi
      /free

        monitor;
          callProcByPtr( *null );
        on-error;
          fail( 'callProcByPtr(*null) should not raise an error' );
        endmon;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     P mockProc        b
     D mockProc        pi
      /free

        mockProcWasCalled = *on;

      /end-free
     P                 e

