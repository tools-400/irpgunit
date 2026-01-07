**free
      // ==========================================================================
      //  iRPGUnit Dev. of RDP Plugin. assertEqual().
      //  ERROR. 8 test cases, 12 assertions, 6 failures, 1 error.
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

dcl-proc test_assertEquals_success export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(d'2025-11-01': d'2025-11-01': 'Dates must match');
  assertEqual(+67,89E+0003: +67,89E+0003: 'Float values must match');
  assertEqual(123,4: 123,4: 'Numeric values must match');
  assertEqual('Donald': 'Donald': 'Names must match');
  assertEqual(t'13.14.07': t'13.14.07': 'Time values must match');
  assertEqual(z'2025-11-01-13.14.07.000000'
              : z'2025-11-01-13.14.07.000000': 'Timestamp values must match');

end-proc;

dcl-proc test_assertEqual_date export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(d'2025-11-01': d'2025-11-15': 'Dates must match');

end-proc;

dcl-proc test_assertEqual_float export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(+67,89E+0003: -1234.9E0: 'Float values must match');

end-proc;

dcl-proc test_assertEqual_numeric export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(123,4: 567,8: 'Numeric values must match');

end-proc;

dcl-proc test_assertEqual_string export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('Dagobert Duck': 'Donald Duck': 'String values must match');

end-proc;

/include qinclude,TESTCASE

dcl-proc test_assertEqual_time export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(t'13.14.07': t'23.47.51': 'Time values must match');

end-proc;

dcl-proc test_assertEqual_timestamp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual(z'2025-11-01-13.14.07.000000': z'2025-11-01-23.47.51': 'Timestamp values must match');

end-proc;

dcl-proc testRuntimeError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s result int(10);
  dcl-s a1 int(10);
  dcl-s zero int(10);

  // Produce a runtime error: division by zero
  result = a1 / zero;

end-proc;

