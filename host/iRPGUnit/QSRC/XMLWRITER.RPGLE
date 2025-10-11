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
/include qinclude,ASSERT
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

dcl-c CRLF x'0d25';
dcl-c TAB '    ';

dcl-ds g_status qualified inz;
  xmlType             like(xmlType_t);
  json                varchar(50000);
  json_countObject    int(10);
  json_countArray     int(10);
  json_indent         int(10);
  json_isValueAllowed ind inz(*off);
  json_isPrettyPrint  ind inz(*on);
end-ds;

dcl-proc writeXmlFile export;
  dcl-pi *n;
    filepath      char(1024) const;
    testSuite     likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result        likeds(result_t) const;
    xmlType       like(xmlType_t) const;
  end-pi;

  dcl-s fileHandle int(10);
  dcl-s rc int(10);

  clear g_status;
  g_status.xmlType = xmlType;

  fileHandle = getXmlFileHandle(filepath);
  writeHeader(fileHandle : testSuite : testSuiteName : result);
  writeProperties(fileHandle);
  writeTestCases(fileHandle : testSuite : testSuiteName : result);
  writeFooter(fileHandle);

  if (fileHandle >= 0);
    rc = close(fileHandle);
  endif;
end-proc;


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
  fileHandle = open(%trimr(filePath) : flags : mode : 819 : 0);
  if (fileHandle < 0);
    // could not open file handle
    errorPtr = errno();
    sndEscapeMsg('Could not create file ' + %trimr(filePath) +
                 ': ' + %str(strError(errorNumber)) :
                 ONE_CALL_STK_LVL_ABOVE);
  endif;

  return fileHandle;
end-proc;


dcl-proc writeHeader;
  dcl-pi *n;
    fileHandle int(10) const;
    testSuite likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result likeds(result_t) const;
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


dcl-proc writeTestCases;
  dcl-pi *n;
    fileHandle int(10) const;
    testSuite likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result likeds(result_t) const;
  end-pi;

  dcl-ds testResult likeds(TestResult_t) based(ptr);
  dcl-s text varchar(50000);
  dcl-s rc int(10);
  dcl-s execTime packed(15:3);

  list_abortIteration(testSuite.testResults);
  ptr = list_getNext(testSuite.testResults);
  dow (ptr <> *null);

    execTime = testResult.execTime / %dec(1000000 : 15 : 3);

    text = TAB + '<testcase name="' + %trimr(testResult.testName) + '" ';
    text += 'assertions="' + %char(testResult.assertCnt) + '" ';
    text += 'classname="' + %trimr(testSuiteName.nm) + '" '; // TODO should look which modules
    text += 'time="' + %char(exectime) + '" ';               // exports this testcase
    text += '>' + CRLF;

    select;
    when (testResult.outcome = TEST_CASE_ERROR);

      // start <error> element
      text += TAB + TAB + '<error message="' + escapeXml(%trimr(testResult.error.txt)) +
          '" type="' + escapeXml(%trimr(testResult.error.id)) + '">' + CRLF;
      text += escapeXml(
          %trimr(testResult.error.qSndStmt.procNm) + ' (' +
          %trim(testResult.error.qSndStmt.qPgm.nm) + '->' +
          %trim(testResult.error.qSndStmt.qMod.nm) + ':');

      if (testResult.error.qSndStmt.specNb = *blank);
        text += '*N)' + CRLF;
      else;
        text += escapeXml(%trim(testResult.error.qSndStmt.specNb) + ')') + CRLF;
      endif;

      // close <error> element
      text += TAB + TAB + '</error>' + CRLF;

    when (testResult.outcome = TEST_CASE_FAILURE);

      // start <failure> element
      text += TAB + TAB + '<failure message="';
      text += escapeXml(%trimr(testResult.failure.msg));
      text += '">';
      text += '<![CDATA[' + CRLF;

      // always the first section of the <failure> element
      if (g_status.xmlType = XML_TYPE_1);
        text += appendCallStackType1(fileHandle: testResult.failure.callstk);
      else;
        text += appendCallStackType2(fileHandle: testResult);
      endif;

      // close <failure> element
      text += TAB + TAB + ']]>';
      text += '</failure>' + CRLF;

    other;
      // test case ran successful
    endsl;

    // close <testcase> element
    text += TAB + '</testcase>' + CRLF;
    rc = write(fileHandle : %addr(text : *data) : %len(text));

    ptr = list_getNext(testSuite.testResults);
  enddo;
