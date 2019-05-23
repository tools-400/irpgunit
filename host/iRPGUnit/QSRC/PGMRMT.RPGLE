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
      //     >>PARM<<  OPTION(*EVENTF);
      //     >>PARM<<  DBGVIEW(*LIST);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

      /include qinclude,PGMRMT

      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------

     D PGMRMT...
     D                 PI
     D  o_returnValue                10I 0
     D  i_userspace                        const  likeds(object_t )
     D  i_testSuite                        const  likeds(object_t )
     D  i_procNames                        const  likeds(ProcNms_t)
     D  i_order                            const  like(order_t    )
     D  i_detail                           const  like(detail_t   )
     D  i_output                           const  like(output_t   )
     D  i_libl                             const  likeDs(libL_t   )
     D  i_qJobD                            const  likeDs(Object_t )
     D  i_rclrsc                           const  like(rclrsc_t   )
     D  i_xmlStmf                          const  like(stmf_fl_t  )
     D                                            options(*nopass)

     D p_xmlStmf       c                   10

     D xmlStmf         s                          like(stmf_t)

      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include qinclude,RMTRUNSRV
      /include qinclude,TEMPLATES

        if (%parms() >= p_xmlStmf and %addr(i_xmlStmf) <> *null);
          xmlStmf = %trimr(i_xmlStmf);
        else;
          xmlStmf = '';
        endif;

        o_returnValue =
            rpgunit_runTestSuite(
               i_userspace: i_testSuite: i_procNames:
               i_order :i_detail: i_output: i_libl: i_qJobD: i_rclrsc: xmlStmf);

        *inlr = *on;
