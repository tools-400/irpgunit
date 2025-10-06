**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Acceptance tests.
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
//     >>PARM<<  MODULE(&LI/JOBLOG    +
//                      &LI/LIBL      +
//                      &LI/LSTSPLF   +
//                      &LI/OBJECT    +
//                      &LI/OSVERSION +
//                      &LI/PGMMSG    +
//                      &LI/SRCMBR    +
//                      &LI/STMF      +
//                      &LI/STRING    +
//                      &LI/USRSPC    +
//                      &LI/SPLF      +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//     >>PARM<<  BOPTION(*DUPPROC);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LSTSPLF  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STMF     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SPLF     ) SRCFILE(&SL/QUNITTEST) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,LIBL
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,SYSTEMAPI
/include qunittest,SPLF_H
/include qinclude,TEMPLATES
/include qinclude,TESTUTILS

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// Constants for the 'run' procedure.
dcl-c errorExpected const(*on);
dcl-c noError const(*off);

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Message text.
dcl-s msgTxt  char(256);
dcl-s numRows int(10);

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds libraryList likeds(LiblData_t) inz;
  dcl-c MIN_NUM_ROWS 5;

  libraryList = getLibl();

  numRows = %div(libraryList.libL.numE: 3);
  if (numRows * 3 <> libraryList.libL.numE);
    numRows += 1;
  endif;

  if (numRows < MIN_NUM_ROWS);
    numRows = MIN_NUM_ROWS;
    if (numRows > libraryList.libL.numE);
      numRows = libraryList.libL.numE;
    endif;
  endif;

end-proc;

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear msgTxt;

end-proc;


dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  chkAndCloSplf();

end-proc;


dcl-proc testEmptyTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM01': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM01) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM01': noError: '*COMP': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM01');

  aEqual('Success. 1 test case, 0 assertion, 0 failure, 0 error.': msgTxt);

  cloSplf();

end-proc;


dcl-proc testSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM02': noError: '*COMP': msgTxt);

  opnSplf('RPGUNIT' :'TESTPGM02');

  aEqual('Success. 1 test case, 1 assertion, 0 failure, 0 error.': msgTxt);

  cloSplf();

end-proc;


dcl-proc testFailures export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM03': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM03) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM03': errorExpected: '*ESCAPE': msgTxt);

  aEqual('FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM03');
  splfLineStartsWith('*** Tests of TESTPGM03 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('testFalse - FAILURE');
  splfLineStartsWith('Expected 5, but was 4.');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('testFalse (TESTPGM03->TESTPGM03:20');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('Expected:        1 ''5''');
  splfLineStartsWith('Actual:          1 ''4''');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('testFalse2 - FAILURE');
  splfLineStartsWith('Expected 6, but was 4.');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('testFalse2 (TESTPGM03->TESTPGM03:28');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('Expected:        1 ''6''');
  splfLineStartsWith('Actual:          1 ''4''');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.');
  cloSplf();

end-proc;


dcl-proc testNonTestProc export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM04': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM04) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM04': noError: '*COMP': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM04');

  aEqual('Success. 2 test cases, 0 assertion, 0 failure, 0 error.': msgTxt);

  cloSplf();

end-proc;


dcl-proc testSetupAndTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM05': errorExpected: '*ESCAPE': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM05');

  aEqual('FAILURE. 2 test cases, 0 assertion, 1 failure, 0 error.': msgTxt);

  aEqual('setup'   : rcvMsgData('*INFO'));
  aEqual('test1'   : rcvMsgData('*INFO'));
  aEqual('tearDown': rcvMsgData('*INFO'));
  aEqual('setup'   : rcvMsgData('*INFO'));
  aEqual('test2'   : rcvMsgData('*INFO')); // Raises a failure.
  aEqual('tearDown': rcvMsgData('*INFO')); // Call 'tearDown' anyway.

  cloSplf();

end-proc;


