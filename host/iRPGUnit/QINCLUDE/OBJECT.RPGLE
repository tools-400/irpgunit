**FREE
/if not defined (IRPGUNIT_OBJECT)
/define IRPGUNIT_OBJECT
// ==========================================================================
//  iRPGUnit - Object Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. Ths program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Resolves the library name for a given object
//
// This procedure determines the actual library where an object resides,
// resolving special values like *LIBL and *CURLIB to their actual library names.
// It validates object existence before returning the resolved library name.
//
// @param object  - Object structure containing name and library information
// @param objType - Type of object to resolve (e.g., '*PGM', '*SRVPGM', '*FILE')
//
// @return Library name where the object resides, or blanks if object not found
///
dcl-pr Object_resolveLibrary char(10) extproc('Object_Object_resolveLibrary');
  object  likeds(object_t) const;
  objType char(10) const;
end-pr;

///
// Retrieves an attribute value for the specified object
//
// Queries system APIs to obtain specific attribute information for the given object.
// Common attributes include creation date, text description, source type, and
// other object-specific properties.
//
// @param object  - Object structure containing name and library information
// @param objType - Type of object to query (e.g., '*PGM', '*SRVPGM', '*MODULE')
//
// @return Attribute value as a character string, blanks if attribute not available
///
dcl-pr Object_getAttribute char(10) extproc('Object_Object_getAttribute');
  object  likeds(object_t) const;
  objType char(10) const;
end-pr;

///
// Checks if an object needs to be recompiled (is dirty)
//
// Determines whether an object requires recompilation by comparing the object's
// creation timestamp with the modification timestamps of its associated source members.
// This is essential for automated testing and build processes.
//
// @param object  - Object structure containing name and library information
// @param objType - Type of object to check (e.g., '*PGM', '*SRVPGM', '*MODULE')
//
// @return *ON if object is dirty and needs recompilation, *OFF if object is clean
///
dcl-pr Object_isDirty ind extproc('Object_Object_isDirty');
  object  likeds(object_t) const;
  objType char(10) const;
end-pr;

///
// Checks if an object exists on the system
//
// Verifies the existence of an object in the specified library. For source objects,
// an optional member name can be provided to check for specific member existence
// within the source file. Handles library resolution including *LIBL and *CURLIB.
//
// @param object  - Object structure containing name and library information
// @param objType - Type of object to check (e.g., '*PGM', '*SRVPGM', '*FILE')
// @param mbr     - Member name for source objects (optional parameter)
//
// @return *ON if object exists, *OFF if object is not found
///
dcl-pr Object_exists ind extproc('Object_Object_exists');
  object  likeds(object_t) const;
  objType char(10) const;
  mbr     char(10) const options(*nopass);
end-pr;

///
// Returns the qualified object name in library/object format
//
// Constructs a fully qualified object name string combining the library name
// and object name in standard IBM i format. This is useful for display purposes
// and when passing qualified names to system commands or APIs.
//
// @param object - Object structure containing name and library information
//
// @return Qualified name in format 'LIBRARY/OBJECT' (up to 21 characters)
///
dcl-pr Object_qName varchar(21) extproc('Object_Object_qName');
  object likeds(object_t) const;
end-pr;

///
// Checks if a test suite service program exists
//
// Verifies the existence of a test suite service program in the specified library.
// Test suites are special service programs that contain unit test procedures for
// the iRPGUnit framework. Validates proper test suite structure and exportability.
//
// @param srvPgm  - Service program name to check
// @param library - Library name where service program should exist
//
// @return *ON if test suite service program exists, *OFF if not found
///
dcl-pr TestSuite_exists ind extproc('Object_TestSuite_exists');
  srvPgm  char(10) const;
  library char(10) const;
end-pr;

///
// Checks if a test suite service program is dirty and needs recompilation
//
// Determines if a test suite service program requires recompilation by checking
// modification timestamps of associated source members. This is essential for
// automated test execution to ensure tests reflect current source code changes.
//
// @param srvPgm  - Service program name to check
// @param library - Library name where service program resides
//
// @return *ON if test suite is dirty and needs recompilation, *OFF if clean
///
dcl-pr TestSuite_isDirty ind extproc('Object_TestSuite_isDirty');
  srvPgm  char(10) const;
  library char(10) const;
end-pr;

/endif

