
     H NoMain Option(*SrcStmt)

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QMHSNDPM

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
       // 2 - RUACPTST.RUN
       // 3 - RUACPTST.TEST...
     D callStkCnt      c                   const(3)

       // The message reference key (unique string of characters that identifies
       // a particular instance of a message in a queue).
     D msgKey          s              4a

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
