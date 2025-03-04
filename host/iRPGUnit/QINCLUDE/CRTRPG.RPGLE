**FREE
/if not defined(CRTRPG)
/define CRTRPG
// ==========================================================================
//  iRPGUnit - Create RPG Unit Test Suite CPP.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// The entry point of RUCRTRPG Parameters are provided by RUCRTRPG command.
dcl-pr crtRpg extpgm('RUCRTRPG');
  testPgm      likeds(Object_t) const;
  srcFile      likeds(Object_t) const;
  srcMbr       like(SrcMbr_t.mbr) const;
  srcStmf      like(ifsStmf_t) const;
  text         like(Text_t) const;
  cOption      likeds(Options_t) const;
  dbgView      like(DbgView_t) const;
  bndSrvPgm    likeds(ObjectArray_t) const;
  bndDir       likeds(ObjectArray_t) const;
  bOption      likeds(Options_t) const;
  define       likeds(defines_t) const;
  dltSplf      like(yesNo_t) const;
  actGrp       like(ActivationGroup_t) const;
  bModules     likeds(ObjectArray_t) const;
  pRpgPpOpt    like(RpgPpOpt_t) const;
  pOption      likeds(Options_t) const;
  compileOpt   like(CompileOpt_t) const;
  targetRls    like(TargetRelease_t) const;
  incDir       likeds(incDir_t) const;
  tgtCcsid     like(tgtCcsid_t) const;
end-pr;

/endif
