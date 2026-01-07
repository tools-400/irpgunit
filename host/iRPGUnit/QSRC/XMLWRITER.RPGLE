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
/include qinclude,CALLSTACK
/include qinclude,CMDRUNSRV
/include qinclude,JENKINS
/include qinclude,PGMMSG
/include qinclude,CMDRUN
/include qinclude,OSVERSION
/include qinclude,LIBL
/include qinclude,LIBC_H
/include qinclude,IFSIO_H
/include qinclude,ERRNO_H
/include qinclude,ERRORCODE
/include qinclude,VSCODE
/include qllist,llist_h

/include qinclude,XMLWRITER

// Use hex constants to define variant character in UTF-8.
// This way RPG correctly translates the strings to the current job CCSID.
// See: https://www.ibm.com/docs/en/i/7.5.0?topic=considerations-runtime-character-set
dcl-c UTF8_START_CDATA u'003C0021005B00430044004100540041005B';
dcl-c UTF8_END_CDATA u'005D005D003E';

// The constents below are made of invariant charcaters.
dcl-c XML_OUTCOME_SUCCESS 'Success';
dcl-c XML_OUTCOME_FAILURE 'Failure';
dcl-c XML_OUTCOME_ERROR 'Error';

dcl-c TAB '  ';

dcl-ds g likeds(sharedChars_t) export;
dcl-ds g_xmlWriter likeds(xmlWriter_t) export;

