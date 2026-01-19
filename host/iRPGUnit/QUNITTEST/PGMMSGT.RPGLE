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
//     >>PARM<<  MODULE(&LI/PGMMSGT);
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CMDRUNSRV
/copy qinclude,ERRORCODE
/copy qinclude,MEMMGR
/copy qinclude,PGMMSG
/copy qinclude,TYPES_H
/copy qinclude,TESTUTILS

/copy qllist,llist_h

/include qinclude,SDS

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

  return (1 / zero); // statement in error

end-proc procWithError;


//----------------------------------------------------------------------
//   Test Procedure Definitions
//----------------------------------------------------------------------

dcl-proc test_caller export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s callingProcName like(procNm_t);

  callingProcName = getCaller();

  assertEqual('test_caller': callingProcName);

end-proc;


dcl-proc test_rcvExcpMsgInfo export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s msgKey char(4);

  dcl-s hTestEvents pointer;
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t);

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  setLowMessageKey(getHighestMsgKey());

  hTestEvents = MemMgr_createList('hTestEvents');
  clrAssertFailEvt(hTestEvents: '');

  monitor;
    procWithError();
    fail('procWithError() did not raise an error.');
  on-error;
     // Success.
  endmon;

  excpMsgInfo = rcvExcpMsgInfo();

  abstractTestEvent = getAssertEventInternal();
  disposeTestEvents(hTestEvents);

  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  aEqual('MCH1211': excpMsgInfo.Id);
  assert(excpMsgInfo.txt <> *blank: 'Exception message not retrieved');
  // We should be checking the message content, but I do not know how to
  // do that, since it depends on the locale.
  aEqual('PGMMSGT': excpMsgInfo.qSndStmt.qPgm.nm);
  aEqual(sds.pgmLib: excpMsgInfo.qSndStmt.qPgm.lib);
  aEqual('procWithError': excpMsgInfo.qSndStmt.procNm);

  // The statement number can be found in
  // procedure procWithError().
  monitor;
    msgKey = getHighestMsgKey();
    aEqual('75': excpMsgInfo.qSndStmt.specNb); // IFS Compile
  on-error;
    getLatestEscMsg(msgKey: *ON);
    aEqual('7500': excpMsgInfo.qSndStmt.specNb); // QSYS Compile
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

  dcl-ds msgInfo1 likeds(MsgInfo_t);
  dcl-ds msgInfo2 likeds(MsgInfo_t);
  dcl-ds msgInfo3 likeds(MsgInfo_t);
  dcl-ds msgInfo4 likeds(MsgInfo_t);
  dcl-s a int(10);
  dcl-s b int(10);
  dcl-s c int(10);
  dcl-s msgKey char(4);

  // -----------------------------
  // save current assertion status
  // -----------------------------
  saveAssertStatus();

  // Prepare

  setLowMessageKey(getHighestMsgKey());

  // Step 1

  monitor;
    a = 10;
    b = 0;     // Attempt made to divide by zero for
    c = a / b; // fixed point operation. (MCH1211)
    fail('Division by zero did not raise an error.');
  on-error;
    msgInfo1 = getMonitoredMessage();
  endmon;

  // Step 2

  // receive message info again
  // and remove message
  msgInfo2 = getMonitoredMessage(*ON);

  // Step 3

  // try to receive it a third time
  msgInfo3 = getMonitoredMessage();

  // Step 4

  monitor;
    procWithError();
    fail('procWithError() did not raise an error.');
  on-error;
    msgInfo4 = getMonitoredMessage();
  endmon;


  // --------------------------------
  // restore current assertion status
  // --------------------------------
  restoreAssertStatus();

  // Check result of step 1

  aEqual('MCH1211': msgInfo1.Id);

  // Check result of step 2

  assert(msgInfo1 = msgInfo2: 'Message #1 must match message #2');

  // Check result of step 3

  assert(msgInfo3.id     = '' and
         msgInfo3.txt    = '' and
         msgInfo3.pgm    = '' and
         msgInfo3.mod    = '' and
         msgInfo3.proc   = '' and
         msgInfo3.specNb = ''
         : 'Message MCH1211 must habe been removed from the job log');

  // Check result of step 4

  aEqual('MCH1211': msgInfo4.Id );
  assert(msgInfo4.txt <> *blank: 'Exception message not retrieved');
  // We should be checking the message content, but I do not know how to
  // do that, since it depends on the locale.
  aEqual('PGMMSGT': msgInfo4.pgm);
  aEqual('procWithError': msgInfo4.proc);

  // The statement number can be found in
  // procedure procWithError().
  monitor;
    msgKey = getHighestMsgKey();
    aEqual('75': msgInfo4.specNb); // IFS Compile
  on-error;
    getLatestEscMsg(msgKey: *ON);
    aEqual('7500': msgInfo4.specNb); // QSYS Compile
  endmon;

end-proc;


dcl-proc getCaller;
  dcl-pi *n like(procNm_t) extproc(*dclcase);
  end-pi;

  return caller();

end-proc;
