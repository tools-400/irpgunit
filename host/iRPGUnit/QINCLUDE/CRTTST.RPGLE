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
// Formats and validates a command string for proper syntax and execution.
// Handles parameter quoting, spacing, and ensures the command meets
// system requirements for length and format.
//
// @param cmd - Raw command string to be formatted and validated
//
// @return Properly formatted command string with correct syntax and spacing
///
dcl-pr formatCommand like(cmd_t) extproc('formatCommand');
  cmd like(cmd_t) const;
end-pr;

///
// Searches the job log for module creation completion messages within
// a specified time window. Extracts module names and libraries from
// successful compilation messages to build a list of created modules.
//
// @param crtMsgID  - Specific message ID to search for (e.g., 'RNX0301' for RPG modules)
// @param timeLimit - Timestamp boundary for limiting the search scope to recent messages
//
// @return Array of module objects that were successfully created and logged
///
dcl-pr getCreatedModulesFromJobLog likeds(objectArray_t) extproc('getCreatedModulesFromJobLog');
  crtMsgID  char(7) const;
  timeLimit timestamp const;
end-pr;

///
// Appends all modules from a source array to a target module array.
// This procedure expands the target array to accommodate the additional
// modules and maintains proper array indexing throughout the operation.
// Used for consolidating modules from multiple compilation operations.
//
// @param modules - Target module array to expand (modified in place)
// @param items   - Source array of modules to append to the target array
///
dcl-pr addModules extproc('addModules');
  modules likeds(objectArray_t);
  items   likeds(objectArray_t);
end-pr;

///
// Adds a single module object to a module array, expanding the array
// capacity as necessary. Handles special logic for adding the first module
// to an empty array and maintains array integrity throughout the process.
// Memory allocation is managed automatically during expansion.
//
// @param modules    - Module array to expand and modify (passed by reference)
// @param module     - Single module object to add to the array
// @param isFirstMod - Optional indicator for first module special handling
///
dcl-pr addModule extproc('addModule');
  modules    likeds(objectArray_t);
  module     likeds(object_t) const;
  isFirstMod ind options(*nopass) const;
end-pr;

///
// Resolves library names for modules by checking the library list and
// validating that all module references point to accessible objects.
// Converts *LIBL references to actual library names and ensures all
// modules exist before compilation attempts.
//
// @param modules - Array of module objects with potentially unresolved library names
//
// @return Array of module objects with fully resolved and validated library names
///
dcl-pr resolvelibraries likeds(objectArray_t) extproc('resolveLibraries');
  modules likeds(objectArray_t) const;
end-pr;

