      //
      // Prototypes for EXTPRC.
      //

       // Count the number of procedures in a ProcList.
     D cntProc         pr            10i 0 extproc('cntProc')
     D  procList                           const likeds(ProcList_t)

     D loadProcList    pr                  likeds(ProcList_t)
     D                                     extproc('loadProcList')
     D  srvPgm                             const likeds(Object_t)

       // Adapt a ProcList (i.e., a list of procedures in a user space) to the ProcNmList inte
       // It is just an adapter. The underlying data is not copied.
     D getProcNmList   pr                  likeds(ProcNmList_t)
     D                                     extproc('getProcNmList')
     D  procList                           likeds(ProcList_t)

     D getProcNm       pr                  like(ProcNm_t)
     D                                     extproc('getProcNm')
     D  procList                           const likeds(ProcList_t)

     D goToNextProc    pr                  extproc('goToNextProc')
        // [Update] Procedure list.
     D  procList                           likeds(ProcList_t)


       //----------------------------------------------------------------------
       //   Templates
       //----------------------------------------------------------------------

     D ProcList_t      ds                  qualified based(template)
     D  hdr                            *
     D  current                        *

