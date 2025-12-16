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
/define NO_DECEDIT
/include qinclude,H_SPEC

/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT

/include qinclude,ASSERT
/include qinclude,CALLSTACK
/include qinclude,CMDRUNSRV
/include qinclude,JSONWTR
/include qinclude,PGMMSG
/include qinclude,CMDRUN
/include qinclude,OSVERSION
/include qinclude,LIBL
/include qinclude,LIBC_H
/include qinclude,IFSIO_H
/include qinclude,ERRNO_H
/include qinclude,ERRORCODE
/include qllist,llist_h

/include qinclude,XMLWRITER

// Use hex constants to define variant character in UTF-8.
// This way RPG correctly translates the strings to the current job CCSID.
// See: https://www.ibm.com/docs/en/i/7.5.0?topic=considerations-runtime-character-set
dcl-c UTF8_START_CDATA u'003C0021005B00430044004100540041005B';
dcl-c UTF8_END_CDATA u'005D005D003E';

// The constents below are made of invariant charcaters.
dcl-c CRLF x'0d25';
dcl-c TAB '    ';

dcl-s START_CDATA varchar(30);
dcl-s END_CDATA varchar(3);

dcl-s dbg_length int(10);

dcl-ds g_status qualified inz;
  xmlType             like(xmlType_t);
  isJUnitStyle        ind;
  json                varchar(50000);
  json_countObject    int(10);
  json_countArray     int(10);
  json_indent         int(10);
  json_isValueAllowed ind inz(*off);
  json_isPrettyPrint  ind inz(*on);
end-ds;

//----------------------------------------------------------------------
// Main entry point for writing the XML result file.
//----------------------------------------------------------------------
dcl-proc writeXmlFile export;
  dcl-pi *n;
    filepath        char(1024) const;
    testSuite       likeds(testSuite_t) const;
    testSuiteName   likeds(Object_t) const;
    testSuiteResult likeds(testSuiteResult_t) const;
    xmlType         like(xmlType_t) const;
    isJUnitStyle    ind const;
  end-pi;

  dcl-s fileHandle int(10);
  dcl-s rc int(10);

  initVariantCharacters();

  clear g_status;
  g_status.xmlType = xmlType;
  g_status.isJUnitStyle = isJUnitStyle;

  fileHandle = getXmlFileHandle(filepath);
  writeHeader(fileHandle : testSuite : testSuiteName : testSuiteResult);
  writeProperties(fileHandle);
  writeTestCases(fileHandle : testSuite : testSuiteName : testSuiteResult);
  writeFooter(fileHandle);

  if (fileHandle >= 0);
    rc = close(fileHandle);
  endif;
end-proc;

//----------------------------------------------------------------------
// Initializes variant characters.
// Characters are translated from UTF-8 to the job CCSID.
//----------------------------------------------------------------------
dcl-proc initVariantCharacters;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  START_CDATA = UTF8_START_CDATA;
  END_CDATA = UTF8_END_CDATA;

end-proc;

//----------------------------------------------------------------------
// Opens the XML file and returns the file handle.
//----------------------------------------------------------------------
dcl-proc getXmlFileHandle;
  dcl-pi *n int(10);
    filePath char(1024) const;
  end-pi;

  dcl-s fileHandle int(10);
  dcl-s flags int(10);
  dcl-s mode int(10);
  dcl-s errorNumber int(10) based(errorPtr);

  if (access(%trimr(filePath) : F_OK) >= 0);
    // delete existing file
    unlink(%trimr(filePath));
  endif;

  // create file
  flags = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID +
          O_TEXTDATA + O_TEXT_CREAT;
  mode =  S_IRUSR + S_IWUSR + S_IRGRP;
  fileHandle = open(%trimr(filePath) : flags : mode : 1208 : 0);
  if (fileHandle < 0);
    // could not open file handle
    errorPtr = errno();
    sndEscapeMsg('Could not create file ' + %trimr(filePath) + ': ' + %str(strError(errorNumber))
                 : ONE_CALL_STK_LVL_ABOVE);
  endif;

  return fileHandle;
end-proc;