dcl-proc testError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s testStartTime   timestamp;
  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM06': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM06) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  testStartTime = getFullTimeStamp();
  run('RUCALLTST TESTPGM06': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  assertJobLogContains('MCH1211': testStartTime);

  opnSplf('RPGUNIT': 'TESTPGM06');
  splfLineStartsWith('*** Tests of TESTPGM06 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('testError - ERROR');
  splfLineStartsWith('MCH1211 - ');
  splfLineStartsWith('testError (TESTPGM06->TESTPGM06:23');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testStackTrace export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM07': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM07) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM07': errorExpected: '*ESCAPE': msgTxt);

  aEqual('FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM07');
  splfLineStartsWith('*** Tests of TESTPGM07 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('testStack - FAILURE');
  splfLineStartsWith('Expected 5, but was 4.');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('failingProc (TESTPGM07->TESTPGM07:20');
  splfLineStartsWith('testStack (TESTPGM07->TESTPGM07:28');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('Expected:        1 ''5''');
  splfLineStartsWith('Actual:          1 ''4''');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.');
  cloSplf();

end-proc;


dcl-proc testMissingObject export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_exists('TESTPGM08': 'QTEMP'));
    runCmd('DLTSRVPGM SRVPGM(QTEMP/TESTPGM08)'); // Must not exists!
  endif;

  callp(e) run('DLTSRVPGM TESTPGM08'); // No TESTPGM08.

  run('RUCALLTST TESTPGM08': errorExpected: '*ESCAPE': msgTxt);

  aEqual('RPGUnit Error. Error while loading test suite *LIBL/TESTPGM08.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM08');
  splfLineStartsWith('*** Tests of TESTPGM08 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('Runtime error: Error while loading test suite *LIBL/TESTPGM08.');

  cloSplf();

end-proc;


dcl-proc testErrorDuringSetup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM09': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM09) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM09': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  aEqual('setup'   : rcvMsgData('*INFO')); // Error during setup.
  // Test should not be called.
  aEqual('tearDown': rcvMsgData('*INFO')); // Teardown should be called anyway

  opnSplf('RPGUNIT': 'TESTPGM09');
  splfLineStartsWith('*** Tests of TESTPGM09 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('test - ERROR');
  splfLineStartsWith('MCH1211 - ');
  splfLineStartsWith('setup (TESTPGM09->TESTPGM09:25');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testErrorDuringTearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM10': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM10) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM10': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.' :msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM10');
  splfLineStartsWith('*** Tests of TESTPGM10 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('test - ERROR');
  splfLineStartsWith('MCH1211 - ');
  splfLineStartsWith('tearDown (TESTPGM10->TESTPGM10:27');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testNoTestCase export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM11': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM11) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM11': errorExpected: '*ESCAPE': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM11');

  aEqual('RPGUnit Error. No test case found in service program *LIBL/TESTPGM11.': msgTxt);

  cloSplf();

end-proc;


dcl-proc testSetupSuiteAndTearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM12': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM12) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM12': errorExpected: '*ESCAPE': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM12');

  aEqual('FAILURE. 2 test cases, 0 assertion, 1 failure, 0 error.': msgTxt);

  aEqual('setupSuite'   : rcvMsgData('*INFO'));
  aEqual('setup'        : rcvMsgData('*INFO'));
  aEqual('test1'        : rcvMsgData('*INFO'));
  aEqual('tearDown'     : rcvMsgData('*INFO'));
  aEqual('setup'        : rcvMsgData('*INFO'));
  aEqual('test2'        : rcvMsgData('*INFO')); // Raises a failure.
  aEqual('tearDown'     : rcvMsgData('*INFO')); // Call 'tearDown' anyway.
  aEqual('tearDownSuite': rcvMsgData('*INFO')); // Call 'tearDownSuite' anyway.

  cloSplf();

end-proc;


dcl-proc testManyTests export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM13': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM13) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM13': noError: '*COMP': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM13');

  aEqual('Success. 256 test cases, 0 assertion, 0 failure, 0 error.': msgTxt);

  cloSplf();

end-proc;


dcl-proc testBigInteger export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM14': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM14) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM14': errorExpected: '*ESCAPE': msgTxt);

  aEqual('FAILURE. 2 test cases, 2 assertions, 1 failure, 0 error.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM14');
  splfLineStartsWith( '*** Tests of TESTPGM14 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit    : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith('test_Different - FAILURE');
  splfLineStartsWith('Expected 1234567890123456789012345678901, but was 12345678901234567890');
  splfLineStartsWith('12345678900.');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('test_Different (TESTPGM14->TESTPGM14:30');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('Expected:        1 ''1234567890123456789012345678901''');
  splfLineStartsWith('Actual:          1 ''1234567890123456789012345678900''');
  splfLineStartsWith('-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith('FAILURE. 2 test cases, 2 assertions, 1 failure, 0 error.');
  cloSplf();

end-proc;


dcl-proc testForceSpoolOnSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM15': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM15) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TSTPGM(TESTPGM15) DETAIL(*ALL)': noError: '*COMP': msgTxt);

  aEqual('Success. 2 test cases, 3 assertions, 0 failure, 0 error.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM15');
  splfLineStartsWith( '*** Tests of TESTPGM15 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'testTrue - Success');
  splfLineStartsWith( '1 assertions');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'testTrue2 - Success');
  splfLineStartsWith( '2 assertions');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'Success. 2 test cases, 3 assertions, 0 failure, 0 error.');
  cloSplf();

end-proc;


dcl-proc testReverseOrder export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM16': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM16) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TSTPGM(TESTPGM16) ORDER(*REVERSE)': noError: '*COMP': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM16');

  aEqual('Success. 2 test cases, 0 assertion, 0 failure, 0 error.': msgTxt);

  aEqual('setup'   : rcvMsgData('*INFO') );
  aEqual('test2'   : rcvMsgData('*INFO') );
  aEqual('tearDown': rcvMsgData('*INFO') );
  aEqual('setup'   : rcvMsgData('*INFO') );
  aEqual('test1'   : rcvMsgData('*INFO') );
  aEqual('tearDown': rcvMsgData('*INFO') );

  cloSplf();

end-proc;


dcl-proc testChooseTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM05 TSTPRC(TEST2)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('FAILURE. 1 test case, 0 assertion, 1 failure, 0 error.': msgTxt);

  aEqual('setup'   : rcvMsgData('*INFO') );
  aEqual('test2'   : rcvMsgData('*INFO') );
  aEqual('tearDown': rcvMsgData('*INFO') );

  opnSplf('RPGUNIT': 'TESTPGM05');
  splfLineStartsWith( '*** Tests of TESTPGM05 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'test2 - FAILURE');
  splfLineStartsWith( 'test2');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'test2 (TESTPGM05->TESTPGM05:3900)');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'Expected:          Not available');
  splfLineStartsWith( 'Actual:            Not available');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'FAILURE. 1 test case, 0 assertion, 1 failure, 0 error.');
  cloSplf();

