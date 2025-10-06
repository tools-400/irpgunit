**FREE
// ==========================================================================
//  iRPGUnit - Job Log Reader.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
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

ctl-opt NoMain;
/include qinclude,H_SPEC

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,COPYRIGHT
/include qinclude,ERRORCODE
/include qinclude,PGMMSG
/include qsysinc,QGYOLJBL
/include qsysinc,QGYCLST

/include qinclude,JOBLOG

//----------------------------------------------------------------------
//   TYPE TEMPLATES
//----------------------------------------------------------------------

dcl-ds hReader_t qualified template;
  length     int(5);
  isPrepared ind;
  fldSlcSize int(10);
  msgQ       varchar(10);
  currMsgCnt int(10);
  data       char(1024);
  fieldSelect likeds(fldSelect_QGYOLJBL_t) overlay(data);
end-ds;

dcl-ds hMsgInfo_t qualified template;
  pJobLogInfo pointer;
  pMsgInfo    pointer;
end-ds;

dcl-c FIELD_SIZE 4;

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr hasField ind extproc(*dclcase);
  i_hReader likeds(hReader_t);
  i_fieldId int(10) const;
end-pr;

dcl-pr prepareRead ind extproc(*dclcase);
  io_hReader  like(hJobLogReader_t);
end-pr;

dcl-pr setMsgQName ind extproc(*dclcase);
  io_hReader likeds(hReader_t);
end-pr;

dcl-pr getExtMsgType char(10) extproc(*dclcase);
  i_typeIntern char(2);
end-pr;

//----------------------------------------------------------------------
// Initializes a job log reader.
// Default settings are:
//  * read from new to old
//  * no message text, no message help
//  * return all messages
// Returns:
//  job log reader handle on succeess, else ''.
//----------------------------------------------------------------------
dcl-proc JobLogReader_init export;
  dcl-pi *n like(hJobLogReader_t);
    i_direction  varchar(10) const;
    i_msgQ       varchar(10) const options(*nopass);
  end-pi;

  dcl-s msgQ like(i_msgQ);

  dcl-s hReaderRtn like(hJobLogReader_t);
  dcl-ds hReader likeds(hReader_t) based(pHReaderDS);

  if (%parms() >= %parmnum(i_msgQ));
    msgQ = i_msgQ;
  else;
    msgQ = JL_RD_MSG_ALL;
  endif;

  pHReaderDS = %addr(hReaderRtn);

  clear hReader;
  hReader.fieldSelect.listDirection = i_direction;
  hReader.fieldSelect.qlfJobNm = '*';
  hReader.fieldSelect.intJobId = '';

  if (hReader.fieldSelect.listDirection = JL_RD_PREVIOUS);
    hReader.fieldSelect.startMsgKey   = x'FFFFFFFF';
  else;
    hReader.fieldSelect.startMsgKey   = x'00000000';
  endif;

  hReader.fieldSelect.maxMsgLen = 0;
  hReader.fieldSelect.maxMsgHlpLen = 0;
  hReader.fieldSelect.fldIdOffs = 0;
  hReader.fieldSelect.fldCnt = 0;
  hReader.fieldSelect.callMsgQNmOffs = 0;
  hReader.fieldSelect.callMsgqNmLen = 0;

  hReader.isPrepared = *off;
  hReader.fldSlcSize = 0;
  hReader.msgQ = msgQ;
  hReader.currMsgCnt = 0;
  hReader.length = %addr(hReader.fieldSelect) - %addr(hReader)
                   +  %size(hReader.fieldSelect);

  return hReaderRtn;

end-proc;

