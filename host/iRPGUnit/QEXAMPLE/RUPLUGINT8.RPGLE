**free
      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. All OK
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      //    >>PRE-COMPILER<<
      //      >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +
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

dcl-proc test_aEqual export;

  dcl-s actual varchar(50) inz('Donald Duck');

  aEqual('Duck': %subst(actual: 8: 4));

end-proc;

dcl-proc test_iEqual export;

  dcl-s actual int(10) inz(123);

  iEqual(123: actual);

end-proc;

dcl-proc test_nEqual export;

  dcl-s actual ind inz(*on);

  nEqual(*on: actual);

end-proc;

dcl-proc test_assert export;

  dcl-s actual varchar(50) inz('Donald Duck');

  assert('Duck' = %subst(actual: 8: 4): 'Value of ''actual'' must end with ''Duck''');

end-proc;

