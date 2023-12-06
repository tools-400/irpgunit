**FREE
// ==========================================================================
//  iRPGUnit - String Utilities.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
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

ctl-opt NoMain;
/define NO_DECEDIT
/include qinclude,H_SPEC
ctl-opt decedit(*jobrun);
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,STRING


//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,SYSTEMAPI
/include qinclude,PGMMSG


//----------------------------------------------------------------------
//   Type Templates
//----------------------------------------------------------------------
/include qinclude,TEMPLATES

dcl-ds errCode_t qualified               based(pDummy);
  bytPrv int(10);
  bytAvl int(10);
  excID char(7);
  reserved_1 char(1);
  excDta char(512);
end-ds;


//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------


//----------------------------------------------------------------------
//  Converts a given string to upper case.
//----------------------------------------------------------------------
dcl-proc uCase export;
  dcl-pi *n like(String_t);
    string  like(String_t) const options(*varsize);
  end-pi;

  dcl-s uCase varchar(4096) inz;

  dcl-s stringBuf char(4096) inz;
  dcl-ds errCode likeds(errCode_t ) inz;

  dcl-ds reqCtrlBlk likeds(reqCtrlBlk_ccsid_t) inz;


  if (string = '');
    return string;
  endif;

  clear reqCtrlBlk;
  reqCtrlBlk.type     = cCVTCASE_TYPE_ccsid;
  reqCtrlBlk.CCSID    = cCVTCASE_CCSID_Job;
  reqCtrlBlk.case     = cCVTCASE_toUpper;
  reqCtrlBlk.reserved = *ALLx'00';
  clear errCode;
  QlgConvertCase(reqCtrlBlk:
                 string: stringBuf: %len(string): errCode);
  uCase = %subst(stringBuf: 1: %len(string));

  return uCase;

end-proc;


//----------------------------------------------------------------------
//  Returns the a given number of characters starting at the
//  left side of a given string.
//----------------------------------------------------------------------
dcl-proc leftStr export;
  dcl-pi *n like(String_t);
    string  like(String_t) const options(*varsize);
    length  int(10) const;
  end-pi;

  dcl-s subString like(string);

  if (length <= %len(string));
    subString = %subst(string: 1: length);
  else;
    subString = string;
  endif;

  return subString;

end-proc;


//----------------------------------------------------------------------
//  Tests if a given string starts with the specified prefix.
//----------------------------------------------------------------------
dcl-proc startsWith export;
  dcl-pi *n ind;
    prefix  like(String_t) const options(*varsize);
    string  like(String_t) const options(*varsize);
  end-pi;

  if (%len(string) = 0  or
      %len(prefix) = 0  or
      %len(string) < %len(prefix));
    return *OFF;
  endif;

  if (uCase(%subst(string: 1: %len(prefix))) <> uCase(prefix));
    return *OFF;
  endif;

  return *ON;

end-proc;


//----------------------------------------------------------------------
//  Tests if a given string ends with the specified suffix.
//----------------------------------------------------------------------
dcl-proc endsWith export;
  dcl-pi *n ind;
    suffix  like(String_t) const options(*varsize);
    string  like(String_t) const options(*varsize);
  end-pi;

  if (%len(string) = 0  or
      %len(suffix) = 0  or
      %len(string) < %len(suffix));
    return *OFF;
  endif;

  if (uCase(suffix) <>
      uCase(%subst(string: %len(string)-%len(suffix)+1: %len(suffix))));
    return *OFF;
  endif;

  return *ON;

end-proc;

//----------------------------------------------------------------------
//  Returns *on if a given string contains the specified
//  sequence of char values.
//----------------------------------------------------------------------
dcl-proc contains export;
  dcl-pi *n ind;
    text    like(String_t) const options(*varsize);
    string  like(String_t) const options(*varsize);
  end-pi;

  if (%len(string) = 0  or
      %len(text) = 0  or
      %len(string) < %len(text));
    return *OFF;
  endif;

  if (%scan(uCase(text): uCase(string)) = 0);
    return *OFF;
  endif;

  return *ON;

end-proc;


//----------------------------------------------------------------------
//  Tells whether or not a given string matches the given *mask*.
//----------------------------------------------------------------------
dcl-proc compare export;
  dcl-pi *n ind;
    generic like(String_t) const options(*varsize);
    string  like(String_t) const options(*varsize);
  end-pi;

  dcl-c T_ANY 1;
  dcl-c T_GENERIC 2;
  dcl-c T_STARTSWITH 3;
  dcl-c T_ENDSWITH 4;
  dcl-c T_MATCH 5;

  dcl-s state int(10);
  dcl-s text like(generic);

  select;
  when generic = '*';
    state = T_ANY; // Anything but not empty
    text = '*';
  when startsWith( '*' : generic) and endsWith('*' : generic );
    state = T_GENERIC;
    text = %subst(generic: 2: %len(generic) - 2);
  when startsWith( '*' : generic);
    state = T_ENDSWITH;
    text = %subst(generic: 2);
  when endsWith( '*' : generic);
    state = T_STARTSWITH;
    text = %subst(generic: 1: %len(generic) - 1);
  other;
    state = T_MATCH;
    text = generic;
  endsl;

  select;
  when (state = T_ANY);
    return %len(string) > 1;
  when (state = T_GENERIC);
    return  contains( text : string );
  when (state = T_STARTSWITH);
    return startsWith( text : string );
  when (state = T_ENDSWITH);
    return endsWith( text : string );
  other;
    // Exact match
    return uCase(text) = uCase(string);
  endsl;

