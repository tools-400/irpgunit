**FREE
// ==========================================================================
//  iRPGUnit - Call a procedure in a SRVPGM.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// Activate a service program and returns the activation mark.
dcl-pr activateSrvPgm  int(10) extproc('CALLPRC_activateSrvPgm');
  srvPgm          value likeds(object_t);
end-pr;

// Calls a procedure, using its associated pointer.
dcl-pr callProcByPtr extproc('CALLPRC_callProcByPtr');
  procptr         pointer(*proc) const;
end-pr;

// Resolve a procedure.
// Fill the procedure pointer, given its name and activation marker.
dcl-pr rslvProc extproc('CALLPRC_rslvProc');
  proc            likeds(proc_t);
  actMark         const like(actMark_t);
end-pr;

