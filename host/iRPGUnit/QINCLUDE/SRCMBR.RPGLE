**FREE
/if defined(IRPGUNIT_SRCMBR)
/eof
/endif
/define IRPGUNIT_SRCMBR
// ==========================================================================
//  iRPGunit - Source Member Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Initialize the source member utilities module
//
// Performs initialization tasks required for the source member utilities module.
// This includes setting up internal data structures, establishing API connections,
// and preparing the module for source member analysis operations.
///
dcl-pr SrcMbr_initialize extproc('SRCMBR_SrcMbr_initialize');
end-pr;

///
// Retrieve source information for a test suite program object
//
// Analyzes a program object to determine its associated source member information,
// including source file location, member name, and related metadata. This is
// essential for determining if test suite objects are current with their source.
//
// @param object - The program object to retrieve source information for
//                 Structure: library/object format identifying the program
//                 Must be a valid *PGM object
//
// @return Source information structure containing:
//         - Source file (library/file)
//         - Source member name
//         - Creation timestamp
//         - Source type
//         Returns empty structure if source information cannot be determined
///
dcl-pr SrcMbr_getTestSuiteSrc likeds(srcInf_t) extproc('SRCMBR_SrcMbr_getTestSuiteSrc');
  object likeds(object_t) const;
end-pr;

///
// Retrieve source information for a module within a program object
//
// Analyzes a specific module within a program object to determine its source
// member information. This is particularly useful for ILE programs that contain
// multiple modules, allowing source tracking at the module level.
//
// @param object - The program object containing the module
//                 Structure: library/object format identifying the program
//                 Must be a valid *PGM object
// @param module - The specific module to retrieve source information for
//                 Structure: library/object format identifying the module
//                 Module name must exist within the specified program
//
// @return Source information structure containing:
//         - Source file (library/file)
//         - Source member name
//         - Creation timestamp
//         - Source type
//         Returns empty structure if module or source information not found
///
dcl-pr SrcMbr_getModSrc likeds(srcInf_t) extproc('SRCMBR_SrcMbr_getModSrc');
  object likeds(object_t) const;
  module likeds(object_t) const;
end-pr;

///
// Get the last change date of a source member
//
// Retrieves the timestamp of when a source member was last modified.
// This information is crucial for determining if compiled objects are
// current with their source code and for build dependency management.
//
// @param qsrcfile - The source file containing the member
//                   Structure: library/file format identifying the source file
//                   Must be a valid source physical file
// @param srcMbr   - The name of the source member (up to 10 characters)
//                   Must exist within the specified source file
//
// @return Timestamp of the last change to the source member
//         Returns *LOVAL if member not found or timestamp unavailable
///
dcl-pr SrcMbr_getLastChgDate timestamp extproc('SRCMBR_SrcMbr_getLastChgDate');
  qsrcfile likeds(object_t) const;
  srcMbr   char(10) const;
end-pr;

///
// Get the description text of a source member
//
// Retrieves the descriptive text associated with a source member.
// This text is typically entered when the member is created or changed
// and provides documentation about the member's purpose.
//
// @param qsrcfile - The source file containing the member
//                   Structure: library/file format identifying the source file
//                   Must be a valid source physical file
// @param srcMbr   - The name of the source member (up to 10 characters)
//                   Must exist within the specified source file
//
// @return Description text of the source member (up to 50 characters)
//         Returns blanks if member not found or no description available
///
dcl-pr SrcMbr_getDescription varchar(50) extproc('SRCMBR_SrcMbr_getDescription');
  qsrcfile likeds(object_t) const;
  srcMbr   char(10) const;
end-pr;

///
// Get the source type of a source member
//
// Retrieves the source type attribute of a source member, which indicates
// the type of source code contained in the member (e.g., RPGLE, CLLE, DSPF).
// This information is essential for determining appropriate compilation procedures.
//
// @param qsrcfile - The source file containing the member
//                   Structure: library/file format identifying the source file
//                   Must be a valid source physical file
// @param srcMbr   - The name of the source member (up to 10 characters)
//                   Must exist within the specified source file
//
// @return Source type of the member (e.g., 'RPGLE', 'CLLE', 'DSPF')
//         Returns blanks if member not found or source type unavailable
///
dcl-pr SrcMbr_getType varchar(10) extproc('SRCMBR_SrcMbr_getType');
  qsrcfile likeds(object_t) const;
  srcMbr   char(10) const;
end-pr;

/include qinclude,TEMPLATES

