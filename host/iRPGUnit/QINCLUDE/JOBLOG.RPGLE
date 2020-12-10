**FREE
// ==========================================================================
//  iRPGUnit - Job Log Reader.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-s hJobLogReader_t varchar(1024) template;

dcl-c JL_RD_NEXT     '*NEXT';
dcl-c JL_RD_PREVIOUS '*PRV';
dcl-c JL_RD_MSG_EXT  '*EXT';
dcl-c JL_RD_MSG_ALL  '*';

dcl-pr JobLogReader_init like(hJobLogReader_t) extproc('JobLogReader_init');
  i_direction  varchar(10) const;
  i_msgQ       varchar(10) const options(*nopass);
end-pr;

dcl-pr JobLogReader_addField extproc('JobLogReader_addField');
  io_hReader    like(hJobLogReader_t);
  i_fieldID     pointer options(*nopass) const;
end-pr;

dcl-pr JobLogReader_read ind extproc('JobLogReader_read');
  io_hReader   like(hJobLogReader_t);
  i_pUserData  pointer options(*nopass) const;
end-pr;

