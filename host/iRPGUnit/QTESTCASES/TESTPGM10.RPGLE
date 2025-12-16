**FREE
// ==========================================================================
//  iRPGUnit Fixture - Error in teardown.
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

ctl-opt NoMain Option(*SrcStmt: *NoDebugIo);

/include qinclude,TESTCASE

dcl-proc test export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
  dcl-s x               int(10);
  dcl-s zero            int(10) inz(*zero);

  x = 1 / zero;

end-proc;
