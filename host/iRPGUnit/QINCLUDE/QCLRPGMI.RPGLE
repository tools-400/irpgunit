      /IF NOT DEFINED(QCLRPGMI)                                                               RADDAT
      /DEFINE QCLRPGMI                                                                        RADDAT
      *                                                                                       RADDAT
      *  Retrieve Program Information (QCLRPGMI) API                                          RADDAT
     D QCLRPGMI...                                                                            RADDAT
     D                 PR                         extpgm('QCLRPGMI')                          RADDAT
     D  o_rcvVar                  65535A   const  options(*varsize)                           RADDAT
     D  i_lenRcvVar                  10I 0 const                                              RADDAT
     D  i_format                      8A   const                                              RADDAT
     D  i_qPgm                       20A   const                                              RADDAT
     D  io_errCode                65535A          options(*varsize)                           RADDAT
      *                                                                                       RADDAT
      *  PGMI0100 Format                                                                      RADDAT
     D pgmi0100_t...                                                                          RADDAT
     D                 DS                  qualified               based(pDummy)              RADDAT
     D  bytRet                 1      4I 0                                                    RADDAT
     D  bytAvl                 5      8I 0                                                    RADDAT
      *  Program creation information                                                         RADDAT
     D  pgm                    9     18A                                                      RADDAT
     D  lib                   19     28A                                                      RADDAT
     D  owner                 29     38A                                                      RADDAT
     D  attr                  39     48A                                                      RADDAT
     D  crtDatTim             49     61A                                                      RADDAT
     D  srcFile               62     71A                                                      RADDAT
     D  srcLib                72     81A                                                      RADDAT
     D  srcMbr                82     91A                                                      RADDAT
     D  srcUpdDatTim          92    104A                                                      RADDAT
     D  obsInf               105    105A                                                      RADDAT
     D  usrPrfOpt            106    106A                                                      RADDAT
     D  usrAdpAut            107    107A                                                      RADDAT
     D  logCmds              108    108A                                                      RADDAT
     D  alwRtvClSrc          109    109A                                                      RADDAT
     D  fixDecDta            110    110A                                                      RADDAT
     D  text                 111    160A                                                      RADDAT
     D  type                 161    161A                                                      RADDAT
     D  teraSpace            162    162A                                                      RADDAT
     D  reserved_1           163    220A                                                      RADDAT
      *  Program statistics information                                                       RADDAT
     D  numParmMin           221    224I 0                                                    RADDAT
     D  numParmMax           225    228I 0                                                    RADDAT
     D  pgmSize              229    232I 0                                                    RADDAT
     D  ascSpcSize           233    236I 0                                                    RADDAT
     D  stcStgSize           237    240I 0                                                    RADDAT
     D  atmStgSize           241    244I 0                                                    RADDAT
     D  numInstr_MI          245    248I 0                                                    RADDAT
     D  numOdtE_MI           249    252I 0                                                    RADDAT
     D  pgmState             253    253A                                                      RADDAT
     D  cmplrID              254    267A                                                      RADDAT
     D  lowRlsRun            268    273A                                                      RADDAT
     D  srtSeq               274    283A                                                      RADDAT
     D  srtSeqLib            284    293A                                                      RADDAT
     D  langID               294    303A                                                      RADDAT
     D  pgmDmn               304    304A                                                      RADDAT
     D  cnvReq               305    305A                                                      RADDAT
     D  reserved_2           306    325A                                                      RADDAT
      *  Program performance information                                                      RADDAT
     D  optimization         326    326A                                                      RADDAT
     D  pagingPool           327    327A                                                      RADDAT
     D  update_PASA          328    328A                                                      RADDAT
     D  clear_PASA           329    329A                                                      RADDAT
     D  pagingAmount         330    330A                                                      RADDAT
     D  reserved_3           331    348A                                                      RADDAT
      *  ILE information                                                                      RADDAT
     D  entryPrcMod          349    358A                                                      RADDAT
     D  entryPrcModLb        359    368A                                                      RADDAT
     D  actGrpAttr           369    398A                                                      RADDAT
     D  obsInfCmprssd        399    399A                                                      RADDAT
     D  runInfCmprssd        400    400A                                                      RADDAT
     D  rlsCrtOn             401    406A                                                      RADDAT
     D  shrActGrp            407    407A                                                      RADDAT
     D  alwUpd               408    408A                                                      RADDAT
     D  pgmCCSID             409    412I 0                                                    RADDAT
     D  numMod               413    416I 0                                                    RADDAT
     D  numSrvPgm            417    420I 0                                                    RADDAT
     D  numCpyRght           421    424I 0                                                    RADDAT
     D  numUnRslvdRef        425    428I 0                                                    RADDAT
     D  rlsCrtFor            429    434A                                                      RADDAT
     D  alwStcStgRInz        435    435A                                                      RADDAT
     D  allCrtDta            436    436A                                                      RADDAT
     D  alwBndSrvPgmLibUpd...                                                                 RADDAT
     D                       437    437A                                                      RADDAT
     D  prfDta               438    447A                                                      RADDAT
     D  teraSpaceMods        448    448A                                                      RADDAT
     D  stgMdl               449    449A                                                      RADDAT
     D  reserved_4           450    536A                                                      RADDAT
      *                                                                                       RADDAT
      *  PGMI0200 Format                                                                      RADDAT
     D pgmi0200_t...                                                                          RADDAT
     D                 DS                  qualified               based(pDummy)              RADDAT
     D  bytRet                 1      4I 0                                                    RADDAT
     D  bytAvl                 5      8I 0                                                    RADDAT
      *  Program creation information                                                         RADDAT
     D  pgm                    9     18A                                                      RADDAT
     D  lib                   19     28A                                                      RADDAT
     D  owner                 29     38A                                                      RADDAT
     D  attr                  39     48A                                                      RADDAT
     D  crtDatTim             49     61A                                                      RADDAT
     D  srcFile               62     71A                                                      RADDAT
     D  srcLib                72     81A                                                      RADDAT
     D  srcMbr                82     91A                                                      RADDAT
     D  srcUpdDatTim          92    104A                                                      RADDAT
     D  obsInf               105    105A                                                      RADDAT
     D  usrPrfOpt            106    106A                                                      RADDAT
     D  usrAdpAut            107    107A                                                      RADDAT
     D  logCmds              108    108A                                                      RADDAT
     D  alwRtvClSrc          109    109A                                                      RADDAT
     D  fixDecDta            110    110A                                                      RADDAT
     D  text                 111    160A                                                      RADDAT
     D  type                 161    161A                                                      RADDAT
     D  teraSpace            162    162A                                                      RADDAT
     D  reserved_1           163    220A                                                      RADDAT
      *  Program statistics information                                                       RADDAT
     D  numParmMin           221    224I 0                                                    RADDAT
     D  numParmMax           225    228I 0                                                    RADDAT
     D  pgmSize              229    232I 0                                                    RADDAT
     D  ascSpcSize           233    236I 0                                                    RADDAT
     D  stcStgSize           237    240I 0                                                    RADDAT
     D  atmStgSize           241    244I 0                                                    RADDAT
     D  numInstr_MI          245    248I 0                                                    RADDAT
     D  numOdtE_MI           249    252I 0                                                    RADDAT
     D  pgmState             253    253A                                                      RADDAT
     D  cmplrID              254    267A                                                      RADDAT
     D  lowRlsRun            268    273A                                                      RADDAT
     D  srtSeq               274    283A                                                      RADDAT
     D  srtSeqLib            284    293A                                                      RADDAT
     D  langID               294    303A                                                      RADDAT
     D  pgmDmn               304    304A                                                      RADDAT
     D  cnvReq               305    305A                                                      RADDAT
     D  reserved_2           306    325A                                                      RADDAT
      *  Program performance information                                                      RADDAT
     D  optimization         326    326A                                                      RADDAT
     D  pagingPool           327    327A                                                      RADDAT
     D  update_PASA          328    328A                                                      RADDAT
     D  clear_PASA           329    329A                                                      RADDAT
     D  pagingAmount         330    330A                                                      RADDAT
     D  reserved_3           331    348A                                                      RADDAT
      *  Program SQL information                                                              RADDAT
     D  numSqlStmts          349    352I 0                                                    RADDAT
     D  rdb                  353    370A                                                      RADDAT
     D  commit               371    380A                                                      RADDAT
     D  alwCpyDta            381    390A                                                      RADDAT
     D  cloSqlCsr            391    400A                                                      RADDAT
     D  naming               401    410A                                                      RADDAT
     D  datFmt               411    420A                                                      RADDAT
     D  datSep               421    421A                                                      RADDAT
     D  timFmt               422    431A                                                      RADDAT
     D  timSep               432    432A                                                      RADDAT
     D  dlyPrp               433    442A                                                      RADDAT
     D  alwBlk               443    452A                                                      RADDAT
      *  ILE information                                                                      RADDAT
     D  entryPrcMod          453    462A                                                      RADDAT
     D  entryPrcModLb        463    472A                                                      RADDAT
     D  actGrpAttr           473    502A                                                      RADDAT
     D  obsInfCmprssd        503    503A                                                      RADDAT
     D  runInfCmprssd        504    504A                                                      RADDAT
     D  rlsCrtOn             505    510A                                                      RADDAT
     D  shrActGrp            511    511A                                                      RADDAT
     D  alwUpd               512    512A                                                      RADDAT
     D  pgmCCSID             513    516I 0                                                    RADDAT
     D  numMod               517    520I 0                                                    RADDAT
     D  numSrvPgm            521    524I 0                                                    RADDAT
     D  numCpyRght           525    528I 0                                                    RADDAT
     D  numUnRslvdRef        529    532I 0                                                    RADDAT
     D  rlsCrtFor            533    538A                                                      RADDAT
     D  alwStcStgRInz        539    539A                                                      RADDAT
      *  Continuation of program SQL information                                              RADDAT
     D  dftRdbCol            540    549A                                                      RADDAT
     D  sqlPkg               550    559A                                                      RADDAT
     D  sqlPkgLib            560    569A                                                      RADDAT
     D  dynUsrPrf            570    579A                                                      RADDAT
     D  sqlSrtSeq            580    589A                                                      RADDAT
     D  sqlSrtSeqLib         590    599A                                                      RADDAT
     D  sqlLangID            600    609A                                                      RADDAT
     D  cnnMtd               610    619A                                                      RADDAT
     D  reserved_4           620    620A                                                      RADDAT
     D  sqlPathOfs           621    624I 0                                                    RADDAT
     D  sqlPathLen           625    628I 0                                                    RADDAT
     D  reserved_5           629    719A                                                      RADDAT
      *  Continuation of ILE information                                                      RADDAT
     D  allCrtDta            720    720A                                                      RADDAT
     D  alwBndSrvPgmLibUpd...                                                                 RADDAT
     D                       721    721A                                                      RADDAT
     D  prfDta               722    731A                                                      RADDAT
     D  teraSpaceMods        732    732A                                                      RADDAT
     D  stgMdl               733    733A                                                      RADDAT
     D  reserved_6           734    820A                                                      RADDAT
      *  Program information through offsets                                                  RADDAT
      *  SQL path            CHAR(*)                                                          RADDAT
      *                                                                                       RADDAT
      *  PGMI0300 Format                                                                      RADDAT
     D pgmi0300_t...                                                                          RADDAT
     D                 DS                  qualified               based(pDummy)              RADDAT
     D  bytRet                 1      4I 0                                                    RADDAT
     D  bytAvl                 5      8I 0                                                    RADDAT
      *  ILE program size information                                                         RADDAT
     D  pgm                    9     18A                                                      RADDAT
     D  lib                   19     28A                                                      RADDAT
     D  curTotPgmSize         29     32I 0                                                    RADDAT
     D  maxPgmSize            33     36I 0                                                    RADDAT
     D  curNbrMods            37     40I 0                                                    RADDAT
     D  maxNbrMods            41     44I 0                                                    RADDAT
     D  curNbrSrvPgms         45     48I 0                                                    RADDAT
     D  maxNbrSrvPgms         49     52I 0                                                    RADDAT
     D  curStrDctSize         53     56I 0                                                    RADDAT
     D  maxStrDctSize         57     60I 0                                                    RADDAT
     D  curCpyRghtSize...                                                                     RADDAT
     D                        61     64I 0                                                    RADDAT
     D  maxCpyRghtSize...                                                                     RADDAT
     D                        65     68I 0                                                    RADDAT
     D  curNumAuxStgSegs...                                                                   RADDAT
     D                        69     72I 0                                                    RADDAT
     D  maxNumAuxStgSegs...                                                                   RADDAT
     D                        73     76I 0                                                    RADDAT
     D  minStcStgSize         77     80I 0                                                    RADDAT
     D  maxStcStgSize         81     84I 0                                                    RADDAT
     D  reserved_1            85     88A                                                      RADDAT
     D  minStcStgSizeLong...                                                                  RADDAT
     D                        89     96I 0                                                    RADDAT
     D  maxStcStgSizeLong...                                                                  RADDAT
     D                        97    104I 0                                                    RADDAT
      *                                                                                       RADDAT
      /ENDIF                                                                                  RADDAT
