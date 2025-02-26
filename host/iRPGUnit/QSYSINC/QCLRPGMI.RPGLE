**FREE
/IF NOT DEFINED(QCLRPGMI)
/DEFINE QCLRPGMI

//  Retrieve Program Information (QCLRPGMI) API
dcl-pr qclrpgmi extpgm('QCLRPGMI');
  o_rcvVar        char(65535) const  options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  i_qPgm          char(20) const;
  io_errCode      char(65535) options(*varsize);
end-pr;

//  PGMI0100 Format
dcl-ds pgmi0100_t qualified template;
  bytRet              int(10);
  bytAvl              int(10);
  //  Program creation information
  pgm                 char(10);
  lib                 char(10);
  owner               char(10);
  attr                char(10);
  crtDatTim           char(13);
  srcFile             char(10);
  srcLib              char(10);
  srcMbr              char(10);
  srcUpdDatTim        char(13);
  obsInf              char(1);
  usrPrfOpt           char(1);
  usrAdpAut           char(1);
  logCmds             char(1);
  alwRtvClSrc         char(1);
  fixDecDta           char(1);
  text                char(50);
  type                char(1);
  teraspace           char(1);
  reserved_1          char(58);
  //  Program statistics information
  numParmMin          int(10);
  numParmMax          int(10);
  pgmSize             int(10);
  ascSpcSize          int(10);
  stcStgSize          int(10);
  atmStgSize          int(10);
  numInstr_mi         int(10);
  numOdtE_mi          int(10);
  pgmState            char(1);
  cmplrID             char(14);
  lowRlsRun           char(6);
  srtSeq              char(10);
  srtSeqLib           char(10);
  langID              char(10);
  pgmDmn              char(1);
  cnvReq              char(1);
  reserved_2          char(20);
  //  Program performance information
  optimization        char(1);
  pagingPool          char(1);
  update_pasa         char(1);
  clear_pasa          char(1);
  pagingAmount        char(1);
  reserved_3          char(18);
  //  ILE information
  entryPrcMod         char(10);
  entryPrcModLb       char(10);
  actGrpAttr          char(30);
  obsInfCmprssd       char(1);
  runInfCmprssd       char(1);
  rlsCrtOn            char(6);
  shrActGrp           char(1);
  alwUpd              char(1);
  pgmCcsid            int(10);
  numMod              int(10);
  numSrvPgm           int(10);
  numCpyRght          int(10);
  numUnrslvdRef       int(10);
  rlsCrtFor           char(6);
  alwStcStgrInz       char(1);
  allCrtDta           char(1);
  alwBndSrvPgmLibUpd  char(1) pos(437);
  prfDta              char(10) pos(438);
  teraspaceMods       char(1) pos(448);
  stgMdl              char(1) pos(449);
  reserved_4          char(87) pos(450);
end-ds;

//  PGMI0200 Format
dcl-ds pgmi0200_t qualified template;
  bytRet              int(10);
  bytAvl              int(10);
  //  Program creation information
  pgm                 char(10);
  lib                 char(10);
  owner               char(10);
  attr                char(10);
  crtDatTim           char(13);
  srcFile             char(10);
  srcLib              char(10);
  srcMbr              char(10);
  srcUpdDatTim        char(13);
  obsInf              char(1);
  usrPrfOpt           char(1);
  usrAdpAut           char(1);
  logCmds             char(1);
  alwRtvClSrc         char(1);
  fixDecDta           char(1);
  text                char(50);
  type                char(1);
  teraspace           char(1);
  reserved_1          char(58);
  //  Program statistics information
  numParmMin          int(10);
  numParmMax          int(10);
  pgmSize             int(10);
  ascSpcSize          int(10);
  stcStgSize          int(10);
  atmStgSize          int(10);
  numInstr_mi         int(10);
  numOdtE_mi          int(10);
  pgmState            char(1);
  cmplrID             char(14);
  lowRlsRun           char(6);
  srtSeq              char(10);
  srtSeqLib           char(10);
  langID              char(10);
  pgmDmn              char(1);
  cnvReq              char(1);
  reserved_2          char(20);
  //  Program performance information
  optimization        char(1);
  pagingPool          char(1);
  update_pasa         char(1);
  clear_pasa          char(1);
  pagingAmount        char(1);
  reserved_3          char(18);
  //  Program SQL information
  numSqlStmts         int(10);
  rdb                 char(18);
  cmtCtl              char(10);
  alwCpyDta           char(10);
  cloSqlCsr           char(10);
  naming              char(10);
  datFmt              char(10);
  datSep              char(1);
  timFmt              char(10);
  timSep              char(1);
  dlyPrp              char(10);
  alwBlk              char(10);
  //  ILE information
  entryPrcMod         char(10);
  entryPrcModLb       char(10);
  actGrpAttr          char(30);
  obsInfCmprssd       char(1);
  runInfCmprssd       char(1);
  rlsCrtOn            char(6);
  shrActGrp           char(1);
  alwUpd              char(1);
  pgmCcsid            int(10);
  numMod              int(10);
  numSrvPgm           int(10);
  numCpyRght          int(10);
  numUnrslvdRef       int(10);
  rlsCrtFor           char(6);
  alwStcStgrInz       char(1);
  //  Continuation of program SQL information
  dftRdbCol           char(10);
  sqlPkg              char(10);
  sqlPkgLib           char(10);
  dynUsrPrf           char(10);
  sqlSrtSeq           char(10);
  sqlSrtSeqLib        char(10);
  sqlLangID           char(10);
  cnnmtd              char(10);
  reserved_4          char(1);
  sqlPathOfs          int(10);
  sqlPathLen          int(10);
  reserved_5          char(91);
  //  Continuation of ILE information
  allCrtDta           char(1);
  alwBndSrvPgmLibUpd  char(1) pos(721);
  prfDta              char(10) pos(722);
  teraspaceMods       char(1) pos(732);
  stgMdl              char(1) pos(733);
  reserved_6          char(87) pos(734);
  //  Program information through offsets
  //  SQL path            CHAR(*)
end-ds;

//  PGMI0300 Format
dcl-ds pgmi0300_t qualified template;
  bytRet            int(10);
  bytAvl            int(10);
  //  ILE program size information
  pgm               char(10);
  lib               char(10);
  curTotPgmSize     int(10);
  maxPgmSize        int(10);
  curNbrMods        int(10);
  maxNbrMods        int(10);
  curNbrSrvPgms     int(10);
  maxNbrSrvPgms     int(10);
  curStrDctDize     int(10);
  maxStrDctSize     int(10);
  curCpyrghtSize    int(10) pos(61);
  maxcpyrghtsize    int(10) pos(65);
  curNumAuxStgSegs  int(10) pos(69);
  maxNumAuxStgSegs  int(10) pos(73);
  minStcStgSize     int(10) pos(77);
  maxStcStgSize     int(10) pos(81);
  reserved_1        char(4) pos(85);
  minStcStgSizeLong int(20) pos(89);
  maxStcStgSizeLong int(20) pos(97);
end-ds;

/ENDIF
