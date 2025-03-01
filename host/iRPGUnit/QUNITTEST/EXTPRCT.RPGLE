**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test EXTPRC.s
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
//     >>PARM<<  MODULE(&LI/EXTPRC    +
//                      &LI/OBJECT    +
//                      &LI/SRCMBR    +
//                      &LI/USRSPC    +
//                      );
//     >>PARM<<    COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/EXTPRC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,EXTPRC
/copy qinclude,OBJECT
/copy qinclude,TEMPLATES
/copy qinclude,TESTUTILS

//----------------------------------------------------------------------
//   Private Procedure Prototypes
//----------------------------------------------------------------------

// The next three procedures are used to invoke the procptr in ProcNmList_t.

dcl-pr cnt int(10) extproc(cnt_p);
  privateData   pointer const;
end-pr;

dcl-pr getNm extproc(getNm_p)
       like(ProcNm_t);
  privateData   pointer const;
end-pr;

dcl-pr goToNext extproc(goToNext_p);
  privateData   pointer const;
end-pr;

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// The next three pointers are used to invoke the procedures in ProcNmList_t.
dcl-s cnt_p pointer(*proc);
dcl-s getNm_p pointer(*proc);
dcl-s goToNext_p pointer(*proc);

//----------------------------------------------------------------------
//   Procedures Definition
//----------------------------------------------------------------------

dcl-proc testOneProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procList likeds(ProcList_t);
  dcl-s procCnt int(10);
  dcl-s procNm like(ProcNm_t);


  if (TestSuite_isDirty('SRVPGM1': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/SRVPGM1) SRCFILE(QTESTCASES)');
  endif;

  procList = loadProcList('SRVPGM1');
  procCnt = cntProc(procList);

  iEqual(1: procCnt);

  procNm = getProcNm(procList);

  aEqual('PROC1': procNm);

end-proc;


dcl-proc testSeveralProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procList likeds(ProcList_t);
  dcl-s procCnt int(10);
  dcl-s procNm like(ProcNm_t);


  if (TestSuite_isDirty('SRVPGM2': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/SRVPGM2) SRCFILE(QTESTCASES)');
  endif;

  procList = loadProcList('SRVPGM2');
  procCnt = cntProc(procList);

  iEqual( 2: procCnt );

  procNm = getProcNm(procList);

  aEqual('PROC1': procNm);

  goToNextProc(procList);
  procNm = getProcNm(procList);

  aEqual('PROC2': procNm);

end-proc;


dcl-proc testProcNmList export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds procList likeds(ProcList_t);
  dcl-ds procNmList likeds(ProcNmList_t);
  dcl-s privateData     pointer based(procNmList.handle);


  if (TestSuite_isDirty('SRVPGM2': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/SRVPGM2) SRCFILE(QTESTCASES)');
  endif;

  // Setup.

  procList = loadProcList('SRVPGM2');

  // Execution.

  procNmList = getProcNmList(procList);

  // Controls.

  cnt_p = procNmList.cnt;
  getNm_p = procNmList.getNm;
  goToNext_p = procNmList.goToNext;

  iEqual(2: cnt(privateData));
  aEqual('PROC1': getNm(privateData));
  goToNext(privateData);
  aEqual('PROC2' : getNm(privateData));

end-proc;


dcl-proc testSrvPgmNotFound export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
  monitor;
    loadProcList('');
    fail('loadProcList('' '') should raise an escape message.');
  on-error;
  endmon;

end-proc;
