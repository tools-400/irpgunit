**FREE
// ==========================================================================
//  iRPGUnit - SAX Parser Unit Test Helper.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
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

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,STRING
/include qunittest,SAX_H

//----------------------------------------------------------------------
//   Global variables
//----------------------------------------------------------------------

// Status of the SAX parser
dcl-ds g_sax qualified;
  path         like(saxPath_t) inz;
  elemName     like(saxElemName_t) inz;
  elemValue    like(saxElementText_t) inz;
  attrName     like(saxAttrName_t) inz;
  attrValue    like(saxAttrValue_t) inz;
  handlerIndex int(10);
  handler      likeds(handler_t) dim(NUM_CALLBACK_HANDLERS);
end-ds;

// Generic prototype of SAX parser callbacks
dcl-s g_pSaxDynamicHandler pointer(*proc);
dcl-pr g_saxDynamicHandler int(10) extproc(g_pSaxDynamicHandler);
  pElement pointer const;
  event    int(10) value;
  elemName like(saxElemName_t) options(*varsize);
end-pr;

//----------------------------------------------------------------------
//   SAX: Initialize parser
//----------------------------------------------------------------------
dcl-proc SAX_initialize export;
  dcl-pi *n;
  end-pi;

  reset g_sax;
  g_sax.handlerIndex = 0;

end-proc;

//----------------------------------------------------------------------
//   SAX parser handler
//----------------------------------------------------------------------
dcl-proc SAX_CallbackHandler export;
  dcl-pi *n int(10);
    testsuite   likeds(saxTestSuite_t);
    event       int(10) value;
    pString     pointer value;
    stringLen   int(20) value;
    exceptionId int(10) value;
  end-pi;

  dcl-s string char(2048) based(pString);
  dcl-s stringValue like(saxBuffer_t);
  dcl-s rc int(10);

  if (stringLen > 0);
    stringValue = %subst(string: 1: stringLen);
  else;
    stringValue = '';
  endif;

  select;
  when (event = *XML_START_ELEMENT); // 21
    g_sax.elemName = stringValue;
    g_sax.elemValue = '';
    pushElement(stringValue);

    select;
    when (stringValue = 'testsuite');
      pushHandler(stringValue: %paddr('testsuiteHandler')
                  : %addr(testsuite));
    endsl;

  when (event = *XML_CHARS); // 5
    g_sax.elemValue += stringValue;

  when (event = *XML_PREDEF_REF); // ?
    g_sax.elemValue += stringValue;

  when (event = *XML_ATTR_NAME); // 2
    g_sax.attrValue = '';
    g_sax.attrName = stringValue;

  when (event = *XML_ATTR_CHARS); // 4
    g_sax.attrValue += stringValue;

  when (event = *XML_ATTR_PREDEF_REF); // ?
    g_sax.attrValue += stringValue;

  endsl;

  if (g_sax.handlerIndex > 0);
    g_pSaxDynamicHandler = g_sax.handler(g_sax.handlerIndex).pHandler;
    rc = g_saxDynamicHandler(g_sax.handler(g_sax.handlerIndex).pCurrentElement
                               : event: stringValue);
  endif;

  select;
  when (event = *XML_END_ELEMENT); // 13
    popElement();

    select;
    when (stringValue = g_sax.handler(g_sax.handlerIndex).elemName);
      popHandler();
    endsl;

  when (event = *XML_END_ATTR); // 26
    g_sax.attrValue = '';
    g_sax.attrName = '';

  endsl;

  return rc;

end-proc;

//----------------------------------------------------------------------
//   SAX: Push Element on *XML_START_ELEMENT
//----------------------------------------------------------------------
dcl-proc pushElement;
  dcl-pi *n extproc(*dclcase);
    elemName like(saxElemName_t) const;
  end-pi;

  g_sax.path += '/' + elemName;

end-proc;

//----------------------------------------------------------------------
//   SAX: Pop Element on *XML_END_ELEMENT
//----------------------------------------------------------------------
dcl-proc popElement;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  i = %scanr('/': g_sax.path);
  g_sax.path = %subst(g_sax.path: 1: i-1);

end-proc;

