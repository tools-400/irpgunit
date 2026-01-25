**FREE
/if not defined (IRPGUNIT_PGMMSG)
/define IRPGUNIT_PGMMSG

///
// ==========================================================================
//  iRPGUnit - Program message handling.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. Ths program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
///

///
// Receives the latest exception message from the job message queue
//
// Retrieves the most recent exception message that occurred in the current job.
// This is useful for capturing error information during test execution and
// debugging scenarios.
//
// @return Latest exception message information structure containing message ID,
//         text, data, and other relevant details
///
dcl-pr rcvExcpMsgInfo likeds(msg_t) extproc('PGMMSG_rcvExcpMsgInfo');
end-pr;

///
// Receives the message replacement data of the latest message
//
// Retrieves the replacement data (substitution variables) associated with
// the most recent message of the specified type. This data contains the
// variable values that were substituted into the message text.
//
// @param msgType - Message type to retrieve data for (e.g., '*EXCP', '*COMP', '*INFO')
//
// @return Message replacement data as a 256-character string, blanks if no data available
///
dcl-pr rcvMsgData char(256) extproc('PGMMSG_rcvMsgData');
  msgType char(10) const;
end-pr;

///
// Receives message text of the latest message of a given type
//
// Retrieves the formatted message text of the most recent message matching
// the specified type. The text includes all substitution variables resolved
// to their actual values.
//
// @param msgType - Message type to retrieve text for (e.g., '*EXCP', '*COMP', '*INFO', '*ANY')
//
// @return Formatted message text as a 256-character string, blanks if no message found
///
dcl-pr rcvMsgTxt like(msgText_t) extproc('PGMMSG_rcvMsgTxt');
  msgType char(10) const;
end-pr;

///
// Receives the latest message of a given type from the call stack
//
// Retrieves the most recent message of the specified type from the program
// message queue at the specified call stack level. This allows precise
// message retrieval from specific procedure calls.
//
// @param msgType    - Message type: '*ANY', '*COMP', '*EXCP', '*INFO', '*STATUS'
// @param callStkCnt - Call stack counter for identifying the procedure that holds the message
//                     (optional, defaults to current call stack level if not specified)
//
// @return Latest message structure of specified type containing all message details
///
dcl-pr rcvPgmMsg likeds(msg_t) extproc('PGMMSG_rcvPgmMsg');
  msgType    char(10) const;
  callStkCnt int(10) options(*nopass) const;
end-pr;

///
// Resends the latest escape message identified by a given key
//
// This procedure is an alias of the "Resend Escape Message" (QMHRSNEM) API.
// It resends a previously received escape message, allowing proper error
// propagation through the call stack.
//
// @param msgKey    - Message key identifying the specific message to resend
// @param errorCode - Error code structure for returning API error information
//                    Should be properly initialized before calling
///
dcl-pr resendEscapeMsg extpgm('QMHRSNEM');
  msgKey    char(4) const;
  errorCode char(32767) options(*varsize) noopt const;
end-pr;

///
// Sends a validation error message to a specific call stack level
//
// Sends a validation error message (CPD0006) to the procedure identified by
// the specified call stack counter. This procedure is primarily used by
// validity checker programs to report validation failures.
//
// @param msg        - Message text to send with the CPD0006 message (up to 256 characters)
// @param callStkCnt - Call stack counter identifying the target procedure
//                     0 = current level, 1 = caller, 2 = caller's caller, etc.
///
dcl-pr sndVldChkMsg extproc('PGMMSG_sndVldChkMsg');
  msg        like(msgText_t) const;
  callStkCnt int(10) const;
end-pr;

///
// Sends a completion message above the control boundary
//
// Sends a completion message to the procedure right before the control boundary,
// which is usually the command line or interactive environment. This is used
// to report successful completion of operations.
//
// @param msg - Message text to send (up to 256 characters)
///
dcl-pr sndCompMsg extproc('PGMMSG_sndCompMsg');
  msg like(msgText_t) const;
end-pr;

///
// Sends an escape message to a specific call stack level
//
// Sends an escape message to the procedure identified by the specified
// call stack counter. Escape messages cause program termination and
// error handling at the target level.
//
// @param msg        - Message text to send (up to 256 characters)
// @param callStkCnt - Call stack counter identifying the target procedure
//                     0 = current level, 1 = caller, 2 = caller's caller, etc.
///
dcl-pr sndEscapeMsg extproc('PGMMSG_sndEscapeMsg');
  msg        like(msgText_t) const;
  callStkCnt int(10) const;
