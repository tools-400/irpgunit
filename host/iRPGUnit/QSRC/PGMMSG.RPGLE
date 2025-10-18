**FREE
// ==========================================================================
//  iRPGUnit - Program message handling.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. Ths program and the accompanying materials
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
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,PGMMSG

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ERRORCODE
/include qinclude,JOBLOG
/include qinclude,STRING
/include qinclude,SYSTEMAPI
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Local Procedures
//----------------------------------------------------------------------

dcl-pr jobLogCallback ind extproc('jobLogCallback');
  i_hmsginfo      pointer const;
  i_puserdata     pointer const;
  i_msgid         char(7) const;
  i_msgtext       varchar(132) const;
  i_msgsenttime   timestamp const;
end-pr;

//----------------------------------------------------------------------
//   Global Fields
//----------------------------------------------------------------------

dcl-ds g_status qualified;
  lastStsMsg   like(msgText_t) inz;
end-ds;


//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Receives the message data of an escape program message.
//----------------------------------------------------------------------
dcl-proc rcvExcpMsgInfo export;
  dcl-pi *N likeds(msg_t);
  end-pi;

  dcl-ds msg likeds(msg_t);

  msg = rcvPgmMsg( '*EXCP' : ONE_CALL_STK_LVL_ABOVE );

  return msg;

end-proc;


//----------------------------------------------------------------------
// Receives the message data of a program message.
//----------------------------------------------------------------------
dcl-proc rcvMsgData export;
  dcl-pi *N char(256);
    msgType   char(10) const;
  end-pi;

  dcl-ds msg likeds(msg_t);

  msg = rcvPgmMsg( msgType : ONE_CALL_STK_LVL_ABOVE );

  return msg.rpldata;

end-proc;


//----------------------------------------------------------------------
// Receives the message text of a program message.
//----------------------------------------------------------------------
dcl-proc rcvMsgTxt export;
  dcl-pi *N like(msgText_t);
    msgType   char(10) const;
  end-pi;

  dcl-ds msg likeds(msg_t);

  msg = rcvPgmMsg( msgType : ONE_CALL_STK_LVL_ABOVE );

  return msg.txt;

end-proc;


//----------------------------------------------------------------------
// Receives a program message.
//----------------------------------------------------------------------
dcl-proc rcvPgmMsg export;
  dcl-pi *N likeds(msg_t);
    msgType      char(10) const;
    callStkCnt   int(10) const options(*nopass);
  end-pi;

  // Safe value for the NoPass parameter callStkCnt.
  dcl-s safeCallStkCnt  like(callStkCnt);

  // Buffer for message info.
  dcl-s rawMsgBuf char(32767);
  dcl-ds rawMsgHdr likeds(rcvm0300hdr) based(rawMsgHdr_p);
  dcl-s rawMsgHdr_p pointer;

  // Position in buffer (starting at 1).
  dcl-s bufPos int(10);

  // Buffer for message sender info.
  dcl-ds senderInfo likeds(rcvm0300sender) based(senderInfo_p);
  dcl-s senderInfo_p pointer;

  // The received message.
  dcl-ds msg likeds(msg_t);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  if %parms() > 1;
    safeCallStkCnt = callStkCnt;
  else;
    safeCallStkCnt = 0;
  endif;

  qmhrcvpm( rawMsgBuf :
            %size(rawMsgBuf) :
            ALL_MSG_INFO_WITH_SENDER_INFO :
            THIS_CALL_STK_ENT :
            ONE_CALL_STK_LVL_ABOVE + safeCallStkCnt :
            msgType :
            NO_MSG_KEY :
            NO_WAIT :
            MARK_AS_OLD :
            percolateErrors );

  rawMsgHdr_p = %addr( rawMsgBuf );

  if (rawMsgHdr.bytAvl = 0);
    sndEscapeMsgToCaller( %trim(msgType) + ' message not found' );
  endif;

  msg.id = rawMsgHdr.msgID;

  bufPos = %size(rawMsgHdr) + 1;
  msg.rpldata = %subst( rawMsgBuf :
                        bufPos :
                        rawMsgHdr.rplDataLenR );

  bufPos += rawMsgHdr.rplDataLenR;
  msg.txt = %subst( rawMsgBuf :
                    bufPos :
                    rawMsgHdr.msgLenR );

  bufPos += rawMsgHdr.msgLenR;
  bufPos += rawMsgHdr.msgHlpLenR;
  senderInfo_p = %addr(rawMsgBuf) + bufPos - 1;
  msg.key = rawMsgHdr.msgKey;
  msg.qsndstmt.qpgm.nm = senderInfo.sndPgmNm;
  msg.qsndstmt.qpgm.lib = NO_VALUE;
  msg.qsndstmt.qmod.nm = senderInfo.sndModNm;
  msg.qsndstmt.qmod.lib = NO_VALUE;
  msg.qsndstmt.procnm = %trimr(senderInfo.sndProcNm);
  msg.qsndstmt.specnb = senderInfo.sndPgmSttNb(1);

  msg.qrcvstmt.qpgm.nm = senderInfo.rcvPgmNm;
  msg.qrcvstmt.qpgm.lib = NO_VALUE;
  msg.qrcvstmt.qmod.nm = senderInfo.rcvModNm;
  msg.qrcvstmt.qmod.lib = NO_VALUE;
  msg.qrcvstmt.procnm = %trimr(senderInfo.rcvProcNm);
  msg.qrcvstmt.specnb = senderInfo.rcvPgmSttNb(1);

  if (rawMsgHdr.msgKey <> '');
    JobLogReader_getMsg(rawMsgHdr.msgKey
                        : %paddr('jobLogCallback')
                        : %addr(msg)
                        : OLJL_SND_PGM_NM
                        : OLJL_SND_PGM_LIB
                        : OLJL_SND_MOD_NM
                        : OLJL_SND_PROC_NM
                        : OLJL_RCV_PGM_NM
                        : OLJL_RCV_PGM_LIB
                        : OLJL_RCV_MOD_NM
                        : OLJL_RCV_PROC_NM);
  endif;

  return msg;

