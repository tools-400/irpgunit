**FREE
// ==========================================================================
//  iRPGUnit - Logging Facilities for CMDRUN.
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
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exports
//----------------------------------------------------------------------

/include qinclude,CMDRUNLOG

//----------------------------------------------------------------------
//   Imports
//----------------------------------------------------------------------

/include qinclude,CALLSTACK
/include qinclude,CMDRUNPRT
/include qinclude,TEMPLATES
/include qinclude,STRING
/include qinclude,VERSION
/include qinclude,OSVERSION

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

dcl-c INDENT '  ';
dcl-c SEPARATOR ' - ';
dcl-c LINE_SEPARATOR '-----------------------';
dcl-c SINGLE_QUOTE '''';
dcl-c TRUNCATED_INDICATOR '(!)';

dcl-c RIGHT_MARGIN 5;
dcl-c LEFT_MARGIN 5;

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Was the spool file header already printed?
dcl-s g_hdrWasPrinted   ind;
// Test service program being run.
dcl-ds g_srvPgm likeds(object_t);
// Specifies how detailed the test run report should be.
dcl-s g_detail char(10) inz(DETAIL_BASIC);
// Specifies whether a report is created.
dcl-s g_output char(10) inz(OUTPUT_ALLWAYS);
// Path and type of the XML stream file
dcl-ds g_xmlStmfInfo likeds(xmlStmfInfo_t) inz;
// Library list, the test suite is executed with.
dcl-ds g_liblData likeds(liblData_t) inz;
// Append 'truncated' information message.
dcl-s g_isLogTruncatedMessage ind inz(*off);
dcl-s g_truncatedMessageLength int(10);

//---------------------------------------------------------------------
//   Program Status Data Structure
//---------------------------------------------------------------------

/include qinclude,SDS

//----------------------------------------------------------------------
// Linefeed.
//----------------------------------------------------------------------
dcl-proc lineFeed export;
  dcl-pi *N;
  end-pi;

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  prtLine('');

end-proc;

//----------------------------------------------------------------------
// Log the completion message. See prototype.
//----------------------------------------------------------------------
dcl-proc logCompMsg export;
  dcl-pi *N;
    msg             varchar(16384) const  options(*varsize);
    failures        int(10) const;
    errors          int(10) const;
  end-pi;

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  if (g_output = OUTPUT_ERROR and (failures + errors = 0));
    return;
  endif;

  initPrinter();
  logHeader( g_srvPgm );
  logRawLine( msg );
  clsPrt();
  clear g_hdrWasPrinted;

end-proc;


//----------------------------------------------------------------------
// Log an error event. See prototype.
//----------------------------------------------------------------------
dcl-proc logError export;
  dcl-pi *N;
    testNm       like(procNm_t) const;
    excpMsgInfo  likeds(msg_t) const;
  end-pi;

  dcl-s line varchar(2048);

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  initPrinter();
  logHeader(g_srvPgm);

  prtLine( getLeftMargin() + %trimr(testNm) + SEPARATOR + 'ERROR' );

  line = '';
  if (excpMsgInfo.id <> '');
    line += excpMsgInfo.id;
    line += SEPARATOR;
  endif;
  line += excpMsgInfo.txt;
  logRawLine( line );

  if ( excpMsgInfo.qSndStmt.procnm <> *blank and
       excpMsgInfo.qSndStmt.qpgm.nm  <> *blank and
       excpMsgInfo.qSndStmt.specnb <> *blank );
    logStackEntry( excpMsgInfo.qSndStmt );
  endif;

  prtLine( getLeftMargin() + LINE_SEPARATOR );
  lineFeed();

end-proc;


//----------------------------------------------------------------------
// Log a failure event. See prototype.
//----------------------------------------------------------------------
dcl-proc logFailure export;
  dcl-pi *N;
    testNm           like(procNm_t) const;
    testFailureEvent likeds(testFailureEvent_t) const;
  end-pi;

  // Index.
  dcl-s i int(10);

  dcl-s pCallStk pointer;
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  initPrinter();
  logHeader(g_srvPgm);

  logRawLine(%trimr(testNm) + SEPARATOR + 'FAILURE');

  logRawLine(testFailureEvent.msg);

  // TODO: check callstack
  pCallstk = testFailureEvent.pCallstk;
  if (Callstack_getNumE(pCallstk) > 0);
    lineFeed(); // new with *TYPE2 log output of 'expected' and 'actual' values
    Callstack_resetIteration(pCallstk);
    dow (Callstack_getNext(pCallstk: callstkEnt));
      //logStackEntry(failure.callStk.entry(i).qStmt);
      logStackEntry(callStkEnt.qStmt);
    enddo;
    lineFeed(); // new with *TYPE2 log output of 'expected' and 'actual' values
  endif;

  // new with *TYPE2 log output of 'expected' and 'actual' values
  logValue(LABEL_EXPECTED: testFailureEvent.logExpected);
  logValue(LABEL_ACTUAL: testFailureEvent.logActual);
  logTruncated(testFailureEvent.logExpected: testFailureEvent.logActual);

  prtLine(getLeftMargin() + LINE_SEPARATOR);
  lineFeed();

end-proc;


//----------------------------------------------------------------------
// Prints the 'expexted' or 'actual' value in format:
// *...+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8
// Expected(!): 0001 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed'
//              0061 ' diam nonumy eirmod tempor invidunt ut labore et dolore magn'
//              0211 'a aliquyam erat, sed diam voluptua. At vero eos et accusam e'
//              0181 't justo duo dolores et ea rebum. Stet clita kasd'
// (!): Value trunacted to nnnn bytes.
//----------------------------------------------------------------------
dcl-proc logValue;
  dcl-pi *N extproc(*dclcase);
    name     varchar(20) const;
    logValue likeds(logValue_t) const;
  end-pi;

  dcl-c TAB_START_POS 14;
  dcl-c TAB_VALUE 19;

  dcl-s line varchar(132);
  dcl-s chunk varchar(132);
  dcl-s chunkSize int(10);
  dcl-s varName like(name);
  dcl-s startPos zoned(4:0);

  if (logValue.isTruncated);
      g_isLogTruncatedMessage = *on;
      g_truncatedMessageLength = logValue.length;
  endif;

  varName = name;
  %subst(varName: 1: 1) = uCase(%subst(varName: 1 :1));

  startPos = 1;

  // Print first line
  line = varName;
  if (logValue.isTruncated);
    line += ' ' + TRUNCATED_INDICATOR;
  endif;

  line += ':';

  if (logValue.length = 0);
    line = tab(line: TAB_VALUE);
    line += 'Not available';
    logRawLine(line);
    return;
  endif;

  chunkSize = (getPrtWidth() - LEFT_MARGIN - RIGHT_MARGIN) - TAB_VALUE - 2;
  chunkSize = %int(chunkSize / 10) * 10;

  dow (startPos <= logValue.length);
    if (startPos + chunkSize > logValue.length);
      chunkSize = logValue.length - startPos + 1;
    endif;

    chunk = %subst(logValue.value: startPos: chunkSize);

    line = tab(line: TAB_START_POS);
    line += rAlign(%char(startPos): %len(startPos));
    line = tab(line: TAB_VALUE);
    line += SINGLE_QUOTE + chunk + SINGLE_QUOTE;
    logRawLine(line);

    startPos += chunkSize;
    line = '';
  enddo;

end-proc;

//----------------------------------------------------------------------
// Prints an information message, if test values have been truncated.
// Message: '(!): Value trunacted to nnnn bytes.'
//----------------------------------------------------------------------
dcl-proc logTruncated;
  dcl-pi *N extproc(*dclcase);
    name  varchar(20) const;
    value likeds(logValue_t) const;
  end-pi;

  if (g_isLogTruncatedMessage);
    logRawLine(TRUNCATED_INDICATOR + ': Value trunacted to '
              + %char(g_truncatedMessageLength) + ' bytes.');
  endif;

end-proc;


//----------------------------------------------------------------------
// Initializes the printer.
//----------------------------------------------------------------------
dcl-proc initPrinter;
  dcl-pi *N extproc(*dclcase);
  end-pi;

  g_isLogTruncatedMessage = *off;
  g_truncatedMessageLength = 0;

end-proc;


//----------------------------------------------------------------------
// Print the report header.
//----------------------------------------------------------------------
dcl-proc logHeader;
  dcl-pi *N extproc(*dclcase);
    srvPgm      likeds(object_t) const;
  end-pi;

  dcl-s version         char(20);
  dcl-s date            char(10);

  if not g_hdrWasPrinted;
    getversion(version: date);
    opnPrt( srvPgm );
    logRawLine( '*** Tests of ' + %trim(srvPgm.nm) + ' ***');
    logRawLine('Date        : ' + %char(%date())
                                + ' / '+%char(%time():*hms));
    logRawLine('Job         : ' + getFormattedJob());
    logRawLine('User        : ' + %trimr(sds.curruser));
    logRawLine('iRPGUnit    : ' + 'v' + %trim(version));
    logRawLine('IBM i       : ' + OS_getVersion());

    lineFeed();

    logLibraryList(g_liblData);

    lineFeed();

    if (g_xmlStmfInfo.path <> '');
      logStmfPath('XML file    : ': g_xmlStmfInfo.path);
      logRawLine('XML type    : ' + g_xmlStmfInfo.type);
      lineFeed();
    endif;

    g_hdrWasPrinted = *on;
  endif;

end-proc;


//----------------------------------------------------------------------
// Outputs the path and type of the XML stream file produced:
//     XML file     : '/home/raddatz/very_long_stream_file_path_exceeding_56'
//                    '_charcaters/iRPGUnit_<TSTPGM>-2025-10-16.04.13.29.log'
//     XML type     : *TYPE2
//----------------------------------------------------------------------
dcl-proc logStmfPath export;
  dcl-pi *N;
    label varchar(80) value;
    path  like(stmf_t) value;
  end-pi;

  // Printing area width (in characters).
  dcl-s prtWidth int(10);
  dcl-s leftMargin varchar(32);
  dcl-s line varchar(2048);
  dcl-s isFirstLine ind;

  if (path = '');    // Do not log blank lines.
    return;
  endif;

  leftMargin = getLeftMargin();

  prtWidth = getPrtWidth() - %len(leftMargin) - RIGHT_MARGIN - %len(label) - (%len(QUOTE) * 2);

  line = path;

  isFirstLine = *on;
  dow (%len(line) > prtWidth);
    prtLine( leftMargin + label + QUOTE + %subst( line : 1 : prtWidth ) + QUOTE );
    line = %subst( line : prtWidth+1 );
    if (isFirstLine);
      leftMargin += spaces(%len(label));
      label = '';
      isFirstLine = *off;
    endif;
  enddo;

  if (%len(%trimr(line)) > 0);
    prtLine( leftMargin + QUOTE + line + QUOTE );
  endif;

end-proc;

//----------------------------------------------------------------------
// Append a line to the report. Splitt long lines.
// !!INFO!! Exported for self-test only.
//----------------------------------------------------------------------
dcl-proc logRawLine export;
  dcl-pi *N;
    line            varchar(2048) value;
  end-pi;

  // Printing area width (in characters).
  dcl-s prtWidth int(10);
  dcl-s leftMargin varchar(32);

  if (line = '');    // Do not log blank lines.
    return;
  endif;

  line = %trimr(line);
  leftMargin = getLeftMargin();

  prtWidth = getPrtWidth() - %len(leftMargin) - RIGHT_MARGIN;

  dow (%len(line) > prtWidth);
    prtLine( leftMargin + %subst( line : 1 : prtWidth ) );
    line = %subst( line : prtWidth+1 );
  enddo;

  if (%len(%trimr(line)) > 0);
    prtLine( leftMargin + line );
  endif;

end-proc;


//----------------------------------------------------------------------
// Append a SUCCESS message to the report.
//----------------------------------------------------------------------
dcl-proc logSuccess export;
  dcl-pi *N;
    testNm       like(procNm_t) const;
    assertionCnt int(10) const;
  end-pi;

  if (g_detail <> DETAIL_ALL);
    return;
  endif;

  if (g_output <> OUTPUT_ALLWAYS);
    return;
  endif;

  initPrinter();
  logHeader(g_srvPgm);

  logRawLine( %trimr(testNm) + ' - Success' );
  logRawLine( INDENT + %char(assertionCnt) + ' assertions' );
  logRawLine( LINE_SEPARATOR );
  lineFeed();

end-proc;


//----------------------------------------------------------------------
// Print a call stack entry.
//----------------------------------------------------------------------
dcl-proc logStackEntry export;
  dcl-pi *N;
    qSndStmt        const likeds(qStatement_t);
  end-pi;

  dcl-s line            varchar(256);

  line = fmtStackEntry( qSndStmt );
  logRawLine( line );

end-proc;


//----------------------------------------------------------------------
// Log runtime error.
//----------------------------------------------------------------------
dcl-proc logRuntimeError export;
  dcl-pi *N;
    line            varchar(2048) const  options(*varsize);
  end-pi;

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  initPrinter();
  logHeader(g_srvPgm);

  logRawLine( line );

end-proc;


//----------------------------------------------------------------------
// Log library list.
// Prints the library list in an arry of 3 items in a row by
// number of rows required. The minimum number of rows is 5:
//
// Output for up to 5 libraries:
//   Cur. library: LLLLLLLLLL
//   Library list: nnnn LLLLLLLLLL
//                 ...
//                 nnnn LLLLLLLLLL
//
// Output for 5+ libraries:
//   Cur. library: LLLLLLLLLL
//   Library list: nnnn LLLLLLLLLL   nnnn LLLLLLLLLL   nnnn LLLLLLLLLL
//                 ...
//                 nnnn LLLLLLLLLL   nnnn LLLLLLLLLL   nnnn LLLLLLLLLL
//----------------------------------------------------------------------
dcl-proc logLibraryList;
  dcl-pi *N extproc(*dclcase);
    libraryList likeds(liblData_t) const;
  end-pi;

  dcl-c min_num_rows 5;
  dcl-c step_width 10;

  dcl-s numRows int(10);
  dcl-s row int(10);
  dcl-s column int(10);
  dcl-s x int(10);
  dcl-s seq zoned(4);

  dcl-s line varchar(80);

  dcl-ds item qualified;
    seq    char(4);
    name   char(10) pos(6);
  end-ds;

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  line = 'Cur. library: ' + libraryList.curlib;
  logRawLine( line );

  if (libraryList.libl.numE = 0);
    line = 'Library list: *NONE';
    logRawLine( line );
    return;
  endif;

  numRows = %div(libraryList.libl.numE: 3);
  if (numRows * 3 <> libraryList.libl.numE);
    numRows += 1;
  endif;

  if (numRows < min_num_rows);
    numRows = min_num_rows;
  endif;

  for row = 1 to numRows;

    if (row = 1);
      line = 'Library list: ';
    endif;

    for column = 0 to 2;

      x = row + (column * numRows);
      if (x <= libraryList.libl.numE);
        seq = (row * step_width) + (column * (numRows * step_width));
        clear item;
        item.seq = %editc(seq: '3');
        item.name = libraryList.libl.lib(x);
        line = line + item + '   ';
      endif;

    endfor;

    logRawLine( line );
    line = '              ';

  endfor;

end-proc;


//----------------------------------------------------------------------
// Formats a call stack entry.
//----------------------------------------------------------------------
dcl-proc fmtStackEntry;
  dcl-pi *N like(line_t) extproc(*dclcase);
    qSndStmt likeds(qStatement_t) const;
  end-pi;

  dcl-s line like(line_t);
  // Specification number. Special value '*N' if not available.
  dcl-s specNb varchar(10);

  if (%trim(qSndStmt.specnb) = '');
    specNb = NO_VALUE;
  else;
    specNb = %triml(%trim(qSndStmt.specnb): '0');
  endif;

  line = INDENT
       + %trim(qSndStmt.procnm)
       + ' ('
       + %trim(qSndStmt.qpgm.nm)
       + '->'
       + %trim(qSndStmt.qmod.nm)
       + ':'
       + %trim(specNb)
       + ')';
  return line;

end-proc;


dcl-proc setLogContext export;
  dcl-pi *N;
    testPgm         const likeds(object_t);
    detail          char(10) const;
    output          char(10) const;
    xmlStmfInfo     likeds(xmlStmfInfo_t) const;
  end-pi;

  g_srvPgm = testPgm;
  g_detail = detail;
  g_output = output;
  g_xmlStmfInfo = xmlStmfInfo;

end-proc;


dcl-proc updateLogContext export;
  dcl-pi *N;
    liblData        const likeds(liblData_t);
  end-pi;

  g_liblData = liblData;

end-proc;


dcl-proc getLogSplF export;
  dcl-pi *N likeds(splf_t);
  end-pi;

  dcl-ds splf likeds(splf_t);

  clear splf;

  if (g_hdrWasPrinted);
    splf = getSplF();
  endif;

  return getSplF();

end-proc;


dcl-proc getFormattedJob;
  dcl-pi *N varchar(32) extproc(*dclcase);
  end-pi;

  return %editc(sds.nbr: 'X') + '/' +
         %trimr(sds.user) + '/' +
         %trim(sds.job);

end-proc;


dcl-proc getLeftMargin;
  dcl-pi *N varchar(32) extproc(*dclcase);
  end-pi;

  dcl-s leftMargin varchar(32) static;

  if (%len(leftMargin) <> LEFT_MARGIN);
    leftMargin = spaces(LEFT_MARGIN);
  endif;

  return leftMargin;

end-proc;

