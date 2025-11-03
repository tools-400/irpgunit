**free
      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. assertEqual().
      //  FAILURE. 6 test cases, 6 assertions, 6 failures, 0 error.
      // ==========================================================================
      //  Copyright (c) 2013-2025 iRPGUnit Project Team
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

ctl-opt datfmt(*iso) timfmt(*iso);
ctl-opt option(*srcstmt);
ctl-opt nomain;

/include qinclude,TESTCASE

dcl-proc test_assertEqual_date export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(d'2025-11-01': d'2025-11-15');

end-proc;

dcl-proc test_assertEqual_float export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(+67,89E+0003: -1234.9E0);

end-proc;

dcl-proc test_assertEqual_numeric export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(123,4: 567,8);

end-proc;

dcl-proc test_assertEqual_string export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('Dagobert Duck': 'Donald Duck');

end-proc;

/include qinclude,TESTCASE

dcl-proc test_assertEqual_time export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(t'13.14.07': t'23.47.51');

end-proc;

dcl-proc test_assertEqual_timestamp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(z'2025-11-01-13.14.07.000000': z'2025-11-01-23.47.51');

end-proc;

