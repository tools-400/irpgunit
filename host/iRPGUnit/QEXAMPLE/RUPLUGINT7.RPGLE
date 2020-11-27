**free
      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. Produce Job Log.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      //    >>PRE-COMPILER<<
      //      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
      //                              SRCFILE(&SL/&SF) SRCMBR(&SM);
      //      >>IMPORTANT<<
      //        >>PARM<< COPTION(*SRCSTMT *EVENTF);
      //        >>PARM<< DBGVIEW(*LIST);
      //      >>END-IMPORTANT<<
      //      >>EXECUTE<<
      //    >>END-PRE-COMPILER<<
      // ==========================================================================

ctl-opt option(*srcstmt);
ctl-opt nomain;

/include qinclude,TESTCASE

dcl-proc Test_BadCall export;
   dcl-pr bad_pgm extpgm;
   end-pr;
   bad_pgm();
   assert (%status() = 0 : 'Expect status <> 0');
end-proc;
