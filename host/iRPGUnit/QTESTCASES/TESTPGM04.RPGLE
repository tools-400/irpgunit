      // ==========================================================================
      //  iRPGUnit Fixture - Exported proc is not a test.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     Dtest1            pr
     Dtest2            pr
     Dnot_a_test       pr

     Ptest1            b                   export
     Dtest1            pi
     Ptest1            e

     Ptest2            b                   export
     Dtest2            pi
     Ptest2            e

     Pnot_a_test       b                   export
     Dnot_a_test       pi
      /free

        fail('not_a_test should not be called.');

      /end-free
     Pnot_a_test       e

