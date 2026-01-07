**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test STMF.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,STMF
/copy qinclude,TEMPLATES
/copy qinclude,IFSIO_H
/copy qinclude,LIBC_H
/copy qinclude,MILIB

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

dcl-c STMF_RPGLE    'temp_irpgunit1.rpgle';
dcl-c STMF_SQLRPGLE 'temp_irpgunit2.sqlrpgle';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s g_startTime timestamp;

//----------------------------------------------------------------------
//   Set up & Tear down
//----------------------------------------------------------------------

dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_startTime = %timestamp();

  crtStmf(STMF_RPGLE);
  crtStmf(STMF_SQLRPGLE);

end-proc;


dcl-proc tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dltStmf(STMF_RPGLE);
  dltStmf(STMF_SQLRPGLE);

end-proc;


//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc testGetCurrentDirectory export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s currDir like(ifsStmf_t);

  currDir = Stmf_getCurrentDirectory();

  assert(currDir <> '': 'Current directory must not be empty');

end-proc;


dcl-proc testResolvePath export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedCurrDir like(ifsStmf_t);
  dcl-s expectedPath like(ifsStmf_t);
  dcl-s resolvedPath like(ifsStmf_t);

  // test resolving relative path
  expectedCurrDir = Stmf_getCurrentDirectory();

  expectedPath = expectedCurrDir + '/' + 'mypgm.rpgle';
  resolvedPath = Stmf_resolvePath('mypgm.rpgle');

  assert(expectedPath = resolvedPath: 'Expected and resolved paths must match');

  // test resolving relative path
  expectedCurrDir = Stmf_getCurrentDirectory();

  expectedPath = expectedCurrDir + '/' + 'mypgm.rpgle';
  resolvedPath = Stmf_resolvePath('./mypgm.rpgle');

  assert(expectedPath = resolvedPath: 'Expected and resolved paths must match');

  // test resolving relative path
  expectedCurrDir = Stmf_getCurrentDirectory();

  expectedPath = expectedCurrDir + '/../' + 'mypgm.rpgle';
  resolvedPath = Stmf_resolvePath('../mypgm.rpgle');

  assert(expectedPath = resolvedPath: 'Expected and resolved paths must match');

  // test paths with backslashes
  expectedPath = '/home/dev/mypgm.rpgle';
  resolvedPath = Stmf_resolvePath('\home\dev\mypgm.rpgle');

  assert(expectedPath = resolvedPath: 'Expected and resolved paths must match');

end-proc;


dcl-proc testExists export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s path like(ifsStmf_t);
  dcl-s exists ind;

  path = Stmf_resolvePath(STMF_RPGLE);
  exists = Stmf_exists(path);
  assert(exists: 'Path must exist: ' + path);

  path = Stmf_resolvePath('foo_not_found.rgple');
  exists = Stmf_exists(path);
  assert(not exists: 'Path must not exist: ' + path);

end-proc;


dcl-proc testGetLastChgDate export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s lastChanged timestamp;

  lastChanged = Stmf_getLastChgDate(STMF_RPGLE);
  assert(lastChanged > g_startTime: 'lastChanged must be greater than g_startTime');

end-proc;


dcl-proc testType export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s type varchar(10);

  type = Stmf_getType(Stmf_resolvePath(STMF_RPGLE));
  assert(type = 'rpgle': 'Type must be ''rpgle''');

  type = Stmf_getType(Stmf_resolvePath(STMF_SQLRPGLE));
  assert(type = 'sqlrpgle': 'Type must be ''sqlrpgle''');

  type = Stmf_getType(Stmf_resolvePath('myFile_no_type'));
  assert(type = '': 'Type must be empty');

  type = Stmf_getType(Stmf_resolvePath('/dir_with_dot.extension/myFile_no_type'));
  assert(type = '': 'Type must be empty');

end-proc;


dcl-proc crtStmf;
  dcl-pi *n extproc(*dclcase);
    stmf   like(ifsStmf_t) value;
  end-pi;

  dcl-s fd int(10);
  dcl-s errorNbr int(10) based(pErrorNbr);
  dcl-s errorText char(256);
  dcl-s data char(11) inz('Hello World');

  monitor;
    stmf = Stmf_getCurrentDirectory() + '/' + stmf;
    fd = open(stmf: O_EXCL + O_CREAT + O_RDWR + O_SHARE_NONE + O_CCSID + O_TEXTDATA + O_TEXT_CREAT
              : S_IRUSR + S_IWUSR + S_IRGRP + S_IROTH: 819: 0);
    if (fd <> -1);
      wait(1100); // wait for 1100 milliseconds
      pwrite(fd: %addr(data): %size(data): 0);
      callp close(fd);
    else;
      pErrorNbr = errno();
      errorText = %str(strerror(errorNbr));
      snd-msg *escape errorText;
    endif;
  on-error;
  endmon;

end-proc;


dcl-proc dltStmf;
  dcl-pi *n extproc(*dclcase);
    stmf   like(ifsStmf_t) value;
  end-pi;

  dcl-s rc int(10);
  dcl-s errorNbr int(10) based(pErrorNbr);
  dcl-s errorText char(256);

  monitor;
    stmf = Stmf_getCurrentDirectory() + '/' + stmf;
    rc = unlink(stmf);
    if (rc = -1);
      pErrorNbr = errno();
      errorText = %str(strerror(errorNbr));
    endif;
  on-error;
  endmon;

end-proc;


dcl-proc wait;
  dcl-pi *n extproc(*dclcase);
    mSecs   int(10) const;
  end-pi;

  dcl-s mi_time char(8);

  mitime(mi_time: 0: 0: 0: %int(mSecs/8));
  waittime(mi_time: WAIT_NORMAL + WAIT_SIGNALS);

end-proc;
