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
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt DECEDIT('0.') NOMAIN;
/define NO_DECEDIT
/include qinclude,H_SPEC

/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT

/include qinclude,JSONWTR
/include qinclude,PGMMSG

dcl-c CRLF x'0d25';
dcl-c TAB '    ';
dcl-c COMMA ',';
dcl-c DOUBLE_QUOTES '"';
dcl-c START_OBJECT '{';
dcl-c END_OBJECT '}';
dcl-c START_ARRAY '[';
dcl-c END_ARRAY ']';
dcl-c DELIMITER ':';

dcl-ds g_status qualified inz;
  json                varchar(50000);
  json_countObject    int(10);
  json_countArray     int(10);
  json_indent         int(10);
  json_isPrettyPrint  ind inz(*on);
end-ds;

dcl-proc Json_clear export;
  dcl-pi *n;
    value        varchar(50000) options(*varsize: *nopass) const; // self-tests only!
    count_object int(10) options(*nopass) const;                  // self-tests only!
    count_array  int(10) options(*nopass) const;                  // self-tests only!
    count_indent int(10) options(*nopass) const;                  // self-tests only!
  end-pi;

  clear g_status.json;
  if (%parms() >= %parmnum(value));
    g_status.json = value;
  else;
    g_status.json = '';
  endif;

  if (%parms() >= %parmnum(count_object));
    g_status.json_countObject = count_object;
  else;
    g_status.json_countObject = 0;
  endif;

  if (%parms() >= %parmnum(count_array));
    g_status.json_countArray = count_array;
  else;
    g_status.json_countArray = 0;
  endif;

  if (%parms() >= %parmnum(count_indent));
    g_status.json_indent = count_indent;
  else;
    g_status.json_indent = 0;
  endif;

  g_status.json_isPrettyPrint = *on;

end-proc;

dcl-proc Json_setPrettyPrintEnabled export;
  dcl-pi *n ind;
    enabled  ind const;
  end-pi;

  g_status.json_isPrettyPrint = enabled;

  return g_status.json_isPrettyPrint;

end-proc;

dcl-proc Json_get export;
  dcl-pi *n varchar(50000);
  end-pi;

  removeTrailingComma();

  if (g_status.json_countObject <> 0);
    sndEscapeMsgAboveCtlBdy('Incorrect Json format. Number of open objects: '
                            + %char(g_status.json_countObject));
  endif;

  if (g_status.json_countArray <> 0);
    sndEscapeMsgAboveCtlBdy('Incorrect Json format. Number of open arrays: '
                            + %char(g_status.json_countArray));
  endif;

  return g_status.json;

end-proc;

dcl-proc Json_startObject export;
  dcl-pi *n;
  end-pi;

  g_status.json += START_OBJECT;

  g_status.json_countObject += 1;
  g_status.json_indent += 1;

end-proc;

dcl-proc Json_endObject export;
  dcl-pi *n;
  end-pi;

  removeTrailingComma();

  g_status.json_countObject -= 1;
  g_status.json_indent -= 1;

  if (Json_lastChar() <> START_OBJECT);
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
      g_status.json += Json_indent();
    endif;
  endif;

  g_status.json += END_OBJECT + COMMA;

end-proc;

dcl-proc Json_startArray export;
  dcl-pi *n;
  end-pi;

  g_status.json += START_ARRAY;

  g_status.json_countArray += 1;
  g_status.json_indent += 1;

end-proc;

