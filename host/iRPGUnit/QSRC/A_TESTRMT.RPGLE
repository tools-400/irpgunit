      // ==========================================================================
      //  iRPGUnit - Plug-in Test Runner.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  TRUNCNBR(*NO);
      //     >>PARM<<  DBGVIEW(*LIST);
      //     >>PARM<<  OPTION(*EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUN   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNV  ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JSONWTR  ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STMF     ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/RMTRUNSRV) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/XMLWRITER) SRCFILE(&SL/QSRC  ) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      //   >>CMD<<     CRTPGM  PGM(&LI/&OB) +
      //                       BNDSRVPGM(*LIBL/RUTESTCASE) +
      //                       ACTGRP(*NEW) +
      //               MODULE(&LI/&OB       +
      //                      &LI/CALLPRC   +
      //                      &LI/CMDRUN    +
      //                      &LI/CMDRUNLOG +
      //                      &LI/CMDRUNPRT +
      //                      &LI/CMDRUNSRV +
      //                      &LI/CMDRUNV   +
      //                      &LI/EXTPRC    +
      //                      &LI/EXTTST    +
      //                      &LI/JOBLOG    +
      //                      &LI/JSONWTR   +
      //                      &LI/LIBL      +
      //                      &LI/LLIST     +
      //                      &LI/OBJECT    +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
      //                      &LI/STMF      +
      //                      &LI/SRCMBR    +
      //                      &LI/STRING    +
      //                      &LI/USRSPC    +
      //                      &LI/RMTRUNSRV +
      //                      &LI/XMLWRITER +
      //                      );
      // >>END-PRE-COMPILER<<
      // ==========================================================================

      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   Exported Procedures
       //----------------------------------------------------------------------

     D A_TESTRMT...
     D                 pr                  extpgm('A_TESTRMT')

       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /include qinclude,TEMPLATES
      /include qinclude,CMDRUNSRV
      /include qinclude,CMDRUNV
      /include qinclude,PGMMSG
      /include qinclude,RMTRUNSRV
      /include qinclude,USRSPC

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D A_TESTRMT...
     D                 pi

     D  g_isSuccess...
     D                 s               n   inz
     D  gi_userspace   ds                  likeds(object_t) inz
     D  gi_testSuite   ds                  likeds(object_t) inz
     D  gi_procNames   ds                  likeds(ProcNms_t) inz
     D  gi_order       s                   like(order_t) inz
     D  gi_detail      s                   like(detail_t) inz
     D  gi_output      s                   like(output_t) inz
     D  gi_libl        ds                  likeDs(libL_t) inz
     D  gi_qJobD       ds                  likeDs(Object_t) inz
     D  gi_rclrsc      s                   like(rclrsc_t) inz
     D  gi_xmlStmf     s                   like(stmf_fl_t) inz
     D  gi_xmlType     s                   like(xmlType_t) inz
     D  gio_msg        s            256a   varying inz

     D g_qUsrSpc       ds                  likeds(Object_t ) inz
      /free

       g_qUsrSpc.nm = 'A_TESTRMT';
       g_qUsrSpc.lib = 'QTEMP';
       crtUsrSpc(g_qUsrSpc: 'iRPGUnit - User Space of A_TESTRMT');

       gi_userspace.lib = 'QTEMP';
       gi_userspace.nm = 'A_TESTRMT';
       gi_testSuite.lib = 'RPGUNITDVP';
       gi_testSuite.nm = 'RUPLUGINT3';
       gi_procNames.numE = 2;
       gi_procNames.name(1) = 'testToggleOK_1';
       gi_procNames.name(2) = 'testToggleOK_2';
       gi_order = ORDER_API;
       gi_detail = DETAIL_BASIC;
       gi_output = OUTPUT_ERROR;
       gi_libl.numE = 1;
       gi_libl.lib(1) = LIBRARY_LIST_CURRENT;
       gi_qJobD.lib = '';
       gi_qJobD.nm = JOBD_DEFAULT;
       gi_rclrsc = RCLRSC_NO;
       gi_xmlStmf = '';
       gi_xmlType = '*TYPE2';

       g_isSuccess=
            runTestSuite(
               gi_userspace: gi_testSuite: gi_procNames: gi_order:
               gi_detail: gi_output: gi_libl: gi_qJobD: gi_rclrsc:
               gi_xmlStmf: gi_xmlType: gio_msg);

       *inlr = *on;

      /end-free