//----------------------------------------------------------------------
// Adds a field that is returned with each message.
// Returns:
//  number of fields returned on success, else -1.
//----------------------------------------------------------------------
dcl-proc JobLogReader_addField export;
  dcl-pi *n int(10);
    io_hReader    like(hJobLogReader_t);
    i_fieldId     int(10) const;
  end-pi;

  dcl-ds hReader likeds(hReader_t) based(pHReader);
  dcl-s  fieldID int(10) based(pFieldID);

  pHReader = %addr(io_hReader);

  if (hReader.isPrepared);
    return -1;
  endif;

  if (hReader.fieldSelect.fldIdOffs >= %size(hReader.data) - %size(i_fieldId));
    return -1;
  endif;

  hReader.fieldSelect.fldIdOffs = %size(hReader.fieldSelect);

  pFieldID = %addr(hReader.fieldSelect) + hReader.fieldSelect.fldIdOffs
                   + FIELD_SIZE * hReader.fieldSelect.fldCnt;

  fieldID = i_fieldId;
  hReader.fieldSelect.fldCnt += 1;

  hReader.fieldSelect.callMsgQNmOffs = hReader.fieldSelect.fldIdOffs +
                                       (FIELD_SIZE * hReader.fieldSelect.fldCnt);

  hReader.length += FIELD_SIZE;

  // Message text
  if (i_fieldId = OLJL_MSG or
      i_fieldId = OLJL_MSG_WITH_RPL_DATA);
    hReader.fieldSelect.maxMsgLen = 256;
  endif;

  // Message help text
  if (i_fieldId = OLJL_MSG_HELP or
      i_fieldId = OLJL_MSG_HELP_WITH_RPL_DATA or
      i_fieldId = OLJL_MSG_HELP_WITH_FORMAT_CHARS or
      i_fieldId = OLJL_MSG_HELP_WITH_RPL_DATA_AND_FORMAT_CHARS);
    hReader.fieldSelect.maxMsgHlpLen = 1000;
  endif;

  return hReader.fieldSelect.fldCnt;

end-proc;

//----------------------------------------------------------------------
// Reads a message from the job log.
// Returns:
//  *on on success, wlse *off.
//----------------------------------------------------------------------
dcl-proc JobLogReader_read export;
  dcl-pi *n ind;
    io_hReader   like(hJobLogReader_t);
    i_callback   pointer(*proc) const;
    i_pUserData  pointer options(*nopass) const;
  end-pi;

  dcl-s pUserData like(i_pUserData);

  dcl-ds hReader likeds(hReader_t) based(pHReader);

  dcl-s pCallback pointer(*proc);
  dcl-pr callback ind extproc(pCallback);
    i_hMsgInfo    pointer      const;
    i_pUserData   pointer      const;
    i_msgId       char(7)      const;
    i_msgText     varchar(132) const;
    i_msgSentTime timestamp    const;
  end-pr;

  dcl-s jobLogList char(32766);
  dcl-ds listInfo likeds(dsOpnList);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);
  dcl-ds msgBasicInfo likeds(dsOLJL0100EntHdr) based(p_msgBasicInfo);

  dcl-ds hMsgInfo likeds(hMsgInfo_t);

  dcl-s msgId char(7);
  dcl-s msgText varchar(132);
  dcl-s msgSentTime timestamp;

  if (%parms() >= %parmnum(i_pUserData));
    pUserData = i_pUserData;
  else;
    pUserData = *null;
  endif;

  pHReader = %addr(io_hReader);

  prepareRead(io_hReader);

  QGYOLJBL( jobLogList :
            %size( jobLogList ) :
            listInfo :
            OLJL_FULL_SYNCHRONOUS_BUILD :
            hReader.fieldSelect :
            hReader.fldSlcSize :
            percolateErrors);

  p_msgBasicInfo = %addr(jobLogList);
  hReader.currMsgCnt = 1;

  pCallback = i_callback;

  dow 1=1;
    if (hReader.currMsgCnt > listInfo.retRcdCnt);
      if (listInfo.totalRcdCnt > listInfo.retRcdCnt);
        sndEscapeMsgToCaller( 'Insufficient implementation. ' +
              'Should use QGYGTLE to retrieve records after ' +
                           %char( listInfo.retRcdCnt ) + '. ' +
                                      'Please open an issue.' );
      else;
        leave;
      endif;
    endif;

    clear hMsgInfo;
    hMsgInfo.pJobLogInfo = %addr(jobLogList);
    hMsgInfo.pMsgInfo = p_msgBasicInfo;

    msgId = msgBasicInfo.msgId;
    msgText = JobLogReader_getCharValue(%addr(hMsgInfo): OLJL_MSG_WITH_RPL_DATA);
    msgSentTime = getSentTimeJobLogMsg( msgBasicInfo );

    if (not callback(%addr(hMsgInfo): pUserData: msgId: msgText: msgSentTime));
      leave;
    endif;

    // Go to next message in the job log.
    p_msgBasicInfo = %addr( jobLogList ) + msgBasicInfo.nextEntOffs;
    hReader.currMsgCnt += 1;
  enddo;

  QGYCLST( listInfo.rqsHdl : percolateErrors );

  return *on;