//----------------------------------------------------------------------
// Writes the XML header section.
//----------------------------------------------------------------------
dcl-proc writeHeader;
  dcl-pi *n;
    fileHandle int(10) const;
    testSuite likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result likeds(testSuiteResult_t) const;
  end-pi;

  dcl-s text char(1000);
  dcl-ds resolvedObject likeds(object_t);

  resolvedObject = resolveObjectPath(testSuiteName : '*SRVPGM');

  text = '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF +
         '<testsuite errors="' + %char(result.errorCnt) + '" ' +
         'failures="' + %char(result.failureCnt) + '" ' +
         'hostname="' + getServerName() + '" ' +
         'id="0" ' +
         'name="' + %trimr(resolvedObject.lib) + '/' + %trimr(resolvedObject.nm) + '" ' +
         'tests="' + %char(testSuite.testCasesCnt) + '" >' + CRLF;

  writeA(fileHandle : text : %len(%trimr(text)));
end-proc;

//----------------------------------------------------------------------
// Writes the XML properties section.
//----------------------------------------------------------------------
dcl-proc writeProperties;
  dcl-pi *n;
    fileHandle int(10) const;
  end-pi;

  dcl-s text varchar(10000);
  dcl-s rc int(10);
  dcl-ds libl likeds(LiblData_t);
  dcl-s i int(10);

  text = TAB + '<properties>' + CRLF;

  libl = getLibl();

  if (libl.curLib <> *blank);
    text += TAB + TAB +
            '<property name="currentlibrary" value="' + %trimr(libl.curLib) + '" />' + CRLF;
  endif;

  if (libl.libl.nume > 0);
    text += TAB + TAB + '<property name="user.librarylist" value="';
    for i = 1 to libl.libl.nume;
      text += libl.libl.lib(i) + ' ';
    endfor;
    text += '"/>' + CRLF;
  endif;
  rc =  write(fileHandle : %addr(text : *data) : %len(text));

  text = TAB + TAB + '<property name="os.version" value="' + OS_getVersion() + '"/>' + CRLF;
  text += TAB + TAB + '<property name="irpgunit.version" value="' + RPGUNIT_VERSION + '"/>' + CRLF;

  text += TAB + '</properties>' + CRLF;
  rc =  write(fileHandle : %addr(text : *data) : %len(text));
end-proc;

//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-proc writeTestCases;
  dcl-pi *n;
    fileHandle int(10) const;
    testSuite likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result likeds(testSuiteResult_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestResult);
  dcl-s text varchar(50000);
  dcl-s rc int(10);
  dcl-s execTime packed(15:3);

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);


  // Iterate the test cases...
  list_resetIteration(testSuite.testResults);
  pTestResult = list_getNext(testSuite.testResults);
  dow (pTestResult <> *null);

    execTime = getReportExecutionTimeTestCase(testCaseResult);

    list_resetIteration(testCaseResult.hTestEvents);
    pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    dow (pAbstractTestEvent <> *null);

      text = TAB + '<testcase name="'
                 + buildReportTestCaseName(testCaseResult: abstractTestEvent) + '" ';
      text += 'assertions="' + %char(getReportNumAsserts(testCaseResult)) + '" ';
      text += 'classname="' + %trimr(testSuiteName.nm) + '" '; // TODO: should look which module
      text += 'time="' + %char(execTime) + '" ';               // exports this testcase
      text += '>' + CRLF;

      select;
      when (abstractTestEvent.outcome = TEST_CASE_ERROR);

        // start <error> element
        text += TAB + TAB + '<error message="' + escapeXml(%trimr(abstractTestEvent.error.msg.txt))+
            '" type="' + escapeXml(%trimr(abstractTestEvent.error.msg.id)) + '">' + CRLF;
        text += escapeXml(
            %trimr(abstractTestEvent.error.msg.qSndStmt.procNm) + ' ('+
            %trim(abstractTestEvent.error.msg.qSndStmt.qPgm.nm) + '->'+
              %trim(abstractTestEvent.error.msg.qSndStmt.qMod.nm) + ':');

        if (abstractTestEvent.error.msg.qSndStmt.specNb = *blank);
          text += '*N)' + CRLF;
        else;
          text += escapeXml(%trim(abstractTestEvent.error.msg.qSndStmt.specNb) + ')') + CRLF;
        endif;

        // close <error> element
        text += TAB + TAB + '</error>' + CRLF;

      when (abstractTestEvent.outcome = TEST_CASE_FAILURE);

        if (testCaseResult.lastFailureEvent = abstractTestEvent.index);

          // start <failure> element
          text += TAB + TAB + '<failure message="';
          text += escapeXml(%trimr(abstractTestEvent.failure.msg));
          text += '">';
          text += START_CDATA + CRLF;

          // always the first section of the <failure> element
          if (g_status.xmlType = XML_TYPE_1);
            text += appendCallStackVersion1(fileHandle: abstractTestEvent.failure.pCallstk);
          else;
            text += appendCallStackVersion2(fileHandle: abstractTestEvent.failure);
          endif;

          // close <failure> element
          text += TAB + TAB + END_CDATA;
          text += '</failure>' + CRLF;

        endif;

      endsl;

      // close <testcase> element
      text += TAB + '</testcase>' + CRLF;
      rc = write(fileHandle : %addr(text : *data) : %len(text));

      pAbstractTestEvent = list_getNext(testCaseResult.hTestEvents);
    enddo;

    pTestResult = list_getNext(testSuite.testResults);
  enddo;
