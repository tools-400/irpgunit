**free
// ==========================================================================
//  iRPGUnit Fixture - Error during test.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE

dcl-proc testError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s x int(10);
  dcl-s zero int(10) inz(*zero);

  x = 1 / zero;

end-proc;

