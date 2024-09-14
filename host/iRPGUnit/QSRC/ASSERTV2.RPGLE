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
/include qinclude,STRING

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   GLOBAL CONSTANTS
//----------------------------------------------------------------------

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
        + 'Expected ' + addQuotes(%trimr(expected)) + ','
        + ' but was ' + addQuotes(%trimr(actual)) + '.';
  endif;

  doAssert(expected = actual: msg
           : ONE_CALL_STK_LVL_ABOVE: %proc());

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
//        + 'Expected ' + addQuotes(%char(expected)) + ','
//        + ' but was ' + addQuotes(%char(actual  )) + '.';
//  endif;
//
//  doAssert(expected = actual: msg
//           : ONE_CALL_STK_LVL_ABOVE: %proc());
//
//end-proc;

//----------------------------------------------------------------------
// Assert equality between two numeric variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_numeric export;
  dcl-pi *n opdesc;
    expected   zoned(63: 20) options(*exact) const;
    actual     zoned(63: 20) options(*exact) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t);

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(formatNumeric(expected)) + ','
        + ' but was ' + addQuotes(formatNumeric(actual)) + '.';
  endif;

  doAssert(expected = actual: msg
           : ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;

//----------------------------------------------------------------------
// Assert equality between two float variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_float export;
  dcl-pi *n opdesc;
    expected   float(8) options(*exact) const;
    actual     float(8) options(*exact) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t);

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%char(expected)) + ','
        + ' but was ' + addQuotes(%char(actual)) + '.';
  endif;

  doAssert(expected = actual: msg
           : ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;

//----------------------------------------------------------------------
// Assert equality using a matcher callback procedure - V2.
//----------------------------------------------------------------------
dcl-proc assertThat export;
  dcl-pi *n opdesc;
    expected   pointer const;
    actual     pointer const;
    matcher    pointer(*proc) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s pMatcherCallback pointer(*proc);
  dcl-pr matcherCallback ind extproc(pMatcherCallback);
    expected   pointer const;
    actual     pointer const;
    message    like(msgText_t);
  end-pr;

  dcl-s msg like(msgText_t);
  dcl-s matcherMessage like(msgText_t);
  dcl-s matcherResult ind;

  pMatcherCallback = matcher;
  matcherResult = matcherCallback(expected: actual: matcherMessage);
  if (matcherMessage <> '');
    msg = matcherMessage;
  else;
    if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
      msg = message;
    else;
      msg = NO_MSG_TEXT;
    endif;
  endif;

  doAssert(matcherResult: msg
           : ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;