end-proc;


dcl-proc testChooseNonExistingTest export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM05': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM05) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM05 TSTPRC(NON_EXISTING_TEST)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 0 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  opnSplf('RPGUNIT': 'TESTPGM05');
  splfLineStartsWith( '*** Tests of TESTPGM05 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'NON_EXISTING_TEST - ERROR');
  splfLineStartsWith( 'Test procedure not found.');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testErrorInSetUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM17': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM17) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM17': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 0 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  aEqual('setupSuite'   : rcvMsgData('*INFO') );    // Error.
  aEqual('tearDownSuite': rcvMsgData('*INFO') );    // Call 'tearDownSuite' anyway.

  opnSplf('RPGUNIT': 'TESTPGM17');
  splfLineStartsWith( '*** Tests of TESTPGM17 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'setupSuite - ERROR');
  splfLineStartsWith( 'MCH1211 - ');
  splfLineStartsWith( 'setupSuite (TESTPGM17->TESTPGM17:25');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'ERROR. 0 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testErrorInTearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM18': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM18) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM18': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  aEqual('setupSuite'   : rcvMsgData('*INFO') );
  aEqual('test1'        : rcvMsgData('*INFO') );
  aEqual('tearDownSuite': rcvMsgData('*INFO') );    // Error.

  opnSplf('RPGUNIT': 'TESTPGM18');
  splfLineStartsWith( '*** Tests of TESTPGM18 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'tearDownSuite - ERROR');
  splfLineStartsWith( 'MCH1211 - ');
  splfLineStartsWith( 'tearDownSuite (TESTPGM18->TESTPGM18:41');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'ERROR. 1 test case, 0 assertion, 0 failure, 1 error.');
  cloSplf();

end-proc;


dcl-proc testErrorsInBothSetUpSuiteAndTearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM19': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM19) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  run('RUCALLTST TESTPGM19': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.': msgTxt);

  aEqual('setupSuite'   : rcvMsgData('*INFO') );    // Error.
  aEqual('tearDownSuite': rcvMsgData('*INFO') );    // Another error.

  opnSplf('RPGUNIT': 'TESTPGM19');
  splfLineStartsWith( '*** Tests of TESTPGM19 ***');
  splfSkipLine();  // Skip "Date"
  splfSkipLine();  // Skip "Job"
  splfSkipLine();  // Skip "User"
  splfSkipLine();  // Skip "iRPGUnit : v3.0.0"
  splfSkipLine();  // Skip "IBM i       : V7R3M0"
  splfSkipLine();  // Skip [blank line]

  splfSkipLine();  // Skip "Cur. library: *CRTDFT"
  i = numRows;
  dow (i > 0);
    splfSkipLine();  // Skip lines of library list
    i -= 1;
  enddo;
  splfSkipLine();  // Skip [blank line]

  splfLineStartsWith( 'setupSuite - ERROR');
  splfLineStartsWith( 'MCH1211 - ');
  splfLineStartsWith( 'setupSuite (TESTPGM19->TESTPGM19:25');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'tearDownSuite - ERROR');
  splfLineStartsWith( 'MCH1211 - ');
  splfLineStartsWith( 'tearDownSuite (TESTPGM19->TESTPGM19:44');
  splfLineStartsWith( '-----------------------');
  splfSkipLine();  // Skip [blank line]
  splfLineStartsWith( 'ERROR. 0 test case, 0 assertion, 0 failure, 2 errors.');
  cloSplf();