dcl-proc Json_addKey export;
  dcl-pi *n;
    key like(string_t) const;
  end-pi;

  dcl-s lastChar varchar(2);

  lastChar = Json_lastChar();
  if (lastChar <> START_OBJECT and lastChar <> START_ARRAY and lastChar <> COMMA);
    sndEscapeMsgAboveCtlBdy('Adding key not allowed. +
                             Missing start of object or end of key/value pair.');
  endif;

  select;
  when (Json_lastChar() = START_OBJECT);
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
    endif;
  when (Json_lastChar() = START_ARRAY);
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
    endif;
  other;
    if (Json_lastChar() <> COMMA);
      g_status.json += COMMA;
    endif;
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
    endif;
  endsl;

  g_status.json += Json_indent();

  g_status.json += (quoteJson(key) + DELIMITER);
  if (g_status.json_isprettyPrint);
    g_status.json += ' ';
  endif;

end-proc;

dcl-proc Json_addString export;
  dcl-pi *n;
    value like(string_t) const;
  end-pi;

  addValueInternally(quoteJson(value));

end-proc;

dcl-proc Json_addInteger export;
  dcl-pi *n;
    integer int(20) const;
  end-pi;

  addValueInternally(%char(integer));

end-proc;

dcl-proc addValueInternally;
  dcl-pi *n extproc(*dclcase);
    value like(string_t) const;
  end-pi;

  dcl-s lastChar varchar(2);

  lastChar = Json_lastChar();
  if (lastChar <> DELIMITER and lastChar <> START_ARRAY and lastChar <> COMMA);
    sndEscapeMsgAboveCtlBdy('Adding value not allowed. +
                             Missing delimiter/array of values.');
  endif;

  select;
  when (Json_lastChar() = DELIMITER);
    // do nothing

  when (Json_lastChar() = START_ARRAY);
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
      g_status.json += Json_indent();
    endif;

  other;
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
      g_status.json += Json_indent();
    endif;

  endsl;

  g_status.json += value + COMMA;

end-proc;

dcl-proc removeTrailingComma;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s lastChar varchar(2);

  lastChar = Json_lastChar();
  if (lastChar = COMMA);
    %len(g_status.json) = %len(g_status.json) - 1;
  endif;

end-proc;

dcl-proc Json_endArray export;
  dcl-pi *n;
  end-pi;

  removeTrailingComma();

  g_status.json_countArray -= 1;
  g_status.json_indent -= 1;

  if (Json_lastChar() <> START_ARRAY);
    if (g_status.json_isPrettyPrint);
      g_status.json += CRLF;
      g_status.json += Json_indent();
    endif;
  endif;

  g_status.json += END_ARRAY + COMMA;

end-proc;

dcl-proc Json_indent export;
  dcl-pi *n varchar(1024);
  end-pi;

  dcl-s i int(10);
  dcl-s text varchar(1024);

  if (not g_status.json_isprettyPrint);
    return '';
  endif;

  text = '';

  i = g_status.json_indent;
  dow (i > 0);
    text += tab;
    i -= 1;
  enddo;

  return text;

end-proc;

dcl-proc Json_lastChar export;
  dcl-pi *n varchar(2);
  end-pi;

  dcl-s lastChar varchar(2);
  dcl-s offset int(10);
  dcl-s c1 char(1) based(pC1);
  dcl-s pC1 pointer;
  dcl-s c2 char(2) based(pC2);
  dcl-s pC2 pointer;

  offset = %len(g_status.json) - 1;
  lastChar = '';

  dow (offset >= 0 and offset < %len(g_status.json) and lastChar = '');
    pC1 = %addr(g_status.json: *data) + offset;
    if (c1 >= x'40' and c1 <= x'FE'); // valid character
      if (c1 <> ' ');
        lastChar = c1;
      endif;
    else;
      // search for CRLF
      if (offset < %len(g_status.json) - 1);
        pC2 = %addr(g_status.json: *data) + offset;
        if (c2 = CRLF);
          lastChar = c2;
        endif;
      endif;
    endif;

    offset -= 1;
  enddo;

  return lastChar;

end-proc;

dcl-proc quoteJson;
  dcl-pi *n varchar(4096);
    value    like(logValue_t.value) options(*varsize) const;
  end-pi;

  dcl-s quoted varchar(4096);

  quoted = DOUBLE_QUOTES + %scanrpl('"': '\"': value) + DOUBLE_QUOTES;

  return quoted;

end-proc;

