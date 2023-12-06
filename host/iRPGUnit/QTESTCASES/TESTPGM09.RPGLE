      // ==========================================================================
      //  iRPGUnit Fixture - Error in setup.
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

     Dsetup            pr
     Dtest             pr
     Dteardown         pr
     D sndInfoMsg      pr
     D  msg                         256a   const

     Psetup            b                   export
     Dsetup            pi
     D x               s             10i 0
     D zero            s             10i 0 inz(*zero)
      /free

        sndInfoMsg( 'setup' );
        x = 1 / zero;

      /end-free
     Psetup            e

     Ptest             b                   export
     Dtest             pi
      /free

        sndInfoMsg( 'Test should not be called.' );

      /end-free
     Ptest             e

     Pteardown         b                   export
     Dteardown         pi
      /free

        sndInfoMsg( 'teardown' );

      /end-free
     Pteardown         e


     P sndInfoMsg      b
     D sndInfoMsg      pi
     D  msg                         256a   const

       // Call Stack Counter.
       // 1 - QCMDEXC
       // 2 - ACPTST.RUN
       // 3 - ACPTST.TEST...
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
