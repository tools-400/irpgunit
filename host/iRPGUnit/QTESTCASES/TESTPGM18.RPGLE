      // ==========================================================================
      //  iRPGUnit Fixture - Error in tearDownSuite.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qinclude,TESTCASE
      /include qinclude,ERRORCODE
      /include qinclude,SYSTEMAPI

     DsetupSuite       pr
     Dtest1            pr
     DteardownSuite    pr
     D sndInfoMsg      pr
     D  msg                         256a   const

     PsetupSuite       b                   export
     DsetupSuite       pi
      /free

        sndInfoMsg( 'setupSuite' );

      /end-free
     PsetupSuite       e

     Ptest1            b                   export
     Dtest1            pi
      /free

        sndInfoMsg( 'test1' );

      /end-free
     Ptest1            e

     PteardownSuite    b                   export
     DteardownSuite    pi
     D x               s             10i 0 inz(0)
      /free

        sndInfoMsg( 'teardownSuite' );

        x = 1 / x;    // Generate error.

      /end-free
     PteardownSuite    e


     P sndInfoMsg      b                   export
     D sndInfoMsg      pi
     D  msg                         256a   const

       // Call Stack Counter.
       // 1 - QCMDEXC
       // 2 - RUACPTST.RUN
       // 3 - RUACPTST.TEST...
     D callStkCnt      c                   const(3)

       // The message reference key (unique string of characters that identifies
       // a particular instance of a message in a queue).
     D msgKey          s              4a
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        QMHSNDPM( *blank :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*INFO' :
                  '*CTLBDY' :
                  callStkCnt :
                  msgKey :
                  percolateErrors );

      /end-free
     P sndInfoMsg      e
