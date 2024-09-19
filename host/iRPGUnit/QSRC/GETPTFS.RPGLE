**free
// ==========================================================================
//  iRPGUnit - Get OS400 PTF Status.
// ==========================================================================
//  Copyright (c) 2013-2024 iRPGUnit Project Team
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

ctl-opt main(getRelease);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT


//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,OSVERSION
/include qinclude,SYSTEMAPI

//----------------------------------------------------------------------
//   MAIN PROGRAM
//----------------------------------------------------------------------

dcl-pr getPTFStatus extpgm('RUGETPTFS');
  i_ptf       char(7);
  o_status    char(20);
end-pr;

//----------------------------------------------------------------------
//   Program Entry Point
//----------------------------------------------------------------------
dcl-proc getRelease;
  dcl-pi *n;
    i_ptf       char(7);
    o_status    char(20);
  end-pi;

  dcl-s release char(6);
  dcl-s ptfStatus char(1);

  release = OS_getVersion();
  ptfStatus = OS_getPTFLoadedStatus(i_ptf: '5770SS1': release);

  select;
  when (ptfStatus = PTF_LOADED_STATUS_NOT_LOADED);
    o_status = 'NEVER_LOADED';
  when (ptfStatus = PTF_LOADED_STATUS_LOADED);
    o_status = 'LOADED';
  when (ptfStatus = PTF_LOADED_STATUS_APPLIED);
    o_status = 'APPLIED';
  when (ptfStatus = PTF_LOADED_STATUS_PERMANENTLY_APPLIED);
    o_status = 'PERMANENTLY_APPLIED';
  when (ptfStatus = PTF_LOADED_STATUS_PERMANENTLY_REMOVED);
    o_status = 'PERMANENTLY_REMOVED';
  when (ptfStatus = PTF_LOADED_STATUS_DAMAGED);
    o_status = 'DAMAGED';
  when (ptfStatus = PTF_LOADED_STATUS_SUPERSEDED);
    o_status = 'SUPERSEDED';
  other;
    o_status = 'UNKNOWN';
  endsl;

end-proc;

