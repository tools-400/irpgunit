      // ==========================================================================
      //  iRPGUnit Fixture - Error during test.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     DtestError        pr

     PtestError        b                   export
     DtestError        pi
     D x               s             10i 0
     D zero            s             10i 0 inz(*zero)
      /free

        x = 1 / zero;

      /end-free
     PtestError        e