//----------------------------------------------------------------------
//   SAX: Push Callback Handler
//----------------------------------------------------------------------
dcl-proc pushHandler;
  dcl-pi *n extproc(*dclcase);
    element         like(saxElemName_t) const;
    pHandler        pointer(*proc) const;
    pCurrentElement pointer const;
  end-pi;

  g_sax.handlerIndex += 1;
  g_sax.handler(g_sax.handlerIndex).elemName = element;
  g_sax.handler(g_sax.handlerIndex).pHandler = pHandler;
  g_sax.handler(g_sax.handlerIndex).pCurrentElement = pCurrentElement;

end-proc;

//----------------------------------------------------------------------
//   SAX: Pop Callback Handler
//----------------------------------------------------------------------
dcl-proc popHandler;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_sax.handler(g_sax.handlerIndex).elemName = '';
  g_sax.handler(g_sax.handlerIndex).pHandler = *null;
  g_sax.handlerIndex -= 1;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Test Suite
//----------------------------------------------------------------------
dcl-proc testsuiteHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement  pointer const;
    event     int(10) value;
    elemName  like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds testsuite likeds(saxTestSuite_t) based(pTestsuite);

  pTestsuite = pElement;

  testsuite.isNull = *off;

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'testcase');
      testsuite.testcases.size += 1;
      pushHandler(elemName: %paddr('testcaseHandler')
                  : %addr(testsuite.testcases.testcase(testsuite.testcases.size)));
    when (elemName = 'properties');
      pushHandler(elemName: %paddr('propertiesHandler')
                  : %addr(testsuite.properties));
    endsl;
  endsl;

  if (g_sax.path = '/testsuite');

    select;
    when (event = *XML_END_ATTR); // 4 / ?
      select;
      when (g_sax.attrName = 'errors');
        testsuite.attr_errors = g_sax.attrValue;
      when (g_sax.attrName = 'failures');
        testsuite.attr_failures = g_sax.attrValue;
      when (g_sax.attrName = 'hostname');
        testsuite.attr_hostname = g_sax.attrValue;
      when (g_sax.attrName = 'id');
        testsuite.attr_id = g_sax.attrValue;
      when (g_sax.attrName = 'name');
        testsuite.attr_name = g_sax.attrValue;
      when (g_sax.attrName = 'tests');
        testsuite.attr_tests = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Test Suite Properties
//----------------------------------------------------------------------
dcl-proc propertiesHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds properties likeds(saxProperties_t) based(pProperties);

  pProperties = pElement;

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'property');
      properties.size += 1;
      pushHandler(elemName: %paddr('propertyHandler')
                  : %addr(properties.property(properties.size)));
    endsl;
  endsl;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Test Suite Property
//----------------------------------------------------------------------
dcl-proc propertyHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds property likeds(saxProperty_t) based(pProperty);

  pProperty = pElement;

  property.isNull = *off;

  if (g_sax.path = '/testsuite/properties/property');

    select;
    when (event = *XML_END_ATTR); // 26
      select;
      when (g_sax.attrName = 'name');
        property.attr_key = g_sax.attrValue;
      when (g_sax.attrName = 'value');
        property.attr_value = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertions
//----------------------------------------------------------------------
dcl-proc testcaseHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds testCase likeds(saxTestCase_t) based(pElement);
  dcl-ds abstractAssertion likeds(saxAbstractTestCaseEvent_t) based(pAbstractAssertion);
  dcl-ds failureAssertion likeds(saxFailureEvent_t) inz(*likeds);
  dcl-ds successAssertion likeds(saxSuccessEvent_t) inz(*likeds);
  dcl-ds errorAssertion likeds(saxRuntimeErrorEvent_t) inz(*likeds);

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'failure');
      testCase.events.size += 1;
      pAbstractAssertion = %addr(testCase.events.testCaseEvent(testCase.events.size));
      abstractAssertion.failure = failureAssertion;
      abstractAssertion.isNull = *off;
      pushHandler(elemName: %paddr('failureHandler')
                  : %addr(abstractAssertion.failure));
    when (elemName = 'success');
      testCase.events.size += 1;
      pAbstractAssertion = %addr(testCase.events.testCaseEvent(testCase.events.size));
      abstractAssertion.success = successAssertion;
      abstractAssertion.isNull = *off;
      pushHandler(elemName: %paddr('successHandler')
                  : %addr(abstractAssertion.success));
    when (elemName = 'error');
      testCase.events.size += 1;
      pAbstractAssertion = %addr(testCase.events.testCaseEvent(testCase.events.size));
      abstractAssertion.error = errorAssertion;
      abstractAssertion.isNull = *off;
      pushHandler(elemName: %paddr('errorHandler')
                  : %addr(abstractAssertion.error));
    endsl;
  endsl;

  if (g_sax.path = '/testsuite/testcase');

    select;
    when (event = *XML_END_ATTR); // 26
      select;
      when (g_sax.attrName = 'outcome');
        testCase.attr_outcome = g_sax.attrValue;
      when (g_sax.attrName = 'classname');
        testCase.attr_classname = g_sax.attrValue;
      when (g_sax.attrName = 'name');
        testCase.attr_name = g_sax.attrValue;
      when (g_sax.attrName = 'assertions');
        testCase.attr_assertions = g_sax.attrValue;
      when (g_sax.attrName = 'time');
        testCase.attr_time = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Failure Events
