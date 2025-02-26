**FREE
// ==========================================================================
//  iRPGUnit - Tag Test Service Program.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr tagTstSrvPgm extproc('TAGTST_tagTstSrvPgm');
  qsrvpgm         const likeds(object_t);
  qsrcfile        const likeds(object_t);
  srcMbr          char(10) const;
end-pr;

