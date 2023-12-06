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
     D cntProc         pr            10i 0 extproc('EXTPRC_cntProc')
     D  procList                           const likeds(ProcList_t)

     D loadProcList    pr                  likeds(ProcList_t)
     D                                     extproc('EXTPRC_loadProcList')
     D  srvPgm                             const likeds(Object_t)

       // Adapt a ProcList (i.e., a list of procedures in a user space) to the ProcNmList inte
       // It is just an adapter. The underlying data is not copied.
     D getProcNmList   pr                  likeds(ProcNmList_t)
     D                                     extproc('EXTPRC_getProcNmList')
     D  procList                           likeds(ProcList_t)

     D getProcNm       pr                  like(ProcNm_t)
     D                                     extproc('EXTPRC_getProcNm')
     D  procList                           const likeds(ProcList_t)

     D goToNextProc    pr                  extproc('EXTPRC_goToNextProc')
        // [Update] Procedure list.
     D  procList                           likeds(ProcList_t)


       //----------------------------------------------------------------------
       //   Templates
       //----------------------------------------------------------------------

     D ProcList_t      ds                  qualified based(template)
     D  hdr                            *
     D  current                        *

