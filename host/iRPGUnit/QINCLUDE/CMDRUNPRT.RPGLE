      // ==========================================================================
      //  iRPGUnit - Printing Facilities for CMDRUN.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Close the printer file.
     D clsPrt          pr                  extproc('CMDRUNPRT_clsPrt')

       // Returns the current spooled file.
     D getSplF         pr                  extproc('CMDRUNPRT_getSplF')
     D                                     likeds(SplF_t)

       // Return the printing area width (in characters).
     D getPrtWidth     pr            10i 0 extproc('CMDRUNPRT_getPrtWidth')

       // Open the printer file.
     D opnPrt          pr                  extproc('CMDRUNPRT_opnPrt')
     D  testPgmNm                          const like(Object_t.nm)

       // Print a line in the printer file.
       // If the line is too long, it will be truncated with no warning.
     D prtLine         pr                  extproc('CMDRUNPRT_prtLine')
     D  line                         80a   const

