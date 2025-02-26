**FREE

// Prototype for API QWVRCSTK (Retrieve Call Stack).

dcl-pr qwvrcstk extpgm('QWVRCSTK');
  rawCallStk      char(32766) options(*varsize);
  rawCallStkLen   int(10) const;
  fmtRcvInfo      char(8) const;
  jobIDInfo       const likeds(dsjidf0100);
  fmtJobIDInfo    char(8) const;
  errors          char(32766) options(*varsize) noopt;
end-pr;

dcl-ds dsjidf0100 qualified template;
  jobNm           char(10);
  usrNm           char(10);
  jobNb           char(6);
  intJobID        char(16);
  reserved        char(2);
  threadInd       int(10);
  threadID        char(8);
end-ds;

dcl-ds dscstk0100hdr qualified template;
  bytEsp                int(10);
  bytAvl                int(10);
  nbCallStkEntForThread int(10);
  callStkOffs           int(10);
  nbCallStkEntRtn       int(10);
  threadID              char(8);
  infoSts               char(1);
end-ds;

dcl-ds dscstk0100ent qualified template;
  len             int(10);
  dspLtoSttid     int(10);
  nbSttid         int(10);
  dspLtoProcNm    int(10);
  procNmLen       int(10);
  rqsLvl          int(10);
  pgmNm           char(10);
  pgmLibNm        char(10);
  miInstNb        int(10);
  modNm           char(10);
  modLibNm        char(10);
  ctlBndry        char(1);
  *N              char(3);
  actGrpNb        uns(10);
  actGrpNm        char(10);
  *N              char(2);
  pgmAspNm        char(10);
  pgmLibAspNm     char(10);
  pgmAspNb        int(10);
  pgmLibAspNb     int(10);
end-ds;


