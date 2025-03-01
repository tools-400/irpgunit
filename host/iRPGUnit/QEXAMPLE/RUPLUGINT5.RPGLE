**FREE
// ==========================================================================
//  iRPGUnit Dev. of RDP Plugin. Very long messages.
//  FAILURE. 2 test cases, 2 assertions, 2 failures, 0 error.
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

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTCASE

// ============================================================
//  Set up test suite. Executed once per RUCALLTST.
// ============================================================
dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

end-proc;

// ============================================================
//  Set up test suite. Executed once per RUCALLTST.
// ============================================================
dcl-proc testLongFailureAEqual export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s url1 varchar(200);
  dcl-s url2 varchar(200);

  url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
          004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
          roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
          rview';

  url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
          c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
          VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
          rview/joe.street';

  aEqual(url1: url2: 'URL');

end-proc;

// ============================================================
//  Set up test suite. Executed once per RUCALLTST.
// ============================================================
dcl-proc testLongFailureAssert export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s url1 varchar(200);
  dcl-s url2 varchar(200);

  url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
          004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
          roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
          rview';

  url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
          c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
          VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
          rview/joe.street';

  assert(url1 = url2: 'URL: Expected"' + url1 + '" but was "' + url2 + '"');

end-proc;

