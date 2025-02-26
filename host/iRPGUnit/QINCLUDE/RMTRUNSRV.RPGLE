**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Adapter.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr rpgunit_runTestSuite int(10) extproc('RMTRUNSRV_rpgunit_runTestSuite');
  userspace       likeds(object_t) const;
  testsuitename   likeds(object_t) const;
  testprocs       likeds(procNms_t) const;
  order           like(order_t) const;
  detail          like(detail_t) const;
  output          like(output_t) const;
  libl            likeds(libl_t) const;
  qJobD           likeds(object_t) const;
  rclrsc          like(rclrsc_t) const;
  xmlstmf         like(stmf_t) const;
end-pr;

