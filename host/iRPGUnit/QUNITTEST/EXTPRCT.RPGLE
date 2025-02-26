      // ==========================================================================
      //  iRPGUnit SelfTest - Test EXTPRC.s
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
      //     >>PARM<<  MODULE(&LI/EXTPRC    +
      //                      &LI/OBJECT    +
      //                      &LI/SRCMBR    +
      //                      &LI/USRSPC    +
      //                      );
      //     >>PARM<<    COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,EXTPRC
      /copy qinclude,OBJECT
      /copy qinclude,TEMPLATES
      /copy qinclude,TESTUTILS

       //----------------------------------------------------------------------
       //   Test Prototypes
       //----------------------------------------------------------------------

     D testOneProc     pr                  extproc('testOneProc')
     D testSeveralProc...
     D                 pr                  extproc('testSeveralProc')
     D testProcNmList  pr                  extproc('testProcNmList')
     D testSrvPgmNotFound...
     D                 pr                  extproc('testSrvPgmNotFound')

       //----------------------------------------------------------------------
       //   Private Procedure Prototypes
       //----------------------------------------------------------------------

       // The next three procedures are used to invoke the procptr in ProcNmList_t.

     D cnt             pr            10i 0 extproc(cnt_p)
     D  privateData                    *   const

     D getNm           pr                  extproc(getNm_p)
     D                                     like(ProcNm_t)
     D  privateData                    *   const

     D goToNext        pr                  extproc(goToNext_p)
     D  privateData                    *   const

       //----------------------------------------------------------------------
       //   Global Variables
       //----------------------------------------------------------------------

       // The next three pointers are used to invoke the procedures in ProcNmList_t.
     D cnt_p           s               *   procptr
     D getNm_p         s               *   procptr
     D goToNext_p      s               *   procptr

       //----------------------------------------------------------------------
       //   Procedures Definition
       //----------------------------------------------------------------------

     PtestOneProc      b                   export
     D                 pi

     D procList        ds                  likeds(ProcList_t)
     D procCnt         s             10i 0
     D procNm          s                   like(ProcNm_t)

      /free

        if (TestSuite_isDirty('SRVPGM1': 'QTEMP'));
           runCmd( 'RUCRTRPG TSTPGM(QTEMP/SRVPGM1) SRCFILE(QTESTCASES)' );
        endif;

        procList = loadProcList( 'SRVPGM1' );
        procCnt = cntProc( procList );

        iEqual( 1: procCnt );

        procNm = getProcNm( procList );

        aEqual( 'PROC1': procNm );

      /end-free
     P                 e


     PtestSeveralProc  b                   export
     D                 pi

     D procList        ds                  likeds(ProcList_t)
     D procCnt         s             10i 0
     D procNm          s                   like(ProcNm_t)

      /free

        if (TestSuite_isDirty('SRVPGM2': 'QTEMP'));
           runCmd( 'RUCRTRPG TSTPGM(QTEMP/SRVPGM2) SRCFILE(QTESTCASES)' );
        endif;

        procList = loadProcList( 'SRVPGM2' );
        procCnt = cntProc( procList );

        iEqual( 2: procCnt );

        procNm = getProcNm( procList );

        aEqual( 'PROC1': procNm );

        goToNextProc( procList );
        procNm = getProcNm( procList );

        aEqual( 'PROC2': procNm );

      /end-free
     P                 e


     PtestProcNmList   b                   export
     D                 pi

     D procList        ds                  likeds(ProcList_t)
     D procNmList      ds                  likeds(ProcNmList_t)
     D privateData     s               *   based(procNmList.handle)

      /free

        if (TestSuite_isDirty('SRVPGM2': 'QTEMP'));
           runCmd( 'RUCRTRPG TSTPGM(QTEMP/SRVPGM2) SRCFILE(QTESTCASES)' );
        endif;

        // Setup.

        procList = loadProcList( 'SRVPGM2' );

        // Execution.

        procNmList = getProcNmList( procList );

        // Controls.

        cnt_p      = procNmList.cnt;
        getNm_p    = procNmList.getNm;
        goToNext_p = procNmList.goToNext;

        iEqual( 2 : cnt( privateData ) );
        aEqual( 'PROC1' : getNm( privateData ) );
        goToNext( privateData );
        aEqual( 'PROC2' : getNm( privateData ) );

      /end-free
     P                 e


     PtestSrvPgmNotFound...
     P                 b                   export
     D                 pi
        monitor;
          loadProcList(' ');
          fail('loadProcList('' '') should raise an escape message.' );

        on-error;
          //
        endmon;
     P                 e
