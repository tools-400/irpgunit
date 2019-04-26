      // ==========================================================================
      //  iRPGUnit - Plug-in Adapter.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     D rpgunit_runTestSuite...
     D                 PR            10I 0 extproc('RMTRUNSRV_+
     D                                     rpgunit_runTestSuite')
     D  userspace                          likeds(object_t ) const
     D  testSuiteName                      likeds(object_t ) const
     D  testProcs                          likeds(ProcNms_t) const
     D  order                              like(order_t    ) const
     D  detail                             like(detail_t   ) const
     D  output                             like(output_t   ) const
     D  libl                               likeDs(libL_t   ) const
     D  qJobD                              likeDs(Object_t ) const
     D  rclrsc                             like(rclrsc_t   ) const

