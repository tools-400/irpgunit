**FREE
// ==========================================================================
//  iRPGUnit - Call a procedure in a SRVPGM.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Activates a service program and establishes program linkage.
// Loads the specified service program into memory and returns an
// activation mark that can be used to resolve procedure addresses
// within the service program.
//
// @param srvPgm - Service program object containing procedures to activate
//
// @return Activation mark identifier for subsequent procedure resolution
///
dcl-pr activateSrvPgm int(10) extproc('CALLPRC_activateSrvPgm');
  srvPgm likeds(object_t) value;
end-pr;

///
// Executes a procedure using its resolved procedure pointer.
// Provides dynamic procedure invocation capability by calling
// the procedure at the specified memory address. Used for
// test case execution and framework procedure calls.
//
// @param procptr - Procedure pointer containing the address of procedure to execute
///
dcl-pr callProcByPtr extproc('CALLPRC_callProcByPtr');
  procptr pointer(*proc) const;
end-pr;

///
// Resolves a procedure name to its memory address within an activated service program.
// Uses the activation mark to locate and populate the procedure pointer
// for the named procedure, enabling dynamic procedure calls.
//
// @param proc    - Procedure structure containing name and pointer to be populated
// @param actMark - Activation marker from previously activated service program
///
dcl-pr rslvProc extproc('CALLPRC_rslvProc');
  proc    likeds(proc_t);
  actMark like(actMark_t) const;
end-pr;
