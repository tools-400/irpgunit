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

/include qunittest,SAX_H

//----------------------------------------------------------------------
//   Global variables
//----------------------------------------------------------------------

// Status of the SAX parser
dcl-ds g_sax qualified;
  path         like(xmlPath_t) inz;
  attrName     like(xmlName_t) inz;
  handlerIndex int(10);
  handler      likeds(handler_t) dim(NUM_CALLBACK_HANDLER);
end-ds;

// Generic prototype of SAX parser callbacks
dcl-s g_pSaxDynamicHandler pointer(*proc);
dcl-pr g_saxDynamicHandler int(10) extproc(g_pSaxDynamicHandler);
  pElement pointer const;
  event    int(10) value;
  value    varchar(1024) options(*varsize);
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
    testsuite   likeds(xmlTestSuite_t);
    event       int(10) value;
    pString     pointer value;
    stringLen   int(20) value;
    exceptionId int(10) value;
  end-pi;

  dcl-s string char(1024) based(pString);
  dcl-s stringValue varchar(1024);

  if (stringLen > 0);
    stringValue = %subst(string: 1: stringLen);
  else;
    stringValue = '';
  endif;

  select;
  when (event = *XML_START_ELEMENT); // = 21
    pushElement(stringValue);

    select;
    when (stringValue = 'testsuite');
      pushHandler(stringValue: %paddr('testsuiteHandler')
                  : %addr(testsuite));
    endsl;

  when (event = *XML_END_ELEMENT);
    popElement();

    select;
    when (stringValue = g_sax.handler(g_sax.handlerIndex).element);
      popHandler();
    endsl;

  when (event = *XML_ATTR_NAME);
    g_sax.attrName = stringValue;

  endsl;

  if (g_sax.handlerIndex > 0);
    g_pSaxDynamicHandler = g_sax.handler(g_sax.handlerIndex).pHandler;
    return g_saxDynamicHandler(g_sax.handler(g_sax.handlerIndex).pCurrentElement
                               : event: stringValue);
  endif;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Push Element on *XML_START_ELEMENT
//----------------------------------------------------------------------
dcl-proc pushElement;
  dcl-pi *n extproc(*dclcase);
    element like(xmlName_t) const;
  end-pi;

  g_sax.path += '/' + element;

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
    element         like(xmlName_t) const;
    pHandler        pointer(*proc) const;
    pCurrentElement pointer const;
  end-pi;

  g_sax.handlerIndex += 1;
  g_sax.handler(g_sax.handlerIndex).element = element;
  g_sax.handler(g_sax.handlerIndex).pHandler = pHandler;
  g_sax.handler(g_sax.handlerIndex).pCurrentElement = pCurrentElement;

end-proc;

//----------------------------------------------------------------------
//   SAX: Pop Callback Handler
//----------------------------------------------------------------------
dcl-proc popHandler;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_sax.handler(g_sax.handlerIndex).element = '';
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
    value     varchar(1024) options(*varsize);
  end-pi;

  dcl-ds testsuite likeds(xmlTestSuite_t) based(pTestsuite);

  pTestsuite = pElement;

  testsuite.isNull = *off;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'testcase');
      testsuite.testcases.size += 1;
      pushHandler(value: %paddr('testcaseHandler')
                  : %addr(testsuite.testcases.testcase(testsuite.testcases.size)));
    when (value = 'properties');
      pushHandler(value: %paddr('propertiesHandler')
                  : *null);
    endsl;

  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'errors');
      testsuite.attr_errors += value;
    when (g_sax.attrName = 'failures');
      testsuite.attr_failures += value;
    when (g_sax.attrName = 'hostname');
      testsuite.attr_hostname += value;
    when (g_sax.attrName = 'id');
      testsuite.attr_id += value;
    when (g_sax.attrName = 'name');
      testsuite.attr_name += value;
    when (g_sax.attrName = 'tests');
      testsuite.attr_tests += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Test Suite Properties
//----------------------------------------------------------------------
dcl-proc propertiesHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  // TODO: extract properties from XML

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Test Cases
//----------------------------------------------------------------------
dcl-proc testcaseHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds testCase likeds(xmlTestCase_t) based(pTestCase);

  pTestCase = pElement;

  testCase.isNull = *off;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'assertion');
      testCase.assertions.size += 1;
      pushHandler(value: %paddr('assertionHandler')
                  : %addr(testCase.assertions.assertion(testCase.assertions.size)));
    endsl;

  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'name');
      testCase.attr_name += value;
    when (g_sax.attrName = 'assertions');
      testCase.attr_assertions += value;
    when (g_sax.attrName = 'classname');
      testCase.attr_classname += value;
    when (g_sax.attrName = 'time');
      testCase.attr_time += value;
    when (g_sax.attrName = 'outcome');
      testCase.attr_outcome += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertions
