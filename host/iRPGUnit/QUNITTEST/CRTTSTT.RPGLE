**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test CRTTSTT.
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
//     >>PARM<<  MODULE(&LI/CRTTST    +
//                      &LI/JOBLOG    +
//                      &LI/LIBL      +
//                      &LI/LSTSPLF   +
//                      &LI/OBJECT    +
//                      &LI/PGMMSG    +
//                      &LI/SRCMBR    +
//                      &LI/STRING    +
//                      &LI/TAGTST    +
//                      &LI/USRSPC    +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/CRTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LSTSPLF  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/SRCMBR   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/TAGTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,LIBL
/copy qinclude,CRTTST
/copy qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// No debugging view given by user.
dcl-c noDbgView const(*blank);
// RPG preprocessor options.
dcl-c rpgPpOptLvl2 const('*LVL2');
// No export option.
dcl-c noExport const(*blank);
// No text.
dcl-c noText const(*blank);

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// No compile option.
dcl-ds noCOption likeds(Options_t);
// No SQL pre-compiler option.
dcl-ds noPOption likeds(Options_t);
// No service program to bind.
dcl-ds noBndSrvPgm likeds(ObjectArray_t);
// No binding directory.
dcl-ds noBndDir likeds(ObjectArray_t);
// No binding option.
dcl-ds noBOption likeds(Options_t);
// No modules.
dcl-ds noModule likeds(ObjectArray_t);
// No SQL pre-compiler compile option.
dcl-s noCompileOpt    varchar(1);
// No activation group.
dcl-s noActGrp        varchar(10);
// No target release
dcl-s noTargetRls     like(TargetRelease_t);
// No condition names
dcl-ds noDefine likeds(defines_t);

// Command to create an RPG module.
dcl-s crtRpgModCmd    char(256);
// Command to create a Cobol module.
dcl-s crtCblModCmd    char(256);
// Command to create a Service Program object.
dcl-s crtSrvPgmCmd    char(256);

dcl-ds liblList likeds(LiblData_t);
dcl-ds newLiblList likeds(LiblData_t);

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

  clear crtCblModCmd;

  clear crtRpgModCmd;

  clear noCOption;
  noCOption.size = 0;

  clear noBndSrvPgm;
  noBndSrvPgm.size = 0;

  clear noBndDir;
  noBndDir.size = 0;

  clear noBOption;
  noBOption.size = 0;

  clear noModule;
  noModule.size = 0;

  clear noDefine;
  noDefine.size = 0;

  liblList = getLibl();
  newLiblList = liblList;
  newLiblList.curLib = sds.pgmLib;
  restoreLibl(newLiblList);

end-proc;

dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  restoreLibl(liblList);

end-proc;


dcl-proc testSrcFile export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noTargetRls:
                                 noDefine);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES)': crtRpgModCmd);

end-proc;


dcl-proc testOneCompileOption export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*SRCSTMT';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES' :
                                 oneCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noTargetRls:
                                 noDefine);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          OPTION(*SRCSTMT)': crtRpgModCmd);

end-proc;


dcl-proc testTwoCompileOptions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds twoCOptions likeds(Options_t);


  twoCOptions.size = 2;
  twoCOptions.option(1) = '*SRCSTMT';
  twoCOptions.option(2) = '*NODEBUGIO';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 twoCOptions:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noTargetRls:
                                 noDefine);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          OPTION(*SRCSTMT *NODEBUGIO)': crtRpgModCmd);

end-proc;


dcl-proc testDbgView export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noCOption:
                                 '*LIST':
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noTargetRls:
                                 noDefine);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          DBGVIEW(*LIST)': crtRpgModCmd);

end-proc;

