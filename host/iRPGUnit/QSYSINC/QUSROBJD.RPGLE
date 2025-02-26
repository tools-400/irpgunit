**FREE
/IF NOT DEFINED(QUSROBJD)
/DEFINE QUSROBJD

//  Retrieve Object Description (QUSROBJD) API
dcl-pr qusrobjd extpgm('QUSROBJD');
  o_rcvVar        char(65535) options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  i_qobj          char(20) const;
  i_type          char(10) const;
  io_errCode      char(65535) options(*nopass: *varsize);
  i_auxStgCtrl    char(65535) const  options(*nopass: *varsize);
end-pr;

//  Auxiliary Storage Pool (ASP) Control Format
dcl-ds auxstgctrl_t qualified template;
  length          int(10);
  device          char(10);
  searchType      char(10);
end-ds;

dcl-ds objd0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  name            char(10);
  lib             char(10);
  type            char(10);
  rtnLib          char(10);
  auxStgP         int(10);
  owner           char(10);
  domain          char(2);
  crtDatTim       char(13);
  chgDatTim       char(13);
end-ds;

dcl-ds objd0200_t qualified template;
  //    OBJD0100 ...
  bytRet          int(10);
  bytAvl          int(10);
  name            char(10);
  lib             char(10);
  type            char(10);
  rtnLib          char(10);
  auxStgP         int(10);
  owner           char(10);
  domain          char(2);
  crtDatTim       char(13);
  chgDatTim       char(13);
  //    OBJD0200 ...
  extObjAtr       char(10);
  text            char(50);
  srcFile         char(10);
  srcLib          char(10);
  srcMbr          char(10);
end-ds;

dcl-ds objd0300_t qualified template;
  //    OBJD0100 ...
  bytRet          int(10);
  bytAvl          int(10);
  name            char(10);
  lib             char(10);
  type            char(10);
  rtnLib          char(10);
  auxStgP         int(10);
  owner           char(10);
  domain          char(2);
  crtDatTim       char(13);
  chgDatTim       char(13);
  //    OBJD0200 ...
  extObjAtr       char(10);
  text            char(50);
  srcFile         char(10);
  srcLib          char(10);
  srcMbr          char(10);
  //    OBJD0300 ...
  srcfDatTim      char(13);
  savDatTim       char(13);
  rstDatTim       char(13);
  crtUsrPrf       char(10);
  crtSys          char(8);
  resDat          char(7);
  savSize         int(10);
  savSeqNbr       int(10);
  stg             char(10);
  savCmd          char(10);
  savVolID        char(71);
  savDev          char(10);
  savfName        char(10);
  savfLibName     char(10);
  savLbl          char(17);
  sysLvl          char(9);
  compiler        char(16);
  objLvl          char(8);
  usrChg          char(1);
  licPgm          char(16);
  ptf             char(10);
  apar            char(10);
end-ds;

dcl-ds objd0400_t qualified template;
  //    OBJD0100 ...
  bytRet             int(10);
  bytAvl             int(10);
  name               char(10);
  lib                char(10);
  type               char(10);
  rtnLib             char(10);
  auxStgP            int(10);
  owner              char(10);
  domain             char(2);
  crtDatTim          char(13);
  chgDatTim          char(13);
  //    OBJD0200 ...
  extObjAtr          char(10);
  text               char(50);
  srcFile            char(10);
  srcLib             char(10);
  srcMbr             char(10);
  //    OBJD0300 ...
  srcfDatTim         char(13);
  savDatTim          char(13);
  rstDatTim          char(13);
  crtUsrPrf          char(10);
  crtSys             char(8);
  resDat             char(7);
  savSize            int(10);
  savSeqNbr          int(10);
  stg                char(10);
  savCmd             char(10);
  savVolID           char(71);
  savDev             char(10);
  savfName           char(10);
  savfLibName        char(10);
  savLbl             char(17);
  sysLvl             char(9);
  compiler           char(16);
  objLvl             char(8);
  usrChg             char(1);
  licPgm             char(16);
  ptf                char(10);
  apar               char(10);
  //    OBJD0400 ...
  lastUseDat         char(7);
  useInfUpd          char(1);
  daysUseCnt         int(10);
  objSize            int(10);
  objSizeMlt         int(10);
  objCmpSts          char(1);
  alwChgPgm          char(1);
  chgByPgm           char(1);
  usrDfnAtr          char(10);
  aspOflw            char(1);
  savActDatTim       char(13);
  objAudVal          char(10);
  priGrp             char(10);
  jrnStat            char(1);
  jrnName            char(10);
  jrnLibName         char(10);
  jrnImages          char(1);
  jrnOmitE           char(1);
  jrnStrDatTim       char(13);
  dgtSigned          char(1);
  savSizeUnits       int(10);
  savSizeMlt         int(10);
  libAspNbr          int(10);
  objAspDev          char(10);
  libAspDev          char(10);
  dgtSignedTrst      char(1);
  dgtSignedMult      char(1);
  reserved_1         char(2);
  priAscSpcSize      int(10);
  optSpcAlgn         char(1);
  objAspGrp          char(10);
  libAspGrp          char(10);
  strJrnRcv          char(10);
  strJrnRcvLib       char(10);
  strJrnRcvLibAspDev char(10);
  strJrnRcvLibAspGrp char(10);
  reserved_2         char(1);
end-ds;

/ENDIF
