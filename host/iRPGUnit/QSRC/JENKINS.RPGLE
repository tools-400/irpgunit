**FREE
// ==========================================================================
//  iRPGUnit - Jenkins File Writer.
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

ctl-opt DECEDIT('0.') NOMAIN;
/define NO_DECEDIT
/include qinclude,H_SPEC

/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT

/include qinclude,CALLSTACK
/include qinclude,CMDRUNSRV
/include qinclude,TEMPLATES
/include qinclude,XMLWRITER
/include qllist,llist_h

/include qinclude,JENKINS

dcl-c TAB_TEXT '  ';

dcl-ds g likeds(sharedChars_t) import;
dcl-ds g_xmlWriter likeds(xmlWriter_t) import;

//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-proc Jenkins_writeTestCases export;
  dcl-pi *n;
    testSuite     likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result        likeds(testSuiteResult_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestResult);
  dcl-s text like(xmlBufferLarge_t);
  dcl-s execTimeSecs like(execTimeSecs_t);
  dcl-s execTimeUnit like(execTimeUnit_t);

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  dcl-s isSuccessEvent ind;

  g_xmlWriter.indLvl += 1;

  // Iterate the test cases...
  list_resetIteration(testSuite.testResults);
  pTestResult = list_getNext(testSuite.testResults);
  dow (pTestResult <> *null);

    execTimeSecs = getReportExecTimeSecs(testCaseResult);
    execTimeUnit = TIME_UNIT_SECOND;

    isSuccessEvent = *off;

    list_resetIteration(testCaseResult.hTestEvents);
    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    dow (pAbstractTestEvent <> *null);

      // ----------------------------------------------------------
      // Check also CMDRUNSRV.writeTestReport(), when
      // changing the logic for selecting the test case events.
      if (testCaseResult.outcome = TEST_CASE_SUCCESS and isSuccessEvent);
        leave;
      endif;

      if (abstractTestEvent.outcome = TEST_CASE_FAILURE
          and not abstractTestEvent.failure.isConfirmed);
        pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
        iter;
      endif;

      if (g_xmlWriter.isJUnitStyle);
        if (abstractTestEvent.outcome <> testCaseResult.outcome);
          pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
          iter;
        endif;
      endif;
      // ----------------------------------------------------------

      text = indent() + '<testcase name="'
                 + buildReportTestCaseName(testCaseResult: abstractTestEvent) + '"';
      text += ' assertions="' + %char(getReportNumAsserts(testCaseResult)) + '"';
      text += ' classname="' + %trimr(testSuiteName.nm) + '"'; // TODO: should look which module
      text += ' time="' + %char(execTimeSecs) + '"';           // exports this testcase
      text += ' timeUnit="' + execTimeUnit + '"';
      text += '>' + newLine();
      appendToXmlFile(text);

      writeTestCaseEventXml(abstractTestEvent);

      // close <testcase> element
      text = indent() + '</testcase>' + newLine();
      appendToXmlFile(text);

      if (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
        isSuccessEvent = *on;
      endif;

      pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    enddo;

    pTestResult = list_getNext(testSuite.testResults);
  enddo;

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Builds and returns the callstack as XML.
//----------------------------------------------------------------------
dcl-proc Jenkins_writeTestCaseFailureV1 export;
  dcl-pi *n;
    pCallstack  pointer const;
  end-pi;

  Jenkins_writeCallStackAsTextV1(pCallstack);

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 1 item.
// NO PRETTY PRINTING!
//----------------------------------------------------------------------
dcl-proc Jenkins_writeCallStackAsTextV1;
  dcl-pi *n extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += CRLF + escapeXml(buildCallstackEntry(callstkEnt));
  enddo;

  text += newLine() + indent();
  appendToXmlFile(text);

end-proc;

//----------------------------------------------------------------------
// Builds a v1/v2 callstack entry.
//----------------------------------------------------------------------
dcl-proc buildCallstackEntry;
  dcl-pi *n like(xmlBuffer_t) extproc(*dclcase);
    callstkEnt likeds(callstkEnt_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  text += callstkEnt.qStmt.procNm
            + ' (' + %trim(callstkEnt.qStmt.qPgm.nm) + '->'
                   + %trim(callstkEnt.qStmt.qMod.nm) + ':'
                   + %trim(callstkEnt.qStmt.specNb)
            + ')';

  return text;

end-proc;

// --------------------------------------------------------
// Appends a test case event in text format.
// --------------------------------------------------------
dcl-proc Jenkins_writeTestCaseFailureV2 export;
  dcl-pi *n;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  text = g.START_CDATA;
  appendToXmlFile(text);

  Jenkins_writeCallStackAsTextV2(testFailureEvent.pCallstk);

  Jenkins_writeFailureValuesAsText(testFailureEvent);

  Jenkins_writeDiagnosticMessagesAsText(testFailureEvent);

  text = g.END_CDATA;
  appendToXmlFile(text);

end-proc;

//----------------------------------------------------------------------
// Appends the diagnostic messages in Json format.
// NO PRETTY PRINTING!
//----------------------------------------------------------------------
dcl-proc Jenkins_writeDiagnosticMessagesAsText;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  // add diagnostic messages
  if (testFailureEvent.logExpected.type = DT_UNDEFINED or
      testFailureEvent.logActual.type = DT_UNDEFINED);

    text = CRLF;
    appendToXmlFile(text);

    text = 'Diagnostic messages:' + CRLF;
    appendToXmlFile(text);

    if (testFailureEvent.logExpected.type = DT_UNDEFINED);
      text = TAB_TEXT
             + crtNoValueMsg(LABEL_EXPECTED: testFailureEvent.assertProc) + CRLF;
      appendToXmlFile(text);
    endif;

    if (testFailureEvent.logActual.type = DT_UNDEFINED);
      text = TAB_TEXT
             + crtNoValueMsg(LABEL_ACTUAL: testFailureEvent.assertProc) + CRLF;
      appendToXmlFile(text);
    endif;

  endif;

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 2 item.
// NO PRETTY PRINTING!
//----------------------------------------------------------------------
dcl-proc Jenkins_writeCallStackAsTextV2;
  dcl-pi *n extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s size int(10);
  dcl-s text like(xmlBuffer_t);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  size = Callstack_getNumE(pCallstk);

  if (size = 0);
    return;
  endif;

  text = CRLF;
  appendToXmlFile(text);

  text = 'Callstack:' + CRLF;
  appendToXmlFile(text);

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text = TAB_TEXT + buildCallstackEntry(callstkEnt) + CRLF;
    appendToXmlFile(text);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Appends the log value (expected and actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc Jenkins_writeFailureValuesAsText;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  Jenkins_writeLogValueAsText(LABEL_EXPECTED: testFailureEvent.logExpected);
  Jenkins_writeLogValueAsText(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Appends a log value (expected or actual) to the Json object.
// NO PRETTY PRINTING!
//----------------------------------------------------------------------
dcl-proc Jenkins_writeLogValueAsText;
  dcl-pi *n extproc(*dclcase);
    name     varchar(20) const;
    logValue likeds(logValue_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-s formattedName like(Name);

  if (logValue.type = DT_UNDEFINED);
    return;
  endif;

  formattedName = name;
  %subst(formattedName: 1: 1) = %upper(formattedName: 1: 1);

  text = CRLF;
  appendToXmlFile(text);

  text = formattedName + ':' + CRLF;
  appendToXmlFile(text);

  text = '  ' + logValue.value + CRLF;
  appendToXmlFile(text);

end-proc;

