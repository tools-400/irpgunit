**FREE
/IF NOT DEFINED(QLICHGLL)
/DEFINE QLICHGLL

//  Change Library List (QLICHGLL) API
dcl-pr qlichgll extpgm('QLICHGLL');
  i_curLib        char(11) const;
  i_prodLib1      char(11) const;
  i_prodLib2      char(11) const;
  i_userLibl      char(2750) const  options(*varsize);
  i_numE          int(10) const;
  io_errCode      char(65535) options(*varsize);
end-pr;

/ENDIF
