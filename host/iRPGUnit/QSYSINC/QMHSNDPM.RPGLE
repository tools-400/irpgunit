      //
      // Send Program Message API
      //

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   msgID                        7a   const
     D   qlfMsgF                     20a   const
     D   msgData                    256a   const options(*varsize)
     D   msgDataLen                  10i 0 const
     D   msgType                     10a   const
     D   callStkEnt                1024a   const options(*varsize)
     D   callStkCnt                  10i 0 const
     D   msgKey                       4a
     D   error                     1024a   options(*varsize)
     D   lenCallStkEnt...
     D                               10i 0 const options(*nopass)
     D   callStkEntQual...
     D                               20a   const options(*nopass)
     D   msgWaitTime...
     D                               10i 0 const options(*nopass)


       //----------------------------------------------------------------------
       //   Symbolic Constants
       //----------------------------------------------------------------------

       // Call stack entry:
       // - current call stack entry
     D CUR_CALL_STK_ENT...
     D                 c                   const('*')
       // - control boundary
     D CONTROL_BOUNDARY...
     D                 c                   const('*CTLBDY')
