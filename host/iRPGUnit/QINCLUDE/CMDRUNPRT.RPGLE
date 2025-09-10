**FREE
// ==========================================================================
//  iRPGUnit - Printing Facilities for CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Closes the currently open printer file and finalizes spooled file output.
// Performs cleanup of printer resources and completes the spooled file
// creation process, making the output available for viewing or processing.
// Essential for proper resource management in test output generation.
///
dcl-pr clsPrt extproc('CMDRUNPRT_clsPrt');
end-pr;

///
// Retrieves information about the current active spooled file.
// Returns details about the spooled file being used for test output,
// including file name, job information, and spooled file number
// for subsequent reference or manipulation by external processes.
//
// @return Complete spooled file information structure
///
dcl-pr getSplF extproc('CMDRUNPRT_getSplF') likeds(splf_t);
end-pr;

///
// Returns the maximum character width available for printed output.
// Determines the printing area width based on printer configuration
// and page layout settings, used for formatting and line wrapping
// calculations in test output formatting and report generation.
//
// @return Maximum number of characters per line for printed output
///
dcl-pr getPrtWidth int(10) extproc('CMDRUNPRT_getPrtWidth');
end-pr;

///
// Initializes and opens the printer file for test output generation.
// Establishes the printer file connection and sets up the spooled file
// environment using the test program name for identification and
// organization of test output. Prepares the printing subsystem.
//
// @param testpgmnm - Test program name to identify the print output
///
dcl-pr opnPrt extproc('CMDRUNPRT_opnPrt');
  testpgmnm like(object_t.nm) const;
end-pr;

///
// Outputs a single formatted line to the printer file.
// Writes the specified text line to the current spooled file output.
// Lines exceeding the maximum width are truncated without warning
// to fit within the available printing area defined by the printer configuration.
//
// @param line - Text line to write to the printer output (max 80 characters)
///
dcl-pr prtLine extproc('CMDRUNPRT_prtLine');
  line char(80) const;
end-pr;
