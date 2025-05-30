**FREE

// List ILE service program information API
dcl-pr qbnlspgm extpgm('QBNLSPGM');
  usrSpc          char(20) const;
  fmt             char(8) const;
  srvPgm          char(20) const;
  errors          char(32766) options(*varsize) noopt;
end-pr;

// Structure of an entry in a QBNLSPGM list.
dcl-ds spgl0100_t qualified template;
  srvPgm          char(10);
  srvPgmLib       char(10);
  mod             char(10);
  modLib          char(10);
  srcFile         char(10);
  srcLib          char(10);
  srcMbr          char(10);
  modAttr         char(10);
  modCrtDatTim    char(13);
  srcUpdDatTim    char(13);
  srtSeqTbl       char(10);
  srtSeqTblLib    char(10);
  langID          char(10);
  optLvl          int(10);
  maxOptLvl       int(10);
  dbgDta          char(10);
  rlsCrtOn        char(6);
  rlsCrtFor       char(6);
  reserved_1      char(20);
  usrModInd       char(1);
  licPgm          char(13);
  ptfNbr          char(5);
  aparID          char(6);
  crtDta          char(1);
  modCcsid        int(10);
  objctlLvl       char(8);
  enablePrfCol    char(1);
  profilingDta    char(10);
  reserved_2      char(1);
  //   ...
end-ds;

dcl-ds spgl0110_t qualified template;
  lenEntry        int(10);
  srvPgm          char(10);
  srvPgmLib       char(10);
  mod             char(10);
  modLib          char(10);
  srcFile         char(10);
  srcLib          char(10);
  srcMbr          char(10);
  modAttr         char(10);
  modCrtDatTim    char(13);
  srcUpdDatTim    char(13);
  srtSeqTbl       char(10);
  srtSeqTblLib    char(10);
  langID          char(10);
  optLvl          int(10);
  maxOptLvl       int(10);
  dbgDta          char(10);
  rlsCrtOn        char(6);
  rlsCrtFor       char(6);
  reserved_1      char(20);
  usrModInd       char(1);
  licPgm          char(13);
  ptfNbr          char(5);
  aparID          char(6);
  crtDta          char(1);
  modCcsid        int(10);
  objctlLvl       char(8);
  enablePrfCol    char(1);
  profilingDta    char(10);
  alwRtvClSrc     char(1);
  numProc         int(10);
  numProcBlckR    int(10);
  numProcBlckM    int(10);
  teraspace       char(1);
  stgMdl          char(1);
  reserved_2      char(2);
  ofsLicIntCdeOpt int(10);
  lenLicIntCdeOpt int(10);
  ofsSrcStmf      int(10);
  lenSrcStmf      int(10);
  ccsidSrcStmf    int(10);
  reserved_3      char(52);
  numSqlStmt      int(10);
  rdb             char(18);
  cmtCtl          char(10);
  alwCpyDta       char(10);
  cloSqlCsr       char(10);
  namConv         char(10);
  dateFmt         char(10);
  dateSep         char(1);
  timeFmt         char(10);
  timeSep         char(1);
  dlyPrepare      char(10);
  alwBlocking     char(10);
  dftColNme       char(10);
  sqlPkgNme       char(10);
  sqlPgkLib       char(10);
  dynUsrPrf       char(10);
  sqlSrtSeqTbl    char(10);
  sqlSrtSeqLib    char(10);
  sqlLngId        char(10);
  connMthd        char(10);
  lenSqlPath      int(10);
  sqlPath         char(3483);
end-ds;

dcl-ds spgl0610_t qualified template;
  size            int(10);  // Size of this entry. Each entry has a different size.
  srvPgm          char(20);
  ccsid           int(10);
  procnmoff       int(10);  // Memory offset to reach the procedure name.
  procnmsize      int(10);  // Longueur du nom de la procedure.
end-ds;

