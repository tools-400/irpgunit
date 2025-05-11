**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Compile Templates.
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
/include qinclude,ERRORCODE
/include qinclude,SYSTEMAPI

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

//---------------------------------------------------------------------
//   Program Status Data Structure
//---------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dltSrvPgm('QTEMP/RPG');
  dltSrvPgm('QTEMP/RPGSQL');
  dltSrvPgm('QTEMP/CBL');

end-proc;

dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dltSrvPgm('QTEMP/RPG');
  dltSrvPgm('QTEMP/RPGSQL');
  dltSrvPgm('QTEMP/CBL');

end-proc;


dcl-proc testRpg export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  runCmd('RUCRTRPG TSTPGM(QTEMP/RPG) +
          SRCFILE(QTEMPLATE) DLTSPLF(*YES)');
  assert(*on = exists('QTEMP/RPG': '*SRVPGM'): 'Service program QTEMP/RPG must exist.');

end-proc;


dcl-proc testRpgSql export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  runCmd('RUCRTRPG TSTPGM(QTEMP/RPGSQL) +
          SRCFILE(QTEMPLATE) DLTSPLF(*YES)');
  assert(*on = exists('QTEMP/RPGSQL': '*SRVPGM'): 'Service program QTEMP/RPGSQL must exist.');

end-proc;


dcl-proc testCbl export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  runCmd('RUCRTCBL TSTPGM(QTEMP/CBL) +
          SRCFILE(QTEMPLATE) DLTSPLF(*YES)');
  assert(*on = exists('QTEMP/CBL': '*SRVPGM'): 'Service program QTEMP/CBL must exist.');

end-proc;


//----------------------------------------------------------------------
//  Returns *ON if the specified object exists, otherwise *OFF.
//----------------------------------------------------------------------
dcl-proc exists;
  dcl-pi *N ind extproc(*dclcase);
    object char(21) const;
    type   char(10) const;
  end-pi;

  dcl-ds qObj likeds(object_t) inz;

  // QUSROBJD API.
  dcl-ds objd0100 likeds(objd0100_t);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  qObj.lib = %subst(object: 1: %scan('/': object) - 1);
  qObj.nm = %subst(object: %scan('/': object) + 1);

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);

  qusrobjd(objd0100: %size(objd0100): 'OBJD0100': qObj: type: errorCode);
  if (errorCode.bytAvl > 0);
    return *OFF;
  else;
    return *ON;
  endif;

end-proc;


//----------------------------------------------------------------------
//  Deletes the specified service program.
//----------------------------------------------------------------------
dcl-proc dltSrvpgm;
  dcl-pi *N extproc(*dclcase);
    srvPgm char(21) const;
  end-pi;

  if (exists(srvPgm: '*SRVPGM'));
    runCmd('DLTSRVPGM SRVPGM(' + srvPgm + ')');
  endif;

end-proc;

