**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test LIBL.
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
//     >>PARM<<  MODULE(&LI/LIBL      +
//                      &LI/LIBLC     +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LIBLC    ) SRCFILE(&SL/QUNITTEST) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,LIBL
/copy qinclude,TEMPLATES

dcl-pr LIBLC extproc('LIBLC');
  curLib    char(10);
  usrLibl   char(2750);
end-pr;

dcl-pr system int(10) extproc('system');
  i_clCommand   pointer value options(*string);
end-pr;

dcl-s EXCP_MSGID char(7) import('_EXCP_MSGID');


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-ds expected qualified;
  curLib       char(10) pos(1);
  usrLibl      char(11) dim(250) pos(11);
  usrLiblArray char(2750) pos(11);
end-ds;

//----------------------------------------------------------------------
//   Set up & Tear down
//----------------------------------------------------------------------

dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  system('DLTJOBD JOBD(QTEMP/RPGUNITT)');
  system('CRTJOBD JOBD(QTEMP/RPGUNITT) INLLIBL(QGPL QTEMP)');

  callp LIBLC(expected.curLib: expected.usrLiblArray);

end-proc;


dcl-proc tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  system('DLTJOBD JOBD(QTEMP/RPGUNITT)');

end-proc;


//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc testGetLibl export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds liblData likeds(LiblData_t);
  dcl-s i int(10);
  dcl-s prvLib char(11) inz;
  dcl-s numLibs int(10) inz;

  // Setup.

  // Run.

  liblData = getLibl();

  // Check.

  assert(liblData.libL.numE > 0: 'Number of libraries shoud be greater than 0');

  for i = 1 to liblData.libL.numE;
    assert(liblData.libL.lib(i) = expected.usrLibl(i):
      'Library list entry ' + %char(i) + ' does not match expected value');
    if (i > 1);
      assert(prvLib <> liblData.libL.lib(i):
        'Previous library list entry must not match current entry');
    endif;
    prvLib = liblData.libL.lib(i);
  endfor;

  for i = liblData.libL.numE + 1 to MAX_NUM_LIB;
     assert(liblData.libL.lib(i) = '':
       'Library list entry ' + %char(i) + ' should be empty');
  endfor;

  assert(liblData.curLib = expected.curLib:
    'Current library ' + %char(i) + ' does not match expected value');

end-proc;


dcl-proc testLoadLibl export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds qJobD likeds(Object_t);
  dcl-ds liblData likeds(LiblData_t);

  // Setup.

  // Run.

  qJobD.nm = 'RPGUNITT';
  qJobD.lib = 'QTEMP';
  liblData = loadLibl(qJobD);

  // Check.

  assert(liblData.libL.numE = 2: 'Number of libraries shoud equal 2');

  assert(liblData.libL.lib(1) = 'QGPL': 'First library list entry should match: QGPL');

  assert(liblData.libL.lib(2) = 'QTEMP': 'Third library list entry should match: QTEMP');

end-proc;


dcl-proc testRestoreLibl export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds qJobD likeds(Object_t);
  dcl-ds savedLibl likeds(LiblData_t);
  dcl-ds currentLibl likeds(LiblData_t);
  dcl-ds newLibl likeds(LiblData_t);
  dcl-ds restoredLibl likeds(LiblData_t);

  // Setup.

  // Run.

  // Save library list
  savedLibl = getLibl();

  // Change library list
  qJobD.nm = 'RPGUNITT';
  qJobD.lib = 'QTEMP';
  newLibl = loadLibl(qJobD);
  changeLibl(newLibl.curLib: newLibl.libL);

  currentLibl = getLibl();

  // Restore library list
  changeLibl(savedLibl.curLib: savedLibl.libL);

  // Get final library list
  restoredLibl = getLibl();

  // Check.
  assert(savedLibl <> newLibl: 'Library list had not been properly changed for testing');

  assert(savedLibl = restoredLibl: 'Restored library list does not match saved library list');

end-proc;

