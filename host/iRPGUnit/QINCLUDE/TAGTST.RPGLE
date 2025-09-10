**FREE
// ==========================================================================
//  iRPGUnit - Tag Test Service Program.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Tags a service program with test procedure metadata for iRPGUnit testing
//
// This procedure associates test procedure metadata with a service program object,
// enabling the iRPGUnit framework to identify and execute test procedures within
// the service program. The tagging process stores information about the source
// location of test procedures, making it possible for test runners to locate and
// invoke test methods dynamically.
//
// @param qsrvpgm  - Qualified service program object to tag with test metadata
//                   Structure: library/object format identifying the target service program
//                   Must be a valid *SRVPGM object that exports test procedures
//                   Service program should contain procedures following iRPGUnit naming conventions
// @param qsrcfile - Qualified source file containing the test procedure source code
//                   Structure: library/file format identifying the source file
//                   Must be a valid source physical file containing RPGLE members
//                   Used for source location tracking and test discovery
// @param srcMbr   - Source member name containing the test procedures
//                   Member name within the specified source file (up to 10 characters)
//                   Must exist within qsrcfile and contain valid iRPGUnit test procedures
//                   Used for precise source location identification
// @param srcStmf  - Stream file path containing test procedure source code (alternative source)
//                   IFS path to source file containing test procedures
//                   Can be used instead of or in addition to source member
//                   Supports modern development workflows using IFS-based source
///
dcl-pr tagTstSrvPgm extproc('TAGTST_tagTstSrvPgm');
  qsrvpgm  likeds(object_t) const;
  qsrcfile likeds(object_t) const;
  srcMbr   like(srcMbr_t.mbr) const;
  srcStmf  like(ifsStmf_t) const;
end-pr;