end-proc;


dcl-proc testSuccessNoOutput export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM02');

  run('RUCALLTST TESTPGM02 OUTPUT(*NONE)': noError: '*COMP': msgTxt);

  aEqual('Success. 1 test case, 1 assertion, 0 failure, 0 error.': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM02') = 0 : 'Unexpected spooled file');

end-proc;


dcl-proc testFailuresNoOutput export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_isDirty('TESTPGM03': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM03) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM03');

  run('RUCALLTST TESTPGM03 OUTPUT(*NONE)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM03') = 0 : 'Unexpected spooled file');

end-proc;


dcl-proc testErrorNoOutput export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM06': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM06) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM06');

  run('RUCALLTST TESTPGM06 OUTPUT(*NONE)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('ERROR. 1 test case, 0 assertion, 0 failure, 1 error.': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM06') = 0 : 'Unexpected spooled file');

end-proc;


dcl-proc testMissingObjectNoOutput export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  if (TestSuite_exists('TESTPGM08': 'QTEMP'));
    runCmd('DLTSRVPGM SRVPGM(QTEMP/TESTPGM08)'); // Must not exists!
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM08');

  run('RUCALLTST TESTPGM08 OUTPUT(*NONE)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('RPGUnit Error. Error while loading test suite *LIBL/TESTPGM08.': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM08') = 0 : 'Unexpected spooled file');

end-proc;


dcl-proc testNoTestCaseNoOutput export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM11': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM11) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM11');

  run('RUCALLTST TESTPGM11 OUTPUT(*NONE)': errorExpected: '*ESCAPE': msgTxt);

  aEqual('RPGUnit Error. No test case found in service program *LIBL/TESTPGM11.': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM11') = 0 : 'Unexpected spooled file');

end-proc;


dcl-proc testDltSplFs export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (TestSuite_isDirty('TESTPGM02': 'QTEMP'));
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM02) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
  endif;

  dltSplFs('RPGUNIT': 'TESTPGM02');

  run('RUCALLTST TESTPGM02': noError: '*COMP': msgTxt);
  run('RUCALLTST TESTPGM02': noError: '*COMP': msgTxt);
  run('RUCALLTST TESTPGM02': noError: '*COMP': msgTxt);

  assert( dltSplFs('RPGUNIT': 'TESTPGM02' ) = 3 : 'Spooled file not found');

end-proc;


dcl-proc testOptionsExact export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);
  dcl-s count           int(10) inz(1406);

  monitor;
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM20) +
            SRCFILE(QTESTCASES) DLTSPLF(*YES)');
    fail('Expected compiler error: RNF3245');
  on-error;
  endmon;

  opnSplf('TESTPGM20': '');

  // No prototype in the OVERLOAD keyword matches the parameters of the call.
  splfContains('*RNF3245 30');

  cloSplf();

end-proc;


//----------------------------------------------------------------------
//   Helper Procedures
//----------------------------------------------------------------------

dcl-proc run;
  dcl-pi *n extproc(*dclcase);
    cmd             varchar(32767) const;
    errorExpected   ind const options(*NoPass);
    msgType         char(10) const options(*NoPass);
    msgTxt          char(256) options(*NoPass);
  end-pi;


  if %parms >= 2 and errorExpected;
    callp(e) qcmdexc( cmd: %len(cmd) );
    assert( %error: 'Expected error missing');
  else;
    qcmdexc( cmd: %len(cmd) );
  endif;

  if %parms >= 4;
    msgTxt = rcvMsgTxt( msgType );
  endif;

end-proc;