end-proc;

//----------------------------------------------------------------------
// Builds and returns the callstack as XML.
//----------------------------------------------------------------------
dcl-proc appendCallStackVersion1;
  dcl-pi *n varchar(10000);
    fileHandle int(10) const;
    pCallstack  pointer const;
  end-pi;

  dcl-s text varchar(10000);

  text += escapeXml(buildCallStackVersion1(pCallstack));

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
//
dcl-proc appendCallStackVersion2;
  dcl-pi *n varchar(10000);
    fileHandle       int(10) const;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  dcl-s text varchar(10000);

  // start Json object
  Json_clear();
  Json_startObject(); // Json Root Object

  Json_addKey('callStack');
  Json_startArray(); // 'callstack'

  buildCallStackVersion2(testFailureEvent.pCallstk);

  Json_endArray(); // 'callstack'

  appendFailureValues(fileHandle: testFailureEvent);

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

  // end Json object
  Json_endObject(); // Json Root Object

  text = Json_get() + CRLF;

  return text;

end-proc;

//----------------------------------------------------------------------
// Produces the 'No value' message.
//----------------------------------------------------------------------
dcl-proc crtNoValueMsg;
  dcl-pi *n varchar(256) extproc(*dclcase);
    name       varchar(20) const;
    assertProc like(assertProcNm_t) const;
  end-pi;

  dcl-s message varchar(256) inz;

  message = 'No ''' + name + ''' value. Procedure '
            + assertProc
            + '() does not provide this information.';

  return message;

end-proc;

//----------------------------------------------------------------------
// Appends the log value (expected and actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc appendFailureValues;
  dcl-pi *n extproc(*dclcase);
    fileHandle       int(10) const;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  appendLogValue(LABEL_EXPECTED: testFailureEvent.logExpected);
  appendLogValue(LABEL_ACTUAL: testFailureEvent.logActual);

end-proc;

//----------------------------------------------------------------------
// Appends a log value (expected or actual) to the Json object.
//----------------------------------------------------------------------
dcl-proc appendLogValue;
  dcl-pi *n extproc(*dclcase);
    name     varchar(20) const;
    logValue likeds(logValue_t) const;
  end-pi;

  Json_addKey(name);
  Json_startObject(); // 'expected|accepted'

  if (logValue.value <> NO_VALUE);
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

//----------------------------------------------------------------------
// Writes the footer as XML.
//----------------------------------------------------------------------
dcl-proc writeFooter;
  dcl-pi *n;
    fileHandle int(10) const;
  end-pi;

  dcl-s text char(1000);

  text = '</testsuite>';
  writeA(fileHandle : text : %len(%trimr(text)));
end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 1 item.
//----------------------------------------------------------------------
dcl-proc buildCallStackVersion1;
  dcl-pi *n varchar(100000);
    pCallstk pointer const;
  end-pi;

  dcl-s text varchar(10000);
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += callstkEnt.qStmt.procNm + ' ('+
        %trim(callstkEnt.qStmt.qPgm.nm) + '->'+
        %trim(callstkEnt.qStmt.qMod.nm) + ':'+
        %trim(callstkEnt.qStmt.specNb) + ')' + CRLF;
  enddo;

  return text;
end-proc;

//----------------------------------------------------------------------
// Builds and returns a callstack version 2 item.
//----------------------------------------------------------------------
dcl-proc buildCallStackVersion2;
  dcl-pi *n;
    pCallstk pointer const;
  end-pi;

  dcl-s callStackItem varchar(1024);
  dcl-ds callstkEnt likeds(callstkEnt_t) inz;

  Callstack_resetIteration(pCallstk);
  dow (Callstack_getNext(pCallstk: callstkEnt));
    // example: iEqual (RUTESTCASE->ASSERT:124)
    callStackItem = callstkEnt.qStmt.procNm + ' ('
                      + %trim(callstkEnt.qStmt.qPgm.nm) + '->'
                      + %trim(callstkEnt.qStmt.qMod.nm) + ':'
                      + %trim(callstkEnt.qStmt.specNb) + ')';

    Json_addString(callStackItem);
  enddo;

end-proc;

//----------------------------------------------------------------------
// Escapes a given value for beeing added to a XML string.
//----------------------------------------------------------------------
// Use this StackOverflow answer for implementing escaping:
// https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
//----------------------------------------------------------------------
dcl-proc escapeXml;
  dcl-pi *n varchar(100000);
    xml varchar(100000) const;
  end-pi;

  dcl-s escaped varchar(100000);

  escaped = %scanrpl('&' : '&amp;' : escaped);
  escaped = %scanrpl('"' : '&quot;' : xml);
  escaped = %scanrpl('''' : '&apos;' : escaped);
  escaped = %scanrpl('<' : '&lt;' : escaped);
  escaped = %scanrpl('>' : '&gt;' : escaped);

  return escaped;
