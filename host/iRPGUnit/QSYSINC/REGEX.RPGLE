**FREE
/IF NOT DEFINED(REGEX)
/DEFINE REGEX

dcl-ds regex_t align qualified template;
  re_nsub         uns(10);
  re_comp         pointer;
  re_cflags       int(10);
  re_erroff       uns(10);
  re_len          uns(10);
  re_ucoll        int(10) dim(2);
  re_lsub         pointer;
  lsub_ar         int(10) dim(16);
  esub_ar         int(10) dim(16);
  reserved1       pointer;
  re_esub         pointer;
  re_specchar     pointer;
  re_phdl         pointer;
  comp_spc        char(112);
  re_map          char(256);
  re_shift        int(5);
  re_dbcs         int(5);
end-ds;

dcl-ds regmatch_t align qualified template;
  rm_so           int(10);
  rm_ss           int(5);
  rm_eo           int(10);
  rm_es           int(5);
end-ds;

//    rm_so  -  offset of substring
//    rm_ss  -  Shift state at start of substring
//    rm_eo  -  offset of first char after substring
//    rm_es  -  Shift state at end of substring

//  Constants:   regcomp() cflags
//     Basic RE rules  (BRE)
dcl-c REG_BASIC    0; // x'0000'

//     Extended RE rules (ERE)
dcl-c REG_EXTENDED 1; // x'0001'

//     Ignore case in match
dcl-c REG_ICASE    2; // x'0002'

//     Convert <backSLASH><n> to <newline>
dcl-c REG_NEWLINE  4; // x'0004'

//     regexec() not report subexpressions
dcl-c REG_NOSUB    8; // x'0008'

//     POSIX: Use IFS newline
//            instead of database newline
//     UTF32: Use database newline
//            instead of IFS newline.
dcl-c REG_ALT_NL  16; // x'0010'

//  Constants:   regexec() eflags
//     First character not start of line
dcl-c REG_NOTBOL 256; // x'0100'

//     Last character not end of line
dcl-c REG_NOTEOL 512; // x'0200'

//  Regular expressions error codes
dcl-c REG_NOMATCH   1; // RE pattern not found
dcl-c REG_BADPAT    2; // Invalid Regular Expression
dcl-c REG_ECOLLATE  3; // Invalid collating element
dcl-c REG_ECTYPE    4; // Invalid character class
dcl-c REG_EESCAPE   5; // Last character is \
dcl-c REG_ESUBREG   6; // Invalid number in \digit
dcl-c REG_EBRACK    7; // imbalance
dcl-c REG_EPAREN    8; // \( \) or () imbalance
dcl-c REG_EBRACE    9; // \{ \} or { } imbalance
dcl-c REG_BADBR    10; // Invalid \{ \} range exp
dcl-c REG_ERANGE   11; // Invalid range exp endpoint
dcl-c REG_ESPACE   12; // Out of memory
dcl-c REG_BADRPT   13; // ?*+ not preceded by valid RE
dcl-c REG_ECHAR    14; // invalid multibyte character
dcl-c REG_EBOL     15; // (shift 6 caret or not) anchor and not BOL
dcl-c REG_EEOL     16; // $ anchor and not EOL
dcl-c REG_ECOMP    17; // Unknown error in regcomp() call
dcl-c REG_EEXEC    18; // Unknown error in regexec() call
dcl-c REG_LAST     18; // Needs to always be the greatest
                       // regerror uses it to check for
                       // valid number

dcl-pr regcomp int(10) extproc('regcomp');
  preg            likeds(regex_t);
  pattern         pointer value  options(*string);
  cflags          int(10) value;
end-pr;

dcl-pr regexec int(10) extproc('regexec');
  preg            likeds(regex_t);
  string          pointer value  options(*string);
  nmatch          uns(10) value;
  pmatch          likeds(regmatch_t) dim(32767) options(*varsize);
  eflags          int(10) value;
end-pr;

dcl-pr regerror uns(10) extproc('regerror');
  errcode         int(10) value;
  preg            like(regex_t);
  errbuf          pointer value;
  errbuf_size     int(10) value;
end-pr;

dcl-pr regfree extproc('regfree');
  preg            likeds(regex_t);
end-pr;

/ENDIF
