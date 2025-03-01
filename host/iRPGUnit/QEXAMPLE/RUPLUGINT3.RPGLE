**FREE
// ==========================================================================
//  iRPGUnit Dev. of RDP Plugin. OK + Toggle
//  FAILURE. 4 test cases, 5 assertions, 1 failure, 0 error.
//  (Toggles the test result with each call.)
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

ctl-opt NoMain Option(*SrcStmt : *NoDebugIO);

dcl-s g_dtaara char(21) inz;

dcl-ds dataStore len(50) dtaara(g_dtaara) qualified;
  toggle1  ind inz;
  toggle2  ind inz;
  reserved char(48) inz;
end-ds;

dcl-ds sds qualified psds;
  pgmName char(10) pos(1);
  pgmLib  char(10) pos(81);
end-ds;

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTCASE

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

// ============================================================
//  Set up test suite. Executed once per RUCALLTST.
// ============================================================
dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  monitor;
    g_dtaara = %trim(sds.pgmLib) + '/' + %trim(sds.pgmName);
    runCmd('CRTDTAARA DTAARA(' + %trim(g_dtaara) + ') TYPE(*CHAR) LEN(50) +
            TEXT(''RPGUnit Data Store of ' + %trim(sds.pgmName) + ''')');
  on-error;
    // ignore errors ...
  endmon;

end-proc;

// ============================================================
//  Contains 1 assertion, all TRUE.
// ============================================================
dcl-proc testAllOK_1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assert(*on: 'OK: 1');

end-proc;

// ============================================================
//  Contains 2 assertions, all TRUE.
// ============================================================
dcl-proc testAllOK_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assert(*on: 'OK: 1');
  assert(*on: 'OK: 2');

end-proc;

// ============================================================
//  Toggles the boolean flag 1. Checks the flag for *ON.
// ============================================================
dcl-proc testToggleOK_1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  in *lock dataStore;
  dataStore.toggle1 = not dataStore.toggle1;
  out dataStore;

  assert(dataStore.toggle1: 'Toggle flag 1 must be *ON');

end-proc;

// ============================================================
//  Toggles the boolean flag 2. Checks the flag for *OFF.
// ============================================================
dcl-proc testToggleOK_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  internalToggleOK_2();

end-proc;

// ============================================================
//  Internal procedure to toggle the boolean flag 2.
// ============================================================
dcl-proc internalToggleOK_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  in *lock dataStore;
  dataStore.toggle2 = not dataStore.toggle2;
  out dataStore;

  assert(not dataStore.toggle2: 'Toggle flag 2 must be *OFF');

end-proc;

