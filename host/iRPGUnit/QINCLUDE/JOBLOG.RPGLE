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

dcl-s hJobLogReader_t varchar(1024) template;

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

dcl-pr JobLogReader_getCharValue varchar(3000) extproc('JOBLOG_JobLogReader_getCharValue');
  i_hMsgInfo   pointer const;
  i_fieldId    int(10) const;
end-pr;

