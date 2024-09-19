**free
// ==========================================================================
//  iRPGUnit - Assertion Facilities.
// ==========================================================================
//  Copyright (c) 2013-2024 iRPGUnit Project Team
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
    expected   like(assertString_t) options(*varsize) const;
    actual     like(assertString_t) options(*varsize) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s msg like(msgText_t);

  dcl-s len_expected int(10);
  dcl-s len_actual int(10);

  // --- Ugly hack for figurative constants *on/*off ---
  //     See:
  //     * https://www.ibm.com/docs/en/i/7.5?topic=constants-rules-figurative#rulfig
  //     * IBM Case TS017248434 (result: works as designed)
  if (%len(expected) > 1 and
      (expected = *on or expected = *off) and
       %len(expected) = %len(expected: *max));
    len_expected = 1; // Assuming it's an indicator
  else;
    len_expected = %len(expected);
  endif;

  if (%len(actual) > 1 and
      (actual = *on or actual = *off) and
       %len(actual) = %len(actual: *max));
    len_actual = 1; // Assuming it's an indicator
  else;
    len_actual = %len(actual);
  endif;
  // ---------------------------------------------------

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%trimr(%subst(expected: 1: len_expected))) + ','
        + ' but was ' + addQuotes(%trimr(%subst(actual: 1: len_actual))) + '.';
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
// Assert equality between two date variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_date export;
  dcl-pi *n opdesc;
    expected   date const;
    actual     date const;
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
// Assert equality between two time variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_time export;
  dcl-pi *n opdesc;
    expected   time const;
    actual     time const;
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
// Assert equality between two timestamp variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_timestamp export;
  dcl-pi *n opdesc;
    expected   timestamp(12) const;
    actual     timestamp(12) const;
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
// Assert equality between two indicator variables - V2.
//----------------------------------------------------------------------
//dcl-proc assertEqual_ind export;
//  dcl-pi *n opdesc;
//    expected   ind options(*exact) const;
//    actual     ind options(*exact) const;
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
//        + ' but was ' + addQuotes(%char(actual)) + '.';
//  endif;
//
//  doAssert(expected = actual: msg
//           : ONE_CALL_STK_LVL_ABOVE: %proc());
//
//end-proc;

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