end-proc;

//----------------------------------------------------------------------
// Gets a message by key from the job log.
// Returns:
//  *on on success, wlse *off.
//----------------------------------------------------------------------
dcl-proc JobLogReader_getMsg export;
  dcl-pi *n ind;
    i_msgKey     char(4) const;
    i_callback   pointer(*proc) const;
    i_pUserData  pointer options(*nopass) const;
    i_fieldId01  int(10) options(*nopass) const;
    i_fieldId02  int(10) options(*nopass) const;
    i_fieldId03  int(10) options(*nopass) const;
    i_fieldId04  int(10) options(*nopass) const;
    i_fieldId05  int(10) options(*nopass) const;
    i_fieldId06  int(10) options(*nopass) const;
    i_fieldId07  int(10) options(*nopass) const;
    i_fieldId08  int(10) options(*nopass) const;
    i_fieldId09  int(10) options(*nopass) const;
    i_fieldId10  int(10) options(*nopass) const;
    i_fieldId11  int(10) options(*nopass) const;
    i_fieldId12  int(10) options(*nopass) const;
    i_fieldId13  int(10) options(*nopass) const;
    i_fieldId14  int(10) options(*nopass) const;
    i_fieldId15  int(10) options(*nopass) const;
    i_fieldId16  int(10) options(*nopass) const;
  end-pi;

  dcl-s hReader like(hJobLogReader_t);
  dcl-ds hReaderDs likeds(hReader_t) based(pHReaderDS);

  pHReaderDS = %addr(hReader);

  hReader = JobLogReader_init(JL_RD_NEXT);
  hReaderDs.fieldSelect.startMsgKey = i_msgKey;

  if (%parms() >= %parmnum(i_fieldId01));
    JobLogReader_addField(hReader: i_fieldId01);
  endif;

  if (%parms() >= %parmnum(i_fieldId02));
    JobLogReader_addField(hReader: i_fieldId02);
  endif;

  if (%parms() >= %parmnum(i_fieldId03));
    JobLogReader_addField(hReader: i_fieldId03);
  endif;

  if (%parms() >= %parmnum(i_fieldId04));
    JobLogReader_addField(hReader: i_fieldId04);
  endif;

  if (%parms() >= %parmnum(i_fieldId05));
    JobLogReader_addField(hReader: i_fieldId05);
  endif;

  if (%parms() >= %parmnum(i_fieldId06));
    JobLogReader_addField(hReader: i_fieldId06);
  endif;

  if (%parms() >= %parmnum(i_fieldId07));
    JobLogReader_addField(hReader: i_fieldId07);
  endif;

  if (%parms() >= %parmnum(i_fieldId08));
    JobLogReader_addField(hReader: i_fieldId08);
  endif;

  if (%parms() >= %parmnum(i_fieldId09));
    JobLogReader_addField(hReader: i_fieldId09);
  endif;

  if (%parms() >= %parmnum(i_fieldId10));
    JobLogReader_addField(hReader: i_fieldId10);
  endif;

  if (%parms() >= %parmnum(i_fieldId11));
    JobLogReader_addField(hReader: i_fieldId11);
  endif;

  if (%parms() >= %parmnum(i_fieldId12));
    JobLogReader_addField(hReader: i_fieldId12);
  endif;

  if (%parms() >= %parmnum(i_fieldId13));
    JobLogReader_addField(hReader: i_fieldId13);
  endif;

  if (%parms() >= %parmnum(i_fieldId14));
    JobLogReader_addField(hReader: i_fieldId14);
  endif;

  if (%parms() >= %parmnum(i_fieldId15));
    JobLogReader_addField(hReader: i_fieldId15);
  endif;

  if (%parms() >= %parmnum(i_fieldId16));
    JobLogReader_addField(hReader: i_fieldId16);
  endif;

  return JobLogReader_read(hReader: i_callback: i_pUserData);

