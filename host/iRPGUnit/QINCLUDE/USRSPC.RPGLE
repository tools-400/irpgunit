**FREE
/if not defined (IRPGUNIT_USRSPC)
/define IRPGUNIT_USRSPC
// ==========================================================================
//  iRPGUnit - User Space Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Creates a user space object and returns a pointer to its data area
//
// This procedure creates a new user space object in the specified library with
// the given description text. User spaces are IBM i objects that provide a way
// to store and retrieve data efficiently without using database files. The
// procedure returns a direct pointer to the user space data area for high-performance
// read and write operations.
//
// @param usrSpc - Qualified user space object to create
//                 Structure: library/object format specifying where to create the user space
//                 Library must exist and user must have *USE authority
//                 Object name must follow IBM i object naming conventions (up to 10 characters)
// @param text   - Descriptive text for the user space object (up to 50 characters)
//                 Appears in object descriptions and WRKOBJ displays
//                 Used for documentation and identification purposes
//                 Can be blank but descriptive text is recommended
//
// @return Pointer to the user space data area for direct memory access
//         Valid pointer if user space creation successful
//         Null pointer if creation fails or insufficient authority
//         Pointer remains valid until user space is deleted or job ends
///
dcl-pr crtUsrSpc pointer extproc('USRSPC_crtUsrSpc');
  usrSpc likeds(object_t) const;
  text   char(50) const;
end-pr;

/endif