end-proc;


//----------------------------------------------------------------------
//  Returns *on if a given string starts and ends with a single quote.
//----------------------------------------------------------------------
dcl-proc isQuoted export;
  dcl-pi *n ind;
    text  like(String_t) const options(*varsize);
  end-pi;

  if %Len(text) = 0;
    return *OFF;
  endif;

  if not startsWith(QUOTE: %TrimR(text)) or
     not endsWith(QUOTE: %TrimR(text));
    return *OFF;
  endif;

  return *ON;

end-proc;


//----------------------------------------------------------------------
//  Embeds a given string in single quotes. Embedded single quotes
//  are doubled.
//----------------------------------------------------------------------
dcl-proc addQuotes export;
  dcl-pi *n like(String_t);
    text  like(String_t) const options(*varsize);
  end-pi;

  dcl-s quoted like(text);
  dcl-s i int(10);

  if %Len(text) = 0;
    return '';
  endif;

  if isQuoted(%Trim(text));
    return text;
  endif;

  quoted = QUOTE;

  for i = 1 to %Len(%TrimR(text));
    quoted += %Subst(text: i: 1);
    if %Subst(text: i: 1) = QUOTE;
      quoted += QUOTE;
    endif;
  endfor;

  quoted += QUOTE;

  return quoted;

end-proc;


//----------------------------------------------------------------------
//  Removes quotes from a quotes string.
//----------------------------------------------------------------------
dcl-proc removeQuotes export;
  dcl-pi *n like(String_t);
    text  like(String_t) const options(*varsize);
  end-pi;

  dcl-s unquoted like(text);
  dcl-s i int(10);

  if %Len(text) = 0;
    return '';
  endif;

  if not isQuoted(%Trim(text));
    return text;
  endif;

  for i = 2 to %Len(%TrimR(text)) - 1;
    unquoted += %Subst(text: i: 1);
    if %Subst(text: i: 1) = QUOTE;
      i += 1;
    endif;
  endfor;

  return unquoted;

end-proc;


//----------------------------------------------------------------------
//  Returns the specified number of spaces.
//----------------------------------------------------------------------
dcl-proc spaces export;
  dcl-pi *n like(String_t);
    length  int(10) const;
    char    char(1) const options(*nopass);
  end-pi;

  dcl-c p_char 2;
  dcl-s rtnLength int(10);
  dcl-s rtnSpaces char(5120) static;
  dcl-s rtnChars static like(rtnSpaces);

  dcl-ds ebcdic qualified;
    char char(1);
    integer uns(3) overlay(char);
  end-ds;
  //  memset -- Set Bytes to Value
  //    The memset() function returns a pointer to dest.
  dcl-pr memset pointer extproc('memset');
    i_pDest pointer value;
    i_char int(10) value;
    i_count uns(10) value;
  end-pr;

  if (length <= 0);
    return '';
  endif;

  if (length > %len(rtnSpaces));
    rtnLength = %len(rtnSpaces);
  else;
    rtnLength = length;
  endif;

  if (%parms() >= p_char);
    if (char <> '');
      ebcdic.char = char;
      memset(%addr(rtnChars): ebcdic.integer: rtnLength);
      return %subst(rtnChars: 1: rtnLength);
    endif;
  endif;

  return %subst(rtnSpaces: 1: rtnLength);

end-proc;


