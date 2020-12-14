**FREE
// ==========================================================================
//  iRPGUnit - List Spooled Files.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

/copy qinclude,TEMPLATES

dcl-s hSplfLister_t varchar(1024) template;

dcl-pr sl_ls_callback ind;
  i_hSplf       pointer       const;
  i_pUserData   pointer       const;
  i_splfNm      char(10)      const;
  i_qJob        likeds(Job_t) const;
  i_splFNbr     int(10)       const;
  i_fileStatus  char(10)      const;
end-pr;

dcl-c SL_STS_CLOSED     '*CLOSED';
dcl-c SL_STS_DEFERRED   '*DEFERRED';
dcl-c SL_STS_SENDING    '*SENDING';
dcl-c SL_STS_FINISHED   '*FINISHED';
dcl-c SL_STS_HELD       '*HELD';
dcl-c SL_STS_MESSAGE    '*MESSAGE';
dcl-c SL_STS_OPEN       '*OPEN';
dcl-c SL_STS_PENDING    '*PENDING';
dcl-c SL_STS_PRINTER    '*PRINTER';
dcl-c SL_STS_READY      '*READY';
dcl-c SL_STS_SAVED      '*SAVED';
dcl-c SL_STS_WRITING    '*WRITING';

dcl-pr SplFLister_init like(hSplfLister_t) extproc('SplFLister_init');
  i_qJob    likeds(Job_t) const options(*nopass);
  i_splfNm  char(10)      const options(*nopass);
  i_usrDta  char(10)      const options(*nopass);
end-pr;

dcl-pr SplFLister_addStatus int(10) extproc('SplFLister_addStatus');
  io_hLister  like(hSplfLister_t);
  i_status    char(10) const;
end-pr;

dcl-pr SplFLister_setStartTime ind extproc('SplFLister_setStartTime');
    io_hLister   like(hSplfLister_t);
    i_startTime  timestamp const;
end-pr;

dcl-pr SplFLister_setEndTime ind extproc('SplFLister_setEndTime');
    io_hLister  like(hSplfLister_t);
    i_endTime   timestamp const;
end-pr;

dcl-pr SplFLister_list ind extproc('SplFLister_list');
  io_hLister   like(hSplfLister_t);
  i_pCallback  pointer(*proc) const;
  i_pUserData  pointer options(*nopass) const;
end-pr;

dcl-pr SplFLister_getUserData char(10) extproc('SplFLister_getUserData');
  i_hSplf  pointer const;
end-pr;

