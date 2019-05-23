      // ==========================================================================
      //  iRPGUnit - Call a procedure in a SRVPGM.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Activate a service program and returns the activation mark.
     D activateSrvPgm  pr            10i 0 extproc('CALLPRC_activateSrvPgm')
     D  srvPgm                             value likeds(Object_t)

       // Calls a procedure, using its associated pointer.
     D callProcByPtr   pr                  extproc('CALLPRC_callProcByPtr')
     D  procPtr                        *   const procptr

       // Resolve a procedure.
       // Fill the procedure pointer, given its name and activation marker.
     D rslvProc        pr                  extproc('CALLPRC_rslvProc')
     D  proc                               likeds(Proc_t)
     D  actMark                            const like(ActMark_t)

