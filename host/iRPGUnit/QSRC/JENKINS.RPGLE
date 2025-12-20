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
/include qinclude,JSONWTR
/include qinclude,TEMPLATES
/include qinclude,XMLWRITER

/include qinclude,JENKINS

dcl-ds g likeds(sharedChars_t) import;

//----------------------------------------------------------------------
// Builds and returns the callstack as XML.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendTestCaseFailureV1 export;
  dcl-pi *n like(xmlBufferLarge_t);
    pCallstack  pointer const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);

  text += escapeXml(Jenkins_buildCallStackV1(pCallstack));

  return text;

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 1 item.
//----------------------------------------------------------------------
dcl-proc Jenkins_buildCallStackV1;
  dcl-pi *n like(xmlBufferLarge_t) extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;


  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += CRLF + buildCallstackEntry(callstkEnt);
  enddo;

  return text;

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
// Produces a Json object with the following format:
//
// {
//     "callstack": [
//         "callstack-items"
//     ],
//     "expected": {
//         "value": "theValue",
//         "type": "theType",
//         "length": 0,
//         "originalLength": 0
//     },
//     "actual": {
//         "value": "theValue",
//         "type": "theType",
//         "length": 0,
//         "originalLength": 0
//     },
//     "diagnosticMessages": [
//         "diagnostic-messages"
//     ]
// }
// --------------------------------------------------------
dcl-proc Jenkins_appendTestCaseAsJson export;
  dcl-pi *n like(xmlBufferLarge_t);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);

  // start Json object
  Json_clear();
  Json_startObject(); // Json Root Object

  Json_addKey('callStack');
  Json_startArray(); // 'callstack'

  Jenkins_buildCallStackAsJson(testFailureEvent.pCallstk);

  Json_endArray(); // 'callstack'

  Jenkins_appendFailureValuesAsJson(testFailureEvent);

  Jenkins_appendDiagnosticMessagesAsJson(testFailureEvent);

  // end Json object
  Json_endObject(); // Json Root Object

  text = CRLF + Json_get() + CRLF;

  return text;

end-proc;

//----------------------------------------------------------------------
// Appends the diagnostic messages in Json format.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendDiagnosticMessagesAsJson;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  // add diagnostic messages
  if (testFailureEvent.logExpected.type = DT_UNDEFINED or
      testFailureEvent.logActual.type = DT_UNDEFINED);

    Json_addKey('diagnosticMessages');
    Json_startArray();

    if (testFailureEvent.logExpected.type = DT_UNDEFINED);
      Json_addString(crtNoValueMsg(LABEL_EXPECTED: testFailureEvent.logExpected.assertProc));
    endif;

    if (testFailureEvent.logActual.type = DT_UNDEFINED);
      Json_addString(crtNoValueMsg(LABEL_ACTUAL: testFailureEvent.logActual.assertProc));
    endif;

    Json_endArray(); // 'diagnosticMessages'
  endif;

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 2 item.
//----------------------------------------------------------------------
dcl-proc Jenkins_buildCallStackAsJson;
  dcl-pi *n extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s callStackItem like(xmlBuffer_t);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    callStackItem = buildCallstackEntry(callstkEnt);

    Json_addString(callStackItem);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Appends the log value (expected and actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendFailureValuesAsJson;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  Jenkins_appendLogValueAsJson(LABEL_EXPECTED: testFailureEvent.logExpected);
  Jenkins_appendLogValueAsJson(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Appends a log value (expected or actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendLogValueAsJson;
  dcl-pi *n extproc(*dclcase);
    name     varchar(20) const;
    logValue likeds(logValue_t) const;
  end-pi;

  Json_addKey(name);
  Json_startObject(); // 'expected|accepted'

  if (logValue.type <> NO_VALUE);
    Json_addKey('value');
    Json_addString(logValue.value);
    Json_addKey('type');
    Json_addString(logValue.type);
    Json_addKey('length');
    Json_addInteger(logValue.length);
    Json_addKey('originalLength');
    Json_addInteger(logValue.originalLength);
  endif;

  Json_endObject(); // 'expected|accepted'

end-proc;

// --------------------------------------------------------
// Appends a test case event in text format.
// --------------------------------------------------------
dcl-proc Jenkins_appendTestCaseFailureAsText export;
  dcl-pi *n;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  text = g.START_CDATA;
  appendToXmlFile(text);

  Jenkins_appendCallStackAsText(testFailureEvent.pCallstk);

  Jenkins_appendFailureValuesAsText(testFailureEvent);

  Jenkins_appendDiagnosticMessagesAsText(testFailureEvent);

  text = g.END_CDATA;
  appendToXmlFile(text);

end-proc;

//----------------------------------------------------------------------
// Appends the diagnostic messages in Json format.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendDiagnosticMessagesAsText;
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
      text = '  ' + crtNoValueMsg(LABEL_EXPECTED: testFailureEvent.logExpected.assertProc) + CRLF;
      appendToXmlFile(text);
    endif;

    if (testFailureEvent.logActual.type = DT_UNDEFINED);
      text = '  ' + crtNoValueMsg(LABEL_ACTUAL: testFailureEvent.logActual.assertProc) + CRLF;
      appendToXmlFile(text);
    endif;

  endif;

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 2 item.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendCallStackAsText;
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
    text = '  ' + buildCallstackEntry(callstkEnt) + CRLF;
    appendToXmlFile(text);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Appends the log value (expected and actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendFailureValuesAsText;
  dcl-pi *n extproc(*dclcase);
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  Jenkins_appendLogValueAsText(LABEL_EXPECTED: testFailureEvent.logExpected);
  Jenkins_appendLogValueAsText(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Appends a log value (expected or actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc Jenkins_appendLogValueAsText;
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

