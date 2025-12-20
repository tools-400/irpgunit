**free
// ==========================================================================
//  iRPGUnit Fixture - Exported proc is not a test.
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

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE

dcl-proc test1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc test2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc not_a_test export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  fail('not_a_test should not be called.');

end-proc;