///
// Compiles RPG source code into a module object using the CRTRPGMOD command.
// Handles all RPG-specific compilation options including preprocessor settings,
// debug information, and target release compatibility. Manages the complete
// compilation process from source validation to module creation.
//
// @param testPgm    - Target module object specification (name/library) for compilation
// @param srcFile    - Source file containing the RPG source code to compile
// @param srcMbr     - Member name within the source file to compile
// @param srcStmf    - Alternative IFS stream file path for source code
// @param cOption    - RPG compiler options controlling code generation and optimization
// @param dbgView    - Debug information level (*SOURCE, *LIST, *ALL, *NONE)
// @param pRpgPpOpt  - RPG-specific preprocessor options for conditional compilation
// @param pOption    - Additional processor options for compilation control
// @param compileOpt - General compilation options affecting code generation
// @param targetRls  - Target system release for backward compatibility (e.g., V7R4M0)
// @param define     - Preprocessor conditional compilation defines
// @param incDir     - Include directories for /COPY and prototype resolution
// @param tgtCcsid   - Target CCSID for character data in the compiled module
// @param cvtCcsid   - Source CCSID for character conversion during compilation
///
dcl-pr crtrpgmod extproc('crtRpgMod');
  testPgm    likeds(object_t) const;
  srcFile    likeds(object_t) const;
  srcMbr     like(srcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  cOption    likeds(options_t) const;
  dbgView    like(dbgView_t) const;
  pRpgPpOpt  like(rpgPpOpt_t) const;
  pOption    likeds(options_t) const;
  compileOpt like(compileOpt_t) const;
  targetRls  like(targetRelease_t) const;
  define     likeds(defines_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
  cvtCcsid   like(cvtCcsid_t) const;
end-pr;

///
// Compiles COBOL source code into a module object using the CRTCBLMOD command.
// Manages COBOL-specific compilation requirements including statement-level
// debugging options and COBOL preprocessor settings. Handles the complete
// COBOL compilation workflow from source validation to module creation.
//
// @param testPgm    - Target module object specification (name/library) for compilation
// @param srcFile    - Source file containing the COBOL source code to compile
// @param srcMbr     - Member name within the source file to compile
// @param srcStmf    - Alternative IFS stream file path for COBOL source code
// @param cOption    - COBOL compiler options controlling code generation
// @param dbgView    - Debug information level (*SOURCE, *STMT, *NONE)
// @param pOption    - Additional processor options for COBOL compilation
// @param compileOpt - General compilation options and settings
// @param targetRls  - Target system release for backward compatibility
// @param define     - Preprocessor defines for conditional compilation
// @param incDir     - Include directories for COPY statement resolution
// @param tgtCcsid   - Target CCSID for character data in the compiled module
// @param cvtCcsid   - Source CCSID for character conversion during compilation
///
dcl-pr crtCblMod extproc('crtCblMod');
  testPgm    likeds(object_t) const;
  srcFile    likeds(object_t) const;
  srcMbr     like(srcMbr_t.mbr) const;
  srcStmf    like(ifsStmf_t) const;
  cOption    likeds(options_t) const;
  dbgView    like(dbgView_t) const;
  pOption    likeds(options_t) const;
  compileOpt like(compileOpt_t) const;
  targetRls  like(targetRelease_t) const;
  define     likeds(defines_t) const;
  incDir     likeds(incDir_t) const;
  tgtCcsid   like(tgtCcsid_t) const;
  cvtCcsid   like(cvtCcsid_t) const;
end-pr;

///
// Creates a service program from compiled modules using the CRTSRVPGM command.
// Handles binding of multiple modules, resolution of external dependencies,
// and management of service program exports. The created service program can
// be used by other programs and service programs as a shared runtime library.
//
// @param testPgm   - Target service program object specification (name/library)
// @param bndSrvPgm - Array of service programs to bind as dependencies
// @param bndDir    - Array of binding directories to search for unresolved symbols
// @param module    - Array of compiled module objects to include in the service program
// @param bOption   - Binding options controlling link-time behavior and optimization
// @param actGrp    - Activation group specification for service program execution
// @param text      - Descriptive text for the created service program object
// @param targetRls - Target system release for backward compatibility
//
// @return Object specification of the successfully created service program
///
dcl-pr crtSrvPgm likeds(object_t) extproc('crtSrvPgm');
  testPgm   likeds(object_t) const;
  bndSrvPgm likeds(objectArray_t) const;
  bndDir    likeds(objectArray_t) const;
  module    likeds(objectArray_t) const;
  bOption   likeds(options_t) const;
  actGrp    like(activationGroup_t) const;
  text      like(text_t) const;
  targetRls like(targetRelease_t) const;
end-pr;

///
// Performs cleanup operations by deleting temporary modules and optionally
// removing compiler-generated spooled files. This procedure helps maintain
// system cleanliness by removing intermediate compilation artifacts that
// are no longer needed after the final program or service program is created.
//
// @param dltSplF   - Indicator to delete compiler spooled files (*ON/*OFF)
// @param startTime - Timestamp boundary for limiting deletion scope to recent objects
// @param modules   - Array of module objects to be deleted from the system
///
dcl-pr deleteModulesAndSpooledFiles extproc('deleteModulesAndSpooledFiles');
  dltSplF   ind const;
  startTime timestamp const;
  modules   likeds(objectArray_t) const;
end-pr;

///
// Constructs a DLTMOD (Delete Module) command string for removing a specific
// module object from the system. The generated command can be executed to
// clean up temporary modules created during the compilation process.
//
// @param testPgm - Module object specification (name/library) to delete
//
// @return Complete DLTMOD command string ready for system execution
///
dcl-pr getDltModCmd like(cmd_t) extproc('getDltModCmd');
  testPgm likeds(object_t) const;
end-pr;

///
// Adds a test case module to an existing module array, expanding the array
// to accommodate the new test case. This procedure is specifically designed
// for incorporating test case modules into the compilation and binding process
// for iRPGUnit test suites.
//
// @param modules  - Existing array of module objects to expand
// @param testCase - Test case module object to add to the array
//
// @return Updated module array containing the original modules plus the new test case
///
dcl-pr addtestcasemodule likeds(objectArray_t) extproc('addTestCaseModule');
  modules  likeds(objectArray_t) const;
  testCase likeds(object_t) const;
end-pr;

///
// Converts an object specification into a standardized string format suitable
// for display, logging, or command construction. The serialized format typically
// includes both the object name and library in a consistent representation.
//
// @param object - Object specification to convert to string format
//
// @return String representation of the object in library/name format
///
dcl-pr serializeObjectName varchar(21) extproc('serializeObjectName');
  object likeds(object_t) const;
end-pr;

/endif
