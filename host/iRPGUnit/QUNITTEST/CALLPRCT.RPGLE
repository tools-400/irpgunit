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
      //                      &LI/JOBLOG    +
      //                      &LI/LLIST     +
      //                      &LI/OBJECT    +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
      //                      &LI/SRCMBR    +
      //                      &LI/STRING    +
      //                      &LI/USRSPC    +
      //                      );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
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

