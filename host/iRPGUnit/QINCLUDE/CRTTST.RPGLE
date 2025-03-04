**FREE
/if not defined (IRPGUNIT_CRTTST)
/define IRPGUNIT_CRTTST
// ==========================================================================
//  iRPGUnit - Implementation of RUCRT* commands.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

//----------------------------------------------------------------------
//   PUBLIC PROTOTYPES
//----------------------------------------------------------------------

dcl-pr crtTst extproc('CRTTST_crtTst');
  testPgm         likeds(object_t) const;
  srcFile         likeds(object_t) const;
  srcMbr          like(srcMbr_t.mbr) const;
  srcStmf         like(ifsStmf_t) const;
  text            like(text_t) const;
  cOption         likeds(options_t) const;
  dbgView         like(dbgView_t) const;
  bndSrvPgm       likeds(objectArray_t) const;
  bndDir          likeds(objectArray_t) const;
  bOption         likeds(options_t) const;
  define          likeds(defines_t) const;
  dltSplF         like(yesno_t) const;
  actGrp          like(activationGroup_t) const;
  bModules        likeds(objectArray_t) const;
  pRpgPpOpt       like(rpgPpOpt_t) const;
  pOption         likeds(options_t) const;
  compileOpt      like(compileOpt_t) const;
  targetRls       like(targetRelease_t) const;
  incDir          likeds(incDir_t) const;
  tgtCcsid        like(tgtCcsid_t) const;
end-pr;

dcl-pr serializeObjectName varchar(21) extproc('CRTTST_serializeObjectName');
  object          likeds(object_t) const;
end-pr;

dcl-pr serializeStmfPath like(serializedStmf_t) extproc('CRTTST_serializeStmfPath');
  srcStmf         like(ifsStmf_t) const;
end-pr;

dcl-pr getCrtRpgModCmd like(cmd_t) extproc('CRTTST_getCrtRpgModCmd');
  pgm             likeds(object_t) const;
  srcFile         likeds(object_t) const;
  srcMbr          like(srcMbr_t.mbr) const;
  srcStmf         like(ifsStmf_t) const;
  cOptions        likeds(options_t) const;
  dbgView         like(dbgView_t) const;
  pRpgPpOpt       like(rpgPpOpt_t) const;
  pOptions        likeds(options_t) const;
  compileopt      like(compileOpt_t) const;
  targetRls       like(targetRelease_t) const;
  define          likeds(defines_t) const;
  incDir          likeds(incDir_t) const;
  tgtCcsid        like(tgtCcsid_t) const;
end-pr;

dcl-pr getCrtCblModCmd like(cmd_t) extproc('CRTTST_getCrtCblModCmd');
  pgm             likeds(object_t) const;
  srcFile         likeds(object_t) const;
  srcMMr          like(srcMbr_t.mbr) const;
  srcStmf         like(ifsStmf_t) const;
  cOptions        likeds(options_t) const;
  dbgView         like(dbgView_t) const;
  pOptions        likeds(options_t) const;
  compileOpt      like(compileOpt_t) const;
  targetRls       like(targetRelease_t) const;
  define          likeds(defines_t) const;
  incDir          likeds(incDir_t) const;
  tgtCcsid        like(tgtCcsid_t) const;
end-pr;

dcl-pr getCrtSrvPgmCmd like(cmd_t) extproc('CRTTST_getCrtSrvPgmCmd');
  pgm             likeds(object_t) const;
  bndSrvPgm       likeds(objectArray_t) const;
  bndDir          likeds(objectArray_t) const;
  module          likeds(objectArray_t) const;
  options         likeds(options_t) const;
  export          char(10) const;
  actGrp          like(activationGroup_t) const;
  text            like(text_t ) const;
  targetRls       like(targetRelease_t) const;
end-pr;

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr formatCommand like(cmd_t) extproc('formatCommand');
  cmd             like(cmd_t) const;
end-pr;

dcl-pr getCreatedModulesFromJobLog likeds(objectArray_t) extproc('getCreatedModulesFromJobLog');
  crtMsgID        char(7) const;
  timeLimit       timestamp const;
end-pr;

dcl-pr addModules extproc('addModules');
  modules         likeds(objectArray_t);
  items           likeds(objectArray_t);
end-pr;

dcl-pr addModule extproc('addModule');
  modules         likeds(objectArray_t);
  module          likeds(object_t) const;
  isFirstMod      ind options(*nopass) const;
end-pr;

dcl-pr resolvelibraries likeds(objectArray_t) extproc('resolveLibraries');
  modules         likeds(objectArray_t) const;
end-pr;

dcl-pr crtrpgmod extproc('crtRpgMod');
  testPgm         likeds(object_t) const;
  srcFile         likeds(object_t) const;
  srcMbr          like(srcMbr_t.mbr) const;
  srcStmf         like(ifsStmf_t) const;
  cOption         likeds(options_t) const;
  dbgView         like(dbgView_t) const;
  pRpgPpOpt       like(rpgPpOpt_t) const;
  pOption         likeds(options_t) const;
  compileOpt      like(compileOpt_t) const;
  targetRls       like(targetRelease_t) const;
  define          likeds(defines_t) const;
  incDir          likeds(incDir_t) const;
   tgtCcsid        like(tgtCcsid_t) const;
end-pr;

dcl-pr crtCblMod extproc('crtCblMod');
  testPgm         likeds(object_t) const;
  srcFile         likeds(object_t) const;
  srcMbr          like(srcMbr_t.mbr) const;
  srcStmf         like(ifsStmf_t) const;
  cOption         likeds(options_t) const;
  dbgView         like(dbgView_t) const;
  pOption         likeds(options_t) const;
  compileOpt      like(compileOpt_t) const;
  targetRls       like(targetRelease_t) const;
  define          likeds(defines_t) const;
  incDir          likeds(incDir_t) const;
  tgtCcsid        like(tgtCcsid_t) const;
end-pr;

dcl-pr crtSrvPgm likeds(object_t) extproc('crtSrvPgm');
  testPgm         likeds(object_t) const;
  bndSrvPgm       likeds(objectArray_t) const;
  bndDir          likeds(objectArray_t) const;
  module          likeds(objectArray_t) const;
  bOption         likeds(options_t) const;
  actGrp          like(activationGroup_t) const;
  text            like(text_t) const;
  targetRls       like(targetRelease_t) const;
end-pr;

dcl-pr deleteModulesAndSpooledFiles extproc('deleteModulesAndSpooledFiles');
  dltSplF         ind const;
  startTime       timestamp const;
  modules         likeds(objectArray_t) const;
end-pr;

dcl-pr getdltmodcmd like(cmd_t) extproc('getDltModCmd');
  testPgm         likeds(object_t) const;
end-pr;

dcl-pr serializeObjectArray like(serializedArray_t) extproc('serializeObjectArray');
  headToken       char(10) const;
  array           likeds(objectArray_t) const;
end-pr;

dcl-pr serializeOptions like(serializedOptions_t) extproc('serializeOptions');
  headToken       char(10) const;
  options         likeds(options_t) const;
end-pr;

dcl-pr serializeString like(serializedString_t) extproc('serializeString');
  headToken       char(10) const;
  text            varchar(5000) options(*varsize) const;
end-pr;

dcl-pr serializeValue like(serializedString_t) extproc('serializeValue');
  headToken       char(10) const;
  value           like(string_t) const;
end-pr;

dcl-pr addtestcasemodule likeds(objectArray_t) extproc('addTestCaseModule');
  modules         likeds(objectArray_t) const;
  testCase        likeds(object_t) const;
end-pr;

/endif
