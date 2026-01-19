**FREE
// ==========================================================================
//  iRPGUnit - List Spooled Files.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-s hSplfLister_t varchar(1024) template;

dcl-pr sl_ls_callback ind;
  i_hSplf       pointer       const;
  i_pUserData   pointer       const;
  i_splfNm      char(10)      const;
  i_qJob        likeds(Job_t) const;
  i_splFNbr     int(10)       const;
  i_fileStatus  char(10)      const;
end-pr;

dcl-c SL_STS_CLOSED     '*CLOSED';
dcl-c SL_STS_DEFERRED   '*DEFERRED';
dcl-c SL_STS_SENDING    '*SENDING';
dcl-c SL_STS_FINISHED   '*FINISHED';
dcl-c SL_STS_HELD       '*HELD';
dcl-c SL_STS_MESSAGE    '*MESSAGE';
dcl-c SL_STS_OPEN       '*OPEN';
dcl-c SL_STS_PENDING    '*PENDING';
dcl-c SL_STS_PRINTER    '*PRINTER';
dcl-c SL_STS_READY      '*READY';
dcl-c SL_STS_SAVED      '*SAVED';
dcl-c SL_STS_WRITING    '*WRITING';

///
// Initialize Spooled File Lister
//
// Creates and initializes a new spooled file lister instance for processing
// spooled files. Configures optional filters for job qualification, spooled
// file name matching, and user data filtering.
//
// @param i_qJob   - Optional job qualification (job name, user, number)
// @param i_splfNm - Optional spooled file name filter
// @param i_usrDta - Optional user data filter for spooled files
//
// @return Handle to the initialized spooled file lister instance
///
dcl-pr SplFLister_init like(hSplfLister_t) extproc('LSTSPLF_SplFLister_init');
  i_qJob   likeds(Job_t) options(*nopass) const;
  i_splfNm char(10)      options(*nopass) const;
  i_usrDta char(10)      options(*nopass) const;
end-pr;

///
// Add Status Filter to Lister
//
// Registers a specific spooled file status to be included in the listing.
// Multiple status filters can be added to create a compound filter condition.
// Only spooled files matching at least one registered status will be returned.
//
// @param io_hLister - Spooled file lister handle to configure (modified)
// @param i_status   - Status constant to include in filtering (SL_STS_* values)
//
// @return Status indicator (0=success, non-zero=error)
///
dcl-pr SplFLister_addStatus int(10) extproc('LSTSPLF_SplFLister_addStatus');
  io_hLister like(hSplfLister_t);
  i_status   char(10) const;
end-pr;

///
// Set Start Time Filter
//
// Configures the lister to only include spooled files created on or after
// the specified timestamp. Used to create time-based filtering for recent
// spooled files or those within a specific time range.
//
// @param io_hLister  - Spooled file lister handle to configure (modified)
// @param i_startTime - Earliest creation timestamp to include in results
//
// @return Success indicator (*ON=filter set successfully, *OFF=error)
///
dcl-pr SplFLister_setStartTime ind extproc('LSTSPLF_SplFLister_setStartTime');
  io_hLister  like(hSplfLister_t);
  i_startTime timestamp const;
end-pr;

///
// Set End Time Filter
//
// Configures the lister to only include spooled files created on or before
// the specified timestamp. Combined with start time, creates a time window
// filter for spooled file selection.
//
// @param io_hLister - Spooled file lister handle to configure (modified)
// @param i_endTime  - Latest creation timestamp to include in results
//
// @return Success indicator (*ON=filter set successfully, *OFF=error)
///
dcl-pr SplFLister_setEndTime ind extproc('LSTSPLF_SplFLister_setEndTime');
  io_hLister like(hSplfLister_t);
  i_endTime  timestamp const;
end-pr;

///
// List Spooled Files with Callback Processing
//
// Executes the spooled file listing operation using configured filters and
// calls a user-provided callback function for each matching spooled file.
// Supports optional user data parameter for maintaining state during processing.
//
// @param io_hLister  - Spooled file lister handle (updated with processing info)
// @param i_pCallback - Pointer to callback function for spooled file processing
// @param i_pUserData - Optional pointer to user data passed to callback
//
// @return Success indicator (*ON=files processed, *OFF=no files found or error)
///
dcl-pr SplFLister_list ind extproc('LSTSPLF_SplFLister_list');
  io_hLister  like(hSplfLister_t);
  i_pCallback pointer(*proc) const;
  i_pUserData pointer options(*nopass) const;
end-pr;

///
// Extract User Data from Spooled File
//
// Retrieves the user data attribute from a spooled file handle obtained during
// callback processing. Provides access to the 10-character user data field
// associated with the spooled file.
//
// @param i_hSplf - Handle to spooled file information from callback processing
//
// @return 10-character user data value associated with the spooled file
///
dcl-pr SplFLister_getUserData char(10) extproc('LSTSPLF_SplFLister_getUserData');
  i_hSplf pointer const;
end-pr;

/copy qinclude,TYPES_H
