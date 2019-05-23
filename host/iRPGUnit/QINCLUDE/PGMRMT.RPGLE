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
     D  i_returnValue                10I 0
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

