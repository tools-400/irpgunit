      /IF NOT DEFINED(QUSROBJD)                                                               RADDAT
      /DEFINE QUSROBJD                                                                        RADDAT
      *                                                                                       RADDAT
      *  Retrieve Object Description (QUSROBJD) API                                           RADDAT
     D QUSROBJD...                                                                            RADDAT
     D                 PR                         extpgm('QUSROBJD')                          RADDAT
     D  o_rcvVar                  65535A          options(*varsize)                           RADDAT
     D  i_lenRcvVar                  10I 0 const                                              RADDAT
     D  i_format                      8A   const                                              RADDAT
     D  i_qObj                       20A   const                                              RADDAT
     D  i_type                       10A   const                                              RADDAT
     D  io_errCode                65535A          options(*nopass: *varsize)    | OptGrp 1    RADDAT
     D  i_auxStgCtrl              65535A   const  options(*nopass: *varsize)    | OptGrp 2    RADDAT
      *                                                                                       RADDAT
      *  Auxiliary Storage Pool (ASP) Control Format                                          RADDAT
     D auxStgCtrl_t    DS                  qualified               based(pDummy)              RADDAT
     D  length                       10I 0                                                    RADDAT
     D  device                       10A                                                      RADDAT
     D  searchType                   10A                                                      RADDAT
      *                                                                                       RADDAT
     D objd0100_t      DS                  qualified           based(pDummy)                  RADDAT
     D  bytRet                       10I 0                                                    RADDAT
     D  bytAvl                       10I 0                                                    RADDAT
     D  name                         10A                                                      RADDAT
     D  lib                          10A                                                      RADDAT
     D  type                         10A                                                      RADDAT
     D  rtnLib                       10A                                                      RADDAT
     D  auxStgP                      10I 0                                                    RADDAT
     D  owner                        10A                                                      RADDAT
     D  domain                        2A                                                      RADDAT
     D  crtDatTim                    13A                                                      RADDAT
     D  chgDatTim                    13A                                                      RADDAT
      *                                                                                       RADDAT
     D objd0200_t      DS                  qualified           based(pDummy)                  RADDAT
      *    OBJD0100 ...                                                                       RADDAT
     D  bytRet                       10I 0                                                    RADDAT
     D  bytAvl                       10I 0                                                    RADDAT
     D  name                         10A                                                      RADDAT
     D  lib                          10A                                                      RADDAT
     D  type                         10A                                                      RADDAT
     D  rtnLib                       10A                                                      RADDAT
     D  auxStgP                      10I 0                                                    RADDAT
     D  owner                        10A                                                      RADDAT
     D  domain                        2A                                                      RADDAT
     D  crtDatTim                    13A                                                      RADDAT
     D  chgDatTim                    13A                                                      RADDAT
      *    OBJD0200 ...                                                                       RADDAT
     D  extObjAtr                    10A                                                      RADDAT
     D  text                         50A                                                      RADDAT
     D  srcFile                      10A                                                      RADDAT
     D  srcLib                       10A                                                      RADDAT
     D  srcMbr                       10A                                                      RADDAT
      *                                                                                       RADDAT
     D objd0300_t      DS                  qualified           based(pDummy)                  RADDAT
      *    OBJD0100 ...                                                                       RADDAT
     D  bytRet                       10I 0                                                    RADDAT
     D  bytAvl                       10I 0                                                    RADDAT
     D  name                         10A                                                      RADDAT
     D  lib                          10A                                                      RADDAT
     D  type                         10A                                                      RADDAT
     D  rtnLib                       10A                                                      RADDAT
     D  auxStgP                      10I 0                                                    RADDAT
     D  owner                        10A                                                      RADDAT
     D  domain                        2A                                                      RADDAT
     D  crtDatTim                    13A                                                      RADDAT
     D  chgDatTim                    13A                                                      RADDAT
      *    OBJD0200 ...                                                                       RADDAT
     D  extObjAtr                    10A                                                      RADDAT
     D  text                         50A                                                      RADDAT
     D  srcFile                      10A                                                      RADDAT
     D  srcLib                       10A                                                      RADDAT
     D  srcMbr                       10A                                                      RADDAT
      *    OBJD0300 ...                                                                       RADDAT
     D  srcFDatTim                   13A                                                      RADDAT
     D  savDatTim                    13A                                                      RADDAT
     D  rstDatTim                    13A                                                      RADDAT
     D  crtUsrPrf                    10A                                                      RADDAT
     D  crtSys                        8A                                                      RADDAT
     D  resDat                        7A                                                      RADDAT
     D  savSize                      10I 0                                                    RADDAT
     D  savSeqNbr                    10I 0                                                    RADDAT
     D  stg                          10A                                                      RADDAT
     D  savCmd                       10A                                                      RADDAT
     D  savVolID                     71A                                                      RADDAT
     D  savDev                       10A                                                      RADDAT
     D  savFName                     10A                                                      RADDAT
     D  savFLibName                  10A                                                      RADDAT
     D  savLbl                       17A                                                      RADDAT
     D  sysLvl                        9A                                                      RADDAT
     D  compiler                     16A                                                      RADDAT
     D  objLvl                        8A                                                      RADDAT
     D  usrChg                        1A                                                      RADDAT
     D  licPgm                       16A                                                      RADDAT
     D  ptf                          10A                                                      RADDAT
     D  apar                         10A                                                      RADDAT
      *                                                                                       RADDAT
     D objd0400_t      DS                  qualified           based(pDummy)                  RADDAT
      *    OBJD0100 ...                                                                       RADDAT
     D  bytRet                       10I 0                                                    RADDAT
     D  bytAvl                       10I 0                                                    RADDAT
     D  name                         10A                                                      RADDAT
     D  lib                          10A                                                      RADDAT
     D  type                         10A                                                      RADDAT
     D  rtnLib                       10A                                                      RADDAT
     D  auxStgP                      10I 0                                                    RADDAT
     D  owner                        10A                                                      RADDAT
     D  domain                        2A                                                      RADDAT
     D  crtDatTim                    13A                                                      RADDAT
     D  chgDatTim                    13A                                                      RADDAT
      *    OBJD0200 ...                                                                       RADDAT
     D  extObjAtr                    10A                                                      RADDAT
     D  text                         50A                                                      RADDAT
     D  srcFile                      10A                                                      RADDAT
     D  srcLib                       10A                                                      RADDAT
     D  srcMbr                       10A                                                      RADDAT
      *    OBJD0300 ...                                                                       RADDAT
     D  srcFDatTim                   13A                                                      RADDAT
     D  savDatTim                    13A                                                      RADDAT
     D  rstDatTim                    13A                                                      RADDAT
     D  crtUsrPrf                    10A                                                      RADDAT
     D  crtSys                        8A                                                      RADDAT
     D  resDat                        7A                                                      RADDAT
     D  savSize                      10I 0                                                    RADDAT
     D  savSeqNbr                    10I 0                                                    RADDAT
     D  stg                          10A                                                      RADDAT
     D  savCmd                       10A                                                      RADDAT
     D  savVolID                     71A                                                      RADDAT
     D  savDev                       10A                                                      RADDAT
     D  savFName                     10A                                                      RADDAT
     D  savFLibName                  10A                                                      RADDAT
     D  savLbl                       17A                                                      RADDAT
     D  sysLvl                        9A                                                      RADDAT
     D  compiler                     16A                                                      RADDAT
     D  objLvl                        8A                                                      RADDAT
     D  usrChg                        1A                                                      RADDAT
     D  licPgm                       16A                                                      RADDAT
     D  ptf                          10A                                                      RADDAT
     D  apar                         10A                                                      RADDAT
      *    OBJD0400 ...                                                                       RADDAT
     D  lastUseDat                    7A                                                      RADDAT
     D  useInfUpd                     1A                                                      RADDAT
     D  daysUseCnt                   10I 0                                                    RADDAT
     D  objSize                      10I 0                                                    RADDAT
     D  objSizeMlt                   10I 0                                                    RADDAT
     D  objCmpSts                     1A                                                      RADDAT
     D  alwChgPgm                     1A                                                      RADDAT
     D  chgByPgm                      1A                                                      RADDAT
     D  usrDfnAtr                    10A                                                      RADDAT
     D  aspOflw                       1A                                                      RADDAT
     D  savActDatTim                 13A                                                      RADDAT
     D  objAudVal                    10A                                                      RADDAT
     D  priGrp                       10A                                                      RADDAT
     D  jrnStat                       1A                                                      RADDAT
     D  jrnName                      10A                                                      RADDAT
     D  jrnLibName                   10A                                                      RADDAT
     D  jrnImages                     1A                                                      RADDAT
     D  jrnOmitE                      1A                                                      RADDAT
     D  jrnStrDatTim                 13A                                                      RADDAT
     D  dgtSigned                     1A                                                      RADDAT
     D  savSizeUnits                 10I 0                                                    RADDAT
     D  savSizeMlt                   10I 0                                                    RADDAT
     D  libASPNbr                    10I 0                                                    RADDAT
     D  objASPDev                    10A                                                      RADDAT
     D  libASPDev                    10A                                                      RADDAT
     D  dgtSignedTrst                 1A                                                      RADDAT
     D  dgtSignedMult                 1A                                                      RADDAT
     D  reserved_1                    2A                                                      RADDAT
     D  priAscSpcSize                10I 0                                                    RADDAT
     D  optSpcAlgn                    1A                                                      RADDAT
     D  objASPGrp                    10A                                                      RADDAT
     D  libASPGrp                    10A                                                      RADDAT
     D  strJrnRcv                    10A                                                      RADDAT
     D  strJrnRcvLib                 10A                                                      RADDAT
     D  strJrnRcvLibASPDev...                                                                 RADDAT
     D                               10A                                                      RADDAT
     D  strJrnRcvLibASPGrp...                                                                 RADDAT
     D                               10A                                                      RADDAT
     D  reserved_2                    1A                                                      RADDAT
      *                                                                                       RADDAT
      /ENDIF                                                                                  RADDAT
