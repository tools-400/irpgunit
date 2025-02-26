**FREE
// ==========================================================================
//  iRPGUnit - Printing Facilities for CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// Close the printer file.
dcl-pr clsPrt extproc('CMDRUNPRT_clsPrt');
end-pr;

// Returns the current spooled file.
dcl-pr getSplF extproc('CMDRUNPRT_getSplF') likeds(splf_t);
end-pr;

// Return the printing area width (in characters).
dcl-pr getPrtWidth int(10) extproc('CMDRUNPRT_getPrtWidth');
end-pr;

// Open the printer file.
dcl-pr opnPrt extproc('CMDRUNPRT_opnPrt');
  testpgmnm       like(object_t.nm) const;
end-pr;

// Print a line in the printer file.
// If the line is too long, it will be truncated with no warning.
dcl-pr prtLine extproc('CMDRUNPRT_prtLine');
  line            char(80) const;
end-pr;

