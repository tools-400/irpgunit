**FREE
// ==========================================================================
//  iRPGUnit - Assertion Facilities.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/define RPGUNIT_INTERNAL
/include qinclude,ASSERT
/include qinclude,ERRORCODE
/include qinclude,JOBLOG
/include qinclude,PGMMSG
/include qinclude,TEMPLATES
/include qinclude,STRING
/include qinclude,SYSTEMAPI

/include qinclude,SDS

/include qsysinc,CEEAPI

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr checkStartPgm extproc('ASSERT_checkStartPgm');
end-pr;

dcl-pr doFail extproc('ASSERT_doFail');
  msg            varchar(16384) options(*varsize) const;
  toCallStackE   int(10) const;
  startProc      varchar(256) options(*varsize) const;
end-pr;

dcl-pr getCallStk extproc('ASSERT_getCallStk') likeds(callStk_t);
  startproc      varchar(256) options(*varsize) const;
end-pr;

dcl-pr getSentTimeMsgQMsg timestamp extproc('ASSERT_getSentTimeMsgQMsg');
  msg            likeds(dsLstm0100EntHdr_t) const;
end-pr;

dcl-pr getvaluefromdesc varchar(32565) extproc('ASSERT_getValueFromDescriptor_internal');
  descinf        likeds(ceedod_inf_t) const;
  strinf         likeds(ceegsi_inf_t) const;
  fc             likeds(fc_t) const;
  value          char(32565) options(*varsize) const;
  dftlen         int(10) const;
end-pr;

dcl-pr getValueFromDescriptor_internal varchar(32565)
       extproc('ASSERT_getValueFromDescriptor_internal');
  descInf        likeds(ceedod_inf_t) const;
  strInf         likeds(ceegsi_inf_t) const;
  fc             likeds(fc_t) const;
  value          char(32565) options(*varsize);
  dftLen         int(10) const;
end-pr;

dcl-pr descTypeToExt varchar(20) extproc('ASSERT_descTypeToExt');
  dataType       int(10) const;
end-pr;

dcl-pr jobLogCallback ind extproc('ASSERT_jobLogCallback');
  i_hMsgInfo     pointer const;
  i_pUserData    pointer const;
  i_msgID        char(7) const;
  i_msgText      varchar(132) const;
  i_msgSentTime  timestamp const;
end-pr;


//----------------------------------------------------------------------
//   GLOBAL CONSTANTS
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   TYPE TEMPLATE
//----------------------------------------------------------------------

dcl-ds jobLogUserData_t qualified template;
  timeLimit   timestamp;
  msgID       char(7);
  isFound     ind;
end-ds;


//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

// Number of assertions called.
dcl-s assertCalled int(10);

// Latest assertion failure event information. Can be blank if no
//  assertion failure event since last assertion.
dcl-ds assertFailEvt likeds(assertFailEvtLong_t);

dcl-ds status qualified;
  qstartpgm   likeds(object_t);
end-ds;

//----------------------------------------------------------------------
// Registers the start program RUPGMRMT or RUCALLTST for
// using the RUTESTCASE service program.
//----------------------------------------------------------------------
dcl-proc registerStartPgm export;
  dcl-pi *N;
    lib   char(10) const;
    pgm   char(10) const;
  end-pi;


  status.qStartPgm.nm = pgm;
  status.qStartPgm.lib = lib;

end-proc;

//----------------------------------------------------------------------
// Check, whether this instance of RUTESTCASE has been registered
// with a start program. If that is not the case, the start progam
// uses another RUTESTCASE service  program, which leads to errors.
//----------------------------------------------------------------------
dcl-proc checkStartPgm export;
  dcl-pi *N;
  end-pi;

  dcl-s msg varchar(256);

  if (status.qStartPgm.lib <> sds.pgmLib);
    msg = 'Start program RUCALLTST or RUPGMRMT was not +
           registered with service program ' +
           %trim(sds.pgmLib) + '/RUTESTCASE. +
           Make sure that there are no duplicate iRPGUnit +
           objects in the library list. +
           Compare the library list with the product library +
           on the iRPGUnit preference page.';
    sndEscapeMsgAboveCtlBdy(msg);
  endif;

end-proc;

