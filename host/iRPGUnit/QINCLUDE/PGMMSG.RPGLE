      /if not defined (IRPGUNIT_PGMMSG)
      /define IRPGUNIT_PGMMSG
      // ==========================================================================
      //  iRPGUnit - Program message handling.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. Ths program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Receive exception message.
     D rcvExcpMsgInfo  pr                  likeds(Msg_t)
     D                                     extproc('PGMMSG_rcvExcpMsgInfo')

       // Receive a program message replacement data.
     D rcvMsgData      pr           256a   extproc('PGMMSG_rcvMsgData')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const

       // Receive a program message text.
     D rcvMsgTxt       pr           256a   extproc('PGMMSG_rcvMsgTxt')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const

       // Receive a program message.
     D rcvPgmMsg       pr                  likeds(Msg_t)
     D                                     extproc('PGMMSG_rcvPgmMsg')
        // Message type: *ANY, *COMP, *EXCP...
     D  msgType                      10a   const
        // If the message was sent to a procedure above in the call stack,
        // indicate how many level above it is.
     D  callStkCnt                   10i 0 const options(*NoPass)

       // Resend an escape message that was monitored in a monitor block.
     D resendEscapeMsg...
     D                 pr                  ExtPgm('QMHRSNEM')
     D  msgKey                        4a   const
     D  errorCode                 32767a   const options(*varsize) noopt

     D sndVldChkMsg...
     D                 pr                  extproc('PGMMSG_sndVldChkMsg')
     D  msg                         256a   const varying
     D  callStkCnt                   10i 0 const

       // Send a completion message.
     D sndCompMsg      pr                  extproc('PGMMSG_sndCompMsg')
     D  msg                         256a   const

       // Send an escape message...
       // ...to any call stack entry.
     D sndEscapeMsg    pr                  extproc('PGMMSG_sndEscapeMsg')
     D  msg                         256a   const
     D  callStkCnt                   10i 0 const

       // ...to the specified procedure.
     D sndEscapeMsgToProcedure...
     D                 pr                  extproc('PGMMSG_+
     D                                     sndEscapeMsgToProcedure')
     D  msg                         256a   const
     D  procedure                   256a   const varying options(*omit)

       // ...to the procedure's caller.
     D sndEscapeMsgToCaller...
     D                 pr                  extproc('PGMMSG_+
     D                                     sndEscapeMsgToCaller')
     D  msg                         256a   const

       // ...to the call stack entry just above the Control Boundary.
       // Useful to terminate a program.
     D sndEscapeMsgAboveCtlBdy...
     D                 pr                  extproc('PGMMSG_+
     D                                     sndEscapeMsgAboveCtlBdy')
     D  msg                         256a   const

       // Send an information message.
     D sndInfoMsg      pr                  extproc('PGMMSG_sndInfoMsg')
     D  msg                         256a   const

       // Send a status message.
     D sndStsMsg       pr                  extproc('PGMMSG_sndStsMsg')
     D  msg                         256a   const

       // Restores the previous status message.
     D rstStsMsg       pr                  extproc('PGMMSG_rstStsMsg')

       // Returns the highest message key of the job log.
     D getHighestMsgKey...
     D                 pr             4a   extproc('PGMMSG_getHighestMsgKey')

       // Returns the latest escape message whose message
       // key is greater than 'lowMsgKey'.
     D getLatestEscMsg...
     D                 pr                  likeds(Msg_t)
     D                                     extproc('PGMMSG_getLatestEscMsg')
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

      /endif