end-proc;


dcl-proc appendCallStackType1;
  dcl-pi *n varchar(10000);
    fileHandle int(10) const;
    callstack  likeds(CallStk_t) const;
  end-pi;

  dcl-s text varchar(10000);

  text += escapeXml(buildCallStackType1(callstack));

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
dcl-proc appendCallStackType2;
  dcl-pi *n varchar(10000);
    fileHandle int(10) const;
    testResult likeds(testResult_t) const;
  end-pi;

  dcl-s text varchar(10000);

  // start Json object
  Json_clear();
  Json_startObject(); // Json Root Object

  Json_addKey('callStack');
  Json_startArray(); // 'callstack'

  buildCallStackType2(testResult.failure.callstk);

  Json_endArray(); // 'callstack'

  buildFailureValues(fileHandle: testResult.failure);

  // add diagnostic messages
  if (testResult.failure.logExpected.type = DT_UNDEFINED or
      testResult.failure.logActual.type = DT_UNDEFINED);

    Json_addKey('diagnosticMessages');
    Json_startArray();

    if (testResult.failure.logExpected.type = DT_UNDEFINED);
      Json_addString(crtNoValueMsg(LABEL_EXPECTED: testResult.failure.logExpected.assertProc));
    endif;

    if (testResult.failure.logActual.type = DT_UNDEFINED);
      Json_addString(crtNoValueMsg(LABEL_ACTUAL: testResult.failure.logActual.assertProc));
    endif;

    Json_endArray(); // 'diagnosticMessages'
  endif;

  // end Json object
  Json_endObject(); // Json Root Object

  text = Json_get() + CRLF;

  return text;

end-proc;


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


dcl-proc buildFailureValues;
  dcl-pi *n extproc(*dclcase);
    fileHandle int(10) const;
    failure    likeds(testResult_t.failure) const;
  end-pi;

  buildLogValue(LABEL_EXPECTED: failure.logExpected);
  buildLogValue(LABEL_ACTUAL: failure.logActual);

end-proc;


dcl-proc buildLogValue;
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


dcl-proc writeFooter;
  dcl-pi *n;
    fileHandle int(10) const;
  end-pi;

  dcl-s text char(1000);

  text = '</testsuite>';
  writeA(fileHandle : text : %len(%trimr(text)));
end-proc;


dcl-proc buildCallStackType1;
  dcl-pi *n varchar(100000);
    callstack likeds(CallStk_t) const;
  end-pi;

  dcl-s text varchar(10000);
  dcl-s i int(10);

  for i = 1 to callstack.nume;
    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += callstack.entry(i).qStmt.procNm + ' (' +
        %trim(callstack.entry(i).qStmt.qPgm.nm) + '->' +
        %trim(callstack.entry(i).qStmt.qMod.nm) + ':' +
        %trim(callstack.entry(i).qStmt.specNb) + ')' + CRLF;
  endfor;

  return text;
end-proc;


dcl-proc buildCallStackType2;
  dcl-pi *n;
    callstack likeds(CallStk_t) const;
  end-pi;

  dcl-s callStackItem varchar(1024);
  dcl-s i int(10);

  for i = 1 to callstack.nume;
    // example: iEqual (RUTESTCASE->ASSERT:124)
    callStackItem = callstack.entry(i).qStmt.procNm + ' ('
                      + %trim(callstack.entry(i).qStmt.qPgm.nm) + '->'
                      + %trim(callstack.entry(i).qStmt.qMod.nm) + ':'
                      + %trim(callstack.entry(i).qStmt.specNb) + ')';

    Json_addString(callStackItem);
  endfor;

end-proc;


// Using this SO answer for implementing escaping:
// https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
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

