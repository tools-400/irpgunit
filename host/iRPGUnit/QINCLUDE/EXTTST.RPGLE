**FREE
// ==========================================================================
//  iRPGUnit - Extract Test Cases.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr activateTestSuite extproc('EXTTST_activateTestSuite');
  testSuite       likeds(testSuite_t);
  actMark         like(actMark_t) const;
end-pr;

dcl-pr getTestProc likeds(proc_t) extproc('EXTTST_getTestProc');
  testSuite       likeds(testSuite_t) const;
  testIdx         int(10) const;
end-pr;

dcl-pr getTestSuite likeds(testSuite_t) extproc('EXTTST_getTestSuite');
  procNmList      likeds(procNmList_t) const;
end-pr;

// Get a test case's name.
dcl-pr getTestNm extproc('EXTTST_getTestNm') like(procNm_t);
  testSuite       likeds(testSuite_t) const;
  testIdx         int(10) const;
end-pr;
