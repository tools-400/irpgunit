**FREE

//
// Get Spooled File Data API
//

dcl-pr qspgetsp extpgm('QSPGETSP');
  splfHdl         int(10) const;
  usrSpcNm        char(20) const;
  fmtNm           char(8) const;
  ordNbOfBuf      int(10) const;
  splfEnd         char(10) const;
  error           char(32766) options(*varsize) noopt;
end-pr;

// QSP API Generic Header Section.
dcl-ds qspgenhdr_t qualified template;
  genUsrAra       char(64);
  hdrSize         int(10);
  strLvl          char(4);
  splfLvl         char(6);
  fmt             char(8);
  compind         char(1);
  *N              char(1);
  usrSpcSizeUsed  int(10);
  firstBufOffs    int(10);
  nbOfBufRqs      int(10);
  nbOfBufRtn      int(10);
  prtDtaSize      int(10);
  nbOfCompPg      int(10);
  nbOfFirstPg     int(10);
  offsToFirstPg   int(10);
  *N              char(8);
end-ds;

