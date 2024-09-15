      // ==========================================================================
      //  iRPGUnit Fixture - Test options(*exact)
      // ==========================================================================
      //  Copyright (c) 2013-2024 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     DtestOptionsExact...
     D                 pr

     DtestOptionsExact...
     D                 pi

     D actualDecLoss   s             30s25 inz(1,1234567890123456789012345)
     D expectedDecLoss...
     D                 s             30s25 inz(1,1234567890123456789012345)
      /free

       assertEqual( actualDecLoss : expectedDecLoss );

      /end-free
     P                 e

