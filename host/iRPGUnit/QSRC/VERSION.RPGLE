**FREE
// ==========================================================================
//  iRPGUnit - Product Version Procedures Definitions.
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

/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT

/include qinclude,VERSION

dcl-proc getversion export;
  dcl-pi *N;
    version   char(20);
    date      char(10);
  end-pi;

  if (RPGUNIT_DATE = 'xx.xx.xxxx'); // Date of dev. library
    date = %char(%date(): *iso);
  else;
    date = convertdatetoiso(RPGUNIT_DATE);
  endif;

  version = RPGUNIT_VERSION;

end-proc;


dcl-proc convertDateToISO;
  dcl-pi *N char(10) extproc(*dclcase);
    euro   char(10) const;
  end-pi;

  dcl-s iso char(10);
  dcl-s date date;

  date = %date(euro: *eur);
  iso = %char(date: *iso);

  return iso;

end-proc;
