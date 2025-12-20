**free
/if not defined (IRPGUNIT_CRTTST)
/define IRPGUNIT_CRTTST
// ==========================================================================
//  iRPGUnit - Implementation of RUCRT* commands.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

//----------------------------------------------------------------------
//   PUBLIC PROTOTYPES
//----------------------------------------------------------------------

///
// Creates a complete iRPGUnit test program by compiling source code and
// binding it with necessary modules and service programs. This is the main
// entry point for the test creation process, handling both source members
// and IFS stream files.
//
// @param testPgm - Target test program object specification (name/library)
// @param srcFile - Source file object containing the test source code
// @param srcMbr - Source member name within the source file
// @param srcStmf - Alternative IFS stream file path for source code
// @param text - Descriptive text for the created program object
// @param cOption - Compiler-specific options controlling code generation
// @param dbgView - Debug view setting (*SOURCE, *LIST, *ALL, *NONE)
// @param bndSrvPgm - Array of service programs to bind with test program
// @param bndDir - Array of binding directories to search for dependencies
// @param bOption - Binding options controlling the link process
// @param define - Preprocessor defines for conditional compilation
// @param dltSplF - Flag to delete compiler spooled files (*YES/*NO)
// @param actGrp - Activation group specification for program execution
// @param bModules - Array of additional modules to bind with the program
// @param pRpgPpOpt - RPG-specific preprocessor options
// @param pOption - Additional processor options for compilation
// @param compileOpt - General compile options affecting code generation
// @param targetRls - Target release version for backward compatibility
// @param incDir - Include directories for copy member and prototype resolution
// @param tgtCcsid - Target CCSID for character data conversion
///
dcl-pr crtTst extproc('CRTTST_crtTst');
  testPgm    likeds(object_t) const;
  srcFile    likeds(object_t) const;
  srcMbr     like(srcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  text       like(text_t) const;
  cOption    likeds(options_t) const;
  dbgView    like(dbgView_t) const;
  bndSrvPgm  likeds(objectArray_t) const;
  bndDir     likeds(objectArray_t) const;
  bOption    likeds(options_t) const;
  define     likeds(defines_t) const;
  dltSplF    like(yesno_t) const;
  actGrp     like(activationGroup_t) const;
  bModules   likeds(objectArray_t) const;
  pRpgPpOpt  like(rpgPpOpt_t) const;
  pOption    likeds(options_t) const;
  compileOpt like(compileOpt_t) const;
  targetRls  like(targetRelease_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
end-pr;

///
// Constructs a properly formatted CRTRPGMOD (Create RPG Module) command
// string with all specified compilation parameters. The generated command
// can be executed to compile RPG source into a module object.
//
// @param pgm - Module object specification (name/library) to create
// @param srcFile - Source file containing the RPG source code
// @param srcMbr - Member name within the source file to compile
// @param srcStmf - Alternative IFS stream file path for source code
// @param cOption - RPG compiler options affecting code generation and optimization
// @param dbgView - Debug information level (*SOURCE, *LIST, *ALL, *NONE)
// @param pRpgPpOpt - RPG preprocessor options for conditional compilation
// @param pOptions - Additional processor-specific compilation options
// @param compileopt - General compilation options and settings
// @param targetRls - Target system release for compatibility (e.g., V7R4M0)
// @param define - Conditional compilation defines for preprocessor
// @param incDir - Directories to search for /COPY and /INCLUDE members
// @param tgtCcsid - Target CCSID for character data in the compiled module
// @param cvtCcsid - Source CCSID for character conversion during compilation
//
// @return Complete CRTRPGMOD command string ready for system execution
///
dcl-pr getCrtRpgModCmd like(cmd_t) extproc('CRTTST_getCrtRpgModCmd');
  pgm        likeds(object_t) const;
  srcFile    likeds(object_t) const;
  srcMbr     like(srcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  cOption    likeds(options_t) const;
  dbgView    like(dbgView_t) const;
  pRpgPpOpt  like(rpgPpOpt_t) const;
  pOptions   likeds(options_t) const;
  compileopt like(compileOpt_t) const;
  targetRls  like(targetRelease_t) const;
  define     likeds(defines_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
  cvtCcsid   like(cvtCcsid_t) const;
end-pr;

///
// Constructs a properly formatted CRTCBLMOD (Create COBOL Module) command
// string for compiling COBOL source code into a module object. Handles
// COBOL-specific compilation parameters and formatting requirements.
//
// @param pgm - Module object specification (name/library) to create
// @param srcFile - Source file containing the COBOL source code
// @param srcMMr - Member name within the source file to compile
// @param srcStmf - Alternative IFS stream file path for COBOL source
// @param cOption - COBOL compiler options for code generation and optimization
// @param dbgView - Debug information level (*SOURCE, *STMT, *NONE)
// @param pOptions - Additional processor options for COBOL compilation
// @param compileOpt - General compilation options and settings
// @param targetRls - Target system release for compatibility
// @param define - Preprocessor defines for conditional compilation
// @param incDir - Include directories for COPY statement resolution
// @param tgtCcsid - Target CCSID for character data in compiled module
// @param cvtCcsid - Source CCSID for character conversion during compilation
//
// @return Complete CRTCBLMOD command string ready for system execution
///
dcl-pr getCrtCblModCmd like(cmd_t) extproc('CRTTST_getCrtCblModCmd');
  pgm        likeds(object_t) const;
  srcFile    likeds(object_t) const;
  srcMMr     like(srcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  cOption    likeds(options_t) const;
  dbgView    like(dbgView_t) const;
  pOptions   likeds(options_t) const;
  compileOpt like(compileOpt_t) const;
  targetRls  like(targetRelease_t) const;
  define     likeds(defines_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
  cvtCcsid   like(cvtCcsid_t) const;
end-pr;

///
// Constructs a properly formatted CRTSRVPGM (Create Service Program) command
// string for creating service programs from compiled modules. Handles binding
// of multiple modules and resolution of external dependencies.
//
// @param pgm - Service program object specification (name/library) to create
// @param bndSrvPgm - Array of service programs to bind as dependencies
// @param bndDir - Array of binding directories to search for unresolved symbols
// @param module - Array of module objects to include in the service program
// @param options - Binding options controlling link-time behavior and optimization
// @param export - Export specification (*ALL, *SRCFILE, or binder language source)
// @param actGrp - Activation group specification for service program execution
// @param text - Descriptive text for the created service program object
// @param targetRls - Target system release for backward compatibility
//
// @return Complete CRTSRVPGM command string ready for system execution
///
dcl-pr getCrtSrvPgmCmd like(cmd_t) extproc('CRTTST_getCrtSrvPgmCmd');
  pgm       likeds(object_t) const;
  bndSrvPgm likeds(objectArray_t) const;
  bndDir    likeds(objectArray_t) const;
  module    likeds(objectArray_t) const;
  options   likeds(options_t) const;
  export    char(10) const;
  actGrp    like(activationGroup_t) const;
  text      like(text_t ) const;
  targetRls like(targetRelease_t) const;
end-pr;

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

///
// Converts an object specification into a standardized string format suitable
// for display, logging, or command construction. The serialized format typically
// includes both the object name and library in a consistent representation.
//
// @param object - Object specification to convert to string format
//
// @return String representation of the object in library/name format
///
dcl-pr serializeObjectName varchar(21) extproc('CRTTST_serializeObjectName');
  object likeds(object_t) const;
end-pr;

/endif
