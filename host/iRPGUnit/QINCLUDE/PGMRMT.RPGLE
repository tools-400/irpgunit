      // ==========================================================================
      //  iRPGUnit - Plug-in Test Runner.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     D PGMRMT          PR                  extpgm('PGMRMT')
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

