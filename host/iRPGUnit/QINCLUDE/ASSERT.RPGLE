**FREE
/if not defined (IRPGUNIT_ASSERT)
/define IRPGUNIT_ASSERT
// ==========================================================================
//  iRPGUnit - Assertion Facilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Performs the core assertion logic for all assertion types.
// Evaluates the given condition and triggers test failure handling
// if the condition is false. Captures call stack information for
// detailed error reporting and test case identification.
//
// @param condition    - Boolean condition to evaluate for assertion
// @param msgIfFalse   - Descriptive message to display when assertion fails
// @param toCallStackE - Call stack entry level for error context identification
// @param startProc    - Name of the procedure that initiated the assertion
///
dcl-pr doAssert extproc('ASSERT_doAssert');
  condition    ind const;
  msgIfFalse   varchar(16384) options(*varsize) const;
  toCallStackE int(10) const;
  startProc    varchar(256) options(*varsize) const;
end-pr;

/include qinclude,TESTCASE

/endif