end-proc;

dcl-proc jobLogCallback;
  dcl-pi *N ind;
    i_hmsginfo      pointer const;
    i_puserdata     pointer const;
    i_msgid         char(7) const;
    i_msgtext       varchar(132) const;
    i_msgsenttime   timestamp const;
  end-pi;

  dcl-ds msg likeds(msg_t) based(i_puserdata);
  dcl-ds msgInfo likeds(jl_rd_msginfo_t) inz;

  msgInfo = JobLogReader_getMsgInfo(i_hmsginfo);
  if (msgInfo.key <> msg.key);
    return *on;
  endif;

  msg.qsndstmt.qpgm.nm = JobLogReader_getCharValue(i_hmsginfo: OLJL_SND_PGM_NM: NO_VALUE);
  msg.qsndstmt.qpgm.lib = JobLogReader_getCharValue(i_hmsginfo: OLJL_SND_PGM_LIB: NO_VALUE);
  msg.qsndstmt.qmod.nm = JobLogReader_getCharValue(i_hmsginfo: OLJL_SND_MOD_NM: NO_VALUE);
  msg.qsndstmt.procnm = JobLogReader_getCharValue(i_hmsginfo: OLJL_SND_PROC_NM: NO_VALUE);

  msg.qrcvstmt.qpgm.nm = JobLogReader_getCharValue(i_hmsginfo: OLJL_RCV_PGM_NM: NO_VALUE);
  msg.qrcvstmt.qpgm.lib = JobLogReader_getCharValue(i_hmsginfo: OLJL_RCV_PGM_LIB: NO_VALUE);
  msg.qrcvstmt.qmod.nm = JobLogReader_getCharValue(i_hmsginfo: OLJL_RCV_MOD_NM: NO_VALUE);
  msg.qrcvstmt.procnm = JobLogReader_getCharValue(i_hmsginfo: OLJL_RCV_PROC_NM: NO_VALUE);

  return *off;

end-proc;

