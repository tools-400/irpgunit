**free
// ==========================================================================
//  iRPGUnit Fixture - Two failing test cases.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE

dcl-proc testFalse export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(5: 2+2);

end-proc;

dcl-proc testFalse2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  iEqual(6: 2+2);

end-proc;

