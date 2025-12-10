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
  logExpected  likeds(logValue_t) const;
  logActual    likeds(logValue_t) const;
  msgIfFalse   varchar(16384) options(*varsize) const;
  toCallStackE int(10) const;
  startProc    varchar(256) options(*varsize) const;
end-pr;

///
// Register the start of a program for testing purposes
//
// @param lib - Library name where the program resides
// @param pgm - Program name to register
///
dcl-pr registerStartPgm extproc('ASSERT_registerStartPgm');
  lib char(10) const;
  pgm char(10) const;
  isJunitStyle ind const;
end-pr;

///
// Returns *on if the exection is due to an runtime
// error, otherwise *off for a failed assertion.
///
dcl-pr isRuntimeError ind extproc('ASSERT_isRuntimeError');
end-pr;

///
// Get the internal assertion event. The actual instance can be one of:
//   - testSuccessEvent_t
//   - testFailureEvent_t
//   - runtimeErrorEvent_t
//
// @return internal assertion event
///
dcl-pr getAssertEventInternal likeds(abstractTestEvent_t) extproc('ASSERT_getAssertEventInternal');
end-pr;

///
// Resets the assertion error flag.
///
dcl-pr resetAssertionError extproc('ASSERT_resetAssertionError');
end-pr;


///
// Returns the 'expected' or 'actual' value shortend for
// logging in the plug-in, the Jenkins XML output and the
// printed test result log.
//
// @param value    - the 'expected' or 'actukl' value that is formatted for logging
// @param dataType - the data type of 'value'. The possible value are:
//                   DT_DATE, DT_FLOAT, DT_INT, DT_NUMERIC, DT_STRING,
//                   DT_TIME, DT_TIMESTAMP, DT_STRING, DT_USER_DEFINED
//
// @return the value formatted for logging
///
dcl-pr getLogValue likeds(logValue_t) extproc('ASSERT_getLogValue');
  value    like(assertString_t) options(*varsize) const;
  dataType like(dataType_t) const;
  assertProc like(assertProcNm_t) const;
  maxLength int(10) const options(*nopass); // for self-test
end-pr;

///
// Returns the literal of a boolean value (*on/*off).
//
// @param boolean - indicator value
//
// @return '*on' if 'boolean' is True, otherwise '*off'
///
dcl-pr toInd varchar(10) extproc('ASSERT_toInd');
  boolean  ind const;
end-pr;

///
// Saves the status of the ASSERT module.
//
// This procdure is used for sellf-tests. Saving the status
// is required for self-tests calling a procedure that affects
// the assertion status, e.g.:
//   - registerStartPgm()
//   - fail()
//   - doAssert()
//   - doFail()
//   - resetAssertionError()
//   - clrAssertFailEvt()
//   - clearAssertCounter()
///
dcl-pr saveAssertStatus extproc('ASSERT_saveAssertStatus');
end-pr;

///
// Restores the status of the ASSERT module.
//
// This procdure is used for sellf-tests.
///
dcl-pr restoreAssertStatus extproc('ASSERT_restoreAssertStatus');
end-pr;

///
// Returns the number of failures counted.
///
dcl-pr getFailureCounted int(10) extproc('ASSERT_getFailureCounted');
end-pr;

/include qinclude,TESTCASE
/include qinclude,TEMPLATES

/endif
