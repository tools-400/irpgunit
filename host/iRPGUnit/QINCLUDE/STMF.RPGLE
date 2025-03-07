**FREE
/if defined(IRPGUNIT_STMF)
/eof
/endif
/define IRPGUNIT_STMF
// ==========================================================================
//  iRPGunit - Stream File Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

/include qinclude,TEMPLATES

///
//  Returns the current directory.
//
//  @return Current directory.
///
dcl-pr Stmf_getCurrentDirectory like(ifsStmf_t) extproc('STMF_Stmf_getCurrentDirectory');
end-pr;

///
//  Resolves the path of a given stream file.
//
//  @param Stream file path.
///
dcl-pr Stmf_resolvePath like(ifsStmf_t) extproc('STMF_Stmf_resolvePath');
  stmf   like(ifsStmf_t) const;
end-pr;

///
//  Tests whether the specified stream file or directory exists.
//
//  @param Stream file path.
///
dcl-pr Stmf_exists ind extproc('STMF_Stmf_exists');
  stmf   like(ifsStmf_t) const;
end-pr;

///
//  Returns the date and time the data of the stream file was
//  last changed.
//
//  @param Stream file path.
///
dcl-pr Stmf_getLastChgDate timestamp extproc('STMF_Stmf_getLastChgDate');
  stmf   like(ifsStmf_t) const;
end-pr;

///
//  Returns the type (file extension) of the stream file.
//
//  @param Stream file path.
///
dcl-pr Stmf_getType varchar(10) extproc('STMF_Stmf_getType');
  stmf   like(ifsStmf_t) const;
end-pr;

