**FREE
// ==========================================================================
//  iRPGUnit Dev. of RDP Plugin. ON-EXIT op-code.
//  Success. 2 test cases, 3 assertions, 0 failure, 0 error.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//    >>PRE-COMPILER<<
//      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
//                              SRCFILE(&SL/&SF) SRCMBR(&SM);
//      >>IMPORTANT<<
//        >>PARM<< COPTION(*SRCSTMT *EVENTF);
//        >>PARM<< DBGVIEW(*LIST);
//      >>END-IMPORTANT<<
//      >>EXECUTE<<
//    >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTCASE

// ============================================================
//  Set up test suite. Executed once per RUCALLTST.
// ============================================================
dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

// ============================================================
//  Test that on-exit is called and that
//  isAbnormalEnd is set to *OFF.
// ============================================================
dcl-proc testAllOK_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assert(*on: 'OK: 1');
  assert(*on: 'OK: 2');

end-proc;

// ============================================================
//  Test that on-exit is called and that
//  isAbnormalEnd is set to *OFF.
// ============================================================
dcl-proc testError_1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s a int(10);
  dcl-s b int(10);

  b = a / b;

  assert(*off: 'SHOULD NEVER BE REACHED');

end-proc;

// ============================================================
//  Procedure, that is called on-exit.
// ============================================================
dcl-proc onExitProcNoError export;
  dcl-pi *n extproc(*dclcase);
    io_onExitWasCalled ind;
  end-pi;

  dcl-s isAbnormalEnde ind;

  on-exit isAbnormalEnde;

  io_onExitWasCalled = *on;

end-proc;

// ============================================================
//  Procedure, that is called on-exit.
// ============================================================
dcl-proc onExitProcWithError export;
  dcl-pi *n extproc(*dclcase);
    io_onExitWasCalled ind;
  end-pi;

  dcl-s value1 int(10);
  dcl-s value2 int(10);

  dcl-s isAbnormalEnde ind;

  value1 = 10;
  value2 = 0;

  // division by zero!
  value2 = value1 / value2;

  on-exit isAbnormalEnde;

  io_onExitWasCalled = *on;

end-proc;