end-proc;

//----------------------------------------------------------------------
// Resolves the library name of a given object.
//----------------------------------------------------------------------
dcl-proc resolveObjectPath;
  dcl-pi *n likeds(object_t);
    object likeds(Object_t) const;
    type char(10) const;
  end-pi;

  dcl-pr sys_retrieveObjectDescription extpgm('QUSROBJD');
    receiver char(65535) options(*varsize);
    length int(10) const;
    format char(8) const;
    qualObjectName char(20) const;
    type char(10) const;
    errorCode likeds(errorCode_t) options(*nopass);
  end-pr;

  dcl-ds resolvedObject likeds(object_t);

  dcl-ds data qualified;
    bytesReturned int(10);
    bytesAvailable int(10);
    name char(10);
    library char(10);
    type char(10);
    returnLibrary char(10);
    auxStoragePoolNumber int(10);
    owner char(10);
    domain char(2);
    created char(13);
    changed char(13);
  end-ds;
  dcl-ds errorCode likeds(errorCode_t);

  if (object.lib <> '*LIBL');
    return object;
  endif;

  resolvedObject.nm = object.nm;

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);

  sys_retrieveObjectDescription(data : %size(data) : 'OBJD0100' : object : type : errorCode);
  if (errorCode.bytAvl = 0);
    resolvedObject.lib = data.returnLibrary;
  endif;

  return resolvedObject;
end-proc;

//----------------------------------------------------------------------
// Returns the name of the IBM i host.
//----------------------------------------------------------------------
dcl-proc getServerName;
  dcl-pi *n varchar(100) end-pi;

  dcl-pr gethostname int(10) extproc('gethostname');
    name pointer value;
    length int(10) value;
  end-pr;

  dcl-s name char(100);
  dcl-s rc int(10);

  rc = gethostname(%addr(name) : %size(name));
  if (rc = -1);
    return 'localhost';
  else;
    return %str(%addr(name));
  endif;
end-proc;

