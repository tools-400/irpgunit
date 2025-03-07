**FREE
/if not defined (IRPGUNIT_PGMMSG)
/define IRPGUNIT_PGMMSG
///
// ==========================================================================
//  iRPGUnit - Program message handling.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. Ths program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
///

/include qinclude,templates

///
// Receives the latest exception message.
///
dcl-pr rcvExcpMsgInfo likeds(msg_t) extproc('PGMMSG_rcvExcpMsgInfo');
end-pr;

///
// Receive the message replacement data of the latest message.
///
dcl-pr rcvMsgData char(256) extproc('PGMMSG_rcvMsgData');
  msgType   char(10) const;
end-pr;

///
// Receives message text of the latest message of a given type.
///
dcl-pr rcvMsgTxt char(256) extproc('PGMMSG_rcvMsgTxt');
  msgType   char(10) const;
end-pr;

///
// Receives the latest message of a given type.
//
// @param Message tye: *ANY, *COMP, *EXCP...
// @param Callstack counter for identifying the procedure that holds the message
///
dcl-pr rcvPgmMsg likeds(msg_t) extproc('PGMMSG_rcvPgmMsg');
  msgType         char(10) const;
  callStkCnt      int(10) const options(*nopass);
end-pr;

///
// Resends the latest escape message identified by a given key.
//
// This procedure is a alias of the "Resend Escape Message" (QMHRSNEM) API.
//
// @param Message key
// @param Structure for returning error information
///
dcl-pr resendEscapeMsg extpgm('QMHRSNEM');
  msgKey          char(4) const;
  errorCode       char(32767) const options(*varsize) noopt;
end-pr;

///
// Sends a validation error message to the procedure identified by the
// specifed callstack counter. (This procedure is used by the validity
// checker programs).
//
// @param Message text send with the CPD0006 message
// @param Callstack counter for identifying the procedure that receives the message
///
dcl-pr sndVldChkMsg extproc('PGMMSG_sndVldChkMsg');
  msg             varchar(256) const;
  callStkCnt      int(10) const;
end-pr;

///
// Sends a completion error message to the procedure right before
// the control boundary. Usually that is the command line.
//
// @param Message text
///
dcl-pr sndCompMsg extproc('PGMMSG_sndCompMsg');
  msg             char(256) const;
end-pr;

///
// Sends an escape message to the procedure identified by the specifed
// callstack counter.
//
// @param Message text
// @param Callstack counter for identifying the procedure that receives the message
///
dcl-pr sndEscapeMsg extproc('PGMMSG_sndEscapeMsg');
  msg             char(256) const;
  callStkCnt      int(10) const;
end-pr;

///
// Sends an escape message to the procedure identified by a given name.
//
// @param Message text
// @param Procedure name  for identifying the procedure that receives the message
///
dcl-pr sndEscapeMsgToProcedure extproc('PGMMSG_sndEscapeMsgToProcedure');
  msg             char(256) const;
  procedure       varchar(256) const  options(*omit);
end-pr;

///
// Sends an escape message to the calling procedure.
//
// @param Message text
///
dcl-pr sndEscapeMsgToCaller extproc('PGMMSG_sndEscapeMsgToCaller');
  msg             char(256) const;
end-pr;

///
// Sends an escape message to the procedure right before the control
// boundary. Usually that is the command line. This procedure is
// useful for terminating a program.
//
// @param Message text
///
dcl-pr sndEscapeMsgAboveCtlBdy extproc('PGMMSG_sndEscapeMsgAboveCtlBdy');
  msg             char(256) const;
end-pr;

///
// Sends an information message to the calling procedure.
//
// @param Message text
///
dcl-pr sndInfoMsg extproc('PGMMSG_sndInfoMsg');
  msg             char(256) const;
end-pr;

///
// Sends a status message that is displayed in the status subfile.
//
// @param Message text
///
dcl-pr sndStsMsg extproc('PGMMSG_sndStsMsg');
  msg             char(256) const;
end-pr;

///
// Restores the last sent status message.
///
dcl-pr rstStsMsg extproc('PGMMSG_rstStsMsg');
end-pr;

///
// Returns the highest message key of the job log.
///
dcl-pr getHighestMsgKey char(4) extproc('PGMMSG_getHighestMsgKey');
end-pr;

///
// Returns the latest escape message whose message
// key is greater than 'lowMsgKey'.
///
dcl-pr getLatestEscMsg likeds(msg_t) extproc('PGMMSG_getLatestEscMsg');
  lowMsgKey       char(4) value;
  doRmvM#sg        ind value;
end-pr;


///
//----------------------------------------------------------------------
//   Exported Constants
//----------------------------------------------------------------------
///

///
// Call stack levels.
///
dcl-c THIS_CALL_STK_LVL      0;
dcl-c ONE_CALL_STK_LVL_ABOVE 1;
dcl-c TWO_CALL_STK_LVL_ABOVE 2;

///
// To resend the last new escape message
///
dcl-c LAST_NEW_ESCAPE_MSG '';

/endif

