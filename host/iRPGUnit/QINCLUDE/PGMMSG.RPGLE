**FREE
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

/include qinclude,templates

// Receive exception message.
dcl-pr rcvExcpMsgInfo likeds(msg_t)
       extproc('PGMMSG_rcvExcpMsgInfo');
end-pr;

// Receive a program message replacement data.
dcl-pr rcvMsgData char(256) extproc('PGMMSG_rcvMsgData');
  // Message type: *ANY, *COMP, *EXCP...
  msgType         char(10) const;
end-pr;

// Receive a program message text.
dcl-pr rcvMsgTxt char(256) extproc('PGMMSG_rcvMsgTxt');
  // Message type: *ANY, *COMP, *EXCP...
  msgType         char(10) const;
end-pr;

// Receive a program message.
dcl-pr rcvPgmMsg likeds(msg_t) extproc('PGMMSG_rcvPgmMsg');
  // Message type: *ANY, *COMP, *EXCP...
  msgType         char(10) const;
  // If the message was sent to a procedure above in the call stack,
  // indicate how many level above it is.
  callStkCnt      int(10) const options(*nopass);
end-pr;

// Resend an escape message that was monitored in a monitor block.
dcl-pr resendEscapeMsg extpgm('QMHRSNEM');
  msgKey          char(4) const;
  errorCode       char(32767) const options(*varsize) noopt;
end-pr;

dcl-pr sndVldChkMsg extproc('PGMMSG_sndVldChkMsg');
  msg             varchar(256) const;
  callStkCnt      int(10) const;
end-pr;

// Send a completion message.
dcl-pr sndCompMsg extproc('PGMMSG_sndCompMsg');
  msg             char(256) const;
end-pr;

// Send an escape message...
// ...to any call stack entry.
dcl-pr sndEscapeMsg extproc('PGMMSG_sndEscapeMsg');
  msg             char(256) const;
  callStkCnt      int(10) const;
end-pr;

// ...to the specified procedure.
dcl-pr sndEscapeMsgToProcedure extproc('PGMMSG_sndEscapeMsgToProcedure');
  msg             char(256) const;
  procedure       varchar(256) const  options(*omit);
end-pr;

// ...to the procedure's caller.
dcl-pr sndEscapeMsgToCaller extproc('PGMMSG_sndEscapeMsgToCaller');
  msg             char(256) const;
end-pr;

// ...to the call stack entry just above the Control Boundary.
// Useful to terminate a program.
dcl-pr sndEscapeMsgAboveCtlBdy extproc('PGMMSG_sndEscapeMsgAboveCtlBdy');
  msg             char(256) const;
end-pr;

// Send an information message.
dcl-pr sndInfoMsg extproc('PGMMSG_sndInfoMsg');
  msg             char(256) const;
end-pr;

// Send a status message.
dcl-pr sndStsMsg extproc('PGMMSG_sndStsMsg');
  msg             char(256) const;
end-pr;

// Restores the previous status message.
dcl-pr rstStsMsg extproc('PGMMSG_rstStsMsg');
end-pr;

// Returns the highest message key of the job log.
dcl-pr getHighestMsgKey char(4) extproc('PGMMSG_getHighestMsgKey');
end-pr;

// Returns the latest escape message whose message
// key is greater than 'lowMsgKey'.
dcl-pr getLatestEscMsg likeds(msg_t) extproc('PGMMSG_getLatestEscMsg');
  lowMsgKey       char(4) value;
  doRmvM#sg        ind value;
end-pr;


//----------------------------------------------------------------------
//   Exported Constants
//----------------------------------------------------------------------

// Call stack levels.
dcl-c THIS_CALL_STK_LVL      0;
dcl-c ONE_CALL_STK_LVL_ABOVE 1;
dcl-c TWO_CALL_STK_LVL_ABOVE 2;

// To resend the last new escape message
dcl-c LAST_NEW_ESCAPE_MSG '';

/endif

