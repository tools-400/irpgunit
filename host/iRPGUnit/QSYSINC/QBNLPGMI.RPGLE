**FREE

// List ILE program information (QBNLPGMI) API.
dcl-pr qbnlpgmi extpgm('QBNLPGMI');
  usrSpc          char(20) const;
  fmt             char(8) const;
  pgm             char(20) const;
  errors          char(32766) options(*varsize) noopt;
end-pr;

// Structure of an entry in a QBNLPGMI list.
dcl-ds pgml0100_t qualified template;
  pgm             char(10);
  pgmLib          char(10);
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
end-ds;
//   ...

