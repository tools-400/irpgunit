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
/include qinclude,TEMPLATES
/include qinclude,STRING
/include qllist,llist_h

dcl-pr memset          pointer extproc('memset');
  i_pDest         pointer value;
  i_char          int(10) value;
  i_count         uns(10) value;
end-pr;

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

dcl-pr cnt             int(10) extproc(cnt_p);
  procnmlisthandle
  pointer const;
end-pr;

dcl-pr getnm like(procNm_t) extproc(getnm_p);
  procnmlisthandle
  pointer const;
end-pr;

dcl-pr gettestcaseptr  pointer;
  testsuite       const likeds(testSuite_t);
  testidx         int(10) const;
end-pr;

dcl-pr gotonext extproc(gotonext_p);
  procnmlisthandle
  pointer const;
end-pr;

dcl-pr istest          ind;
  nm              const like(procNm_t);
end-pr;


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Procedure pointers for ProcNmList_t.
dcl-s cnt_p           pointer(*proc);
dcl-s getnm_p         pointer(*proc);
dcl-s gotonext_p      pointer(*proc);


//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------

dcl-proc activateTestSuite export;
  dcl-pi *N;
    testsuite       likeds(testSuite_t);
    actMark         const like(actMark_t);
  end-pi;

  dcl-ds testcase likeds(proc_t) based(testcase_p);
  dcl-s testcase_p      pointer;
  dcl-s testidx         int(10);


  rslvProc( testsuite.setupsuite : actMark );
  rslvProc( testsuite.setup      : actMark );

  for testidx = 1 to testsuite.testcasescnt;
    testcase_p = gettestcaseptr( testsuite : testidx );
    rslvProc( testcase : actMark );
  endfor;

  rslvProc( testsuite.teardown      : actMark );
  rslvProc( testsuite.teardownsuite : actMark );

end-proc;


dcl-proc gettestcaseptr;
  dcl-pi *N              pointer;
    testsuite       const likeds(testSuite_t);
    testidx         int(10) const;
  end-pi;

  return testsuite.testlist + %size( proc_t ) * ( testidx - 1 );

end-proc;


dcl-proc getTestNm export;
  dcl-pi *N like(procNm_t);
    testsuite       const likeds(testSuite_t);
    testidx         int(10) const;
  end-pi;

  dcl-ds testproc likeds(proc_t);


  testproc = getTestProc( testsuite : testidx );
  return testproc.procnm;

end-proc;


dcl-proc getTestProc export;
  dcl-pi *N likeds(proc_t);
    testsuite       const likeds(testSuite_t);
    testidx         int(10) const;
  end-pi;

  dcl-ds testcase likeds(proc_t) based(testcase_p);
  dcl-s testcase_p      pointer;


  testcase_p = gettestcaseptr( testsuite : testidx );
  return testcase;

end-proc;


dcl-proc getTestSuite export;
  dcl-pi *N likeds(testSuite_t);
    procnmlist      const likeds(procNmList_t);
  end-pi;

  dcl-ds testsuite likeds(testSuite_t);
  dcl-ds testcase likeds(proc_t)
  based(testcase_p);
  dcl-s testcase_p      pointer;

  dcl-s privatedata     pointer based(procnmlist.handle);
  dcl-s proccnt         int(10);
  dcl-s procidx         int(10);
  dcl-s procnm          like(procNm_t);


  cnt_p      = procnmlist.cnt;
  getnm_p    = procnmlist.getnm;
  gotonext_p = procnmlist.gotonext;

  proccnt = cnt( privatedata );

  clear testsuite;
  testsuite.testlist = %alloc( proccnt * %size( proc_t ) );
  memset(testsuite.testlist : x'00' : proccnt * %size( proc_t ));
  testsuite.testresults = list_create();

  for procidx = 1 to proccnt;
    procnm = getnm( privatedata );
    select;
    when istest( procnm );
      testsuite.testcasescnt += 1;
      testcase_p = gettestcaseptr( testsuite :
                                   testsuite.testcasescnt );
      clear testcase;
      testcase.procnm = procnm;
    when uCase(procnm) = 'SETUPSUITE';
      testsuite.setupsuite.procnm = procnm;
    when uCase(procnm) = 'SETUP';
      testsuite.setup.procnm = procnm;
    when uCase(procnm) = 'TEARDOWN';
      testsuite.teardown.procnm = procnm;
    when uCase(procnm) = 'TEARDOWNSUITE';
      testsuite.teardownsuite.procnm = procnm;

    // Cobol procedures

    when uCase(procnm) = 'SETUPSTE';
      testsuite.setupsuite.procnm = procnm;
    when uCase(procnm) = 'SETUP';
      testsuite.setup.procnm = procnm;
    when uCase(procnm) = 'TEARDWN';
      testsuite.teardown.procnm = procnm;
    when uCase(procnm) = 'TEARDWNSTE';
      testsuite.teardownsuite.procnm = procnm;
    endsl;
    gotonext( privatedata );
  endfor;

  return testsuite;

end-proc;


dcl-proc istest;
  dcl-pi *N              ind;
    nm              const like(procNm_t);
  end-pi;

  dcl-s nmprefix        like(procNm_t);


  return startswith(TEST_PREFIX: nm);

end-proc istest;

