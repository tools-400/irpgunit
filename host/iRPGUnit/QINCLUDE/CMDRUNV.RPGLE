      /if not defined(CMDRUNV)
      /define CMDRUNV
      // ==========================================================================
      //  iRPGUnit - RUCALLTST Validity checking program.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // The entry point of RUCALLTST. Parameters are provided by RUCALLTST command.
     D cmdRunV         pr                  extpgm('CMDRUNV')
     D  gi_testSuite                       const likeds(Object_t)
     D  gi_testProcs                       const likeds(ProcNms_t)
     D  gi_order                           const like(order_t)
     D  gi_detail                          const like(detail_t)
     D  gi_output                          const like(output_t)
     D  gi_libl                            const likeds(LibL_t)
     D  gi_jobd                            const likeds(Object_t)
     D  gi_rclRsc                          const like(rclrsc_t)
     D  gi_xmlStmf                         const like(stmf_t)

     D validateXmlStmf...
     D                 pr           256a   varying
     D                                     extproc('CMDRUNV_+
     D                                     validateXmlStmf+
     D                                     ')
     D  i_xmlStmf                          const like(stmf_t)

     D resolvePathVariables...
     D                 pr                  like(stmf_t)
     D                                     extproc('CMDRUNV_+
     D                                     resolvePathVariables+
     D                                     ')
     D  i_path                             const like(stmf_t)
     D  i_testSuite                        const likeds(Object_t)

      /include qinclude,CMDRUN
      /endif

