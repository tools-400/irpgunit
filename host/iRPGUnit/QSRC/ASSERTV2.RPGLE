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
  dcl-s condition ind;
  dcl-s dataTypeExpected like(dataType_t);
  dcl-s dataTypeActual like(dataType_t);
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

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
    dataTypeExpected = DT_IND;
  else;
    len_expected = %len(expected);
    dataTypeExpected = DT_STRING;
  endif;

  if (%len(actual) > 1 and
      (actual = *on or actual = *off) and
       %len(actual) = %len(actual: *max));
    len_actual = 1; // Assuming it's an indicator
    dataTypeActual = DT_IND;
  else;
    len_actual = %len(actual);
    dataTypeActual = DT_STRING;
  endif;
  // ---------------------------------------------------

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(leftStr(expected: len_expected)) + ','
        + ' but was ' + addQuotes(leftStr(actual: len_actual)) + '.';
  endif;

  if (dataTypeExpected = DT_IND);
    logExpected = getLogValue(toInd(leftStr(expected: len_expected)): dataTypeExpected: %proc());
  else;
    logExpected = getLogValue(leftStr(expected: len_expected): dataTypeExpected: %proc());
  endif;

  if (dataTypeActual = DT_IND);
    logActual = getLogValue(toInd(leftStr(actual: len_expected)): dataTypeActual: %proc());
  else;
    logActual = getLogValue(leftStr(actual: len_expected): dataTypeActual: %proc());
  endif;

  condition = leftStr(expected: len_expected) = leftStr(actual: len_actual);
  doAssert(condition: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(formatNumeric(expected)) + ','
        + ' but was ' + addQuotes(formatNumeric(actual)) + '.';
  endif;

  logExpected = getLogValue(%char(expected): DT_NUMERIC: %proc());
  logActual = getLogValue(%char(actual): DT_NUMERIC: %proc());

  doAssert(expected = actual: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%char(expected)) + ','
        + ' but was ' + addQuotes(%char(actual)) + '.';
  endif;

  logExpected = getLogValue(%char(expected): DT_FLOAT: %proc());
  logActual = getLogValue(%char(actual): DT_FLOAT: %proc());

  doAssert(expected = actual: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%char(expected)) + ','
        + ' but was ' + addQuotes(%char(actual)) + '.';
  endif;

  logExpected = getLogValue(%char(expected: *iso): DT_DATE: %proc());
  logActual = getLogValue(%char(actual: *iso): DT_DATE: %proc());

  doAssert(expected = actual: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%char(expected)) + ','
        + ' but was ' + addQuotes(%char(actual)) + '.';
  endif;

  logExpected = getLogValue(%char(expected: *iso): DT_TIME: %proc());
  logActual = getLogValue(%char(actual: *iso): DT_TIME: %proc());

  doAssert(expected = actual: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual   likeds(logValue_t) inz;

  if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
    msg = message;
  else;
    msg = msg
        + 'Expected ' + addQuotes(%char(expected)) + ','
        + ' but was ' + addQuotes(%char(actual)) + '.';
  endif;

  logExpected = getLogValue(%char(expected: *iso): DT_TIMESTAMP: %proc());
  logActual = getLogValue(%char(actual: *iso): DT_TIMESTAMP: %proc());

  doAssert(expected = actual: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

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
    pExpected  pointer const;
    pActual    pointer const;
    matcher    pointer(*proc) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  dcl-s pMatcherCallback pointer(*proc);
  dcl-pr matcherCallback ind extproc(pMatcherCallback);
    pExpected    pointer const;
    pActual      pointer const;
    message      like(msgText_t);
    logExpected  like(logValue_t.value);
    logActual    like(logValue_t.value);
  end-pr;

  dcl-s logExpectedValue like(logValue_t.value);
  dcl-s logActualValue like(logValue_t.value);

  dcl-s msg like(msgText_t);
  dcl-ds logExpected likeds(logValue_t) inz;
  dcl-ds logActual likeds(logValue_t) inz;
  dcl-s matcherMessage like(msgText_t);
  dcl-s matcherResult ind;

  pMatcherCallback = matcher;
  matcherResult = matcherCallback(pExpected: pActual
                                  : matcherMessage: logExpectedValue: logActualValue);
  if (matcherMessage <> '');
    msg = matcherMessage;
  else;
    if (%parms() >= %parmnum(message) and %addr(message) <> *NULL);
      msg = message;
    else;
      msg = NO_MSG_TEXT;
    endif;
  endif;

  logExpected = getLogValue(logExpectedValue: DT_USER_DEFINED: %proc());
  logActual = getLogValue(logActualValue: DT_USER_DEFINED: %proc());

  doAssert(matcherResult: logExpected: logActual: msg: ONE_CALL_STK_LVL_ABOVE: %proc());

end-proc;

