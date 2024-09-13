**free
// ==========================================================================
//  iRPGUnit - Assertion Facilities.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,ASSERTV2
/include qinclude,PGMMSG

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   GLOBAL CONSTANTS
//----------------------------------------------------------------------

dcl-c NO_MSG_TEXT '*N';

dcl-c START_PROC_ASSERT_EQUAL_STRING  'assertEqual_string';
// Constant disabled, because it is handled by: assertEqual_numeric
// dcl-c START_PROC_ASSERT_EQUAL_INTEGER 'assertEqual_integer';
dcl-c START_PROC_ASSERT_EQUAL_NUMERIC 'assertEqual_numeric';

//----------------------------------------------------------------------
//   TYPE TEMPLATE
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Assert equality between two alphanumeric variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_string export;
  dcl-pi *n opdesc;
    expected   like(assertString_t) const;
    actual     like(assertString_t) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t);

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + QUOTE + %trimr(expected) + QUOTE + ','
        + ' but was ' + QUOTE + %trimr(actual  ) + QUOTE + '.';
  endif;

  doAssert(expected = actual: msg
           : ONE_CALL_STK_LVL_ABOVE: START_PROC_ASSERT_EQUAL_STRING);

end-proc;

//----------------------------------------------------------------------
// Assert equality between two integer variables - V2.
// Procedure disabled, because it is handled by: assertEqual_numeric
//----------------------------------------------------------------------
//dcl-proc assertEqual_integer export;
//  dcl-pi *n opdesc;
//    expected   int(20) const;
//    actual     int(20) const;
//    message    like(msgText_t) options(*nopass: *omit) const;
//  end-pi;
//
//  dcl-s msg like(msgText_t);
//
//  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
//    msg = message;
//  else;
//    msg = msg
//        + 'Expected ' + QUOTE + %char(expected) + QUOTE + ','
//        + ' but was ' + QUOTE + %char(actual  ) + QUOTE + '.';
//  endif;
//
//  doAssert(expected = actual: msg
//           : ONE_CALL_STK_LVL_ABOVE: START_PROC_ASSERT_EQUAL_INTEGER);
//
//end-proc;
//end-proc;

//----------------------------------------------------------------------
// Assert equality between two numeric variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_numeric export;
  dcl-pi *n opdesc;
    expected   zoned(63: 20) const;
    actual     zoned(63: 20) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t);

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + QUOTE + %char(expected) + QUOTE + ','
        + ' but was ' + QUOTE + %char(actual  ) + QUOTE + '.';
  endif;

  doAssert(expected = actual: msg
           : ONE_CALL_STK_LVL_ABOVE: START_PROC_ASSERT_EQUAL_NUMERIC);

end-proc;

