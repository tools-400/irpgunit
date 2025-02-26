**FREE
// ==========================================================================
//  iRPGUnit - Extract Procedures From a SRVPGM.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// Count the number of procedures in a ProcList.
dcl-pr cntProc int(10) extproc('EXTPRC_cntProc');
  procList        likeds(procList_t) const;
end-pr;

dcl-pr loadProcList likeds(procList_t) extproc('EXTPRC_loadProcList');
  srvPgm          likeds(object_t) const;
end-pr;

// Adapt a ProcList (i.e., a list of procedures in a user space) to the ProcNmList inte
// It is just an adapter. The underlying data is not copied.
dcl-pr getProcNmList likeds(procNmList_t) extproc('EXTPRC_getProcNmList');
  procList        likeds(procList_t);
end-pr;

dcl-pr getProcNm like(procNm_t) extproc('EXTPRC_getProcNm');
  procList        likeds(procList_t) const;
end-pr;

dcl-pr goToNextProc extproc('EXTPRC_goToNextProc');
  // [Update] Procedure list.
  procList        likeds(procList_t);
end-pr;


//----------------------------------------------------------------------
//   Templates
//----------------------------------------------------------------------

dcl-ds procList_t qualified template;
  hdr             pointer;
  current         pointer;
end-ds;

