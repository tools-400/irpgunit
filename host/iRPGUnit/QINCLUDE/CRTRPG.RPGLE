**FREE
/if not defined(CRTRPG)
/define CRTRPG
// ==========================================================================
//  iRPGUnit - Create RPG Unit Test Suite CPP.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Creates an RPG test service program from source code.
//
// Entry point for the RUCRTRPG command that orchestrates the complete build process
// including module compilation, service program binding, and cleanup operations
// for iRPGUnit RPG test service programs. This procedure handles both traditional
// source members and IFS stream files as input sources.
//
// @param testPgm    - Target test service program object to create
// @param srcFile    - Source file containing the RPG test source code
// @param srcMbr     - Source member name within the source file
// @param srcStmf    - IFS stream file path as alternative source location
// @param text       - Descriptive text for the created service program
// @param cOption    - Compilation options controlling module creation behavior
// @param dbgView    - Debug view specification for debugging support level
// @param bndSrvPgm  - Array of service programs to bind during creation
// @param bndDir     - Array of binding directories to search for exports
// @param bOption    - Binding options controlling service program creation
// @param define     - Preprocessor definitions for conditional compilation
// @param dltSplf    - Flag to delete compilation spooled files after creation
// @param actGrp     - Activation group specification for runtime isolation
// @param bModules   - Additional modules to include in the service program
// @param pRpgPpOpt  - RPG preprocessor options for advanced source processing
// @param pOption    - Processor options controlling compilation behavior
// @param compileOpt - Compiler-specific optimization and control options
// @param targetRls  - Target release level for compatibility control
// @param incDir     - Include directories for copy member resolution
// @param tgtCcsid   - Target CCSID for character data conversion
///
dcl-pr crtRpg extpgm('RUCRTRPG');
  testPgm    likeds(Object_t) const;
  srcFile    likeds(Object_t) const;
  srcMbr     like(SrcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  text       like(Text_t) const;
  cOption    likeds(Options_t) const;
  dbgView    like(DbgView_t) const;
  bndSrvPgm  likeds(ObjectArray_t) const;
  bndDir     likeds(ObjectArray_t) const;
  bOption    likeds(Options_t) const;
  define     likeds(defines_t) const;
  dltSplf    like(yesNo_t) const;
  actGrp     like(ActivationGroup_t) const;
  bModules   likeds(ObjectArray_t) const;
  pRpgPpOpt  like(RpgPpOpt_t) const;
  pOption    likeds(Options_t) const;
  compileOpt like(CompileOpt_t) const;
  targetRls  like(TargetRelease_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
end-pr;

/endif
