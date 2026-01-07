**FREE
// ==========================================================================
//  iRPGUnit - ACPTSTT Unit Test Helper.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr chkAndCloSplF extproc('chkAndCloSplF');
end-pr;

dcl-pr cloSplf extproc('cloSplf');
end-pr;

dcl-pr opnSplf extproc('opnSplf');
  splfNm  char(10) value;
  usrData char(10) value;
end-pr;

dcl-pr splfLineStartsWith extproc('splfLineStartsWith');
  expString varchar(256) const;
end-pr;

dcl-pr splfContains extproc('splfContains');
  expString varchar(256) const;
end-pr;

dcl-pr splfSkipLine extproc('splfSkipLine');
end-pr;

dcl-pr dltSplfs int(10) extproc('dltSplfs');
  splfNm  char(10) value;
  usrData char(10) value;
end-pr;