dcl-proc testModTargetRls export;
  dcl-pi *n extproc(*dclcase);
  end-pi;


  // Use members stored in library QSYSINC for testing
  // purposes. Members SYSTYPES and SQLUDF must exist
  // as we need to retrieve their source types.

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noCOption:
                                 '*LIST':
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 '*CURRENT':
                                 noDefine);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          DBGVIEW(*LIST) TGTRLS(*CURRENT)': crtRpgModCmd);

  crtCblModCmd = getCrtCblModCmd('SQLUDF    *CURLIB   ':
                                 'QCBLLESRC QSYSINC   ':
                                 'SQLUDF':
                                 noCOption:
                                 '*LIST':
                                 noPOption:
                                 noCompileOpt:
                                 '*CURRENT':
                                 noDefine);
  aEqual('CRTCBLMOD MODULE(*PGMID) +
          SRCFILE(QSYSINC/QCBLLESRC) SRCMBR(SQLUDF) +
          DBGVIEW(*LIST) TGTRLS(*CURRENT)': crtCblModCmd);

end-proc;

dcl-proc testOneBndSrvPgm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Binding one Service Program.
  dcl-ds oneBndSrvPgm likeds(ObjectArray_t);


  // Setup.

  oneBndSrvPgm.size = 1;
  oneBndSrvPgm.object(1).nm = 'SRVPGM_NM';
  oneBndSrvPgm.object(1).lib = 'SRVPGM_LIB';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 oneBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM)) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testTwoBndSrvPgm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Binding two Service Programs.
  dcl-ds twoBndSrvPgm likeds(ObjectArray_t);


  // Setup.

  twoBndSrvPgm.size = 2;
  twoBndSrvPgm.object(1).nm = 'SRVPGM_NM';
  twoBndSrvPgm.object(1).lib = 'SRVPGM_LIB';
  twoBndSrvPgm.object(2).nm = 'SRVPGM_NM2';
  twoBndSrvPgm.object(2).lib = 'SRVPGM_LB2';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 twoBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM) (SRVPGM_LB2/SRVPGM_NM2)) +
          DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testOneBndDir export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One binding directory.
  dcl-ds oneBndDir likeds(ObjectArray_t);


  // Setup.

  oneBndDir.size = 1;
  oneBndDir.object(1).nm = 'BNDDIR_NM';
  oneBndDir.object(1).lib = 'BNDDIR_LIB';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 oneBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDDIR(BNDDIR_LIB/BNDDIR_NM) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testBndDirWithoutLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One binding directory.
  dcl-ds oneBndDir likeds(ObjectArray_t);


  // Setup.

  oneBndDir.size = 1;
  oneBndDir.object(1).nm = 'BNDDIR_NM';
  oneBndDir.object(1).lib = *blank;

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 oneBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDDIR(BNDDIR_NM) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testOneBindingOption export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One Binding Option.
  dcl-ds oneBOption likeds(Options_t);


  // Setup.

  oneBOption.size = 1;
  oneBOption.option(1) = '*DUPPROC';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 oneBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          OPTION(*DUPPROC) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testExport export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s export          char(10);


  // Setup.

  export = '*ALL';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 export:
                                 noActGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          EXPORT(*ALL) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testActGrp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s actGrp char(10);


  // Setup.

  actGrp = 'QTEST';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 actGrp:
                                 noText:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          ACTGRP(QTEST) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;

dcl-proc testTargetRls export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s targetRls       like(TargetRelease_t);


  // Setup.

  targetRls = '*CURRENT';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 targetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          DETAIL(''*BASIC'') TGTRLS(*CURRENT)': crtSrvPgmCmd);

end-proc;

dcl-proc testText export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s text            char(50);


  // Setup.

  text = 'Object ''description'' text';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 text:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          TEXT(''Object ''''description'''' text'') DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testSerializeObjectNameWithLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // An object name.
  dcl-ds object likeds(Object_t);

  // Setup.

  object.nm = 'OBJNAME';
  object.lib = 'OBJLIB';

  // Execute and control.

  aEqual('OBJLIB/OBJNAME': serializeObjectName(object));

end-proc;


dcl-proc testSerializeObjectNameWithoutLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // An object name.
  dcl-ds object likeds(Object_t);

  // Setup.

  object.nm = 'OBJNAME';
  object.lib = *blank;

  // Execute and control.

  aEqual('OBJNAME': serializeObjectName(object));

end-proc;