end-pr;

///
// Sends an escape message to a named procedure
//
// Sends an escape message to the procedure identified by the specified
// procedure name. This allows targeting specific procedures by name
// rather than call stack position.
//
// @param msg       - Message text to send (up to 256 characters)
// @param procedure - Procedure name identifying the target procedure
//                    Can be *OMIT to use default targeting
///
dcl-pr sndEscapeMsgToProcedure extproc('PGMMSG_sndEscapeMsgToProcedure');
  msg       like(msgText_t) const;
  procedure varchar(256) options(*omit) const;
end-pr;

///
// Sends an escape message to the calling procedure
//
// Sends an escape message to the immediate caller of the current procedure.
// This is a convenience procedure equivalent to using call stack counter 1.
//
// @param msg - Message text to send (up to 256 characters)
///
dcl-pr sndEscapeMsgToCaller extproc('PGMMSG_sndEscapeMsgToCaller');
  msg like(msgText_t) const;
end-pr;

///
// Sends an escape message above the control boundary
//
// Sends an escape message to the procedure right before the control boundary,
// usually the command line. This procedure is useful for terminating a program
// and returning control to the calling environment.
//
// @param msg - Message text to send (up to 256 characters)
///
dcl-pr sndEscapeMsgAboveCtlBdy extproc('PGMMSG_sndEscapeMsgAboveCtlBdy');
  msg like(msgText_t) const;
end-pr;

///
// Sends an information message to the calling procedure
//
// Sends an informational message to the immediate caller of the current
// procedure. Information messages provide status updates without affecting
// program flow.
//
// @param msg - Message text to send (up to 256 characters)
///
dcl-pr sndInfoMsg extproc('PGMMSG_sndInfoMsg');
  msg like(msgText_t) const;
end-pr;

///
// Sends a status message for display in status subfile
//
// Sends a status message that is displayed in the job's status message subfile.
// Status messages provide real-time feedback about ongoing operations and
// are typically displayed at the bottom of interactive screens.
//
// @param msg - Message text to display (up to 256 characters)
///
dcl-pr sndStsMsg extproc('PGMMSG_sndStsMsg');
  msg like(msgText_t) const;
end-pr;

///
// Restores the last sent status message
//
// Restores the previously displayed status message, effectively undoing
// the last status message change. This is useful for temporary status
// updates that need to be reverted.
///
dcl-pr rstStsMsg extproc('PGMMSG_rstStsMsg');
end-pr;

///
// Returns the highest message key from the job message queue
//
// Retrieves the highest (most recent) message key from the job's message queue.
// This is useful for establishing a baseline before performing operations
// that might generate messages.
//
// @return Highest message key as a 4-character binary value
///
dcl-pr getHighestMsgKey char(4) extproc('PGMMSG_getHighestMsgKey');
end-pr;

///
// Returns the latest escape message newer than specified key
//
// Retrieves the most recent escape message whose message key is greater
// than the specified lower bound key. Optionally removes the message
// from the queue after retrieval.
//
// @param lowMsgKey - Lower bound message key for search (4-character binary)
// @param doRmvMsg  - *ON to remove the message after retrieval, *OFF to leave it
//
// @return Latest escape message structure found, empty if no message matches criteria
///
dcl-pr getLatestEscMsg likeds(msg_t) extproc('PGMMSG_getLatestEscMsg');
  lowMsgKey char(4) value;
  doRmvMsg  ind value;
end-pr;

///
// Retrieves the latest escape message between 'highMsgKey' and NOW.
///
dcl-pr caller like(procNm_t) extproc('PGMMSG_caller');
  offset  int(3) options(*nopass: *omit) const;
  module  char(10) options(*nopass: *omit);
  program char(10) options(*nopass: *omit);
  stmtID  char(10) options(*nopass: *omit);
end-pr;

///
//----------------------------------------------------------------------
//   Exported Constants
//----------------------------------------------------------------------
///

///
// Send message to current call stack entry.
///
dcl-c THIS_CALL_STK_LVL      0;

///
// Send message to previous call stack entry.
///
dcl-c ONE_CALL_STK_LVL_ABOVE 1;

///
// Send message two call stack entries up.
///
dcl-c TWO_CALL_STK_LVL_ABOVE 2;

///
// Resend the lastest escape message
///
dcl-c LAST_NEW_ESCAPE_MSG '';

/include qinclude,TYPES_H

/endif

