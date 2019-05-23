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
     D  testSuiteName                      const likeds(Object_t)
     D  testProcs                          const likeds(ProcNms_t)
     D  order                              const like(order_t)
     D  detail                             const like(detail_t)
     D  output                             const like(output_t)
     D  libl                               const likeds(LibL_t)
     D  jobd                               const likeds(Object_t)
     D  rclRsc                             const like(rclrsc_t)
     D  xmlStmf                            const like(stmf_t)

      // Replace stream file path variables.
     D resolvePathVariables...
     D                 pr                  like(stmf_t)
     D  path                               const like(stmf_t)
     D  testSuiteName                      const likeds(Object_t)

      /include qinclude,CMDRUN
      /endif

