**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test ASSERT.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------
dcl-c FAILURE_MESSAGE 'Failure message';

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

dcl-proc testClearAssertFailEvent export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(assertFailEvt_t) inz;
  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t) inz;

  clrAssertFailEvt();

  assertFailEvt = getAssertFailEvt();
  assertFailEvtLong = getAssertFailEvtLong();

  aEqual(EMPTY_ASSERT_FAIL_EVT: assertFailEvt);
  aEqual(EMPTY_ASSERT_FAIL_EVT_LONG: assertFailEvtLong);

end-proc;


dcl-proc testFailInsideMonitorBlock export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s excpWasCaught   ind inz(*off);
  dcl-s success         ind inz(*off);

  dcl-ds msgInfo likeds(MsgInfo_t);

  success = CMDRUNSRV_runProc(); // statement in error

  select;
  when success;
    // Success.
    msgInfo = getMonitoredMessage(*off);
    assert( msgInfo.txt = FAILURE_MESSAGE );
  when excpWasCaught;
    fail('The failure exception should not be caught by the monitor block');
  other;
    fail('fail() should have raised an exception');
  endsl;

end-proc;


dcl-proc testTwoAndTwoEqualsFour export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  iEqual(4: 2 + 2);

  // Controls.

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

end-proc;


dcl-proc testTwoAndTwoIsNotEqualToFive export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s excpWasSeen ind;
  dcl-ds assertFailEvt likeds(AssertFailEvt_t);


  // Execution.

  monitor;
    iEqual(5: 2 + 2); // statement in error
    excpWasSeen = *off;
  on-error;
    excpWasSeen = *on;
  endmon;

  // Controls.

  assertFailEvt = getAssertFailEvt();

  assert(excpWasSeen: 'iEqual(5: 2 + 2) should have raised an error message.');

  aEqual('Expected 5, but was 4.': assertFailEvt.msg);

  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm);
  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qMod.nm);
  aEqual('testTwoAndTwoIsNotEqualToFive': assertFailEvt.callStk.Entry(1).qStmt.procNm);

  monitor;
    aEqual('113': assertFailEvt.callStk.Entry(1).qStmt.specNb);  // IFS Compile
  on-error;
    aEqual('11300': assertFailEvt.callStk.Entry(1).qStmt.specNb);  // QSYS Compile
  endmon;

end-proc;


dcl-proc testHelloEqualsHello export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  aEqual( 'Hello' : 'Hello' );

  // Control.

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

end-proc;


dcl-proc testGoodByeIsNotHello export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s excpWasSeen ind;
  dcl-ds assertFailEvt likeds(AssertFailEvt_t);


  // Execution.

  monitor;
    aEqual('Hello': 'Good bye'); // statement in error
    excpWasSeen = *off;
  on-error;
    excpWasSeen = *on;
  endmon;

  // Controls.

  assertFailEvt = getAssertFailEvt();

  assert(excpWasSeen: 'aEqual( Hello : Good bye ) should have raised an error message.');

  aEqual('Expected ''Hello'', but was ''Good bye''.': assertFailEvt.msg);
  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm);
  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qMod.nm);
  aEqual('testGoodByeIsNotHello': assertFailEvt.callStk.Entry(1).qStmt.procNm);

  monitor;
    aEqual('168'  : assertFailEvt.callStk.Entry(1).qStmt.specNb); // IFS Compile
  on-error;
    aEqual('16800': assertFailEvt.callStk.Entry(1).qStmt.specNb); // QSYS Compile
  endmon;

end-proc;


dcl-proc testAssertCount export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s assertCallCntAtBeg int(10);
  dcl-s assertCallCnt int(10) Dim(4);

  // Setup.

  assertCallCntAtBeg = getAssertCalled();

  // Execution.

  assert( *on: *blank );
  assertCallCnt(1) = getAssertCalled();

  iEqual( 4: 2+2 );
  assertCallCnt(2) = getAssertCalled();

  aEqual( 'Hello': 'Hello' );
  assertCallCnt(3) = getAssertCalled();

  callp(e) assert( *off : *blank );
  assertCallCnt(4) = getAssertCalled();

  // Controls.

  iEqual(assertCallCntAtBeg + 1: assertCallCnt(1));
  iEqual(assertCallCntAtBeg + 2: assertCallCnt(2));
  iEqual(assertCallCntAtBeg + 3: assertCallCnt(3));
  iEqual(assertCallCntAtBeg + 4: assertCallCnt(4));

