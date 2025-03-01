**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test PGMMSG.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/JOBLOG    +
//                      &LI/PGMMSG    +
//                      );
//     >>PARM<<    COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,ERRORCODE
/copy qinclude,PGMMSG
/copy qinclude,TEMPLATES
/copy qinclude,TESTUTILS

/include qinclude,SDS

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

//dcl-pr callSndEscapeMsgToCaller
//       extproc('callSndEscapeMsgToCaller');
//end-pr;
//dcl-pr monitorEscapeMsgAndResendIt
//       extproc('monitorEscapeMsgAndResendIt+
//       ');
//end-pr;
//dcl-pr procWithError
//       int(10) extproc('procWithError');
//end-pr;

//----------------------------------------------------------------------
//   Helper Procedures Definitions
//----------------------------------------------------------------------

dcl-proc callSndEscapeMsgToCaller;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  sndEscapeMsgToCaller('Dummy error message');

end-proc;


dcl-proc monitorEscapeMsgAndResendIt;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  monitor;
    procWithError();
  on-error;
    resendEscapeMsg(LAST_NEW_ESCAPE_MSG : percolateErrors);
  endmon;

end-proc;


dcl-proc procWithError;
  dcl-pi *n int(10) extproc(*dclcase);
  end-pi;

  dcl-s zero int(10) inz(0);

  return (1 / zero);

end-proc procWithError;


//----------------------------------------------------------------------
//   Test Procedure Definitions
//----------------------------------------------------------------------

dcl-proc test_rcvExcpMsgInfo export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s msgKey char(4);

  setLowMessageKey(getHighestMsgKey());

  monitor;
    procWithError();
    fail('procWithError() did not raise an error.');
  on-error;
     // Success.
  endmon;

  excpMsgInfo = rcvExcpMsgInfo();

  aEqual('MCH1211': excpMsgInfo.Id);
  assert(excpMsgInfo.txt <> *blank: 'Exception message not retrieved');
  // We should be checking the message content, but I do not know how to
  // do that, since it depends on the locale.
  aEqual('PGMMSGT': excpMsgInfo.qSndStmt.qPgm.nm);
  aEqual(sds.pgmLib: excpMsgInfo.qSndStmt.qPgm.lib);
  aEqual('procWithError': excpMsgInfo.qSndStmt.procNm);

  monitor;
    msgKey = getHighestMsgKey();
    aEqual('88': excpMsgInfo.qSndStmt.specNb);   // IFS Compile
  on-error;
    getLatestEscMsg(msgKey: *ON);
    aEqual('8800': excpMsgInfo.qSndStmt.specNb);   // QSYS Compile
  endmon;

end-proc;


dcl-proc test_sndEscapeMsgToCaller export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);

  monitor;
    callsndEscapeMsgToCaller();
    fail('sndEscapeMsgToCaller() did not raise an exception.');
  on-error;
     // Success.
  endmon;

  excpMsgInfo = rcvExcpMsgInfo();

  aEqual('Dummy error message' : excpMsgInfo.txt);

end-proc;


dcl-proc test_resendEscapeMsg export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s resentMsgSeen ind;
  dcl-ds msg likeds(Msg_t);

  monitor;
    monitorEscapeMsgAndResendIt();
    resentMsgSeen = *off;
  on-error;
    resentMsgSeen = *on;
  endmon;

  assert(resentMsgSeen: 'Resent msg not seen');
  msg = rcvPgmMsg('*ESCAPE');
  aEqual('MCH1211': msg.id);

end-proc;


dcl-proc test_monitorMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds msgInfo likeds(MsgInfo_t);
  dcl-ds msgInfo2 likeds(MsgInfo_t);
  dcl-ds msgInfo3 likeds(MsgInfo_t);
  dcl-s a int(10);
  dcl-s b int(10);
  dcl-s c int(10);
  dcl-s msgKey char(4);

  setLowMessageKey(getHighestMsgKey());

  monitor;
    a = 10;
    b = 0;     // Attempt made to divide by zero for
    c = a / b; // fixed point operation. (MCH1211)
    fail('Division by zero did not raise an error.');
  on-error;
    msgInfo = getMonitoredMessage();
  endmon;

  aEqual('MCH1211': msgInfo.Id);

  // receive message info again
  // and remove message
  msgInfo2 = getMonitoredMessage(*ON);
  assert(msgInfo = msgInfo2: 'Message info values must match');

  // try to receive it a third time
  msgInfo3 = getMonitoredMessage();
  assert(msgInfo3.id     = '' and
         msgInfo3.txt    = '' and
         msgInfo3.pgm    = '' and
         msgInfo3.mod    = '' and
         msgInfo3.proc   = '' and
         msgInfo3.specNb = ''
         : 'Message MCH1211 must habe been removed from the job log');

  monitor;
    procWithError();
    fail('procWithError() did not raise an error.');
  on-error;
    msgInfo = getMonitoredMessage();
  endmon;

  aEqual('MCH1211': msgInfo.Id );
  assert(msgInfo.txt <> *blank: 'Exception message not retrieved');
  // We should be checking the message content, but I do not know how to
  // do that, since it depends on the locale.
  aEqual('PGMMSGT': msgInfo.pgm);
  aEqual('procWithError': msgInfo.proc);

  monitor;
    msgKey = getHighestMsgKey();
    aEqual('88': msgInfo.specNb);   // IFS Compile
  on-error;
    getLatestEscMsg(msgKey: *ON);
    aEqual('8800': msgInfo.specNb);   // QSYS Compile
  endmon;

end-proc;