//----------------------------------------------------------------------
// Cobol enabled.
// Assert equality between two alphanumeric variables.
//----------------------------------------------------------------------
dcl-proc aEqual export;
  dcl-pi *N opdesc;
    expected    char(32565) const;
    actual      char(32565) const;
    fieldname   char(64) options(*nopass: *omit) const;
  end-pi;

  dcl-c p_expected 1;
  dcl-c p_actual 2;
  dcl-c p_fieldName 3;

  dcl-s tExpected    varchar(32565);
  dcl-s tActual      varchar(32565);
  dcl-s tFieldName   like(fieldname);
  dcl-s msg          like(msgText_t) inz;

  dcl-ds descInf likeds(ceedod_inf_t) inz;
  dcl-ds strinf likeds(ceegsi_inf_t) inz;
  dcl-ds fc likeds(fc_t) inz;

  ceedod(p_expected: descInf.descType: descInf.dataType
         : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
  ceegsi(p_expected: strinf.dataType
         : strinf.curLen: strinf.maxLen: fc);
  tExpected = getvaluefromdesc(
                descInf: strinf: fc: expected: %size(expected));

  ceedod(p_actual: descInf.descType: descInf.dataType
         : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
  ceegsi(p_actual: strinf.dataType
         : strinf.curLen: strinf.maxLen: fc);
  tActual = getvaluefromdesc(descInf: strinf: fc: actual: %size(actual));

  if (%parms() >= p_fieldName and %addr(fieldname) <> *null);

    ceedod(p_fieldName: descInf.descType: descInf.dataType
           : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
    ceegsi(p_fieldName: strinf.dataType
           : strinf.curLen: strinf.maxLen: fc);
    tFieldName = getvaluefromdesc(
                   descInf: strinf: fc: fieldname: %size(fieldname));

    msg = %trim(tFieldName) + ': ';
  endif;

  msg = msg
        + 'Expected ' + QUOTE + %trimr(tExpected) + QUOTE + ','
        + ' but was ' + QUOTE + %trimr(tActual) + QUOTE + '.';
  doAssert(tExpected = tActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;


//----------------------------------------------------------------------
// Assert equality between two integers.
//----------------------------------------------------------------------
dcl-proc iEqual export;
  dcl-pi *N opdesc;
    expected    zoned(31) const;
    actual      zoned(31) const;
    fieldName   varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t) inz;


  if (%parms() >= 3 and %addr(fieldName) <> *null);
    msg = %trim(fieldName) + ': ';
  endif;

  msg = msg
        + 'Expected ' + formatNumeric(expected) + ','
        + ' but was ' + formatNumeric(actual) + '.';
  doAssert(expected = actual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;

//----------------------------------------------------------------------
// Assert equality between two alphanumeric variables.
//----------------------------------------------------------------------
dcl-proc nEqual export;
  dcl-pi *N opdesc;
    expected    ind const;
    actual      ind const;
    fieldName   varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t) inz;


  if (%parms() >= 3 and %addr(fieldName) <> *null);
    msg = %trim(fieldName) + ': ';
  endif;

  msg = msg
        + 'Expected ' + QUOTE + expected + QUOTE + ','
        + ' but was ' + QUOTE + actual   + QUOTE + '.';
  doAssert(expected = actual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());


end-proc;


//----------------------------------------------------------------------
// Cobol enabled.
// Asserts that a condition is true. See prototype.
//----------------------------------------------------------------------
dcl-proc assert export;
  dcl-pi *N opdesc;
    condition    ind const;
    msgIfFalse   like(oldMsg_t) options(*nopass) const;
  end-pi;

  dcl-c p_msgiffalse 2;

  dcl-s tMsgIfFalse varchar(16384);
  dcl-ds descInf likeds(ceedod_inf_t) inz;
  dcl-ds strinf likeds(ceegsi_inf_t) inz;
  dcl-ds fc likeds(fc_t) inz;

  if (%parms() >= p_msgiffalse);

    ceedod(p_msgiffalse: descInf.descType: descInf.dataType
           : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
    ceegsi(p_msgiffalse: strinf.dataType
           : strinf.curLen: strinf.maxLen: fc);
    tMsgIfFalse = getvaluefromdesc(
                    descInf: strinf: fc: msgIfFalse: %len(msgIfFalse));

    doAssert(condition: tMsgIfFalse: ONE_CALL_STK_LVL_ABOVE: %proc());
  else;
    // Called by Cobol or new RPG after iRPGUnit v4.
    doAssert(condition: NO_MSG_TEXT: ONE_CALL_STK_LVL_ABOVE: %proc());
  endif;

end-proc;


//----------------------------------------------------------------------
// Cobol enabled.
// Signals a test failure and stops the test.
//----------------------------------------------------------------------
dcl-proc fail export;
  dcl-pi *N opdesc;
    msg   like(oldMsg_t) options(*nopass) const;
  end-pi;

  dcl-c p_msg 1;

  dcl-s tMsg varchar(16384);
  dcl-ds descInf likeds(ceedod_inf_t) inz;
  dcl-ds strinf likeds(ceegsi_inf_t) inz;
  dcl-ds fc likeds(fc_t) inz;

  if (%parms() >= p_msg);

    ceedod(p_msg: descInf.descType: descInf.dataType
           : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
    ceegsi(p_msg: strinf.dataType
           : strinf.curLen: strinf.maxLen: fc);
    tMsg = getvaluefromdesc(descInf: strinf: fc: msg: %len(msg));

    doFail(tMsg: -1: %proc());
  else;
    // Called by Cobol or new RPG after iRPGUnit v4.
    doFail(NO_MSG_TEXT: -1: %proc());
  endif;

end-proc;


dcl-proc doAssert export;
  dcl-pi *N;
    condition      ind const;
    msgIfFalse     varchar(16384) options(*varsize) const;
    toCallStackE   int(10) const;
    startProc      varchar(256) options(*varsize) const;
  end-pi;

  checkStartPgm();

  assertCalled += 1;
  clrAssertFailEvt();

  if not condition;
    doFail(msgIfFalse:  toCallStackE + 1: startProc);
  endif;

end-proc;


dcl-proc doFail export;
  dcl-pi *N;
    msg            varchar(16384) options(*varsize) const;
    toCallStackE   int(10) const;
    startProc      varchar(256) options(*varsize) const;
  end-pi;

  assertFailEvt.msg = %trimr(msg);
  assertFailEvt.callstk = getCallStk(startProc);

  if (toCallStackE = -1);
    sndEscapeMsgToProcedure(msg: TEST_CASE_EXECUTOR);
  else;
    sndEscapeMsg(msg: toCallStackE + 1);
  endif;

end-proc;


//----------------------------------------------------------------------
// Clear the latest assertion failure event.
//----------------------------------------------------------------------
dcl-proc clrAssertFailEvt export;
  dcl-pi *N;
  end-pi;

  clear assertFailEvt;

end-proc;


//----------------------------------------------------------------------
// Returns the number of time assertions were called. See prototype.
//----------------------------------------------------------------------
dcl-proc getAssertCalled export;
  dcl-pi *N int(10);
  end-pi;

  return assertCalled;

end-proc;

//----------------------------------------------------------------------
// Return information about the latest assertion failure event.
//----------------------------------------------------------------------
dcl-proc getAssertFailEvt export;
  dcl-pi *N likeds(assertfailevt_t);
  end-pi;

  // Assert Failure Event of version 1
  dcl-ds assertFailEvt_v1 likeds(assertfailevt_t) inz;

  assertFailEvt_v1.msg = assertFailEvt.msg;
  assertFailEvt_v1.callstk = assertFailEvt.callstk;

  return assertFailEvt_v1;

end-proc;


//----------------------------------------------------------------------
// Return information about the latest assertion failure event.
//----------------------------------------------------------------------
dcl-proc getAssertFailEvtLong export;
  dcl-pi *N likeds(assertFailEvtLong_t);
  end-pi;

  return assertFailEvt;

end-proc;


//----------------------------------------------------------------------
// Resets the counter of the failed assertions.
//----------------------------------------------------------------------
dcl-proc clearAssertCounter export;
  dcl-pi *N;
  end-pi;

  assertCalled = 0;

end-proc;


//----------------------------------------------------------------------
// Searches the job log backwards for a specific message key, starting
// with the most recent message and back to a given timestamp.
//----------------------------------------------------------------------
dcl-proc assertJoblogContains export;
  dcl-pi *N opdesc;
    msgID           char(7) const;
    timeLimit       timestamp const;
  end-pi;

  dcl-s hReader         like(hjoblogreader_t);
  dcl-ds userData likeds(jobLogUserData_t);

  clear userData;
  userData.timeLimit = timeLimit;
  userData.isFound = *off;
  userData.msgID = msgID;

  hReader = JobLogReader_init(jl_rd_previous);
  joblogreader_read(hReader: %paddr('ASSERT_jobLogCallback'): %addr(userData));

  assert(userData.isFound: 'Message ' + msgID + ' not found in the job log.');

end-proc;


//----------------------------------------------------------------------
// Call back of JobLogReader used by assertJobLogContains().
//----------------------------------------------------------------------
dcl-proc jobLogCallback;
  dcl-pi *N ind;
    i_hMsgInfo      pointer const;
    i_pUserData     pointer const;
    i_msgID         char(7) const;
    i_msgText       varchar(132) const;
    i_msgSentTime   timestamp const;
  end-pi;

  dcl-ds userData likeds(jobLogUserData_t)
  based(i_pUserData);

  if (i_msgSentTime < userData.timeLimit);
    return *off;
  endif;

  if (i_msgID = userData.msgID);
    userData.isFound = *on;
    return *off;
  endif;

  return *on;

end-proc;


//----------------------------------------------------------------------
// Searches a given message queue backwards for a message identified
// by 'Id', 'text' or 'help text' starting with the most recent message
// and back to a given timestamp.
//----------------------------------------------------------------------
dcl-proc assertMessageQueueContains export;
  dcl-pi *N opdesc;
    userOrQueue     char(10) const;
    library         char(10) options(*omit) const;
    msgID           char(7) options(*omit) const;
    msgText         varchar(132) options(*omit) const;
    msgHelp         varchar(256) options(*omit) const;
    timeLimit       timestamp const;
  end-pi;

  // Message queue message field selection for QGYOLMSG API.
  dcl-ds fldSelect qualified;
    listDirection   char(10) inz('*PRV');
    reserved_1      char(2) inz;
    severity        int(10) inz(0);
    maxMsgLen       int(10) inz(132);
    maxMsgHlpLen    int(10) inz(0);
    selectOffs      int(10);
    selectCnt       int(10) inz(1);
    strMsgKeyOffs   int(10);
    fldIdOffs       int(10);
    fldCnt          int(10) inz(0);
    msgSelect       char(10) inz('*ALL');
    strMsgKey1      char(4) inz(x'FFFFFFFF');
    fldId           int(10) dim(4) inz;
  end-ds;

  dcl-s checkMsgID       ind inz(*off);
  dcl-s checkMsgText     ind inz(*off);
  dcl-s checkMsgHelp     ind inz(*off);
  dcl-s checkCount       int(10) inz(0);
  dcl-s checkMatch       int(10) inz(0);

  dcl-ds msgQueueInf     likeds(dsUserQueueInf);
  dcl-ds msgQueuesUsed   likeds(dsMsgQueuesUsed_t);
  dcl-ds listInfo        likeds(dsOpnList);
  dcl-ds msgBasicInfo    likeds(dsLstm0100EntHdr_t) based(p_msgBasicInfo);
  dcl-s p_msgBasicInfo   pointer;
  dcl-ds fldInfo         likeds(dsUserQueueInf_t_t) based(p_fldInfo);
  dcl-s p_fldInfo        pointer;
  dcl-s fldData          char(32766) based(p_fldData);
  dcl-s p_fldData        pointer;

  dcl-s i                int(10);
  dcl-s msgQueueList     char(32766);
  dcl-s sentTimestamp    timestamp;
  dcl-s msgIdx           int(10);
  dcl-s msgFound         ind inz(*off);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  fldSelect.selectOffs = %addr(fldSelect.msgSelect) - %addr(fldSelect);
  fldSelect.strMsgKeyOffs = %addr(fldSelect.strMsgKey1) - %addr(fldSelect);
  fldSelect.fldIdOffs = %addr(fldSelect.fldId) - %addr(fldSelect);

  clear msgQueueInf;
  if (%parms() >= %parmnum(library) and %addr(library) <> *null);
    msgQueueInf.ind = LSTM_MSG_QUEUE_NAME;
    msgQueueInf.userOrQueueNm = userOrQueue;
    msgQueueInf.libraryNm = library;
  else;
    msgQueueInf.ind = LSTM_USER_NAME;
    msgQueueInf.userOrQueueNm = userOrQueue;
  endif;

  fldSelect.fldCnt = 1;
  fldSelect.fldId(fldSelect.fldCnt) = LSTM_RPLY_STATUS;

  fldSelect.fldCnt += 1;
  fldSelect.fldId(fldSelect.fldCnt) = LSTM_SND_USER_PROFILE;

  if (%parms() >= %parmnum(msgID) and %addr(msgID) <> *null);
    checkMsgID = *on;
    checkCount += 1;
  endif;

  if (%parms() >= %parmnum(msgText) and %addr(msgText) <> *null);
    checkMsgText = *on;
    checkCount += 1;
    fldSelect.fldCnt += 1;
    fldSelect.fldId(fldSelect.fldCnt) = LSTM_MSG_WITH_RPL_DATA;
  endif;

  if (%parms() >= %parmnum(msgHelp) and %addr(msgHelp) <> *null);
    checkMsgHelp = *on;
    checkCount += 1;
    fldSelect.fldCnt += 1;
    fldSelect.fldId(fldSelect.fldCnt) = LSTM_MSG_HELP_WITH_RPL_DATA;
  endif;

  if (checkMsgID);
    if (msgID = '*EMPTY' and checkCount > 1);
      sndEscapeMsgToCaller('All other selection parameters must be +
                            omitted, when msgId is set to ''*EMPTY''');
    endif;
  endif;

  qgyolmsg(msgQueueList :
           %size(msgQueueList) :
           listInfo :
           LSTM_FULL_SYNCHRONOUS_BUILD :
           LSTM_SORT_NONE :
           fldSelect :
           %size(fldSelect) :
           msgQueueInf :
           msgQueuesUsed :
           percolateErrors);

  p_msgBasicInfo = %addr(msgQueueList);
  msgIdx = 1;

  checkMatch = 0;
  p_fldInfo = *null;

  if checkMsgID and msgID = '*EMPTY' and listInfo.totalRcdCnt = 0;
    return;
  endif;

  dow listInfo.totalRcdCnt > 0;
    if msgIdx > listInfo.retRcdCnt;
      if listInfo.totalRcdCnt > listInfo.retRcdCnt;
        sndEscapeMsgToCaller('Insufficient implementation. ' +
              'Should use QGYGTLE to retrieve records after ' +
                           %char(listInfo.retRcdCnt) + '. ' +
                                      'Please open an issue.');
      else;
        leave;
      endif;
    endif;

    sentTimestamp = getSentTimeMsgQMsg(msgBasicInfo);

    if sentTimestamp < timeLimit;
      leave;
    endif;

    if checkMsgID;
      checkMatch += 1;
    endif;

    if (msgBasicInfo.retFldCnt > 0);
      p_fldInfo = %addr(msgQueueList) + msgBasicInfo.retFldOffs;
      for i = 1 to msgBasicInfo.retFldCnt;
        if fldInfo.dataLen > 0;
          p_fldData = p_fldInfo + %size(fldInfo);
          select;
          when fldInfo.fldID = LSTM_MSG_WITH_RPL_DATA;
            if checkMsgText;
              if compare(msgText: %subst(fldData: 1: fldInfo.dataLen));
                checkMatch += 1;
              endif;
            endif;
          when fldInfo.fldID = LSTM_MSG_HELP_WITH_RPL_DATA;
            if checkMsgHelp;
              if compare(msgHelp: %subst(fldData: 1: fldInfo.dataLen));
                checkMatch += 1;
              endif;
            endif;
          endsl;
        endif;

        p_fldInfo = %addr(msgQueueList) + fldInfo.nextFldOffs;
      endfor;
    endif;

    if checkMatch = checkCount;
      msgFound = *on;
      leave;
    endif;

    // Go to next message in the job log.
    p_msgBasicInfo = %addr(msgQueueList) + msgBasicInfo.nextEntOffs;
    msgIdx += 1;
  enddo;

  qgyclst(listInfo.rqsHdl: percolateErrors);

  assert(msgFound: 'Message not found in message queue.');

end-proc;


//----------------------------------------------------------------------
//  Returns the call stack. Excludes stack entries RURUNNER
//  and the lower levels to QCMD.
//----------------------------------------------------------------------
dcl-proc getCallStk;
  dcl-pi *N likeds(callStk_t);
    startproc   varchar(256) options(*varsize) const;
  end-pi;

  // Call stack entries.
  dcl-ds callStk         likeds(callStk_t) inz;
  // Job id.
  dcl-ds jobIdInfo       likeds(dsjidf0100);
  // Call stack info header.
  dcl-ds hdr             likeds(dscstk0100hdr) based(hdr_p);
  dcl-s hdr_p            pointer;
  // Call stack info entry.
  dcl-ds ent             likeds(dscstk0100ent) based(ent_p);
  dcl-s ent_p            pointer;
  // Big buffer to receive call stack info.
  dcl-s rawCallStk       char(16383);
  // Statement Id.
  dcl-s sttid            char(10) based(sttid_p);
  dcl-s sttid_p          pointer;
  // Procedure name buffer.
  dcl-s procMmBuffer_p   pointer;
  dcl-s procNmBuffer     char(256) based(procMmBuffer_p);
  // Index.
  dcl-s i                int(10);
  dcl-s maxStkEnt        int(10);
  dcl-ds callStkE        likeds(callStkEnt_t);
  dcl-s doReturnStckE    ind inz(*off);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  jobIdInfo.jobNm = '*';
  jobIdInfo.usrNm = '';
  jobIdInfo.jobNb = '';
  jobIdInfo.intJobID = '';
  jobIdInfo.reserved = *loval;
  jobIdInfo.threadInd = 1;
  jobIdInfo.threadID  = *loval;

  qwvrcstk(rawCallStk :
           %size(rawCallStk) :
           'CSTK0100' :
           jobIdInfo :
           'JIDF0100' :
           percolateErrors);

  hdr_p = %addr(rawCallStk);
  ent_p = hdr_p + hdr.callStkOffs;

  maxStkEnt = hdr.nbCallStkEntRtn - 2;
  if (maxStkEnt > MAX_CALL_STK_SIZE);
    maxStkEnt = MAX_CALL_STK_SIZE;
  endif;

  for i = 1 to maxStkEnt;

    if (ent.pgmNm = 'RUCALLTST' or ent.pgmNm = 'RUPGMRMT');
      leave;
    endif;

    clear callStkE;

    if (i = maxStkEnt);
      callStkE.level = 0;
      callStkE.qstmt.procnm = CALL_STACK_INCOMPLETE;
    else;
      callStkE.level = 0;
      callStkE.qstmt.qpgm.nm = ent.pgmNm;
      callStkE.qstmt.qpgm.lib = ent.pgmLibNm;
      callStkE.qstmt.qmod.nm = ent.modNm;
      callStkE.qstmt.qmod.lib = ent.modLibNm;

      if ent.procNmLen <> 0;
        procMmBuffer_p = ent_p + ent.dspLtoProcNm;
        callStkE.qstmt.procnm =
           %subst(procNmBuffer: 1: ent.procNmLen);
      else;
        callStkE.qstmt.procnm = '';
      endif;

      if ent.nbSttid > 0;
        sttid_p = ent_p + ent.dspLtoSttid;
        callStkE.qstmt.specnb = %triml(%trim(sttid): '0');
      else;
        callStkE.qstmt.specnb = '*N';
      endif;
    endif;

    // Skip all procedures until we saw the
    // assertion procedure
    if (callStkE.qstmt.qpgm.nm = 'RUTESTCASE' and
        (callStkE.qstmt.qmod.nm = 'ASSERT' or
         callStkE.qstmt.qmod.nm = 'ASSERTV2') and
        callStkE.qstmt.procnm = startproc);
      doReturnStckE = *on;
      ent_p += ent.len;
      iter;
    endif;

    if (not doReturnStckE);
      ent_p += ent.len;
      iter;
    endif;

    callStk.nume += 1;
    callStk.entry(callStk.nume) = callStkE;

    ent_p += ent.len;

  endfor;

  return callStk;

end-proc;

//----------------------------------------------------------------------
// Converts the time a message was sent from the internal
// format CYMD to the ISO format.
//----------------------------------------------------------------------
dcl-proc getSentTimeMsgQMsg;
  dcl-pi *N timestamp;
    msg   likeds(dsLstm0100EntHdr_t) const;
  end-pi;

  dcl-s sentDateAsISO char(8);

  sentDateAsISO = %char(%date(msg.sentDate: *cymd0): *iso0);
  return %timestamp(sentDateAsISO + msg.sentTime + msg.microSeconds: *iso0);
end-proc;


//----------------------------------------------------------------------
// Returns the value of a given string depending on the
// descriptor information.
//----------------------------------------------------------------------
// Patially taken from Scott Klement's HTTPAPI.
//----------------------------------------------------------------------
// getRealSA(): Okay, this one's hard to explain :)
//
// The original peSoapAction parameter to HTTPAPI was defined as
// fixed length "64A CONST".  This was problematic because people
// needed to be able to specify longer strings.  So they'd use
// XPROC -- but that's really cumbersome.
//
// I wanted to allow longer SoapAction, but I don't want to break
// backward compatibility?  This is where it gets tricky...  how
// can old programs pass a 64A, and new programs pass a 16384A
// and have the routine work in either case??
//
// If the parameter is "16384A VARYING" the first two bytes must
// be the length of the data.  Since the original peSoapAction
// wasn't VARYING, the first two bytes would be actual data.
// and due to the nature of a Soap-Action, they'd have to be
// human readable.  That means the first character in the
// SoapAction would have to be > x'40' (Blank in EBCDIC)
//
// So a VARYING string that's 16384 long would be hex x'4000'
// in the first two bytes, but the lowest valid soap-action would
// be x'4040'
//
// This routine uses that fact to distinguish between the two
// types of SoapAction parameters and return the correct result
// (is this clever? or ugly?)
//
// NOTE: This is now used for content-type and useragent as well
//----------------------------------------------------------------------
dcl-proc getValueFromDescriptor_internal export;
  dcl-pi *N varchar(32565);
    descInf   likeds(ceedod_inf_t) const;
    strInf    likeds(ceegsi_inf_t) const;
    fc        likeds(fc_t) const;
    value     char(32565) options(*varsize);
    dftLen    int(10) const;
  end-pi;

  dcl-s length      char(2) based(p_value);
  dcl-s fixLength   char(32565) based(p_value);
  dcl-s varying2    varchar(32563) based(p_value);

  p_value = %addr(value);

  // Get value without an operational descriptor.
  // Version: 3.2 and before

  // Missing operational descriptor.
  if (fc.msgSev > 0 and fc.msgNo = x'0502');
    // Check if we have:
    //  a) an incorrect Cobol call without opdesc or
    //  b) an old RPG call from assert() or fail()
    //     with a message parameter defined as OldMsg_t.
    if (length > x'4000');
      return %subst(fixLength: 1: dftLen);
    else;
      // New style with a varying field, but without
      // an operational descriptor. Before: 4.0
      return varying2;
    endif;
  endif;

  // Get value from a descriptor.
  // Version: 4.0+

  select;
  when (descInf.dataType = DOD_TYPE_CHAR); // SBCS characters
    return %subst(value: 1: strInf.curLen);
  when (descInf.dataType = DOD_TYPE_CHARV2); // 2-byte-length + SBCS characters
    return %subst(value: 3: strInf.curLen);
  other;
    sndEscapeMsgAboveCtlBdy(
      'Unsupported data type: ' + descTypeToExt(descInf.dataType));
  endsl;

end-proc;


dcl-proc descTypeToExt;
  dcl-pi *N varchar(20);
    dataType   int(10) const;
  end-pi;

  select;
  when (dataType = DOD_TYPE_ESC);
    return 'unknown';
  when (dataType = DOD_TYPE_CHAR);
    return 'typeChar';      // SBCS characters
  when (dataType = DOD_TYPE_CHARZ);
    return 'typeCharZ';     // SBCS characters x'00' terminated
  when (dataType = DOD_TYPE_CHARV2);
    return 'typeCharV2';    // 2-byte varying SBCS characters
  when (dataType = DOD_TYPE_CHARV4);
    return 'typeCharV4';    // 4-byte varying SBCS characters
  when (dataType = DOD_TYPE_BIT);
    return 'typeBit';       // bits with values of 0 or 1
  when (dataType = DOD_TYPE_BITV2);
    return 'typeBitV2';     // 2-byte varying bits with values of 0 or 1
  when (dataType = DOD_TYPE_BITV4);
    return 'typeBitV4';     // 4-byte varying bits with values of 0 or 1
  when (dataType = DOD_TYPE_GCHAR);
    return 'typeGChar';     // DBCS characters
  when (dataType = DOD_TYPE_GCHARZ);
    return 'typeGCharZ';    // DBCS characters x'00' terminated
  when (dataType = DOD_TYPE_GCHARV2);
    return 'typeGCharV2';   // 2-byte varying DBCS characters
  when (dataType = DOD_TYPE_GCHARV4);
    return 'typeGCharV4';   // 4-byte varying DBCS characters
  other;
    return '*N';
  endsl;

end-proc;

