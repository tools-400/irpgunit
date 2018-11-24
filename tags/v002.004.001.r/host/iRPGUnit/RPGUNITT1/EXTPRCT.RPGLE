      // =====================================================================
      //
      // Tests EXTPRC.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKEXTPRCT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKEXTPRCT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /copy RPGUNITY1,EXTPRC
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


       //----------------------------------------------------------------------
       //   Test Prototypes
       //----------------------------------------------------------------------

     D testOneProc     pr                  extproc('testOneProc')
     D testSeveralProc...
     D                 pr                  extproc('testSeveralProc')
     D testProcNmList  pr                  extproc('testProcNmList')
     D testSrvPgmNotFound...
     D                 pr                  extproc('testSrvPgmNotFound')
     D setUpSuite      pr                  extproc('setUpSuite')
     D tearDownSuite   pr                  extproc('tearDownSuite')


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
     DtestOneProc      pi

     D procList        ds                  likeds(ProcList_t)
     D procCnt         s             10i 0
     D procNm          s                   like(ProcNm_t)

      /free

        procList = loadProcList( 'SRVPGM1' );
        procCnt = cntProc( procList );

        iEqual( 1: procCnt );

        procNm = getProcNm( procList );

        aEqual( 'PROC1': procNm );

      /end-free
     PtestOneProc      e


     PtestSeveralProc  b                   export
     DtestSeveralProc  pi

     D procList        ds                  likeds(ProcList_t)
     D procCnt         s             10i 0
     D procNm          s                   like(ProcNm_t)

      /free

        procList = loadProcList( 'SRVPGM2' );
        procCnt = cntProc( procList );

        iEqual( 2: procCnt );

        procNm = getProcNm( procList );

        aEqual( 'PROC1': procNm );

        goToNextProc( procList );
        procNm = getProcNm( procList );

        aEqual( 'PROC2': procNm );

      /end-free
     PtestSeveralProc  e


     PtestProcNmList   b                   export
     DtestProcNmList   pi

     D procList        ds                  likeds(ProcList_t)
     D procNmList      ds                  likeds(ProcNmList_t)
     D privateData     s               *   based(procNmList.handle)

      /free

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
     DtestSrvPgmNotFound...
     D                 pi

     D escapeMsgSeen   s               n

      /free

        monitor;
          loadProcList(' ');
          escapeMsgSeen = *off;

        on-error;
          escapeMsgSeen = *on;
        endmon;

        assert( escapeMsgSeen:
                'loadProcList('' '') should raise an escape message.' );

      /end-free
     PtestSrvPgmNotFound...
     P                 e

     PsetUpSuite       b                   export
     DsetUpSuite       pi
      /free

        runcmd( 'RUCRTTST TSTPGM(QTEMP/SRVPGM1) SRCFILE(RPGUNITF1)' );
        runcmd( 'RUCRTTST TSTPGM(QTEMP/SRVPGM2) SRCFILE(RPGUNITF1)' );

      /end-free
     PsetUpSuite       e


     PtearDownSuite    b                   export
     DtearDownSuite    pi
      /free

        runcmd( 'DLTSRVPGM SRVPGM(QTEMP/SRVPGM1)' );
        runcmd( 'DLTSRVPGM SRVPGM(QTEMP/SRVPGM2)' );

      /end-free
     PtearDownSuite    e
