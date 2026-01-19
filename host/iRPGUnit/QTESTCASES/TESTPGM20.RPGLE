**free
// ==========================================================================
//  iRPGUnit Fixture - Test options(*exact). CmpErr.
//  Intentionally fails compiling with errror:
//  RNF3245 No prototype in the OVERLOAD keyword matches the parameters
// ==========================================================================
//  Copyright (c) 2013-2024 iRPGUnit Project Team
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

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE

dcl-proc testOptionsExact;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s actualDecLoss zoned(30:25) inz(1,1234567890123456789012345);
  dcl-s expectedDecLoss zoned(30:25) inz(1,1234567890123456789012345);

  assertEqual( actualDecLoss : expectedDecLoss );

end-proc;

