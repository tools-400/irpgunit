**free
// ==========================================================================
//  iRPGUnit Fixture - Failure in proc called by test.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE

dcl-proc failingProc;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(5:2+2);

end-proc;

dcl-proc testStack export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  failingProc();

end-proc;

