**FREE
/if not defined(IRPGUNIT_STRING)
/define IRPGUNIT_STRING
// ==========================================================================
//  iRPGUnit - String Utilities.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr uCase like(String_t) extproc('STRING_uCase');
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr leftStr like(String_t) extproc('STRING_leftStr');
  string  like(String_t) const options(*varsize);
  length  int(10) const;
end-pr;

dcl-pr startsWith ind extproc('STRING_startsWith');
  prefix  like(String_t) const options(*varsize);
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr endsWith ind extproc('STRING_endsWith');
  suffix  like(String_t) const options(*varsize);
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr contains ind extproc('STRING_contains');
  text    like(String_t) const options(*varsize);
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr compare ind extproc('STRING_compare');
  generic like(String_t) const options(*varsize);
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr isQuoted ind extproc('STRING_isQuoted');
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr addQuotes like(String_t) extproc('STRING_addQuotes');
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr removeQuotes like(String_t) extproc('STRING_removeQuotes');
  string  like(String_t) const options(*varsize);
end-pr;

dcl-pr spaces like(String_t) extproc('STRING_spaces');
  length  int(10) const;
  char    char(1) const options(*nopass);
end-pr;

dcl-pr parseNum zoned(63:20) extproc('STRING_parseNum');
  i_string    varchar(96) const options(*trim);
  i_decPoint  char(1)     const options(*nopass);
  i_comma     char(1)     const options(*nopass);
  i_curSym    char(1)     const options(*nopass);
end-pr;

dcl-pr formatNumeric varchar(128) extproc('formatNumeric');
  numericValue  like(assertNumeric_t) const;
end-pr;

/endif

