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

/include qinclude,COPYRIGHT
/include qinclude,ERRORCODE
/include qsysinc,QGYOLJBL

/include qinclude,JOBLOG

dcl-ds hReader_t qualified;
  length int(5);
  data   char(2014);
end-ds;

dcl-proc JobLogReader_init export;
  dcl-pi *n like(hJobLogReader_t);
    i_direction  varchar(10) const;
    i_msgQ       varchar(10) const options(*nopass);
  end-pi;

  dcl-ds hReader likeds(hReader_t);


  return hReader;

end-proc;

