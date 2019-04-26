      // ==========================================================================
      //  iRPGUnit Fixture - Big integers.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE

     Dtest_Equal       pr
     Dtest_Different   pr

     Ptest_Equal       b                   export
     Dtest_Equal       pi
      /free
             // 0000000001111111111222222222233
        iEqual( 1234567890123456789012345678901 :
                1234567890123456789012345678901 );
      /end-free
     Ptest_Equal       e

     Ptest_Different   b                   export
     Dtest_Different   pi
      /free
             // 0000000001111111111222222222233
        iEqual( 1234567890123456789012345678901 :
                1234567890123456789012345678900 );
      /end-free
     Ptest_Different   e