end-proc;

//----------------------------------------------------------------------
// Returns the message information of the current entry.
// Returns:
//  jl_rd_msgInfo_t
//----------------------------------------------------------------------
dcl-proc JobLogReader_getMsgInfo export;
  dcl-pi *n likeds(jl_rd_msgInfo_t);
    i_hMsgInfo   pointer const;
  end-pi;

  dcl-ds msgInfoRtn likeds(jl_rd_msgInfo_t);

  dcl-ds hMsgInfo likeds(hMsgInfo_t) based(i_hMsgInfo);
  dcl-ds msgBasicInfo likeds(dsOLJL0100EntHdr) based(hMsgInfo.pMsgInfo);

  msgInfoRtn.severity = msgBasicInfo.msgSeverity;
  msgInfoRtn.id = msgBasicInfo.msgId;

  msgInfoRtn.type = getExtMsgType(msgBasicInfo.msgType);

  msgInfoRtn.key = msgBasicInfo.msgKey;
  msgInfoRtn.file = msgBasicInfo.msgfNm;
  msgInfoRtn.lib = msgBasicInfo.msgfLib;
  msgInfoRtn.sndTime = %date(msgBasicInfo.sentDate: *cymd0) +
                       %time(msgBasicInfo.sentTime: *hms0) +
                       %mseconds(%dec(msgBasicInfo.microSeconds: 6: 0));
  msgInfoRtn.threadId = msgBasicInfo.threadId;
  msgInfoRtn.timeZone = msgBasicInfo.timeZone;

  return msgInfoRtn;

end-proc;

//----------------------------------------------------------------------
// Returns the external message type.
//----------------------------------------------------------------------

dcl-proc getExtMsgType;
  dcl-pi *n char(10);
    i_typeIntern char(2);
  end-pi;

  dcl-s msgType char(10);

  select;
  when (i_typeIntern = '01');
    msgType = '*COMP';
  when (i_typeIntern = '02');
    msgType = '*DIAG';
  when (i_typeIntern = '04');
    msgType = '*INFO';
  when (i_typeIntern = '05');
    msgType = '*INQ';
  when (i_typeIntern = '06');
    msgType = '*COPY';
  when (i_typeIntern = '08');
    msgType = '*RQS';
  when (i_typeIntern = '10');
    msgType = '*RQS';
  when (i_typeIntern = '14');
    msgType = '*NOTIFY';
  when (i_typeIntern = '15');
    msgType = '*ESCAPE';
  when (i_typeIntern = '16');
    msgType = '*NOTIFY';
  when (i_typeIntern = '17');
    msgType = '*ESCAPE';
  when (i_typeIntern = '21');
    msgType = '*REPLY';
  when (i_typeIntern = '22');
    msgType = '*REPLY';
  when (i_typeIntern = '23');
    msgType = '*REPLY';
  when (i_typeIntern = '24');
    msgType = '*REPLY';
  when (i_typeIntern = '25');
    msgType = '*REPLY';
  when (i_typeIntern = '26');
    msgType = '*REPLY';
  other;
    msgType = NO_VALUE;
  endsl;

  return msgType;

end-proc;

