**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test EXTTST.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/CALLPRC   +
//                      &LI/CMDRUNLOG +
//                      &LI/CMDRUNPRT +
//                      &LI/CMDRUNSRV +
//                      &LI/EXTPRC    +
//                      &LI/EXTTST    +
//                      &LI/JOBLOG    +
//                      &LI/LLIST     +
//                      &LI/OBJECT    +
//                      &LI/OSVERSION +
//                      &LI/PGMMSG    +
//                      &LI/SRCMBR    +
//                      &LI/STRING    +
//                      &LI/USRSPC    +
//                     );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/CALLPRC  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNSRV) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/EXTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LLIST    ) SRCFILE(&SL/QLLIST) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CALLPRC
/copy qinclude,EXTTST
/copy qinclude,EXTPRC
/copy qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Global DS
//----------------------------------------------------------------------

dcl-ds testSuite likeds(TestSuite_t);

dcl-s mockProcArray dim(2) like(ProcNm_t);
dcl-ds mockProcNmList likeds(ProcNmList_t);

//---------------------------------------------------------------------
//   Global Variable
//---------------------------------------------------------------------

dcl-s dummyHandle char(5) inz('dummy');
dcl-s mockProcIdx int(10);
dcl-s mockProcCnt int(10);
// Expected test procedure.
dcl-ds expTestProc likeds(Proc_t);

//---------------------------------------------------------------------
//   Program Status Data Structure
//---------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear expTestProc;

  clear mockProcArray;
  mockProcIdx = 1;
  mockProcCnt = 0;

  mockProcNmList.handle = %addr(dummyHandle);
  mockProcNmList.cnt = %paddr('getMockProcCnt');
  mockProcNmList.getNm = %paddr('getMockProcNm');
  mockProcNmList.goToNext = %paddr('goToNext');

end-proc;


dcl-proc testOneProcOneTestCase export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  mockProcCnt = 1;
  mockProcArray(1) = 'TEST_1';

  // Execution.

  testSuite = getTestSuite(mockProcNmList);

  // Controls.

  iEqual(1: testSuite.testCasesCnt);
  aEqual(*blank: testSuite.setUp.procNm);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

  aEqual(*blank: testSuite.tearDown.procNm);

end-proc;


dcl-proc testOneProcNoTestCase export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  mockProcCnt = 1;
  mockProcArray(1) = 'NOT_A_TEST_1';

  testSuite = getTestSuite( mockProcNmList);

  iEqual(0: testSuite.testCasesCnt);

end-proc;


dcl-proc testTwoProcsTwoTestCases export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  mockProcCnt = 2;
  mockProcArray(1) = 'TEST_1';
  mockProcArray(2) = 'TEST_2';

  testSuite = getTestSuite( mockProcNmList);

  iEqual(2: testSuite.testCasesCnt);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

  expTestProc.procNm = 'TEST_2';
  testProcEqual(expTestProc: testSuite: 2);

end-proc;


dcl-proc testSetupProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  mockProcCnt = 2;
  mockProcArray(1) = 'SETUP';
  mockProcArray(2) = 'TEST_1';

  testSuite = getTestSuite(mockProcNmList);

  iEqual(1: testSuite.testCasesCnt);
  aEqual('SETUP': testSuite.setUp.procNm);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

end-proc;


dcl-proc testTearDownProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  mockProcCnt = 2;
  mockProcArray(1) = 'TEARDOWN';
  mockProcArray(2) = 'TEST_1';

  // Execution.

  testSuite = getTestSuite(mockProcNmList);

  // Controls.

  iEqual( 1 : testSuite.testCasesCnt);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

  aEqual('TEARDOWN': testSuite.tearDown.procNm);

end-proc;


dcl-proc testSetupSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  mockProcCnt = 2;
  mockProcArray(1) = 'SETUPSUITE';
  mockProcArray(2) = 'TEST_1';

  // Execution.

  testSuite = getTestSuite( mockProcNmList);

  // Controls.

  iEqual(1: testSuite.testCasesCnt);
  aEqual('SETUPSUITE': testSuite.setupSuite.procNm);
  aEqual(*blank: testSuite.setup.procNm);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

end-proc;


dcl-proc testTeardownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  mockProcCnt = 2;
  mockProcArray(1) = 'TEARDOWNSUITE';
  mockProcArray(2) = 'TEST_1';

  // Execution.

  testSuite = getTestSuite(mockProcNmList);

  // Controls.

  iEqual(1 : testSuite.testCasesCnt);
  aEqual(*blank: testSuite.setupSuite.procNm);
  aEqual(*blank: testSuite.setup.procNm);

  expTestProc.procNm = 'TEST_1';
  testProcEqual(expTestProc: testSuite: 1);

  aEqual(*blank: testSuite.teardown.procNm);
  aEqual('TEARDOWNSUITE': testSuite.teardownSuite.procNm);