//----------------------------------------------------------------------
// Send an validation error message. Used by validity checker programs.
//----------------------------------------------------------------------
dcl-proc sndVldChkMsg export;
  dcl-pi *N;
    msg          like(msgText_t) const;
    callStkCnt   int(10) const;
  end-pi;

  // The message reference key.
  dcl-s msgKey char(4);
  dcl-s diagMsg varchar(256);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  diagMsg = '0000' + %trimr(msg);

  qmhsndpm( 'CPD0006' :
            'QCPFMSG   *LIBL' :
            %trimr(diagMsg) :
            %len(%trimr(diagMsg)) :
            '*DIAG' :
            CUR_CALL_STK_ENT :
            ONE_CALL_STK_LVL_ABOVE + callStkCnt :
            msgKey :
            percolateErrors );

  qmhsndpm( 'CPF0002' :
            'QCPFMSG   *LIBL' :
            '' :
            0 :
            '*ESCAPE' :
            CUR_CALL_STK_ENT :
            ONE_CALL_STK_LVL_ABOVE + callStkCnt :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Send a completion message. See prototype.
//----------------------------------------------------------------------
dcl-proc sndCompMsg export;
  dcl-pi *N;
    msg   like(msgText_t) const;
  end-pi;

  // The message reference key.
  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // CPDA0FF with severity 0.
  qmhsndpm( 'CPDA0FF' :
            'QCPFMSG   *LIBL' :
            %trimr(msg) :
            %len(%trimr(msg)) :
            '*COMP' :
            CONTROL_BOUNDARY :
            ONE_CALL_STK_LVL_ABOVE :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Send an escape message. See prototype.
//----------------------------------------------------------------------
dcl-proc sndEscapeMsg export;
  dcl-pi *N;
    msg          like(msgText_t) const;
    callStkCnt   int(10) const;
  end-pi;

  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // CPF9897 with severity 40.
  qmhsndpm( 'CPF9897' :
            'QCPFMSG   *LIBL' :
            msg :
            %len(msg) :
            '*ESCAPE' :
            CUR_CALL_STK_ENT :
            ONE_CALL_STK_LVL_ABOVE + callStkCnt :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Send an escape message to a procedure. See prototype.
//----------------------------------------------------------------------
dcl-proc sndEscapeMsgToProcedure export;
  dcl-pi *N;
    msg         like(msgText_t) const;
    procedure   varchar(256) const  options(*omit);
  end-pi;

  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // CPF9897 with severity 40.
  qmhsndpm( 'CPF9897' :
            'QCPFMSG   *LIBL' :
            msg :
            %len(msg) :
            '*ESCAPE' :
            procedure :
            0 :
            msgKey :
            percolateErrors :
            %len(procedure) :
            '*NONE     *NONE' :
            -1);

end-proc;


//----------------------------------------------------------------------
// Send an escape message to the caller. See prototype.
//----------------------------------------------------------------------
dcl-proc sndEscapeMsgToCaller export;
  dcl-pi *N;
    msg   like(msgText_t) const;
  end-pi;

  sndEscapeMsg( msg : two_call_stk_lvl_above );

end-proc;


//----------------------------------------------------------------------
// Send an escape message above control boundary. See prototype.
//----------------------------------------------------------------------
dcl-proc sndEscapeMsgAboveCtlBdy export;
  dcl-pi *N;
    msg like(msgText_t) const;
  end-pi;

  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // CPF9897 with severity 40.
  qmhsndpm( 'CPF9897' :
            'QCPFMSG   *LIBL' :
            %trimr(msg) :
            %len(%trimr(msg)) :
            '*ESCAPE' :
            CONTROL_BOUNDARY :
            ONE_CALL_STK_LVL_ABOVE :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Send an information message to the caller. See prototype.
//----------------------------------------------------------------------
dcl-proc sndInfoMsg export;
  dcl-pi *N;
    msg like(msgText_t) const;
  end-pi;

  // The message reference key.
  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // Send an immediate *INFO message without message ID
  qmhsndpm( '' :
            'QCPFMSG   *LIBL' :
            %trimr(msg) :
            %len(%trimr(msg)) :
            '*INFO' :
            CUR_CALL_STK_ENT :
            ONE_CALL_STK_LVL_ABOVE :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Send a status message.
//----------------------------------------------------------------------
dcl-proc sndStsMsg export;
  dcl-pi *N;
    msg   like(msgText_t) const;
  end-pi;

  // The message reference key.
  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  g_status.lastStsMsg = msg;

  // CPDA0FF with severity 40.
  qmhsndpm( 'CPDA0FF' :
            'QCPFMSG   *LIBL' :
            %trimr(msg) :
            %len(%trimr(msg)) :
            '*STATUS' :
            '*EXT' :
            *zero :
            msgKey :
            percolateErrors );

end-proc;


//----------------------------------------------------------------------
// Restores the previous status message.
//----------------------------------------------------------------------
dcl-proc rstStsMsg export;
  dcl-pi *N;
  end-pi;

  sndStsMsg(g_status.lastStsMsg);

end-proc;


//----------------------------------------------------------------------
// Retrieves the message key of the latest message in the job log.
//----------------------------------------------------------------------
dcl-proc getHighestMsgKey export;
  dcl-pi *N char(4);
  end-pi;

  // The message reference key.
  dcl-s msg varchar(128) inz('getHighestMsgKey');
  dcl-s msgKey char(4);
  dcl-ds rawmsgbuf qualified;
    bytRet   int(10);
    bytAvl   int(10);
  end-ds;
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // Send an immediate *INFO message without message ID
  qmhsndpm( '':
            'QCPFMSG   *LIBL' :
            msg :
            %len(msg) :
            '*INFO' :
            CUR_CALL_STK_ENT :
            this_call_stk_lvl :
            msgKey :
            percolateErrors );

  qmhrcvpm( rawmsgbuf :
            %size(rawmsgbuf) :
            EXTENDED_MSG_INFO :
            THIS_CALL_STK_ENT :
            this_call_stk_lvl :
            '*INFO' :
            msgKey :
            NO_WAIT :
            REMOVE_MSG :
            percolateErrors );

  return msgKey;

end-proc;


//----------------------------------------------------------------------
// Retrieves the latest escape message between 'highMsgKey' and NOW.
//----------------------------------------------------------------------
dcl-proc getLatestEscMsg export;
  dcl-pi *N likeds(msg_t);
    lowMsgKey   char(4) value;
    doRmvM#sg   ind value;
  end-pi;

  dcl-ds msg likeds(msg_t);

  // The message reference key.
  dcl-s lowKey          int(10) based(pLowKey);

  dcl-ds highMsgKey qualified inz;
    intValue   int(10);
  end-ds;

  dcl-s rawMsgBuf char(1024);
  dcl-ds rcvm0300 likeds(rcvm0300hdr) based(pRcvm0300);
  dcl-s pRcvm0300 pointer inz(%addr(rawMsgBuf));
  dcl-ds senderInfo likeds(rcvm0300sender) based(senderinfo_p);
  dcl-s msgOffs int(10);
  dcl-s msgLen int(10);
  dcl-s action char(10);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  if (lowMsgKey = *allx'00');
    sndEscapeMsgToCaller('Invalid lowMsgKey value. lowMsgKey must be greater than 0');
  endif;

  clear msg;

  pLowKey = %addr(lowMsgKey);
  highMsgKey = getHighestMsgKey();

  if (doRmvM#sg);
    action = REMOVE_MSG;
  else;
    action = KEEP_UNCHANGED;
  endif;

  reset errorCode;
  dow (msg.txt = '' and highMsgKey.intValue > lowKey and errorCode.bytAvl = 0);
    highMsgKey.intValue -= 1;
    qmhrcvpm( rawMsgBuf : %size(rawMsgBuf) :
              ALL_MSG_INFO_WITH_SENDER_INFO :
              THIS_CALL_STK_ENT : this_call_stk_lvl : '*ANY' :
              highMsgKey : NO_WAIT : KEEP_UNCHANGED : errorCode );
    if (errorCode.bytAvl > 0);
      if (errorCode.excID = 'CPF2410'); // Message key not found
        reset errorCode;
      endif;
    else;
      if (rcvm0300.bytAvl > 0);
        if (rcvm0300.msgLenR > 0);
          // Stored message description
          msgLen = rcvm0300.msgLenR;
          msgOffs = %size(rcvm0300) + 1 + rcvm0300.rplDataLenR;
        else;
          // Impromptu message
          msgLen = rcvm0300.rplDataLenR;
          msgOffs = %size(rcvm0300) + 1;
        endif;
        msg.id = rcvm0300.msgID;
        msg.txt = %subst(rawMsgBuf: msgOffs: msgLen);
        msg.rpldata = %subst(rawMsgBuf: %size(rcvm0300) + 1
                             : rcvm0300.rplDataLenR);
        senderinfo_p = %addr(rawMsgBuf) + %size(rcvm0300) +
                          rcvm0300.rplDataLenR +
                          rcvm0300.msgLenR +
                          rcvm0300.msgHlpLenR;
        msg.qsndstmt.qpgm.nm = senderInfo.sndPgmNm;
        msg.qsndstmt.qpgm.lib = NO_VALUE;
        msg.qsndstmt.qmod.nm = senderInfo.sndModNm;
        msg.qsndstmt.qmod.lib = NO_VALUE;
        msg.qsndstmt.procnm = %trimr(senderInfo.sndProcNm);
        msg.qsndstmt.specnb = senderInfo.sndPgmSttNb(1);

        msg.qrcvstmt.qpgm.nm = senderInfo.rcvPgmNm;
        msg.qrcvstmt.qpgm.lib = NO_VALUE;
        msg.qrcvstmt.qmod.nm = senderInfo.rcvModNm;
        msg.qrcvstmt.qmod.lib = NO_VALUE;
        msg.qrcvstmt.procnm = %trimr(senderInfo.rcvProcNm);
        msg.qrcvstmt.specnb = senderInfo.rcvPgmSttNb(1);

        if (rcvm0300.msgKey <> '');
          JobLogReader_getMsg(rcvm0300.msgKey
                              : %paddr('jobLogCallback')
                              : %addr(msg)
                              : OLJL_SND_PGM_NM
                              : OLJL_SND_PGM_LIB
                              : OLJL_SND_MOD_NM
                              : OLJL_SND_PROC_NM
                              : OLJL_RCV_PGM_NM
                              : OLJL_RCV_PGM_LIB
                              : OLJL_RCV_MOD_NM
                              : OLJL_RCV_PROC_NM);
        endif;

        if (doRmvM#sg);
          qmhrcvpm( rawMsgBuf : 8 :
                    BRIEF_MSG_INFO :
                    THIS_CALL_STK_ENT : this_call_stk_lvl : '*ANY' :
                    rcvm0300.msgKey : NO_WAIT : REMOVE_MSG :
                    errorCode );
        endif;
      endif;
    endif;
  enddo;

  return msg;

end-proc;

