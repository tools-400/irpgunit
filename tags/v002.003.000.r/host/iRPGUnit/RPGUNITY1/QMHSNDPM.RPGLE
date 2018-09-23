      //
      // Send Program Message API
      //

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   msgID                        7a   const
     D   qlfMsgF                     20a   const
     D   msgData                    256a   const options(*varsize)
     D   msgDataLen                  10i 0 const
     D   msgType                     10a   const
     D   callStkEnt                  10a   const
     D   callStkCnt                  10i 0 const
     D   msgKey                       4a
     D   error                     1024a   options(*varsize) noopt


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