//----------------------------------------------------------------------
dcl-proc assertionHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds abstractAssertion likeds(xmlAbstractAssertion_t) based(pAbstractAssertion);
  dcl-ds failureAssertion likeds(xmlFailureAssertion_t) inz(*likeds);
  dcl-ds successAssertion likeds(xmlSuccessAssertion_t) inz(*likeds);
  dcl-ds errorAssertion likeds(xmlErrorAssertion_t) inz(*likeds);

  pAbstractAssertion = pElement;

  abstractAssertion.isNull = *off;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'failure');
      failureAssertion.attr_name = abstractAssertion.attr_name;
      failureAssertion.attr_outcome = abstractAssertion.attr_outcome;
      abstractAssertion.failure = failureAssertion;
      pushHandler(value: %paddr('failureHandler')
                  : %addr(abstractAssertion.failure));
    when (value = 'success');
      successAssertion.attr_name = abstractAssertion.attr_name;
      successAssertion.attr_outcome = abstractAssertion.attr_outcome;
      abstractAssertion.success = successAssertion;
      pushHandler(value: %paddr('successHandler')
                  : %addr(abstractAssertion.success));
    when (value = 'error');
      errorAssertion.attr_name = abstractAssertion.attr_name;
      errorAssertion.attr_outcome = abstractAssertion.attr_outcome;
      abstractAssertion.error = errorAssertion;
      pushHandler(value: %paddr('errorHandler')
                  : %addr(abstractAssertion.error));
    endsl;

  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'name');
      abstractAssertion.attr_name += value;
    when (g_sax.attrName = 'outcome');
      abstractAssertion.attr_outcome += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Failure Events
//----------------------------------------------------------------------
dcl-proc failureHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds failureAssertion likeds(xmlFailureAssertion_t) based(pFailureAssertion);

  pFailureAssertion = pElement;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'callstack');
      pushHandler(value: %paddr('callstackHandler')
                  : %addr(failureAssertion.callstack));
    when (value = 'expected');
      pushHandler(value: %paddr('valueHandler')
                  : %addr(failureAssertion.expected));
    when (value = 'actual');
      pushHandler(value: %paddr('valueHandler')
                  : %addr(failureAssertion.actual));
    endsl;

  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'message');
      failureAssertion.attr_message += value;
    when (g_sax.attrName = 'line');
      failureAssertion.attr_line += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Success Events
//----------------------------------------------------------------------
dcl-proc successHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds successAssertion likeds(xmlSuccessAssertion_t) based(pSuccessAssertion);

  pSuccessAssertion = pElement;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'expected');
      pushHandler(value: %paddr('valueHandler')
                  : %addr(successAssertion.expected));
    endsl;

  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'line');
      successAssertion.attr_line += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Assertion Errors Events
//----------------------------------------------------------------------
dcl-proc errorHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds errorAssertion likeds(xmlErrorAssertion_t) based(pErrorAssertion);

  pErrorAssertion = pElement;

  select;
  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'message');
      errorAssertion.attr_message += value;
    when (g_sax.attrName = 'type');
      errorAssertion.attr_type += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Callstack
//----------------------------------------------------------------------
dcl-proc callstackHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds callstack likeds(xmlCallstack_t) based(pCallstack);

  pCallstack = pElement;

  select;
  when (event = *XML_START_ELEMENT); // = 21

    select;
    when (value = 'item');
      callstack.size += 1;
      pushHandler(value: %paddr('stackEntryHandler')
                  : %addr(callstack.stackEntry(callstack.size)));
    endsl;

  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Callstack Entry
//----------------------------------------------------------------------
dcl-proc stackEntryHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds callstackEntry likeds(xmlCallstackEntry_t) based(pCallstackEntry);

  pCallstackEntry = pElement;

  callstackEntry.isNull = *off;

  select;
  when (event = *XML_ATTR_CHARS or event = *XML_ATTR_PREDEF_REF);
    select;
    when (g_sax.attrName = 'program');
      callstackEntry.attr_program += value;
    when (g_sax.attrName = 'module');
      callstackEntry.attr_module += value;
    when (g_sax.attrName = 'procedure');
      callstackEntry.attr_procedure += value;
    when (g_sax.attrName = 'line');
      callstackEntry.attr_line += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

//----------------------------------------------------------------------
//   SAX: Handle Value
//----------------------------------------------------------------------
dcl-proc valueHandler;
  dcl-pi *n int(10) extproc(*dclcase);
    pElement pointer const;
    event    int(10) value;
    value    varchar(1024) options(*varsize);
  end-pi;

  dcl-ds logValue likeds(xmlLogValue_t) based(pLogValue);
  dcl-s element like(xmlName_t) static inz;

  pLogValue = pElement;

  logValue.isNull = *off;

  select;
  when (event = *XML_START_ELEMENT);
    element = value;
  when (event = *XML_END_ELEMENT);
    element = '';
  when ((event = *XML_CHARS or event = *XML_PREDEF_REF) and element <> '');
    select;
    when (element = 'value');
      logValue.attr_value += value;
    when (element = 'type');
      logValue.attr_type += value;
    when (element = 'length');
      logValue.attr_length += value;
    when (element = 'originalLength');
      logValue.attr_originalLength += value;
    endsl;
  endsl;

  return XML_SAX_CONTINUE;

end-proc;

