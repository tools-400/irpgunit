**FREE
// ==========================================================================
//  iRPGUnit - XML File Writer.
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

ctl-opt DECEDIT('0.') NOMAIN;
/define NO_DECEDIT
/include qinclude,H_SPEC

/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT

/include qinclude,ERRORCODE
/include qinclude,CALLSTACK
/include qinclude,IFSIO_H
/include qinclude,JENKINS
/include qinclude,TEMPLATES
/include qinclude,XMLWRITER
/include qllist,llist_h

/include qinclude,VSCODE

/include qinclude,SDS

dcl-ds g likeds(sharedChars_t) import;
dcl-ds g_xmlWriter likeds(xmlWriter_t) import;

//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-proc VSCode_writeTestCases export;
  dcl-pi *n;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(Object_t) const;
    testSuiteResult likeds(testSuiteResult_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestCaseResult);
  dcl-s text like(xmlBuffer_t);
  dcl-s execTime like(execTimeMSecs_t);

  g_xmlWriter.indLvl += 1;

  // Iterate the test cases...
  list_resetIteration(testSuite.testResults);
  pTestCaseResult = list_getNext(testSuite.testResults);
  dow (pTestCaseResult <> *null);

    execTime = testCaseResult.execTimeMSecs;

    // open <testcase> element
    text = indent() + '<testcase name="' + getTestCaseName(testCaseResult) + '" ';
    text += 'assertions="' + %char(testCaseResult.assertCnt) + '" ';
    text += 'classname="' + %trimr(testSuiteName.nm) + '" '; // TODO: should look which module
    text += 'time="' + %char(execTime) + '" ';               // exports this testcase
    text += 'outcome="' + outcomeToXml(testCaseResult.outcome) + '" ';
    text += '>' + CRLF;
    appendToXmlFile(text);

    VSCode_writeTestCaseEvents(testCaseResult);

    // close <testcase> element
    text = indent() + '</testcase>' + CRLF;
    appendToXmlFile(text);

    pTestCaseResult = list_getNext(testSuite.testResults);
  enddo;

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Writes a XML test case.
//----------------------------------------------------------------------
dcl-proc VSCode_writeTestCaseEvents;
  dcl-pi *n extproc(*dclcase);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  if (g_xmlWriter.isJUnitStyle and testCaseResult.outcome = TEST_CASE_SUCCESS);
    return;
  endif;

  list_resetIteration(testCaseResult.hTestEvents);
  pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  dow (pAbstractTestEvent <> *null);

    // open <assertion> element
    text = indent() + '<assertion name="'
                                   + getAssertProcName(abstractTestEvent) + '" ';
    text += 'outcome="' + outcomeToXml(abstractTestEvent.outcome) + '" ';
    text += '>' + CRLF;
    appendToXmlFile(text);

    VSCode_writeTestCaseEvent(abstractTestEvent);

    // close <assertion> element
    text = indent() + '</assertion>' + CRLF;
    appendToXmlFile(text);

    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Writes a unit test case event in VS Code style.
//----------------------------------------------------------------------
dcl-proc VSCode_writeTestCaseEvent;
  dcl-pi *n extproc(*dclcase);
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-ds runtimeErrorEvent likeds(runtimeErrorEvent_t) inz;
  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;

  dcl-s text like(xmlBuffer_t);

  g_xmlWriter.indLvl += 1;

  select;
  when (abstractTestEvent.outcome = TEST_CASE_ERROR);

    runtimeErrorEvent = abstractTestEvent.error;

    // start <error> element
    text = indent() + '<error message="'
           + escapeXml(%trimr(runtimeErrorEvent.msg.txt))
           + '" type="' + escapeXml(%trimr(runtimeErrorEvent.msg.id)) + '">' + CRLF;
    appendToXmlFile(text);

    VSCode_writeCallstackEntry(runtimeErrorEvent.msg.qSndStmt: 'messageSender');
    VSCode_writeCallstackEntry(runtimeErrorEvent.msg.qRcvStmt: 'messageReceiver');

    // close <error> element
    text = indent() + '</error>' + CRLF;
    appendToXmlFile(text);

  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);

    testFailureEvent = abstractTestEvent.failure;

    // start <failure> element
    text = indent() + '<failure message="';
    text += escapeXml(%trimr(testFailureEvent.msg));
    text += '">';
    appendToXmlFile(text);

    VSCode_appendTestCaseAsXml(abstractTestEvent.failure);
    text = indent();
    appendToXmlFile(text);

    // close <failure> element
    text = '</failure>' + CRLF;
    appendToXmlFile(text);

  endsl;

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

