**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test MK* Scripts.
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
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,TESTCASE

//----------------------------------------------------------------------
//   Program Status Data Structure
//----------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  cleanup();

end-proc;


dcl-proc tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  cleanup();

end-proc;


dcl-proc testMKACPTSTT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'ACPTSTT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKACPTSTT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKASSERTT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'ASSERTT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKASSERTT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKCALLPRCT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'CALLPRCT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKCALLPRCT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKCMDRUNLT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'CMDRUNLOGT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKCMDRUNLT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKCMDRUNT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'CMDRUNT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKCMDRUNT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKCRTTSTT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'CRTTSTT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKCRTTSTT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKEXTPRCT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'EXTPRCT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKEXTPRCT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKEXTTSTT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'EXTTSTT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKEXTTSTT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKJOBLOGT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'JOBLOGT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKJOBLOGT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKLIBLT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'LIBLT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKLIBLT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKLSTSPLFT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'LSTSPLFT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKLSTSPLFT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKMSGQT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'MSGQT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKMSGQT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKOPDESCT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'OPDESCT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKOPDESCT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKPGMMSGT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'PGMMSGT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKPGMMSGT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKRUNT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'RUNT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKRUNT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKSTRINGT export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'STRINGT';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKSTRINGT');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc testMKUTILST export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c TEST_SUITE 'TESTUTILST';

  // Setup.

  deleteTestSuite(TEST_SUITE);

  // Run.

  executeScript('MKUTILST');

  // Check.

  assert(checkTestSuite(TEST_SUITE): 'Service program ' + TEST_SUITE + ' not found.');

end-proc;


dcl-proc executeScript;
  dcl-pi *n extproc(*dclcase);
    script varchar(10) options(*trim) const;
  end-pi;
  dcl-s params varchar(100);

  params = %trim(sds.pgmLib) + ' NONE';

  runCmd('STRREXPRC SRCMBR(' + script + ') +
          SRCFILE(' + %trim(sds.pgmLib) + '/QUNITTEST) +
          PARM(''' + params + ''')');

  end-proc;


  dcl-proc deleteTestSuite;
  dcl-pi *n extproc(*dclcase);
    srvPgm varchar(10) options(*trim) const;
  end-pi;

  monitor;
    runCmd('DLTSRVPGM SRVPGM(' + %trim(sds.pgmLib) + '/' + srvPgm + ')');
  on-error;
    // Ignore not found error
  endmon;

end-proc;


dcl-proc checkTestSuite;
  dcl-pi *n ind extproc(*dclcase);
    srvPgm varchar(10) options(*trim) const;
  end-pi;

  monitor;
     runCmd('CHKOBJ OBJ(' + %trim(sds.pgmLib) + '/' + srvPgm + ') +
             OBJTYPE(*SRVPGM)');
     return *on;
  on-error;
     return *off;
  endmon;

end-proc;


dcl-proc cleanup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s params varchar(100);

  params = 'CLEAN ' + %trim(sds.pgmLib);

  runCmd('STRREXPRC SRCMBR(A_INSTALL) +
          SRCFILE(' + %trim(sds.pgmLib) + '/QBUILD) +
          PARM(''' + params + ''')');

end-proc;

