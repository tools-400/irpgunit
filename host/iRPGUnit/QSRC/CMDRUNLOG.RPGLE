**FREE
// ==========================================================================
//  iRPGUnit - Logging Facilities for CMDRUN.
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

/include qinclude,CMDRUNPRT
/include qinclude,TEMPLATES
/include qinclude,STRING
/include qinclude,VERSION
/include qinclude,OSVERSION

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

// Log a header message.
dcl-pr logHdr extproc('logHdr');
  // Name of the service program containing the tests.
  srvPgm          const likeds(object_t);
end-pr;

dcl-pr getFormattedJob varchar(32) extproc('getFormattedJob');
end-pr;

dcl-pr getLeftMargin varchar(32) extproc('getLeftMargin');
end-pr;

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

dcl-c INDENT         '  ';
dcl-c SEPARATOR      ' - ';
dcl-c LINE_SEPARATOR '-----------------------';

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
// Library list, the test suite is executed with.
dcl-ds g_liblData likeds(liblData_t) inz;

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

  logHdr( g_srvPgm );
  logRawLine( msg );
  clsPrt();
  clear g_hdrWasPrinted;

end-proc;


//----------------------------------------------------------------------
// Log an error event. See prototype.
//----------------------------------------------------------------------
dcl-proc logError export;
  dcl-pi *N;
    testNm          const like(procNm_t);
    excpMsgInfo     const likeds(msg_t);
  end-pi;

  dcl-s line varchar(2048);

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  logHdr( g_srvPgm );

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
dcl-proc logfailure export;
  dcl-pi *N;
    testNm          const like(procNm_t);
    failure         const likeds(assertFailEvtLong_t);
  end-pi;

  // Index.
  dcl-s i int(10);

  if (g_output = OUTPUT_NONE);
    return;
  endif;

  logHdr( g_srvPgm );

  logRawLine( %trimr(testNm) + SEPARATOR + 'FAILURE' );
  logRawLine( failure.msg );

  for i = 1 to failure.callStk.numE;
    logStackEntry( failure.callStk.entry(i).qStmt );
  endfor;

  prtLine( getLeftMargin() + LINE_SEPARATOR );
  lineFeed();

end-proc;


//----------------------------------------------------------------------
// Print the report header.
//----------------------------------------------------------------------
dcl-proc logHdr;
  dcl-pi *N;
    srvPgm          const likeds(object_t);
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
    g_hdrWasPrinted = *on;
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

  dcl-c right_margin 5;

  if (line = '');    // Do not log blank lines.
    return;
  endif;

  line = %trimr(line);
  leftMargin = getLeftMargin();

  prtWidth = getPrtWidth() - %len(leftMargin) - right_margin;

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
    testNm          const like(procNm_t);
    assertionCnt    int(10) const;
  end-pi;

  if (g_detail <> DETAIL_ALL);
    return;
  endif;

  if (g_output <> OUTPUT_ALLWAYS);
    return;
  endif;

  logHdr( g_srvPgm );

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

  logHdr( g_srvPgm );

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
  dcl-pi *N;
    libraryList     const likeds(liblData_t);
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
    lineFeed();
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

  lineFeed();

end-proc;


//----------------------------------------------------------------------
// Formats a call stack entry.
//----------------------------------------------------------------------
dcl-proc fmtStackEntry;
  dcl-pi *N like(line_t);
    qSndStmt        const likeds(qStatement_t);
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
  end-pi;

  g_srvPgm = testPgm;
  g_detail = detail;
  g_output = output;

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
  dcl-pi *N              varchar(32);
  end-pi;

  return %editc(sds.nbr: 'X') + '/' +
         %trimr(sds.user) + '/' +
         %trim(sds.job);

end-proc;


dcl-proc getLeftMargin;
  dcl-pi *N              varchar(32);
  end-pi;

  dcl-s leftMargin varchar(32) static;

  dcl-c LEFT_MARGIN 5;

  if (%len(leftMargin) <> LEFT_MARGIN);
    leftMargin = spaces(LEFT_MARGIN);
  endif;

  return leftMargin;

end-proc;