//----------------------------------------------------------------------
// Returns the value of a character field of a given job log message.
//----------------------------------------------------------------------
dcl-proc JobLogReader_getCharValue export;
  dcl-pi *n varchar(3000);
    i_hMsgInfo   pointer const;
    i_fieldId    int(10) const;
    i_dftValue   varchar(256) options(*nopass) const;
  end-pi;

  dcl-s value varchar(3000);

  dcl-ds hMsgInfo likeds(hMsgInfo_t) based(i_hMsgInfo);

  dcl-ds msgBasicInfo likeds(dsOLJL0100EntHdr) based(hMsgInfo.pMsgInfo);
  dcl-ds msgFieldInfo likeds(dsOLJL0100FldHdr) based(p_msgFieldInfo);
  dcl-s data char(3000) based(pData);
  dcl-s i int(10);

  p_msgFieldInfo = hMsgInfo.pJobLogInfo + msgBasicInfo.retFldOffs;

  for i = 1 to msgBasicInfo.retFldCnt;

    if (msgFieldInfo.fldId = i_fieldId);
      if (msgFieldInfo.dataType = 'C');
        if (msgFieldInfo.dataLen > 0);
          pData = p_msgFieldInfo + %size(msgFieldInfo);
          value = %subst(data: 1: msgFieldInfo.dataLen);
        endif;
        leave;
      endif;
    endif;

    p_msgFieldInfo = hMsgInfo.pJobLogInfo + msgFieldInfo.nextFldOffs;
  endfor;

  if (value = '' and %parms() >= %parmnum(i_dftValue));
    value = i_dftValue;
  endif;

  return value;

end-proc;

//----------------------------------------------------------------------
// Checks, if a given field id has been selected to be returned.
//----------------------------------------------------------------------
dcl-proc hasField;
  dcl-pi *n ind;
    i_hReader likeds(hReader_t);
    i_fieldId int(10) const;
  end-pi;

  dcl-s fieldId int(10) based(pFieldId);
  dcl-s i int(10);

  for i = 1 to i_hReader.fieldSelect.fldCnt;
    pFieldId = %addr(i_hReader.fieldSelect)
               + i_hReader.fieldSelect.fldIdOffs + ((i - 1) * FIELD_SIZE);
    if (fieldId = i_fieldId);
      return *on;
    endif;
  endfor;

  return *off;

end-proc;

//----------------------------------------------------------------------
// Prepares the message selection information.
//----------------------------------------------------------------------
dcl-proc prepareRead;
  dcl-pi *n ind;
    io_hReader  like(hJobLogReader_t);
  end-pi;

  dcl-ds hReader likeds(hReader_t) based(pHReader);

  pHReader = %addr(io_hReader);

  if (hReader.isPrepared);
    return *on;
  endif;

  if (hReader.fieldSelect.fldCnt = 0 or not hasField(hReader: OLJL_MSG_WITH_RPL_DATA));
    if (JobLogReader_addField(io_hReader: OLJL_MSG_WITH_RPL_DATA) < 1);
      return *off;
    endif;
  endif;

  setMsgQName(hReader);

  hReader.isPrepared = *on;
  hReader.fldSlcSize = %size(hReader.fieldSelect)
                           + hReader.fieldSelect.fldCnt * FIELD_SIZE
                           + hReader.fieldSelect.callMsgqNmLen;

  return *on;

end-proc;

//----------------------------------------------------------------------
// Set the message queue name in the message selection information
// data structure.
//----------------------------------------------------------------------
dcl-proc setMsgQName;
  dcl-pi *n ind;
    io_hReader likeds(hReader_t);
  end-pi;

  dcl-s msgQName char(10) based(p_msgQName);

  if (io_hReader.fieldSelect.callMsgQNmOffs >= %size(io_hReader.data) - %len(io_hReader.msgQ));
    return *off;
  endif;

  p_msgQName = %addr(io_hReader.fieldSelect) + io_hReader.fieldSelect.callMsgQNmOffs;

  %subst(msgQName: 1: %len(io_hReader.msgQ)) = io_hReader.msgQ;
  io_hReader.fieldSelect.callMsgqNmLen = %len(io_hReader.msgQ);

  io_hReader.length += %len(io_hReader.msgQ);

  return *on;

end-proc;

//----------------------------------------------------------------------
// Converts the time a job log entry was added from the internal
// format CYMD to the ISO format.
//----------------------------------------------------------------------
dcl-proc getSentTimeJobLogMsg;
  dcl-pi *n timestamp;
    msg likeds(dsOLJL0100EntHdr) const;
  end-pi;

  dcl-s sentDateAsIso char(8);

  sentDateAsIso = %char(%date(msg.sentDate: *cymd0): *iso0);
  return %timestamp(sentDateAsIso + msg.sentTime + msg.microSeconds: *iso0);

end-proc;

