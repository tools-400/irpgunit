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
/include qinclude,TEMPLATES
/include qinclude,XMLWRITER

/include qinclude,JENKINS

dcl-c TAB_TEXT '  ';

dcl-ds g likeds(sharedChars_t) import;

//----------------------------------------------------------------------
// Builds and returns the callstack as XML.
//----------------------------------------------------------------------
dcl-proc Jenkins_writeTestCaseFailureV1 export;
  dcl-pi *n;
    pCallstack  pointer const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);

  text += Jenkins_buildCallStackAsTextV1(pCallstack);

  text += newLine() + indent();
  appendToXmlFile(text);

end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 1 item.
// NO PRETTY PRINTING!
//----------------------------------------------------------------------
dcl-proc Jenkins_buildCallStackAsTextV1;
  dcl-pi *n like(xmlBufferLarge_t) extproc(*dclcase);
    pCallstk pointer const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += CRLF + escapeXml(buildCallstackEntry(callstkEnt));
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
// Appends a test case event in text format.
// --------------------------------------------------------
dcl-proc Jenkins_writeTestCaseFailureAsText export;
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

  Jenkins_appendLogValueAsText(LABEL_EXPECTED: testFailureEvent.logExpected);
  Jenkins_appendLogValueAsText(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Appends a log value (expected or actual) to the Json object.
// NO PRETTY PRINTING!
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