end-proc;


dcl-proc testAssertWithSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  assert( *on : 'Should not raise an error' );

  // Controls.

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

end-proc;


dcl-proc testAssertWithFailure export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);


  // Execution.

  monitor;
    assert(*off: 'Failure message.'); // statement in error
    fail('assert( *off : ...) should have raised an error.');
  on-error;
     // Success. Failure exception was seen.
  endmon;

  // Controls.

  assertFailEvt = getAssertFailEvt();

  aEqual('Failure message.': assertFailEvt.msg);

  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qPgm.nm);
  aEqual('ASSERTT': assertFailEvt.callStk.Entry(1).qStmt.qMod.nm);
  aEqual('testAssertWithFailure': assertFailEvt.callStk.Entry(1).qStmt.procNm);

  monitor;
    aEqual('256'  : assertFailEvt.callStk.Entry(1).qStmt.specNb); // IFS Compile
  on-error;
    aEqual('25600': assertFailEvt.callStk.Entry(1).qStmt.specNb); // QSYS Compile
  endmon;

end-proc;


dcl-proc testBigIntegerEquality export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // 0000000001111111111222222222233
  // 1234567890123456789012345678901
  iEqual( 9999999999999999999999999999999 :
          9999999999999999999999999999999 );

  // Control.

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

end-proc;


dcl-proc testAssertClear export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s assertCallCnt int(10);

  // Setup.

  assertCallCnt = getAssertCalled();

  // Execution.

  assert(*on: *blank);
  iEqual(4: 2+2);
  aEqual('Hello': 'Hello');
  callp(e) assert(*off: *blank);

  // Controls.

  iEqual(assertCallCnt + 4: getAssertCalled());
  clearAssertCounter();
  iEqual(0: getAssertCalled());

end-proc;


dcl-proc testGetLogValue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c MAX_LENGTH 20;
  dcl-c value_string_short 'The quick brown fox';
  dcl-c value_string_long 'The quick brown fox jumps over the lazy dog';

  dcl-s logValueExpected like(logValue_t.value);

  dcl-ds logValue likeds(logValue_t);

  // String Short
  logValueExpected = value_string_short;
  logValue = getLogValue(value_string_short: DT_STRING: %proc(): MAX_LENGTH);
  assertEqual(logValueExpected: logValue.value);
  assertEqual(DT_STRING: logValue.type);
  assertEqual('0': logValue.isTruncated);

  // String Long: 'value   ...   value'
  logValueExpected = 'The quic....lazy dog';
  logValue = getLogValue(value_string_long: DT_STRING: %proc(): MAX_LENGTH);
  assertEqual(logValueExpected: logValue.value);
  assertEqual(DT_STRING: logValue.type);
  assertEqual('1': logValue.isTruncated);

end-proc;


dcl-proc testToInd export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('*on': toInd(*on));
  assertEqual('*off': toInd(*off));

end-proc;

