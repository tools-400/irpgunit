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

dcl-proc writeXmlFile export;
  dcl-pi *n;
    filepath char(1024) const;
    testSuite likeds(testSuite_t) const;
    testSuiteName likeds(Object_t) const;
    result likeds(result_t) const;
  end-pi;

  dcl-s fileHandle int(10);
  dcl-s rc int(10);

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
                 ': ' + %str(strerror(errorNumber)) :
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
  text += TAB + TAB + '<property name="irpgunit.version" value="' + cRPGUNIT_VERSION + '"/>' + CRLF;

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
        text += TAB + TAB + '<error message="' + escapeXml(%trimr(testResult.error.txt)) +
            '" type="' + escapeXml(%trimr(testResult.error.id)) + '">' + CRLF;
        text += escapeXml(
            %trimr(testResult.error.sender.procNm) + ' (' +
            %trim(testResult.error.sender.qPgm.nm) + '->' +
            %trim(testResult.error.sender.qMod.nm) + ':');
        if (testResult.error.sender.specNb = *blank);
            text += '*N)' + CRLF;
        else;
            text += escapeXml(%trim(testResult.error.sender.specNb) + ')') + CRLF;
        endif;
        text += TAB + TAB + '</error>' + CRLF;

      when (testResult.outcome = TEST_CASE_FAILURE);
        text += TAB + TAB + '<failure message="';
        text += %trimr(testResult.failure.msg);
        text += '">' + CRLF;
        text += escapeXml(buildCallStack(testResult.failure.callStk));
        text += TAB + TAB + '</failure>' + CRLF;

      other;
        // test case ran successful
    endsl;

    text += TAB + '</testcase>' + CRLF;

    rc = write(fileHandle : %addr(text : *data) : %len(text));

    ptr = list_getNext(testSuite.testResults);
  enddo;
end-proc;


dcl-proc writeFooter;
  dcl-pi *n;
    fileHandle int(10) const;
  end-pi;

  dcl-s text char(1000);

  text = '</testsuite>';
  writeA(fileHandle : text : %len(%trimr(text)));
end-proc;


dcl-proc buildCallStack;
  dcl-pi *n varchar(100000);
    callstack likeds(CallStk_t) const;
  end-pi;

  dcl-s text varchar(10000);
  dcl-s i int(10);

  for i = 1 to callstack.nume;
    if (callstack.entry(i).sender.qPgm.nm = 'RUCALLXML');
      leave;
    endif;

    // example: iEqual (RUTESTCASE->ASSERT:124)
    text += callstack.entry(i).sender.procNm + ' (' +
        %trim(callstack.entry(i).sender.qPgm.nm) + '->' +
        %trim(callstack.entry(i).sender.qMod.nm) + ':' +
        %trim(callstack.entry(i).sender.specNb) + ')' + CRLF;
  endfor;

  return text;
end-proc;


// Using this SO answer for implementing escaping:
// https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
dcl-proc escapeXml;
  dcl-pi *n varchar(100000);
    xml varchar(100000) const;
  end-pi;

  dcl-s escaped varchar(100000);
  dcl-s x int(10);

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
  dcl-s library char(10) inz('*LIBL');
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

