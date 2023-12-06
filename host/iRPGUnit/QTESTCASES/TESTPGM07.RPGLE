      // ==========================================================================
      //  iRPGUnit Fixture - Failure in proc called by test.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     D failingProc     pr
     D testStack       pr

     P failingProc     b
     D                 pi
      /free

        iEqual(5:2+2);

      /end-free
     P                 e

     P testStack       b                   export
     D                 pi
      /free

        failingProc();

      /end-free
     P                 e

