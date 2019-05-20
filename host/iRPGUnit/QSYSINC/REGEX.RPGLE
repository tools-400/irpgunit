      /IF NOT DEFINED(REGEX)
      /DEFINE REGEX

     d regex_t         DS                  align   qualified       based(pDummy)
     d  re_nsub                      10U 0
     d  re_comp                        *
     d  re_cflags                    10I 0
     d  re_erroff                    10U 0
     d  re_len                       10U 0
     d  re_ucoll                     10I 0 dim(2)
     d  re_lsub                        *
     d  lsub_ar                      10I 0 dim(16)
     d  esub_ar                      10I 0 dim(16)
     d  reserved1                      *
     d  re_esub                        *
     d  re_specchar                    *
     d  re_phdl                        *
     d  comp_spc                    112A
     d  re_map                      256A
     d  re_shift                      5I 0
     d  re_dbcs                       5I 0

     d regmatch_t      DS                  align   qualified       based(pDummy)
     d  rm_so                        10I 0
     d  rm_ss                         5I 0
     d  rm_eo                        10I 0
     d  rm_es                         5I 0

      //    rm_so  -  offset of substring
      //    rm_ss  -  Shift state at start of substring
      //    rm_eo  -  offset of first char after substring
      //    rm_es  -  Shift state at end of substring
      //
      //  Constants:   regcomp() cflags
      //     Basic RE rules  (BRE)
     d REG_BASIC       C                   0                                    x'0000'
      //     Extended RE rules (ERE)
     d REG_EXTENDED    C                   1                                    x'0001'
      //     Ignore case in match
     d REG_ICASE       C                   2                                    x'0002'
      //     Convert <backslash><n> to <newline>
     d REG_NEWLINE     C                   4                                    x'0004'
      //     regexec() not report subexpressions
     d REG_NOSUB       C                   8                                    x'0008'
      //     POSIX: Use IFS newline
      //            instead of database newline
      //     UTF32: Use database newline
      //            instead of IFS newline.
     d REG_ALT_NL      C                   16                                   x'0010'

      //  Constants:   regexec() eflags
      //     First character not start of line
     d REG_NOTBOL      C                   256                                  x'0100'
      //     Last character not end of line
     d REG_NOTEOL      C                   512                                  x'0200'

      //  Regular expressions error codes
     d REG_NOMATCH     C                     1
     d REG_BADPAT      C                     2
     d REG_ECOLLATE    C                     3
     d REG_ECTYPE      C                     4
     d REG_EESCAPE     C                     5
     d REG_ESUBREG     C                     6
     d REG_EBRACK      C                     7
     d REG_EPAREN      C                     8
     d REG_EBRACE      C                     9
     d REG_BADBR       C                    10
     d REG_ERANGE      C                    11
     d REG_ESPACE      C                    12
     d REG_BADRPT      C                    13
     d REG_ECHAR       C                    14
     d REG_EBOL        C                    15

     d regcomp         PR            10I 0 extproc('regcomp')
     d   preg                                     likeds(regex_t)
     d   pattern                       *   value  options(*string)
     d   cflags                      10I 0 value

     d regexec         PR            10I 0 extproc('regexec')
     d   preg                                     likeds(regex_t)
     d   string                        *   value  options(*string)
     d   nmatch                      10U 0 value
     d   pmatch                                   likeds(regmatch_t)
     d                                            dim(32767)
     d                                            options(*varsize)
     d   eflags                      10I 0 value

     d regerror        PR            10U 0 extproc('regerror')
     d   errcode                     10I 0 value
     d   preg                                     like(regex_t)
     d   errbuf                        *   value
     d   errbuf_size                 10I 0 value

     d regfree         PR                  extproc('regfree')
     d   preg                                     likeds(regex_t)

      /ENDIF