dcl-proc testGetAssertFailEvt export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(assertFailEvt_t);
  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  dcl-s url1 varchar(200);
  dcl-s url2 varchar(200);
  dcl-s expectedMsg varchar(500);

  // Setup.

  url1 = 'https://portal.azure.com/#resource/subscriptions/07ac1a17-d+
          004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDEVTR01/p+
          roviders/Microsoft.Compute/virtualMachines/VM-AXDEVTR01/ove+
          rview';

  url2 = 'https://foobaa.portal.azure.com/#resource/subscriptions/07a+
          c1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/RG-VM-AXDE+
          VTR01/providers/Microsoft.Compute/virtualMachines/VM-AXDEVT+
          rview/joe.street';

  expectedMsg =
         'URL: Expected ''https://portal.azure.com/#resource/subscrip+
          tions/07ac1a17-d004-4d62-8d1b-0e2ec9809770/resourceGroups/R+
          G-VM-AXDEVTR01/providers/Microsoft.Compute/virtualMachines/+
          VM-AXDEVTR01/overview'', but was ''https://foobaa.portal.az+
          ure.com/#resource/subscriptions/07ac1a17-d004-4d62-8d1b-0e2+
          ec9809770/resourceGroups/RG-VM-AXDEVTR01/providers/Microsof+
          t.Compute/virtualMachines/VM-AXDEVTrview/joe.street''.';

  // Execution.

  monitor;
    aEqual(url1: url2: 'URL');
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvt = getAssertFailEvt();
  assertFailEvtLong = getAssertFailEvtLong();

  assert(assertFailEvtLong.msg = expectedMsg: 'Message does not match the expected value');
  assert(assertFailEvt.msg = %subst(assertFailEvtLong.msg : 1: %len(assertFailEvt.msg))
         : 'Message texts must match');

end-proc;


//----------------------------------------------------------------------
//   Procedure that simulates the test case executor procedure
//   of module CMDRUNSRV. It must receive the message sent by fail().
//----------------------------------------------------------------------

dcl-proc CMDRUNSRV_runProc;
  dcl-pi *n ind extproc(*dclcase);
  end-pi;

  monitor;
    if (failInsideMonitorBlock());
      return *off; // Let the caller report the error.
    endif;
  on-error;
    // Success, exception seen.
    return *on;
  endmon;

end-proc;


dcl-proc failInsideMonitorBlock;
  dcl-pi *n ind extproc(*dclcase);
  end-pi;

  monitor;
    fail(FAILURE_MESSAGE);
    return *off;
  on-error;
    return *on; // Bad. Message was captured.
  endmon;

end-proc;


