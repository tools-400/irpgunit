      // ==========================================================================
      //  iRPGUnit Fixture - Two failing test cases.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     DtestFalse        pr
     DtestFalse2       pr

     PtestFalse        b                   export
     D                 pi
      /free

        iEqual(5: 2+2);

      /end-free
     P                 e

     PtestFalse2       b                   export
     D                 pi
      /free

        iEqual(6: 2+2);

      /end-free
     P                 e

