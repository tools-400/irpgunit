      //----------------------------------------------------------------------
      //   Exported Procedure Prototypes
      //----------------------------------------------------------------------

       // Receive exception message.
     D rcvExcpMsgInfo  pr                  likeds(Msg_t)
     D                                     extproc('rcvExcpMsgInfo')

       // Receive a program message replacement data.
     D rcvMsgData      pr           256a   extproc('rcvMsgData')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const

       // Receive a program message text.
     D rcvMsgTxt       pr           256a   extproc('rcvMsgTxt')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const

       // Receive a program message.
     D rcvPgmMsg       pr                  likeds(Msg_t)
     D                                     extproc('rcvPgmMsg')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const
        // If the message was sent to a procedure above in the call stack,
        // indicate how many level above it is.
     D  callStkCnt                   10i 0 const options(*NoPass)

       // Resend an escape message that was monitored in a monitor block.
     D resendEscapeMsg...
     D                 pr                  ExtPgm('QMHRSNEM')
     D  msgKey                        4a   const
     D  errorCode                 32565a   const options(*varsize) noopt

       // Send a completion message.
     D sndCompMsg      pr                  extproc('sndCompMsg')
     D  msg                         256a   const

       // Send an escape message...
       // ...to any call stack entry.
     D sndEscapeMsg    pr                  extproc('sndEscapeMsg')
     D  msg                         256a   const
     D  callStkCnt                   10i 0 const

       // ...to the procedure's caller.
     D sndEscapeMsgToCaller...
     D                 pr                  extproc('sndEscapeMsgToCaller')
     D  msg                         256a   const

       // ...to the call stack entry just above the Control Boundary.
       // Useful to terminate a program.
     D sndEscapeMsgAboveCtlBdy...
     D                 pr                  extproc('sndEscapeMsgAboveCtlBdy')
     D  msg                         256a   const

       // Send an information message.
     D sndInfoMsg      pr                  extproc('sndInfoMsg')
     D  msg                         256a   const

       // Send a status message.
     D sndStsMsg       pr                  extproc('sndStsMsg')
     D  msg                         256a   const

       // Restores the previous status message.
     D rstStsMsg       pr                  extproc('rstStsMsg')

       // Returns the highest message key of the job log.
     D getHighestMsgKey...
     D                 pr             4a   extproc('getHighestMsgKey')

       // Returns the latest escape message whose message
       // key is greater than 'lowMsgKey'.
     D getLatestEscMsg...
     D                 pr                  likeds(Msg_t)
     D                                     extproc('getLatestEscMsg')
     D  lowMsgKey                     4a   Value
     D  doRmvMsg                       n   Value


      //----------------------------------------------------------------------
      //   Exported Constants
      //----------------------------------------------------------------------

       // Call stack levels.
     D THIS_CALL_STK_LVL...
     D                 c                   const(0)
     D ONE_CALL_STK_LVL_ABOVE...
     D                 c                   const(1)
     D TWO_CALL_STK_LVL_ABOVE...
     D                 c                   const(2)

       // To resend the last new escape message
     D LAST_NEW_ESCAPE_MSG...
     D                 c                   const(*blank)
