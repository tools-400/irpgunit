**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Test Runner.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr pgmrmt extpgm('PGMRMT');
  go_returncode   int(10);
  gi_userspace    const  likeds(object_t);
  gi_testsuite    const  likeds(object_t);
  gi_procnames    const  likeds(procNms_t);
  gi_order        const  like(order_t);
  gi_detail       const  like(detail_t);
  gi_output       const  like(output_t);
  gi_libl         const  likeds(libl_t);
  gi_qJobD        const  likeds(object_t);
  gi_rclrsc       const  like(rclrsc_t);
  gi_xmlstmf      const  like(stmf_fl_t) options(*nopass);
end-pr;

