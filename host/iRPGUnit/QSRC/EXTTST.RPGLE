**FREE
// ==========================================================================
//  iRPGUnit - Extract Test Cases.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,EXTTST

//---------------f------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,CALLPRC
/include qinclude,EXTPRC
/include qinclude,MEMMGR
/include qinclude,TEMPLATES
/include qinclude,STRING
/include qllist,llist_h

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

dcl-pr memset pointer extproc('memset');
  i_pDest pointer value;
  i_char  int(10) value;
  i_count uns(10) value;
end-pr;

dcl-pr cnt int(10) extproc(cnt_p);
  procnmlisthandle
  pointer const;
end-pr;

dcl-pr getnm like(procNm_t) extproc(getNm_p);
  procnmlisthandle
  pointer const;
end-pr;

dcl-pr gotonext extproc(gotoNext_p);
  procnmlisthandle
  pointer const;
end-pr;

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Procedure pointers for ProcNmList_t.
dcl-s cnt_p pointer(*proc);
dcl-s getNm_p pointer(*proc);
dcl-s gotoNext_p pointer(*proc);


//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------

dcl-proc activateTestSuite export;
  dcl-pi *N;
    testSuite likeds(testSuite_t);
    actMark   like(actMark_t) const;
  end-pi;

  dcl-ds testCase likeds(proc_t) based(pTtestCase);
  dcl-s pTtestCase      pointer;
  dcl-s testIdx         int(10);


  rslvProc( testSuite.setupsuite : actMark );
  rslvProc( testSuite.setup      : actMark );

  for testIdx = 1 to testSuite.testCasesCnt;
    pTtestCase = getTestCasePtr( testSuite : testIdx );
    testCase.seqNbr = testIdx;
    rslvProc( testCase : actMark );
  endfor;

  rslvProc( testSuite.tearDown      : actMark );
  rslvProc( testSuite.tearDownSuite : actMark );

end-proc;


dcl-proc getTestCasePtr;
  dcl-pi *N pointer extproc(*dclcase);
    testSuite likeds(testSuite_t) const;
    testIdx   int(10) const;
  end-pi;

  return testSuite.testList + %size(proc_t) * (testIdx - 1);

end-proc;


dcl-proc getTestNm export;
  dcl-pi *N like(procNm_t);
    testSuite       const likeds(testSuite_t);
    testIdx         int(10) const;
  end-pi;

  dcl-ds testproc likeds(proc_t);


  testproc = getTestProc( testSuite : testIdx );
  return testproc.procnm;

end-proc;


dcl-proc getTestProc export;
  dcl-pi *N likeds(proc_t);
    testSuite       const likeds(testSuite_t);
    testidx         int(10) const;
  end-pi;

  dcl-ds testcase likeds(proc_t) based(testcase_p);
  dcl-s testcase_p      pointer;


  testcase_p = getTestCasePtr( testSuite : testidx );
  return testcase;

end-proc;


dcl-proc getTestSuite export;
  dcl-pi *N likeds(testSuite_t);
    procNmList      const likeds(procNmList_t);
  end-pi;

  dcl-ds testSuite likeds(testSuite_t);
  dcl-ds testCase likeds(proc_t) based(testCase_p);
  dcl-s testCase_p      pointer;

  dcl-s privateData     pointer based(procNmList.handle);
  dcl-s procCnt         int(10);
  dcl-s procIdx         int(10);
  dcl-s procNm          like(procNm_t);


  cnt_p      = procNmList.cnt;
  getNm_p    = procNmList.getnm;
  gotoNext_p = procNmList.gotonext;

  procCnt = cnt( privateData );

  clear testSuite;
  testSuite.testList = MemMgr_alloc(procCnt * %size(proc_t): 'testSuite.testList');
  memset(testSuite.testList : x'00': procCnt * %size(proc_t));
  testSuite.testResults = *null;

  for procIdx = 1 to procCnt;
    procNm = getnm( privateData );
    select;
    when isTest( procNm );
      testSuite.testCasesCnt += 1;
      testCase_p = getTestCasePtr(testSuite: testSuite.testCasesCnt);
      clear testCase;
      testCase.procnm = procNm;
    when uCase(procNm) = 'SETUPSUITE';
      testSuite.setupSuite.procnm = procNm;
    when uCase(procNm) = 'SETUP';
      testSuite.setup.procnm = procNm;
    when uCase(procNm) = 'TEARDOWN';
      testSuite.tearDown.procnm = procNm;
    when uCase(procNm) = 'TEARDOWNSUITE';
      testSuite.tearDownSuite.procnm = procNm;

    // Cobol procedures

    when uCase(procNm) = 'SETUPSTE';
      testSuite.setupSuite.procnm = procNm;
    when uCase(procNm) = 'SETUP';
      testSuite.setup.procnm = procNm;
    when uCase(procNm) = 'TEARDWN';
      testSuite.tearDown.procnm = procNm;
    when uCase(procNm) = 'TEARDWNSTE';
      testSuite.tearDownSuite.procnm = procNm;
    endsl;
    gotonext( privateData );
  endfor;

  return testSuite;

end-proc;


dcl-proc isTest;
  dcl-pi *N ind extproc(*dclcase);
    nm   const like(procNm_t);
  end-pi;

  dcl-s nmPrefix like(procNm_t);


  return startsWith(TEST_PREFIX: nm);

end-proc isTest;

