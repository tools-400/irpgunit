**free
// ==========================================================================
//  iRPGUnit Fixture - One empty test case.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

dcl-proc testEmpty export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

