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

dCl-S hJobLogReader_t varchar(1024) template;

dcl-ds jl_rd_msgInfo_t qualified template;
  severity      int(10);
  id            char(7);
  type          char(10);
  key           char(4);
  file          char(10);
  lib           char(10);
  sndTime       timestamp;
  threadId      char(8);
  timeZone      char(10);
end-ds;

dcl-pr jl_rd_callback ind;
  i_hMsgInfo    pointer      const;
  i_pUserData   pointer      const;
  i_msgId       char(7)      const;
  i_msgText     varchar(132) const;
  i_msgSentTime timestamp    const;
end-pr;

dcl-c JL_RD_NEXT     '*NEXT';
dcl-c JL_RD_PREVIOUS '*PRV';
dcl-c JL_RD_MSG_EXT  '*EXT';
dcl-c JL_RD_MSG_ALL  '*';

dcl-pr JobLogReader_init like(hJobLogReader_t) extproc('JOBLOG_JobLogReader_init');
  i_direction  varchar(10) const;
  i_msgQ       varchar(10) const options(*nopass);
end-pr;

dcl-pr JobLogReader_addField int(10) extproc('JOBLOG_JobLogReader_addField');
  io_hReader   like(hJobLogReader_t);
  i_fieldId    int(10) const;
end-pr;

dcl-pr JobLogReader_read ind extproc('JOBLOG_JobLogReader_read');
  io_hReader   like(hJobLogReader_t);
  i_callback   pointer(*proc) const;
  i_pUserData  pointer options(*nopass) const;
end-pr;

dcl-pr JobLogReader_getMsg ind extproc('JOBLOG_JobLogReader_getMsg');
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
end-pr;

dcl-pr JobLogReader_getMsgInfo likeds(jl_rd_msgInfo_t) extproc('JobLogReader_getMsgInfo');
  i_hMsgInfo   pointer const;
end-pr;

dcl-pr JobLogReader_getCharValue varchar(3000) extproc('JOBLOG_JobLogReader_getCharValue');
  i_hMsgInfo   pointer const;
  i_fieldId    int(10) const;
  i_dftValue   varchar(256) options(*nopass) const;
end-pr;

