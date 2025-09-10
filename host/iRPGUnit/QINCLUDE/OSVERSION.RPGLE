**FREE
// ==========================================================================
//  iRPGUnit - OS Version Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Retrieves the current operating system version
//
// This procedure queries the system to determine the current IBM i operating
// system version and release level. The version information is essential for
// determining system capabilities and API availability.
//
// @return Operating system version in VxRxMx format (e.g., 'V7R4M0', 'V7R5M0')
//         where V=Version, R=Release, M=Modification level
///
dcl-pr OS_getVersion char(6) extproc('OSVERSION_OS_getVersion');
end-pr;

///
// Gets the loaded status of a specified PTF (Program Temporary Fix)
//
// Queries the system to determine the installation and application status of
// a specific PTF. This is crucial for determining if required fixes are
// installed before using certain system features or APIs.
//
// @param ptfID      - Program Temporary Fix identifier (7 characters, e.g., 'SI12345')
// @param productID  - Product identifier for the PTF (7 characters, e.g., '5770SS1')
// @param releaseLvl - Release level in VxRxMx format (optional parameter)
//                     If not specified, uses current system release
//
// @return PTF loaded status as character:
//         '0' = PTF is not loaded on the system
//         '1' = PTF is loaded but not applied (temporary)
//         '2' = PTF is applied (permanent installation)
//         ' ' = PTF status could not be determined or error occurred
///
dcl-pr OS_getPTFLoadedStatus char(1) extproc('OSVERSION_OS_getPTFLoadedStatus');
  ptfID      char(7) const;
  productID  char(7) const;
  releaseLvl char(6) options(*nopass) const;
end-pr;

