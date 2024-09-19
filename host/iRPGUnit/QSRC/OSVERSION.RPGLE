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
/include qinclude,COPYRIGHT

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

dcl-proc OS_getPTFLoadedStatus export;
  dcl-pi *n char(1);
    ptfID        char(7) const;
    productID    char(7) const;
    releaseLvl   char(6) const;
  end-pi;

  dcl-ds PTF_inf   likeds(PTF_inf_t) inz(*likeds);
  dcl-ds ptfr0100  likeds(ptfr0100_t) inz(*likeds);
  dcl-ds errCode   likeds(errorCode_t) inz(*likeds);

  PTF_inf.ptfID      = ptfID;
  PTF_inf.productID  = productID;
  PTF_inf.releaseLvl = OS_getVersion();

  api_retrieveProgramTemporaryFixInfo(
    ptfr0100: %size(ptfr0100): PTF_inf: 'PTFR0100': errCode);
  if (errCode.bytAvl > 0);
     if (errCode.excID = 'CPF6602'); // Not found
       return PTF_LOADED_STATUS_NOT_LOADED;
     else;
       return '*';
     endif;
  endif;

  return ptfr0100.loadStat;

end-proc;
