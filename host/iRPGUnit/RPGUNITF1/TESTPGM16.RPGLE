
     H NoMain Option(*SrcStmt)

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QMHSNDPM

     Dsetup            pr
     Dtest1            pr
     Dtest2            pr
     Dteardown         pr
     D sndInfoMsg      pr
     D  msg                         256a   const

     Psetup            b                   export
     Dsetup            pi
      /free

        sndInfoMsg( 'setup' );

      /end-free
     Psetup            e

     Ptest1            b                   export
     Dtest1            pi
      /free

        sndInfoMsg( 'test1' );

      /end-free
     Ptest1            e

     Ptest2            b                   export
     Dtest2            pi
      /free

        sndInfoMsg( 'test2' );

      /end-free
     Ptest2            e

     Pteardown         b                   export
     Dteardown         pi
      /free

        sndInfoMsg( 'teardown' );

      /end-free
     Pteardown         e


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
