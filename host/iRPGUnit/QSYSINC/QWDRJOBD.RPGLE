**FREE
/IF NOT DEFINED(QWDRJOBD)
/DEFINE QWDRJOBD

//  Retrieve Job Description Information (QWDRJOBD) API
dcl-pr qwdrjobd extpgm('QWDRJOBD');
  o_rcvVar        char(65535) options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  i_qJobD         char(20) const;
  io_errCode      char(65535) options(*varsize);
end-pr;

dcl-ds qwdrjobd_qObj_t qualified template;
  name            char(10);
  lib             char(10);
end-ds;

//  JOBD0100 Format
dcl-ds jobd0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  qJobD           likeds(qwdrjobd_qObj_t);
  user            char(10);
  date            char(8);
  sws             char(8);
  qJobQ           likeds(qwdrjobd_qObj_t);
  jobPty          char(2);
  hold            char(10);
  qOutQ           likeds(qwdrjobd_qObj_t);
  outPty          char(2);
  prtDev          char(10);
  prtText         char(30);
  syntax          int(10);
  endSev          int(10);
  logSev          int(10);
  logLvl          char(1);
  logText         char(10);
  logCLPgm        char(10);
  inqMsgRpy       char(10);
  devRcyAcn       char(13);
  tsePool         char(10);
  acgCde          char(15);
  rtgDta          char(80);
  text            char(50);
  reserved_1      char(1);
  ofsInlLibl      int(10);
  numInlLiblE     int(10);
  ofsRqsDta       int(10);
  lenRqsDta       int(10);
  jobMsgQMx       int(10);
  jobMsgQFl       char(10);
  dateCymd        char(10);
  alwMltThd       char(10);
  splfAcn         char(10);
  ofsInlAspGrp    int(10);
  numInlAspGrpE   int(10);
  lenInlAspGrpE   int(10);
  ddmCnv          char(10);
  logOutput       char(10);
  //   Initial library list                  Array (*) of CHAR(11)
  //   Request data                          CHAR(*)
  //   Initial ASP group information entry   Array (*) of CHAR(*)
end-ds;

/ENDIF