end-proc;


dcl-proc testActivateTestSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s actMark like(ActMark_t);
  dcl-ds srvPgm likeds(Object_t);
  dcl-ds testCase dim(3) likeds(Proc_t);


  // Set up Activation Mark.
  // I use the 'self-shunt' pattern here. The test program tries to activate itself to g
  // own Activation Mark.

  srvPgm.nm = sds.pgmName;
  srvPgm.lib = sds.pgmLib;
  actMark = activateSrvPgm( srvPgm);

  // Set up TestSuite.

  testSuite.setUpSuite.procNm = 'ET_setUpSuite';
  testSuite.setUp.procNm = 'ET_setUp';
  testSuite.testCasesCnt = 3;
  testSuite.testList = %addr(testCase);
  testCase(1).procNm = 'ET_testProc_1';
  testCase(2).procNm = 'ET_testProc_2';
  testCase(3).procNm = 'ET_testProc_3';
  testSuite.tearDown.procNm = 'ET_tearDown';
  testSuite.tearDownSuite.procNm = 'ET_tearDownSuite';

  // Execution.

  activateTestSuite(testSuite: actMark);

  // Controls.

  assert(testSuite.setUpSuite.procPtr = %paddr('ET_setUpSuite'):
         'Resolution of ET_setUpSuite failed');
  assert(testSuite.setUp.procPtr = %paddr('ET_setUp'):
         'Resolution of ET_setUp failed');

  expTestProc.procNm = 'ET_testProc_1';
  expTestProc.procPtr = %paddr('ET_testProc_1');
  testProcEqual(expTestProc: testSuite: 1);

  expTestProc.procNm = 'ET_testProc_2';
  expTestProc.procPtr = %paddr('ET_testProc_2');
  testProcEqual(expTestProc: testSuite: 2);

  expTestProc.procNm = 'ET_testProc_3';
  expTestProc.procPtr = %paddr('ET_testProc_3');
  testProcEqual(expTestProc: testSuite: 3);

  assert(testSuite.tearDown.procPtr = %paddr('ET_tearDown')
         : 'Resolution of ET_tearDown failed');
  assert(testSuite.tearDownSuite.procPtr = %paddr(ET_tearDownSuite)
         : 'Resolution of ET_tearDownSuite failed');

end-proc;


//----------------------------------------------------------------------
//   Exported Procedure Definitions
//----------------------------------------------------------------------

dcl-proc ET_setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_testProc_1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_testProc_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;

dcl-proc ET_testProc_3 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
end-proc;


//----------------------------------------------------------------------
//   Private Procedure Definitions
//----------------------------------------------------------------------

// Mock implementation of mockProcNmList_t.getNm.
dcl-proc getMockProcNm;
  dcl-pi *n like(ProcNm_t) extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');
  return mockProcArray(mockProcIdx);

end-proc;


// Mock implementation of mockProcNmList_t.goToNext.
dcl-proc goToNext;
  dcl-pi *n extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');
  mockProcIdx += 1;

end-proc;


// Mock implementation of mockProcNmList_t.cnt.
dcl-proc getMockProcCnt;
  dcl-pi *n int(10) extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');
  return mockProcCnt;

end-proc;


// High-level assertion.
dcl-proc testProcEqual;
  dcl-pi *n extproc(*dclcase);
    expTestProc likeds(Proc_t) const;
    testSuite   likeds(TestSuite_t) const;
    testIdx     int(10) const;
  end-pi;

  // Actual test procedure.
  dcl-ds actTestProc likeds(Proc_t);

  actTestProc = getTestProc(testSuite: testIdx);

  aEqual(expTestProc.procNm:  actTestProc.procNm);
  assert(expTestProc.procPtr = actTestProc.procPtr: 'Wrong test procedure pointer');

end-proc;


// Mock implementation of mockProcNmList_t.getNm.
dcl-proc return_NOT_A_TEST_1;
  dcl-pi *n like(ProcNm_t) extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');

  return 'NOT_A_TEST_1';

end-proc;


// Mock implementation of mockProcNmList_t.getNm.
dcl-proc return_SETUP_then_TEST_1;
  dcl-pi *n like(ProcNm_t) extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');

  select;
  when mockProcIdx = 1;
    return 'SETUP';
  when mockProcIdx = 2;
    return 'TEST_1';
  other;
    fail('Unreachable code');
  endsl;

end-proc;


// Mock implementation of mockProcNmList_t.getNm.
dcl-proc return_TEST_n;
  dcl-pi *n like(ProcNm_t) extproc(*dclcase);
    mockProcNmListHandle char(5) const;
  end-pi;

  assert('dummy' = mockProcNmListHandle: 'Wrong ProcNmList handle');

  return 'TEST_' + %char(mockProcIdx);

end-proc;

