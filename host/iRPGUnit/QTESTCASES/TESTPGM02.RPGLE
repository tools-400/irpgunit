      // ==========================================================================
      //  iRPGUnit Fixture - One successful test case.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     DtestTrue         pr

     PtestTrue         b                   export
     DtestTrue         pi
      /free

        iEqual(4: 2+2);

      /end-free
     PtestTrue         e

