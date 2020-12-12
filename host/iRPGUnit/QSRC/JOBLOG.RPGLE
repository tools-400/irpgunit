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

dcl-ds msgInfo_t qualified template;
  pJobLogInfo pointer;
  pMsgInfo    pointer;
end-ds;

dcl-c FIELD_SIZE 4;

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr hasField ind extproc('hasField');
  i_hReader likeds(hReader_t);
  i_fieldId int(10) const;
end-pr;

dcl-pr prepareRead ind extproc('prepareRead');
  io_hReader  like(hJobLogReader_t);
end-pr;

dcl-pr setMsgQName ind extproc('setMsgQName');
  io_hReader likeds(hReader_t);
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
  hReader.fieldSelect.fldIdOff = 0;
  hReader.fieldSelect.fldCnt = 0;
  hReader.fieldSelect.callMsgqNmOff = 0;
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

  if (hReader.fieldSelect.fldIdOff >= %size(hReader.data) - %size(i_fieldId));
    return -1;
  endif;

  hReader.fieldSelect.fldIdOff = %size(hReader.fieldSelect);

  pFieldID = %addr(hReader.fieldSelect) + hReader.fieldSelect.fldIdOff
                   + FIELD_SIZE * hReader.fieldSelect.fldCnt;

  fieldID = i_fieldId;
  hReader.fieldSelect.fldCnt += 1;

  hReader.fieldSelect.callMsgqNmOff = hReader.fieldSelect.fldIdOff +
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

  dcl-ds msgInfo likeds(msgInfo_t);

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

    clear msgInfo;
    msgInfo.pJobLogInfo = %addr(jobLogList);
    msgInfo.pMsgInfo = p_msgBasicInfo;

    msgId = msgBasicInfo.msgId;
    msgText = JobLogReader_getCharValue(%addr(msgInfo): OLJL_MSG_WITH_RPL_DATA);
    msgSentTime = getSentTimeJobLogMsg( msgBasicInfo );

    if (not callback(%addr(msgInfo): pUserData: msgId: msgText: msgSentTime));
      leave;
    endif;

    // Go to next message in the job log.
    p_msgBasicInfo = %addr( jobLogList ) + msgBasicInfo.nextEntOff;
    hReader.currMsgCnt += 1;
  enddo;

  QGYCLST( listInfo.rqsHdl : percolateErrors );

  return *on;

end-proc;

//----------------------------------------------------------------------
// Returns the value of a character field of a given job log message.
//----------------------------------------------------------------------
dcl-proc JobLogReader_getCharValue export;
  dcl-pi *n varchar(3000);
    i_hMsgInfo   pointer const;
    i_fieldId    int(10) const;
  end-pi;

  dcl-s value varchar(3000);

  dcl-ds msgInfo likeds(msgInfo_t) based(i_hMsgInfo);

  dcl-ds msgBasicInfo likeds(dsOLJL0100EntHdr) based(msgInfo.pMsgInfo);
  dcl-ds msgFieldInfo likeds(dsOLJL0100FldHdr) based(p_msgFieldInfo);
  dcl-s data char(3000) based(pData);
  dcl-s i int(10);

  p_msgFieldInfo = msgInfo.pJobLogInfo + msgBasicInfo.retFldOff;

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

    p_msgFieldInfo = msgInfo.pJobLogInfo + msgFieldInfo.nextFldOff;
  endfor;

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
               + i_hReader.fieldSelect.fldIdOff + ((i - 1) * FIELD_SIZE);
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

  if (io_hReader.fieldSelect.callMsgqNmOff >= %size(io_hReader.data) - %len(io_hReader.msgQ));
    return *off;
  endif;

  p_msgQName = %addr(io_hReader.fieldSelect) + io_hReader.fieldSelect.callMsgqNmOff;

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
  return %timestamp(sentDateAsIso + msg.sentTime + msg.microseconds: *iso0);

end-proc;

