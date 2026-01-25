**FREE
/if defined(libl)
/eof
/endif
/define libl
// ==========================================================================
//  iRPGUnit - Library list Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Retrieve the current library list configuration.
// Captures the current job's library list settings including the current
// library and user library list entries for later restoration or reference.
//
// @return Library list data structure containing current configuration
///
dcl-pr getLibL likeds(liblData_t) extproc('LIBL_getLibL');
end-pr;

///
// Load library list configuration from a job description.
// Reads the library list settings from the specified job description
// object and returns them in a format suitable for applying to the
// current job or storing for later use.
//
// @param qJobD - Job description object to load library list from
//
// @return Library list data structure with loaded configuration
///
dcl-pr loadLibL likeds(liblData_t) extproc('LIBL_loadLibL');
  qJobD const likeds(object_t);
end-pr;

///
// Restore library list from previously saved configuration.
// Applies the library list configuration stored in the provided data
// structure to the current job, effectively restoring a previous state.
//
// @param libldata - Library list data structure containing saved configuration
///
dcl-pr restoreLibL extproc('LIBL_restoreLibL');
  libLData const likeds(liblData_t);
end-pr;

///
// Apply a new library list configuration to the current job.
// Changes both the current library and the user library list according
// to the provided parameters.
//
// @param curlib - Current library to set for the job
// @param libl   - Library list structure containing user library list entries
///
dcl-pr changeLibL extproc('LIBL_changeLibL');
  curLib char(10) const;
  libL   const likeds(libl_t);
end-pr;

///
// Configure library list for test suite execution environment.
// Sets up the appropriate library list for running a test suite by
// combining the provided library list with the test suite library
// and job description settings.
//
// @param libL         - Library list structure to apply
// @param jobD         - Job description object for additional configuration
// @param testSuiteLib - Test suite library name to include in the list
//
// @return *ON if library list was successfully configured, *OFF if failed
///
dcl-pr setTestSuiteLibL ind extproc('LIBL_setTestSuiteLibL');
  libL         likeds(libl_t) value;
  jobD         likeds(object_t) value;
  testSuiteLib char(10) value;
end-pr;

/include qinclude,TYPES_H