dcl-proc testAssertEqual_string export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  // Test 1-char string
  assertEqual('1': '1');

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  assertEqual('e': 'e');

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  monitor;
    assertEqual('e': 'u');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''e'', but was ''u''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : 'e': 'string': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : 'u': 'string': *off);
  endmon;

  // Test equality
  assertEqual(LABEL_EXPECTED: LABEL_EXPECTED);

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    assertEqual(LABEL_EXPECTED: 'unexpected value');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''expected'', but was ''unexpected value''.'
           : 'Error messages does not match expected value.');
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(LABEL_EXPECTED: 'unexpected value': 'String values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'String values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;


dcl-proc testAssertEqual_integer export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  // Test equality
  assertEqual(9223372036854775807: 9223372036854775807);

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    assertEqual(-9223372036854775807: -123);
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''-9223372036854775807'', but was ''-123''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '-9223372036854775807,00000000000000000000': 'numeric': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '-123,00000000000000000000': 'numeric': *off);
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(9223372036854775807: 123: 'Integer values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Integer values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;


dcl-proc testAssertEqual_numeric export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  dcl-s actualExact     packed(63:20) inz(*hival);
  dcl-s expectedExact   packed(63:20) inz(*hival);

  dcl-s actualLess      packed(15:5) inz(*hival);
  dcl-s expectedLess    packed(15:5) inz(*hival);

  dcl-s actualLike      like(assertNumeric_t) inz(*hival);
  dcl-s expectedLike    like(assertNumeric_t) inz(*hival);

  dcl-s actualShort     int(3) inz(*hival);
  dcl-s expectedShort   int(3) inz(*hival);

  dcl-s actualInt       int(5) inz(*hival);
  dcl-s expectedInt     int(5) inz(*hival);

  dcl-s actualLong      int(20) inz(*hival);
  dcl-s expectedLong    int(20) inz(*hival);

  dcl-s actualZoned     zoned(20) inz(*hival);
  dcl-s expectedZoned   zoned(20) inz(*hival);

  dcl-s actualSingle    float(4) inz(*hival);
  dcl-s expectedSingle  float(4) inz(*hival);

  dcl-s actualDouble    float(8) inz(*hival);
  dcl-s expectedDouble  float(8) inz(*hival);

  // Test compiler
  assertEqual(actualExact: expectedExact);
  assertEqual(actualLess: expectedLess);
  assertEqual(expectedLike: actualLike);
  assertEqual(expectedInt: actualInt);
  assertEqual(expectedShort: actualShort);
  assertEqual(expectedLong: actualLong);
  assertEqual(expectedZoned: actualZoned);

  assertEqual(expectedSingle: actualSingle);
  assertEqual(expectedDouble: actualDouble);

  // The following assertEqual() statement produces the following compiler error
  // message, if 'actualDecLoss' or 'expectedDecLoss' are defined with too many
  // positions or decimal positions, e.g.:
  //   63s15    too many positions before the comma
  //   63s25    too many positions after the comma
  //   "RNF3245: No prototype in the OVERLOAD keyword of ASSERTEQUAL matches the call."
  // See test case: ACPTSTT.testOptionsExact() and TESTPGM20
  //
  // assertEqual( expectedDecLoss : actualDecLoss );

  // Test equality
  assertEqual(1234567890,1234: 1234567890,1234);

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    assertEqual(-1234567890,123: -1234567890,122);
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''-1234567890,123'', but was ''-1234567890,122''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '-1234567890,12300000000000000000': 'numeric': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '-1234567890,12200000000000000000': 'numeric': *off);
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(1234567890,1234: 1234567890,1233: 'Numeric values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Numeric values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;


dcl-proc testAssertThat export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expected varchar(128);
  dcl-s actual   varchar(128);

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  // Test equality
  expected = 'Donald Duck';
  actual = expected;
  assertThat(%addr(expected): %addr(actual): %paddr(assertThatMatcherWithMsg));

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message but
  // with a message returned by the matcher
  monitor;
    expected = 'Donald Duck';
    actual = 'Dagobert Duck';
    assertThat(%addr(expected): %addr(actual): %paddr(assertThatMatcherWithMsg));
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Matcher: Actual values does not match expected value.'
           : 'Error messages does not match message from matcher.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : 'Donald Duck': 'user-defined': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : 'Dagobert Duck': 'user-defined': *off);
  endmon;

  // Test unequality without any assertion message
  monitor;
    expected = 'Donald Duck';
    actual = 'Dagobert Duck';
    assertThat(%addr(expected): %addr(actual): %paddr(assertThatMatcherWithoutMsg));
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = NO_VALUE);
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : 'Donald Duck': 'user-defined': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : 'Dagobert Duck': 'user-defined': *off);
  endmon;

  // Test unequality with error message
  monitor;
    expected = 'Donald Duck';
    actual = 'Dagobert Duck';
    assertThat(%addr(expected): %addr(actual): %paddr(assertThatMatcherWithoutMsg):
               'Matcher did not accept actual value.');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Matcher did not accept actual value.');
  endmon;

end-proc;