dcl-s g_hFile int(10);

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
    onFailure       like(onFailure_t) const;
    isJUnitStyle    ind const;
  end-pi;

  dcl-s rc int(10);
  dcl-s indLvl int(10);

  initVariantCharacters();

  clear g_xmlWriter;
  g_xmlWriter.xmlType = xmlType;
  g_xmlWriter.onFailure = onFailure;
  g_xmlWriter.isJUnitStyle = isJUnitStyle;
  g_xmlWriter.isPrettyPrint = *on;
  g_xmlWriter.indLvl = 0;
  g_hFile = -1;

  g_hFile = getXmlFileHandle(filepath);

  writeHeader(g_hFile : testSuite : testSuiteName : testSuiteResult: indLvl);
  writeProperties();

  select;
  when (g_xmlWriter.xmlType = XML_JENKINS_TYPE_1);
    writeTestCasesJenkinsStyle(testSuite: testSuiteName: testSuiteResult);
  when (g_xmlWriter.xmlType = XML_JENKINS_TYPE_2);
    writeTestCasesJenkinsStyle(testSuite: testSuiteName: testSuiteResult);
  when (g_xmlWriter.xmlType = XML_TYPE_VSCODE_1);
    VSCode_writeTestCases(testSuite: testSuiteName: testSuiteResult);
  other;
    sndEscapeMsgAboveCtlBdy('Invalid XML type: ' + %trim(xmlType));
  endsl;

  writeFooter();

  if (g_hFile >= 0);
    rc = close(g_hFile);
    g_hFile = -1;
  endif;

  if (g_xmlWriter.indLvl <> 0);
    sndEscapeMsgAboveCtlBdy('''g_xmlWriter.indLvl'' must be 0.');
  endif;

end-proc;

//----------------------------------------------------------------------
// Initializes variant characters.
// Characters are translated from UTF-8 to the job CCSID.
//----------------------------------------------------------------------
dcl-proc initVariantCharacters;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g.START_CDATA = UTF8_START_CDATA;
  g.END_CDATA = UTF8_END_CDATA;

end-proc;

//----------------------------------------------------------------------
// Opens the XML file and returns the file handle.
//----------------------------------------------------------------------
dcl-proc getXmlFileHandle;
  dcl-pi *n int(10) extproc(*dclcase);
    filePath char(1024) const;
  end-pi;

  dcl-s hFile int(10);
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
  hFile = open(%trimr(filePath) : flags : mode : 1208 : 0);
  if (hFile < 0);
    // could not open file handle
    errorPtr = errno();
    sndEscapeMsg('Could not create file ' + %trimr(filePath) + ': ' + %str(strError(errorNumber))
                 : ONE_CALL_STK_LVL_ABOVE);
  endif;

  return hFile;
end-proc;

//----------------------------------------------------------------------
// Writes the XML header section.
//----------------------------------------------------------------------
dcl-proc writeHeader;
  dcl-pi *n extproc(*dclcase);
    fileHandle    int(10) const;
    testSuite     likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result        likeds(testSuiteResult_t) const;
    indLevel      int(10);
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-ds resolvedObject likeds(object_t);

  resolvedObject = resolveObjectPath(testSuiteName : '*SRVPGM');

  text = '<?xml version="1.0" encoding="UTF-8" ?>' + newLine() +
         '<testsuite errors="' + %char(result.errorCnt) + '"' +
         ' failures="' + %char(result.failureCnt) + '"' +
         ' hostname="' + getServerName() + '"' +
         ' id="0"' +
         ' name="' + %trimr(resolvedObject.lib) + '/' + %trimr(resolvedObject.nm) + '"' +
         ' tests="' + %char(testSuite.testCasesCnt) + '">' + newLine();

  appendToXmlFile(text);

end-proc;

//----------------------------------------------------------------------
// Writes the XML properties section.
//----------------------------------------------------------------------
dcl-proc writeProperties;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text like(xmlBuffer_t);
  dcl-ds libl likeds(LiblData_t);
  dcl-s i int(10);

  g_xmlWriter.indLvl += 1;

  text = indent() + '<properties>' + newLine();
  appendToXmlFile(text);

  libl = getLibl();

  if (libl.curLib <> *blank);
    writeProperty('currentlibrary': %trimr(libl.curLib));
  endif;

  if (libl.libl.nume > 0);
    text = '';
    for i = 1 to libl.libl.nume;
      if (i > 1);
        text += ' ';
      endif;
      text += %trimr(libl.libl.lib(i));
    endfor;
    writeProperty('user.librarylist': text);
  endif;

  writeProperty('os.version': OS_getVersion());
  writeProperty('irpgunit.version': RPGUNIT_VERSION);
  writeProperty('output.type': %trim(g_xmlWriter.xmlType));
  writeProperty('onFailure': %trim(g_xmlWriter.onFailure));

  text = indent() + '</properties>' + newLine();
  appendToXmlFile(text);

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-proc writeProperty;
  dcl-pi *n extproc(*dclcase);
    name  like(xmlName_t) const;
    value like(xmlValue_t) options(*varsize) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  g_xmlWriter.indLvl += 1;

  text = indent() + '<property name="' + name + '" value="' + value + '"/>' + newLine();
  appendToXmlFile(text);

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Writes the XML test cases section.
//----------------------------------------------------------------------
dcl-proc writeTestCasesJenkinsStyle;
  dcl-pi *n extproc(*dclcase);
    testSuite     likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result        likeds(testSuiteResult_t) const;
  end-pi;

  dcl-ds testCaseResult likeds(testCaseResult_t) based(pTestResult);
  dcl-s text like(xmlBufferLarge_t);
  dcl-s execTimeSecs like(execTimeSecs_t);

  dcl-ds abstractTestEvent likeds(abstractTestEvent_t) based(pAbstractTestEvent);

  dcl-s isSuccessEvent ind;

  g_xmlWriter.indLvl += 1;

  // Iterate the test cases...
  list_resetIteration(testSuite.testResults);
  pTestResult = list_getNext(testSuite.testResults);
  dow (pTestResult <> *null);

    execTimeSecs = getReportExecTimeSecs(testCaseResult);

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
// Returns the XML representation of a test case event.
//----------------------------------------------------------------------
dcl-proc writeTestCaseEventXml export;
  dcl-pi *n;
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s text like(xmlBufferLarge_t);

  g_xmlWriter.indLvl += 1;

  text = '';

  select;
  when (abstractTestEvent.outcome = TEST_CASE_ERROR);

    // start <error> element
    text += indent() + '<error message="'
            + escapeXml(%trimr(abstractTestEvent.error.msg.txt))
            + '" type="' + escapeXml(%trimr(abstractTestEvent.error.msg.id)) + '">'
            + newLine();
    text += escapeXml(%trimr(abstractTestEvent.error.msg.qSndStmt.procNm) + ' ('
                      + %trim(abstractTestEvent.error.msg.qSndStmt.qPgm.nm) + '->'
                      + %trim(abstractTestEvent.error.msg.qSndStmt.qMod.nm) + ':');

    if (abstractTestEvent.error.msg.qSndStmt.specNb = *blank);
      text += '*N)' + newLine();
    else;
      text += escapeXml(%trim(abstractTestEvent.error.msg.qSndStmt.specNb) + ')') + newLine();
    endif;

    // close <error> element
    text += indent() + '</error>' + newLine();
    appendToXmlFile(text);

  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);

    // start <failure> element
    text += indent() + '<failure message="';
    text += escapeXml(%trimr(abstractTestEvent.failure.msg));
    text += '">';
    appendToXmlFile(text);

    // always the first section of the <failure> element
    if (g_xmlWriter.xmlType = XML_JENKINS_TYPE_1);
      Jenkins_writeTestCaseFailureV1(abstractTestEvent.failure.pCallstk);
    else;
      Jenkins_writeTestCaseFailureAsText(abstractTestEvent.failure);
    endif;

    // close <failure> element
    text = '</failure>' + newLine();
    appendToXmlFile(text);

  endsl;

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Returns the name of the test case as is.
//----------------------------------------------------------------------
dcl-proc getTestCaseName export;
  dcl-pi *n like(procNm_t);
    testCaseResult likeds(testCaseResult_t) const;
  end-pi;

  dcl-s testCaseName like(procNm_t);

  testCaseName = testCaseResult.testName;

  return testCaseName;

end-proc;

//----------------------------------------------------------------------
// Returns the name of the assertion depending of the test case type.
//----------------------------------------------------------------------
dcl-proc getAssertProcName export;
  dcl-pi *n like(procNm_t);
    abstractTestEvent likeds(abstractTestEvent_t) const;
  end-pi;

  dcl-s assertProcName like(procNm_t);

  select;
  when (abstractTestEvent.outcome = TEST_CASE_SUCCESS);
    assertProcName = abstractTestEvent.success.assertProc;
  when (abstractTestEvent.outcome = TEST_CASE_FAILURE);
    assertProcName = abstractTestEvent.failure.assertProc;
  other;
    assertProcName = '';
  endsl;

  return assertProcName;

end-proc;

//----------------------------------------------------------------------
// Returns the XML representation of 'outcome'.
//----------------------------------------------------------------------
dcl-proc outcomeToXml export;
  dcl-pi *n varchar(30);
    outcome like(outcome_t) const;
  end-pi;

  dcl-s xmlOutcome varchar(30);

  select;
  when (outcome = TEST_CASE_SUCCESS);
    xmlOutcome = XML_OUTCOME_SUCCESS;
  when (outcome = TEST_CASE_FAILURE);
    xmlOutcome = XML_OUTCOME_FAILURE;
  when (outcome = TEST_CASE_ERROR);
    xmlOutcome = XML_OUTCOME_ERROR;
  other;
    sndEscapeMsgAboveCtlBdy('Unexpected ''outcome'': ' + outcome);
  endsl;

  return xmlOutcome;

end-proc;

//----------------------------------------------------------------------
// Write an XML element.
//----------------------------------------------------------------------
dcl-proc writeXmlElement export;
  dcl-pi *n;
    name  like(xmlName_t) options(*varsize) const;
    value like(xmlValue_t) options(*varsize) const;
  end-pi;

  dcl-s text like(xmlBuffer_t);

  g_xmlWriter.indLvl += 1;

  text = indent() + startXmlElement(name);
  text += value;
  text += endXmlElement(name) + newLine();
  appendToXmlFile(text);

on-exit;
  g_xmlWriter.indLvl -= 1;

end-proc;

//----------------------------------------------------------------------
// Produces the 'No value' message.
//----------------------------------------------------------------------
dcl-proc crtNoValueMsg export;
  dcl-pi *n varchar(256);
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
// Writes the footer as XML.
//----------------------------------------------------------------------
dcl-proc writeFooter;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text like(xmlBuffer_t);

  text = '</testsuite>';
  appendToXmlFile(text);
end-proc;

//----------------------------------------------------------------------
// Escapes a given value for beeing added to a XML string.
//----------------------------------------------------------------------
// Use this StackOverflow answer for implementing escaping:
// https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
//----------------------------------------------------------------------
dcl-proc escapeXml export;
  dcl-pi *n like(xmlBuffer_t);
    xml like(xmlBuffer_t) options(*varsize) const;
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
  dcl-pi *n likeds(object_t) extproc(*dclcase);
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
  dcl-pi *n varchar(100) extproc(*dclcase);
  end-pi;

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

//----------------------------------------------------------------------
// Returns the indention for pretty printing.
//----------------------------------------------------------------------
dcl-proc indent export;
  dcl-pi *n varchar(100);
  end-pi;

  dcl-s i int(10);
  dcl-s indention varchar(100);

  indention = '';

  if (g_xmlWriter.isPrettyPrint);
    for i = 1 to g_xmlWriter.indLvl;
      indention += TAB;
    endfor;
  endif;

  return indention;

end-proc;

//----------------------------------------------------------------------
// Returns the linefeed character for pretty printing.
//----------------------------------------------------------------------
dcl-proc newLine export;
  dcl-pi *n varchar(10);
  end-pi;

  dcl-s linefeed varchar(10);

  if (g_xmlWriter.isPrettyPrint);
    linefeed = CRLF;
  else;
    linefeed = '';
  endif;

  return linefeed;

end-proc;

//----------------------------------------------------------------------
// Starts an XML element.
//----------------------------------------------------------------------
dcl-proc startXmlElement export;
  dcl-pi *n like(xmlName_t);
    name   like(xmlName_t) value;
  end-pi;

  dcl-s element like(xmlName_t);

  element = '<' + name + '>';

  return element;

end-proc;

//----------------------------------------------------------------------
// Starts an XML element.
//----------------------------------------------------------------------
dcl-proc endXmlElement export;
  dcl-pi *n like(xmlName_t);
    name   like(xmlName_t) value;
  end-pi;

  dcl-s element like(xmlName_t);

  element = '</' + name + '>';

  return element;

end-proc;

//----------------------------------------------------------------------
// Produces an empty XML element.
//----------------------------------------------------------------------
dcl-proc emptyXmlElement export;
  dcl-pi *n like(xmlName_t);
    name   like(xmlName_t) value;
  end-pi;

  dcl-s element like(xmlName_t);

  element = '<' + name + '/>';

  return element;

end-proc;

//----------------------------------------------------------------------
// Writes the specified data to the XML output file.
//----------------------------------------------------------------------
dcl-proc appendToXmlFile export;
  dcl-pi *n;
    text like(xmlBufferLarge_t) options(*varsize);
  end-pi;

  dcl-s rc int(10);

  rc =  write(g_hFile : %addr(text : *data) : %len(text));

  %len(text) = 0;

end-proc;

