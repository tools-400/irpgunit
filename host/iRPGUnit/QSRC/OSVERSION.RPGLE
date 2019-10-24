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
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain;
/include qinclude,H_SPEC

/define COPYRIGHT_DSPEC
/include qinclude,OSVERSION
/include qinclude,SYSTEMAPI
/include qinclude,ERRORCODE

dcl-proc OS_getVersion export;
  dcl-pi *n char(6) end-pi;

  dcl-ds data likeds(prdr0100_t);
  dcl-ds productInfo likeds(prdi0100_t);
  dcl-ds errorCode likeds(errorCode_t);

  productInfo.productId = '*OPSYS';
  productInfo.releaseLvl = '*CUR';
  productInfo.productOpt = '0000';
  productInfo.loadId = '*CODE';

  clear errorCode;

  api_retrieveProductInfo(
     data : %size(data) : 'PRDR0100' : productInfo : errorCode);
  return data.releaseLvl;
end-proc;