dcl-proc testAssertEqual_date export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  // Test equality
  assertEqual(D'2024-09-16': D'2024-09-16');

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    assertEqual(D'2024-09-16' : D'2002-01-02');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''2024-09-16'', but was ''2002-01-02''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '2024-09-16': 'date': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '2002-01-02': 'date': *off);
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(D'2024-09-16': D'2002-01-02': 'Date values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Date values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;

dcl-proc testAssertEqual_time export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong
         likeds(assertFailEvtLong_t);

  // Test equality
  assertEqual( T'11.22.33' : T'11.22.33' );

  // No exception message => OK.

  aEqual( EMPTY_ASSERT_FAIL_EVT : getAssertFailEvt() );

  // Test unequality without assertion message
  monitor;
    assertEqual(T'11.22.33': T'22.33.44');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''11.22.33'', but was ''22.33.44''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '11.22.33': 'time': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '22.33.44': 'time': *off);
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(T'11.22.33': T'22.33.44': 'Time values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Time values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;

dcl-proc testAssertEqual_timestamp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);

  // Test equality
  assertEqual(Z'2024-09-16-11.22.33.123456789012': Z'2024-09-16-11.22.33.123456789012');

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    assertEqual(Z'2024-09-16-11.22.33.123456789012': Z'2023-01-16-22.33.44.654321789012');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg =
           'Expected ''2024-09-16-11.22.33.123456789012'', but was ' +
           '''2023-01-16-22.33.44.654321789012''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '2024-09-16-11.22.33.123456789012': 'timestamp': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '2023-01-16-22.33.44.654321789012': 'timestamp': *off);
  endmon;

  // Test unequality with assertion message
  monitor;
    assertEqual(Z'2024-09-16-11.22.33.123456789012': Z'2023-01-16-22.33.44.654321789012':
                'Timestamp values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Timestamp values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;

dcl-proc testAssertEqual_ind export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvtLong likeds(assertFailEvtLong_t);
  dcl-s ind1 ind inz(*on);
  dcl-s ind2 ind inz(*on);

  // Test indicator figurative constant.
  monitor;
    assertEqual(*on: *off);
    fail('Expected the asssertion to fail.');
  on-error;
    // Does not yet work. Opened IBM support case:
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''1'', but was ''0''.'
           : 'Error messages does not match expected value.');
    verifyLogValue(LABEL_EXPECTED: assertFailEvtLong.logExpected
                   : '*on': 'indicator': *off);
    verifyLogValue(LABEL_ACTUAL: assertFailEvtLong.logActual
                   : '*off': 'indicator': *off);
  endmon;

  // Test equality
  ind2 = *on;
  ind2 = *on;
  assertEqual(ind1: ind2);

  // No exception message => OK.

  aEqual(EMPTY_ASSERT_FAIL_EVT: getAssertFailEvt());

  // Test unequality without assertion message
  monitor;
    ind2 = *on;
    ind2 = *off;
    assertEqual(ind1: ind2);
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Expected ''1'', but was ''0''.'
           : 'Error messages does not match expected value.');
  endmon;

  // Test unequality with assertion message
  monitor;
    ind2 = *on;
    ind2 = *off;
    assertEqual(ind1: ind2: 'Indicator values do not match');
    fail('Expected the asssertion to fail.');
  on-error;
    assertFailEvtLong = getAssertFailEvtLong();
    assert(assertFailEvtLong.msg = 'Indicator values do not match'
           : 'Error messages does not match expected value.');
  endmon;

end-proc;

dcl-proc assertThatMatcherWithMsg export;
  dcl-pi *n ind extproc(*dclcase);
    pExpected    pointer const;
    pActual      pointer const;
    message      like(msgText_t) options(*nopass);
    logExpected  like(logValue_t.value) options(*nopass);
    logActual    like(logValue_t.value) options(*nopass);
  end-pi;

  dcl-s expected varchar(128) based(pExpected);
  dcl-s actual   varchar(128) based(pActual);

  // Set values displayed in the test log
  logExpected = expected;
  logActual = actual;

  if (expected = actual);
    message = '';
    return *on;
  else;
    message = 'Matcher: Actual values does not match expected value.';
    return *off;
  endif;

end-proc;


dcl-proc assertThatMatcherWithoutMsg export;
  dcl-pi *n ind extproc(*dclcase);
    pExpected    pointer const;
    pActual      pointer const;
    message      like(msgText_t) options(*nopass);
    logExpected  like(logValue_t.value) options(*nopass);
    logActual    like(logValue_t.value) options(*nopass);
  end-pi;

  dcl-s expected varchar(128) based(pExpected);
  dcl-s actual   varchar(128) based(pActual);

  // Set values displayed in the test log
  logExpected = expected;
  logActual = actual;

  if (expected = actual);
    return *on;
  else;
    return *off;
  endif;

end-proc;


dcl-proc verifyLogValue export;
  dcl-pi *n extproc(*dclcase);
    text        varchar(10) const;
    logValue    likeds(logValue_t) const;
    value       like(logValue_t.value) const;
    type        like(dataType_t) const;
    isTruncated ind const;
  end-pi;

  dcl-s varName varchar(30);

  varName = 'log' + text;

  assert(value = logValue.value
         : varName + '.value does not match expected value');
  assert(type = logValue.type
         : varName + '.type does not match expected value');
  assert(isTruncated = logValue.isTruncated
         : varName + '.isTruncated does not match expected value');

end-proc;

