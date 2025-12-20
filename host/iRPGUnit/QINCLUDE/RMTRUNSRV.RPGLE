**FREE
/if defined(IRPGUNIT_RMTRUNSRV)
/eof
/endif
/define IRPGUNIT_RMTRUNSRV
// ==========================================================================
//  iRPGUnit - Plug-in Adapter.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Fills the user space for reporting the test result to the RDi plug-in.
//
// @param userSpace       - Qualified name of the user space.
// @param testSuite       - Test suite that was executed.
// @param testSuiteName   - Qualified name oif the test suite service program.
// @param testSuiteResult - Test result.
// @param isJUnitStyle    - Specifies whether the test case fails on the first
//                          failed assertion. Fails on the first failed assertion
//                          if set to *on, otherwise continues.
///
dcl-pr fillUserSpace extproc('RMTRUNSRV_fillUserSpace');
  userSpace       likeds(object_t ) const;
  testSuite       likeds(testSuite_t) const;
  testSuiteName   likeds(object_t) const;
  testSuiteResult likeds(testSuiteResult_t) const;
  isJUnitStyle    ind const;
end-pr;

