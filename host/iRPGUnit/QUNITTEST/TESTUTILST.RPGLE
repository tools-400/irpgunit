**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test TESTUTILS.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
//                        RPGPPOPT(*LVL2);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/JOBLOG    +
//                      &LI/STRING    +
//                      &LI/PGMMSG    +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,TESTUTILS
/copy qinclude,TEMPLATES
/copy qinclude,STRING

/copy qsysinc,QCMDEXC

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s mustDeleteFile ind inz(*off);

//----------------------------------------------------------------------
//   Setup/Teardown
//----------------------------------------------------------------------

dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s cmd varchar(500);

  mustDeleteFile = *off;

  monitor;
    cmd = 'CRTSRCPF FILE(QTEMP/RPGUNITTST) RCDLEN(112)';
    QCMDEXC(cmd: %len(cmd));
    mustDeleteFile = *on;
  on-error;
    tearDownSuite();
  endmon;

  addMemberOfType(MBR_RPGLE);
  addMemberOfType(MBR_SQLRPGLE);
  addMemberOfType(MBR_CBLLE);
  addMemberOfType(MBR_SQLCBLLE);

end-proc;


dcl-proc tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s cmd varchar(500);

  monitor;
    cmd = 'DLTF FILE(QTEMP/RPGUNITTST)';
    QCMDEXC(cmd: %len(cmd));
    mustDeleteFile = *off;
  on-error;
  endmon;

end-proc;


dcl-proc addMemberOfType;
  dcl-pi *n extproc(*dclcase);
    srcType   varchar(10) const;
  end-pi;

  dcl-s cmd varchar(500);

  cmd = 'ADDPFM FILE(QTEMP/RPGUNITTST) MBR(' + srcType + ') +
           TEXT(''iRPGUnit Test Member'') +
           SRCTYPE(' + srcType + ')';

  QCMDEXC(cmd: %len(cmd));

end-proc;


//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc test_waitSeconds export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s startTime       timestamp;
  dcl-s endTime         timestamp;
  dcl-s lowerBoundary   timestamp;
  dcl-s upperBoundary   timestamp;
  dcl-s mSecsPassed     uns(10);

  dcl-c WAIT_SECONDS 1;

  // Tolerance is +/- 0.2 seconds
  dcl-c TOLERANCE 200000;

  // Setup.

  startTime = %timestamp();

  // Run.

  waitSeconds(WAIT_SECONDS);

  // Check.

  endTime = %timestamp();

  mSecsPassed = %diff(endTime: startTime: *mseconds);

  lowerBoundary =
    startTime + %seconds(WAIT_SECONDS) - %mseconds(TOLERANCE);

  upperBoundary =
    startTime + %seconds(WAIT_SECONDS) + %mseconds(TOLERANCE);

  assert(endTime > lowerBoundary
         : 'Time passed must be greater than lower boundary.');

  assert(endTime < upperBoundary
         : 'Time passed must be greater than upper boundary.');

end-proc;


dcl-proc test_getFullTimestamp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s startTime timestamp;
  dcl-s timestamp timestamp;
  dcl-s mSecsAreValid ind;

  dcl-c MAX_SECONDS 5;

  // Setup.

  mSecsAreValid = *off;
  startTime = %timestamp();

  // Run.

  dou (mSecsAreValid or maxTimeReached(startTime: MAX_SECONDS));
    timestamp = %timestamp();
    if (%subdt(timestamp: *mseconds) > 0);
      mSecsAreValid = *on;
    endif;
  enddo;

  // Check.

  assert(mSecsAreValid
         : 'No valid microSeconds found in ' +
            %char(MAX_SECONDS) + ' seconds');

end-proc;


dcl-proc test_getMemberType export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s srcType varchar(10);

  srcType = getMemberType('RPGUNITTST': 'QTEMP': MBR_RPGLE);
  assert(srcType = MBR_RPGLE: 'getMemberType() must return RPGLE');

  srcType = getMemberType('RPGUNITTST': 'QTEMP': MBR_SQLRPGLE);
  assert(srcType = MBR_SQLRPGLE: 'getMemberType() must return SQLRPGLE');

  srcType = getMemberType('RPGUNITTST' : 'QTEMP': MBR_CBLLE);
  assert(srcType = MBR_CBLLE: 'getMemberType() must return CBLLE');

  srcType = getMemberType('RPGUNITTST': 'QTEMP': MBR_SQLCBLLE);
  assert(srcType = MBR_SQLCBLLE: 'getMemberType() must return SQLCBLLE');

end-proc;


dcl-proc test_getMemberType_error export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s srcType varchar(10);

  monitor;
    srcType = getMemberType('RPGUNITTST': 'QTEMP': 'NOT.FOUND');
    fail('getMemberType() should have raised an error');
  on-error;
    // Good, error seen.
  endmon;

end-proc;


dcl-proc test_getStmfType export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s srcType varchar(10);

  srcType = getStmfType('/home/dev/missingExtension/member.rpgle');
  assert(srcType = lCase(MBR_RPGLE): 'getStmfType() must return RPGLE');

  srcType = getStmfType('/home/dev/missingExtension/member.sqlrpgle');
  assert(srcType = lCase(MBR_SQLRPGLE): 'getStmfType() must return SQLRPGLE');

  srcType = getStmfType('/home/dev/missingExtension/member.cblle');
  assert(srcType = lCase(MBR_CBLLE): 'getStmfType() must return CBLLE');

  srcType = getStmfType('/home/dev/missingExtension/member.sqlcblle');
  assert(srcType = lCase(MBR_SQLCBLLE): 'getStmfType() must return SQLCBLLE');

  srcType = getStmfType('\home\dev\missingExtension\member.sqlcblle');
  assert(srcType = lCase(MBR_SQLCBLLE): 'getStmfType() must return SQLCBLLE');

  srcType = getStmfType('/home/dev/missingExtension');
  assert(srcType = '': 'getStmfType() must return an empty value');

  srcType = getStmfType('/home/dev.de/missingExtension');
  assert(srcType = '': 'getStmfType() must return an empty value');

end-proc;


//----------------------------------------------------------------------
//   Returns TRUE, when the maximun processing time has been reached.
//----------------------------------------------------------------------

dcl-proc maxTimeReached;
  dcl-pi *n ind extproc(*dclcase);
    startTime   timestamp const;
    maxSecs     uns(10) const;
  end-pi;

  if (startTime + %seconds(maxSecs) < %timestamp());
    return *on;
  endif;

  return *off;

end-proc;

