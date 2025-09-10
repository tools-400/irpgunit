**FREE
// ==========================================================================
//  iRPGUnit - Extract Procedures From a SRVPGM.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Count Procedures in List
//
// Returns the total number of procedures found in the specified procedure list.
// Used to determine the size of a procedure list for iteration or array sizing.
//
// @param procList - The procedure list structure to count
//
// @return Integer count of procedures in the list
///
dcl-pr cntProc int(10) extproc('EXTPRC_cntProc');
  procList likeds(procList_t) const;
end-pr;

///
// Load Service Program Procedure List
//
// Extracts all exported procedures from a service program and loads them into
// a procedure list structure. Creates a user space containing procedure metadata
// for subsequent analysis and testing operations.
//
// @param srvPgm - Service program object to analyze
//
// @return Procedure list structure containing all exported procedures
///
dcl-pr loadProcList likeds(procList_t) extproc('EXTPRC_loadProcList');
  srvPgm likeds(object_t) const;
end-pr;

///
// Adapt Procedure List to Name List Interface
//
// Converts a procedure list structure to a procedure name list interface for
// compatibility with existing APIs. Acts as an adapter without copying the
// underlying data, providing efficient access to procedure names only.
//
// @param procList - The procedure list to adapt
//
// @return Procedure name list interface structure
///
dcl-pr getProcNmList likeds(procNmList_t) extproc('EXTPRC_getProcNmList');
  procList likeds(procList_t);
end-pr;

///
// Get Current Procedure Name
//
// Retrieves the name of the procedure currently pointed to by the procedure
// list iterator. Must be called after positioning to a valid procedure entry.
//
// @param procList - The procedure list containing the current position
//
// @return Name of the current procedure
///
dcl-pr getProcNm like(procNm_t) extproc('EXTPRC_getProcNm');
  procList likeds(procList_t) const;
end-pr;

///
// Advance to Next Procedure
//
// Moves the procedure list iterator to the next procedure in the list.
// Updates the current position pointer to enable sequential processing
// of all procedures in the list.
//
// @param procList - The procedure list to advance (updated by reference)
///
dcl-pr goToNextProc extproc('EXTPRC_goToNextProc');
  procList likeds(procList_t);
end-pr;


//----------------------------------------------------------------------
//   Templates
//----------------------------------------------------------------------

dcl-ds procList_t qualified template;
  hdr       pointer;
  current   pointer;
end-ds;
