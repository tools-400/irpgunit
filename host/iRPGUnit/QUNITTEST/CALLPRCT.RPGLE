**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test CALLPRC.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/CALLPRCT);
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CALLPRC
/copy qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s mockProcWasCalled ind;

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------
dcl-proc testCallProcByPtr export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  mockProcWasCalled = *off;

  callProcByPtr(%paddr(mockProc));

  assert(mockProcWasCalled: 'mockProc not called');

end-proc;


dcl-proc testCallProcByPtr_NullPtr export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  monitor;
    callProcByPtr(*null);
  on-error;
    fail('callProcByPtr(*null) should not raise an error');
  endmon;

end-proc;

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------
dcl-proc mockProc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  mockProcWasCalled = *on;

end-proc;

