
     H NoMain Option(*SrcStmt)

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QMHSNDPM

     DsetupSuite       pr
     Dtest1            pr
     DteardownSuite    pr
     D sndInfoMsg      pr
     D  msg                         256a   const

     PsetupSuite       b                   export
     DsetupSuite       pi
     D x               s             10i 0 inz(0)
      /free

        sndInfoMsg( 'setupSuite' );

        x = 1 / x;    // Generate error.

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
      /free

        sndInfoMsg( 'teardownSuite' );

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