//----------------------------------------------------------------------
//  Parses a string to a number.
//  Range, with control option EXPROPTS(*RESDECPOS):
//    9999999999999999999999999999999999999999999.99999999999999999999
//   -9999999999999999999999999999999999999999999.99999999999999999999
//----------------------------------------------------------------------
dcl-proc parseNum export;
  dcl-pi *n zoned(63:20);
    i_string    varchar(96) const options(*trim);
    i_decPoint  char(1)     const options(*nopass);
    i_comma     char(1)     const options(*nopass);
    i_curSym    char(1)     const options(*nopass);
  end-pi;

  // Return value
  dcl-ds result qualified;
    value                zoned(63:20) inz(0);
    asString        char(63) overlay(value);
  end-ds;

  // Optional parameters
  dcl-ds mask qualified;
    curSym     char(1) inz;
    comma      char(1) inz;
    decPoint   char(1) inz;
  end-ds;

  // Static values
  dcl-c REFERENCE_VALUE 1000,5;
  dcl-s jobFmt char(7) static;
  dcl-ds job qualified static;
    comma    char(1);
    decPoint char(1);
    curSym   char(1);
  end-ds;

  // Local fields
  dcl-s is1NumDigit  ind;
  dcl-s isFraction   ind;
  dcl-s isEndOfValue ind;

  dcl-s sign         char(1);
  dcl-s digit1Pos    int(10);
  dcl-s fract1Pos    int(10);
  dcl-s digits       varchar(96);
  dcl-s fraction     varchar(96);

  dcl-s x  int(10);
  dcl-s c1 char(1);
  dcl-s c2 char(2);

  // Determine comma and decimal point
  if (jobFmt = '');
    jobFmt = %editc(REFERENCE_VALUE: '1');
    job.decPoint = %subst(jobFmt: 2: 1) ;
    job.comma = %subst(jobFmt: 6: 1) ;
    job.curSym = '$';
  endif;

  // Process optional parameter values ...
  // ... decimal point
  if (%parms >= %parmnum(i_decPoint));
    mask.decPoint = i_decPoint;
  else;
    mask.decPoint = job.decPoint;
  endif;

  // ... comma
  if (%parms >= %parmnum(i_comma));
    mask.comma = i_comma;
  else;
    mask.comma = job.comma;
  endif;

  // ... currency symbol
  if (%parms >= %parmnum(i_curSym));
    mask.curSym = i_curSym;
  else;
    mask.curSym = job.curSym;
  endif;

  // Initialize
  is1NumDigit = *off;
  isFraction = *off;
  isEndOfValue = *off;
  digits = '';
  fraction = '';

  // Spin through input data
  for x = 1 to %len(i_string);

    if (not isEndOfValue);
      // get character of current position
      c1 = %subst(i_string: x: 1);

      // get possible CR sign
      if (x < %len(i_string));
        c2 = %subst(i_string: x: 2);
        c2 = %xlate('cr':'CR': c2);
      endif;

      select;
      // Ignore BLANKS and currency symbol
      when (c1 = '' or c1 = mask.curSym);
        // if we did not yet got a numeric character
        if (not is1NumDigit);
          // ... then ignore BLANKS and currency symbol
          iter;
        endif;

      // Ignore decimal point,
      // but switch do decimal positions.
      // E.g.:   .123,456
      when (c1 = mask.decPoint);
        is1NumDigit = *on;
        iter;

      // Switch do decimal positions
      when (c1 = mask.comma);
        // If we did not yet got decimal positions, ...
        if (not isFraction);
          // ... then switch to decimal positions
          isFraction  = *on;
          is1NumDigit = *on;
          iter;
        endif;

      // Get sign '+'/'-', leading or trailing
      when (c1 = '+'  or c1 = '-');
        // if we did not yet got the sign
        if (sign = '');
          // ... then remember the sign
          sign = c1;
          is1NumDigit = *on;
          iter;
        else;
          // ... else cancel processing
          sndEscapeMsgToCaller(
            'Format error: Duplicate sign (' + c1 + ') at position ' + %char(x));
        endif;

      // Get sign 'CR', always trailing
      when (c2 = 'CR');
        // if we did not yet got the sign and if
        // we already got a numeric digit
        if (sign = '');
          if (is1NumDigit);
            // ... then remember the sign
            sign = '-';
            x += 1;
          endif;
          isEndOfValue = *on;
          iter;
        endif;

      // Process digits
      when (c1 >= '0' and c1 <= '9');
        if (isFraction);
          fraction = fraction + c1;
        else;
          if (not is1NumDigit and c1 = '0');
            // skip leading ignore '0'
          else;
            digits = digits + c1;
          endif;
        endif;

        is1NumDigit = *on;
        iter;

      endsl;
    endif;

    sndEscapeMsgToCaller(
      'Format error: Invalid character (' + c1 + ') at position ' + %char(x));

  endfor;

  // Strip trailling *BLANKS and '0' of decimal portion
  %len(fraction) = %checkr('0 ': fraction);

  // Make sure that the fraction does not exceed the limit
  if (%len(fraction) > %decpos(result.value));
    sndEscapeMsgToCaller('Numeric value contains too many fraction digits');
  endif;

  // Make sure that we did not get to many digits
  if (%len(digits) > %len(result.value) - %decpos(result.value));
    sndEscapeMsgToCaller('Number of significant digits exceeded');
  endif;

  // Put the result together
  fract1Pos = %len(result.value) - %decpos(result.value) + 1;
  digit1Pos = fract1Pos - %len(digits);

  %subst(result.asString: digit1Pos: %len(digits)) = digits;
  %subst(result.asString: fract1Pos: %len(fraction)) = fraction;

  // Finally set the sign accordingly
  if (sign = '-');
    result.value = result.value * -1;
  endif;

  return result.value;

end-proc;