// --------------------------------------------------------
// Writes the test case as XML in VS Code style.
// --------------------------------------------------------
dcl-proc VSCode_appendTestCaseAsXml;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  text = CRLF;
  appendToXmlFile(text);

  // always the first section of the <failure> element
  VSCode_writeCallStack(testFailureEvent.pCallstk);

  VSCode_writeFailureValues(testFailureEvent);

  VSCode_writeDiagnosticMessages(testFailureEvent);

end-proc;

// --------------------------------------------------------
// Writes the callstack in VS Code style.
// --------------------------------------------------------
dcl-proc VSCode_writeCallStack;
  dcl-pi *n extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-s size int(10);

  g_xmlWriter.indLvl += 1;

  // start Json object
  size = Callstack_getNumE(pCallstk);
  text = indent() + '<callstack size="' + %char(size) + '">' + CRLF;
  appendToXmlFile(text);

  VSCode_writeCallstackEntries(pCallstk);

  text = indent() + '</callstack>' + CRLF;
  appendToXmlFile(text);

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

// --------------------------------------------------------
// Writes the callstack entries in VS Code style.
// --------------------------------------------------------
dcl-proc VSCode_writeCallstackEntries;
  dcl-pi *n extproc(*dclcase);
    pCallstack pointer const;
  end-pi;

  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  Callstack_resetIteration(pCallstack);
  dow (Callstack_getNext(pCallstack: callstkEnt));
    VSCode_writeCallstackEntry(callstkEnt.qStmt: 'item');
  enddo;

end-proc;

// --------------------------------------------------------
// Writes a callstack entry in VS Code style.
// <item program="TEMPDET" module="TEMPDET" procedure="test_getDeptDetail_notFound" line="1465"/>
// --------------------------------------------------------
dcl-proc VSCode_writeCallstackEntry;
  dcl-pi *n extproc(*dclcase);
    qStmt       likeds(qStatement_t) const;
    elementName like(xmlName_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  g_xmlWriter.indLvl += 1;

  text = indent() + '<' + elementName;
  text += ' program="' + %trim(qStmt.qPgm.nm) + '"';
  text += ' programLibrary="' + %trim(qStmt.qPgm.lib) + '"';
  text += ' module="' + %trim(qStmt.qMod.nm) + '"';
  text += ' moduleLibrary="' + %trim(qStmt.qMod.lib) + '"';
  text += ' procedure="' + %trim(qStmt.procNm) + '"';
  text += ' line="' + %trim(qStmt.specNb) + '"/>' + CRLF;

  appendToXmlFile(text);

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Writes the expected and actual log values in VS Code style.
//----------------------------------------------------------------------
dcl-proc VSCode_writeFailureValues;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  VSCode_writeLogValue(LABEL_EXPECTED: testFailureEvent.logExpected);
  VSCode_writeLogValue(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Writes the expected and actual log values in VS Code style.
//----------------------------------------------------------------------
dcl-proc VSCode_writeLogValue;
  dcl-pi *n extproc(*dclcase);
    name       like(xmlName_t) const;
    logValue   likeds(logValue_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  g_xmlWriter.indLvl += 1;

  if (logValue.type <> NO_VALUE);
    text = indent() + startXmlElement(name) + CRLF;
    appendToXmlFile(text);

    writeXmlElement('value': logValue.value);
    writeXmlElement('type': logValue.type);
    writeXmlElement('length': %char(logValue.length));
    writeXmlElement('originalLength': %char(logValue.originalLength));

    text = indent() + endXmlElement(name) + CRLF;
  else;
    text = indent() + emptyXmlElement(name) + CRLF;
  endif;

  appendToXmlFile(text);

on-exit;

  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Writes the diagnostic messages in VS Code style.
//----------------------------------------------------------------------
dcl-proc VSCode_writeDiagnosticMessages;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-s message1 like(xmlValue_t);
  dcl-s message2 like(xmlValue_t);
  dcl-s size int(10);

  g_xmlWriter.indLvl += 1;

  size = 0;

  if (testFailureEvent.logExpected.type = DT_UNDEFINED);
    message1 = crtNoValueMsg(LABEL_EXPECTED: testFailureEvent.logExpected.assertProc);
    size += 1;
  endif;

  if (testFailureEvent.logActual.type = DT_UNDEFINED);
    message2 = crtNoValueMsg(LABEL_ACTUAL: testFailureEvent.logActual.assertProc);
    size += 1;
  endif;

  if (size > 0);

    text = indent() + '<diagnosticMessages size="' + %char(size) + '">' + CRLF;
    appendToXmlFile(text);

    writeXmlElement('item': message1);
    writeXmlElement('item': message2);

    text = indent() + '</diagnosticMessages>' + CRLF;
    appendToXmlFile(text);

  endif;

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