//----------------------------------------------------------------------
dcl-proc failureHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds failureAssertion likeds(saxFailureEvent_t) based(pFailureAssertion);

  pFailureAssertion = pElement;

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'callstack');
      pushHandler(elemName: %paddr('callstackHandler')
                  : %addr(failureAssertion.callstack));
    when (elemName = 'expected');
      pushHandler(elemName: %paddr('valueHandler')
                  : %addr(failureAssertion.expected));
    when (elemName = 'actual');
      pushHandler(elemName: %paddr('valueHandler')
                  : %addr(failureAssertion.actual));
    when (elemName = 'diagnosticMessages');
      pushHandler(elemName: %paddr('diagnosticMessagesHandler')
                  : %addr(failureAssertion.diagMsgs));
    endsl;
  endsl;

  if (g_sax.path = '/testsuite/testcase/failure');

    select;
    when (event = *XML_END_ELEMENT); // 13
      failureAssertion.elementText = getElementValue();
    when (event = *XML_END_ATTR); // 26
      select;
//      when (g_sax.attrName = 'outcome');
//        failureAssertion.attr_outcome = g_sax.attrValue;
      when (g_sax.attrName = 'message');
        failureAssertion.attr_message = g_sax.attrValue;
      when (g_sax.attrName = 'line');
        failureAssertion.attr_line = g_sax.attrValue;
      when (g_sax.attrName = 'name');
        failureAssertion.attr_name = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Success Events
//----------------------------------------------------------------------
dcl-proc successHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds successAssertion likeds(saxSuccessEvent_t) based(pSuccessAssertion);

  pSuccessAssertion = pElement;

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'expected');
      pushHandler(elemName: %paddr('valueHandler')
                  : %addr(successAssertion.expected));
    endsl;
  endsl;

  if (g_sax.path = '/testsuite/testcase/success');

    select;
    when (event = *XML_END_ATTR); // 26
      select;
//      when (g_sax.attrName = 'outcome');
//        successAssertion.attr_outcome = g_sax.attrValue;
      when (g_sax.attrName = 'line');
        successAssertion.attr_line = g_sax.attrValue;
      when (g_sax.attrName = 'name');
        successAssertion.attr_name = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Errors Events
//----------------------------------------------------------------------
dcl-proc errorHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds runtimeError likeds(saxRuntimeErrorEvent_t) based(pErrorAssertion);

  pErrorAssertion = pElement;

  if (g_sax.path = '/testsuite/testcase/error');

    select;
    when (event = *XML_END_ELEMENT); // 13
      runtimeError.elementText = getElementValue();
    when (event = *XML_END_ATTR); // 26
      select;
//      when (g_sax.attrName = 'outcome');
//        runtimeError.attr_outcome = g_sax.attrValue;
      when (g_sax.attrName = 'message');
        runtimeError.attr_message = g_sax.attrValue;
      when (g_sax.attrName = 'type');
        runtimeError.attr_type = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Callstack
//----------------------------------------------------------------------
dcl-proc callstackHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds callstack likeds(saxCallstack_t) based(pCallstack);

  pCallstack = pElement;

  select;
  when (event = *XML_START_ELEMENT); // 21

    select;
    when (elemName = 'item');
      callstack.size += 1;
      pushHandler(elemName: %paddr('stackEntryHandler')
                  : %addr(callstack.stackEntry(callstack.size)));
    endsl;

  endsl;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Callstack Entry
