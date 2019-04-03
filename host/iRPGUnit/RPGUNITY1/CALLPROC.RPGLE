      //
      // Prototypes for CALLPROC.
      //

       // Activate a service program and returns the activation mark.
     D activateSrvPgm  pr            10i 0 extproc('activateSrvPgm')
     D  srvPgm                             value likeds(Object_t)

       // Calls a procedure, using its associated pointer.
     D callProcByPtr   pr                  extproc('callProcByPtr')
     D  procPtr                        *   const procptr

       // Resolve a procedure.
       // Fill the procedure pointer, given its name and activation marker.
     D rslvProc        pr                  extproc('rslvProc')
     D  proc                               likeds(Proc_t)
     D  actMark                            const like(ActMark_t)

