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
      //   >>END-IMPORTANT<<
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
      //                      &LI/LIBL      +
      //                      &LI/LLIST     +
      //                      &LI/OSVERSION +
      //                      &LI/PGMMSG    +
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
      /include qinclude,CMDRUNV
      /include qinclude,PGMMSG
      /include qinclude,RMTRUNSRV
      /include qinclude,USRSPC

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D A_TESTRMT...
     D                 pi

     D  go_returnCode  s             10I 0 inz
     D  gi_userspace   ds                  likeds(object_t ) inz
     D  gi_testSuite   ds                  likeds(object_t ) inz
     D  gi_procNames   ds                  likeds(ProcNms_t) inz
     D  gi_order       s                   like(order_t    ) inz
     D  gi_detail      s                   like(detail_t   ) inz
     D  gi_output      s                   like(output_t   ) inz
     D  gi_libl        ds                  likeDs(libL_t   ) inz
     D  gi_qJobD       ds                  likeDs(Object_t ) inz
     D  gi_rclrsc      s                   like(rclrsc_t   ) inz
     D  gi_xmlStmf     s                   like(stmf_fl_t  ) inz

     D qUsrSpc         ds                  likeds(Object_t ) inz
      /free

       qUsrSpc.nm = 'A_TESTRMT';
       qUsrSpc.lib = 'QTEMP';
       crtUsrSpc(qUsrSpc: 'iRPGUnit - User Space of A_TESTRMT');

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

       go_returnCode =
            rpgunit_runTestSuite(
               gi_userspace: gi_testSuite: gi_procNames: gi_order
             : gi_detail: gi_output: gi_libl: gi_qJobD: gi_rclrsc: gi_xmlStmf);

       *inlr = *on;

      /end-free
