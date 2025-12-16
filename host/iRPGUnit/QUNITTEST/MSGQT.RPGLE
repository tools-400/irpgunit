**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test Message Queue.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
//                 COPTION(*EVENTF);
//   >>IMPORTANT<<
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,PGMMSG
/copy qinclude,TESTUTILS
/copy qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c MSG_QUEUE_QNM 'QTEMP/MSGQT';
dcl-c MSG_QUEUE_NM 'MSGQT';
dcl-c MSG_QUEUE_LB 'QTEMP';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s testStartTime timestamp;
dcl-s assertCntBefore int(10);
dcl-s assertCntAfter int(10);

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  testStartTime = getFullTimeStamp();
  clear assertCntBefore;
  clear assertCntAfter;

  monitor;
     runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');
  on-error;
     // Ignore errors
  endmon;

  runCmd('CRTMSGQ MSGQ(' + MSG_QUEUE_QNM + ') +
          TEXT(''IRPGUnit SelfTest - Tet Message Queue.'')');

end-proc;


dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');

end-proc;


dcl-proc testNoMsgInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);


  // Setup.

  assertCntBefore = getAssertCalled();

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       *omit: 'MSGQUEUET*': *omit: testStartTime);
     fail('assertMessageQueueContains(...) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 1 : assertCntAfter);
  aEqual('Message not found in message queue.': assertFailEvt.msg);

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    '*EMPTY': *omit: *omit: testStartTime);

end-proc;


dcl-proc testMsgInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.1');
  assertCntBefore = getAssertCalled();

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.2');
  assertCntBefore = getAssertCalled();

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.3');
  assertCntBefore = getAssertCalled();

  // Run.

  // exact match
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit.1': *omit: testStartTime);

  // any message starting with 'MSGQT'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT*': *omit: testStartTime);

  // any message starting containing 'iRPGUnit'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: '*iRPGUnit*': *omit: testStartTime);

  // message ending with '.2'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: '*.2': *omit: testStartTime);

  // Check.

  assertCntAfter = getAssertCalled();
  iEqual(assertCntBefore + 4: assertCntAfter);

end-proc;


dcl-proc testMsgTooOldInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit - too old');

  // Ensure message is in queue
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit - too old': *omit: testStartTime);

  // Set new start time
  testStartTime = getFullTimeStamp();

  // Add a valid message
  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit - new');

  assertCntBefore = getAssertCalled();

  // Run.

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit - new': *omit: testStartTime);

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       *omit: 'MSGQT - iRPGUnit - too old': *omit: testStartTime);
     fail('testMsgTooOldInMessageQueue(..) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 2: assertCntAfter);
  aEqual('Message not found in message queue.': assertFailEvt.msg );

end-proc;


dcl-proc testSpecialValueEmpty export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);
  dcl-ds msgInfo likeds(MsgInfo_t);

  // Setup.

  assertCntBefore = getAssertCalled();
  setLowMessageKey(getHighestMsgKey());

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       '*EMPTY': 'MSGQUEUET*': *omit: testStartTime);
     fail('Other parameters must be omitted when msgId = *EMPTY');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
     msgInfo = getMonitoredMessage();
  endmon;

  // Check.

  iEqual(assertCntBefore: assertCntAfter);
  aEqual('' : assertFailEvt.msg);
  aEqual('All other selection parameters must be omitted, when msgId is set to ''*EMPTY'''
         : msgInfo.txt);

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    '*EMPTY': *omit: *omit: testStartTime);

end-proc;


//----------------------------------------------------------------------
//   Private Helper Procedures
//----------------------------------------------------------------------

dcl-proc sndQueueMsg;
  dcl-pi *n extproc(*dclcase);
    queueNm   char(10) const;
    queueLb   char(10) const;
    text      varchar(256) const;
  end-pi;

  dcl-s cmd varchar(1024);

  cmd = 'SNDMSG MSG(''' + %trim(text) + ''') +
           TOMSGQ(' + %trim(queueLb) + '/' + %trim(queueNm) + ') +
           MSGTYPE(*INFO)';

  runCmd(cmd);

end-proc;
