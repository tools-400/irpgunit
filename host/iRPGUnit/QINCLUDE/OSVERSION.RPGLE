**FREE
// ==========================================================================
//  iRPGUnit - XML File Writer.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr OS_getVersion char(6) extproc('OSVERSION_OS_getVersion');
end-pr;

dcl-pr OS_getPTFLoadedStatus char(1) extproc('OSVERSION_OS_getPTFLoadedStatus');
  ptfID        char(7) const;
  productID    char(7) const;
  releaseLvl   char(6) const;
end-pr;