//----------------------------------------------------------------------
dcl-proc stackEntryHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds callstackEntry likeds(saxCallstackEntry_t) based(pCallstackEntry);

  pCallstackEntry = pElement;

  callstackEntry.isNull = *off;

  if (g_sax.path = '/testsuite/testcase/failure/callstack/item');

    select;
    when (event = *XML_END_ATTR); // 26
      select;
      when (g_sax.attrName = 'program');
        callstackEntry.attr_program = g_sax.attrValue;
      when (g_sax.attrName = 'module');
        callstackEntry.attr_module = g_sax.attrValue;
      when (g_sax.attrName = 'procedure');
        callstackEntry.attr_procedure = g_sax.attrValue;
      when (g_sax.attrName = 'line');
        callstackEntry.attr_line = g_sax.attrValue;
      endsl;
    endsl;

  endif;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Value
//----------------------------------------------------------------------
dcl-proc valueHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds logValue likeds(saxLogValue_t) based(pLogValue);

  pLogValue = pElement;

  logValue.isNull = *off;

  select;
  when (event = *XML_END_ELEMENT); // 13
    select;
    when (g_sax.elemName = 'value');
      logValue.attr_value = getElementValue();
    when (g_sax.elemName = 'type');
      logValue.attr_type = getElementValue();
    when (g_sax.elemName = 'length');
      logValue.attr_length = getElementValue();
    when (g_sax.elemName = 'originalLength');
      logValue.attr_originalLength = getElementValue();
    endsl;
  endsl;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Diagnostic Messages
//----------------------------------------------------------------------
dcl-proc diagnosticMessagesHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    elemName like(saxElemName_t) options(*varsize);
  end-pi;

  dcl-ds diagMsgs likeds(saxDiagnosticMessages_t) based(pDiagMsgs);

  pDiagMsgs = pElement;

  select;
  when (event = *XML_END_ELEMENT); // 13
    select;
    when (g_sax.elemName = 'item');
      diagMsgs.size += 1;
      diagMsgs.message(diagMsgs.size) = getElementValue();
    endsl;
  endsl;

  return SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Returns the value of the current XML element.
//----------------------------------------------------------------------
dcl-proc getElementValue;
  dcl-pi *n like(saxElementText_t) extproc(*dclcase);
  end-pi;

  dcl-s rtnValue like(saxElementText_t);
  dcl-s i int(10);
  dcl-s length int(10);

  i = %len(g_sax.elemValue);
  dow (i > 0 and isWhiteSpaceChar(%subst(g_sax.elemValue: i: 1)));
    i -= 1;
  enddo;

  rtnValue = leftStr(g_sax.elemValue: i);

  i = 1;
  dow (i < %len(rtnValue) and isWhiteSpaceChar(%subst(rtnValue: i: 1)));
    i += 1;
  enddo;

  length = %len(rtnValue) - i + 1;
  rtnValue = rightStr(rtnValue: length);

  return rtnValue;

end-proc;

//----------------------------------------------------------------------
//   SAX: Returns the value of the current XML element as an array
//        of text lines.
//----------------------------------------------------------------------
dcl-proc SAX_getElementTextLines export;
  dcl-pi *n likeds(saxElementLines_t);
    elemValue like(saxElementText_t) const;
  end-pi;

  dcl-s i int(10);
  dcl-s char char(1);
  dcl-s lineFeedChar char(1);
  dcl-s line like(saxElementLine_t);
  dcl-ds lines likeds(saxElementLines_t);

  dcl-c CR x'0D';
  dcl-c LF x'25';

  clear lines;

  if (elemValue = '');
    lines.size = 0;
    return lines;
  endif;

  i = 1;
  dow (i <= %len(elemValue));
    char = %subst(elemValue: i: 1);

    // Initialize linefeed character
    if (lineFeedChar = '' and (char = LF or char = CR));
      lineFeedChar = char;
    endif;

    if (char = lineFeedChar);
      lines.size += 1;
      lines.line(lines.size) = line;
      line = '';
    else;
      if (char <> CR and char <> LF);
        line += char;
      endif;
    endif;
    i += 1;
  enddo;

  if (line <> '');
    lines.size += 1;
    lines.line(lines.size) = line;
    line = '';
  endif;

  return lines;

end-proc;

//----------------------------------------------------------------------
//   Returns *on if the specified value is a whichtespace character.
//----------------------------------------------------------------------
dcl-proc isWhiteSpaceChar;
  dcl-pi *n ind extproc(*dclcase);
    char char(1) const;
  end-pi;

  if (char < x'40' or char > x'FE');
    return *on;
  endif;

  if (char = x'40');
    return *on;
  endif;

  return *off;

end-proc;

