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

       //----------------------------------------------------------------------
       //   Exported Procedures
       //----------------------------------------------------------------------

      /include qinclude,PGMRMT

       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /include qinclude,TEMPLATES
      /include qinclude,ASSERT
      /include qinclude,CMDRUNV
      /include qinclude,PGMMSG
      /include qinclude,RMTRUNSRV

      /include qinclude,SDS

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D PGMRMT...
     D                 pi
     D  go_returnCode                10I 0
     D  gi_userspace                       const  likeds(object_t )
     D  gi_testSuite                       const  likeds(object_t )
     D  gi_procNames                       const  likeds(ProcNms_t)
     D  gi_order                           const  like(order_t    )
     D  gi_detail                          const  like(detail_t   )
     D  gi_output                          const  like(output_t   )
     D  gi_libl                            const  likeDs(libL_t   )
     D  gi_qJobD                           const  likeDs(Object_t )
     D  gi_rclrsc                          const  like(rclrsc_t   )
     D  gi_xmlStmf                         const  like(stmf_fl_t  )
     D                                            options(*nopass)

     D p_xmlStmf       c                   10

     D xmlStmf         s                          like(stmf_t)
     D errMsg          s            256a   varying
      /free

       registerStartPgm(sds.pgmLib: sds.pgmName);

       if (%parms() >= p_xmlStmf and %addr(gi_xmlStmf) <> *null);
         xmlStmf = %trimr(gi_xmlStmf);
         if (xmlStmf <> '');
           errMsg = validateXmlStmf(xmlStmf: gi_testSuite);
           if (errMsg <> '');
             sndEscapeMsgAboveCtlBdy( errMsg  );
           endif;
         endif;
       else;
         xmlStmf = '';
       endif;

       go_returnCode =
            rpgunit_runTestSuite(
               gi_userspace: gi_testSuite: gi_procNames: gi_order
               : gi_detail: gi_output: gi_libl: gi_qJobD: gi_rclrsc: xmlStmf);

       *inlr = *on;

      /end-free
