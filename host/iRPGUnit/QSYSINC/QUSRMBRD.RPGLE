**FREE
/if not defined(QUSRMBRD)
/define QUSRMBRD

//  Retrieve Member Description (QUSRMBRD) API
dcl-pr qusrmbrd extpgm('QUSRMBRD');
  o_rcvVar        char(65535) options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  i_qFile         char(20) const;
  i_mbr           char(10) const;
  i_ovrPrc        char(1) const;
  io_errCode      char(65535) options(*nopass: *varsize); // OptGrp 1
  i_findMbrPrc    char(1) const  options(*nopass);        // OptGrp 2
end-pr;

//  MBRD0100 Format
dcl-ds mbrd0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  qFile           char(20);
  mbr             char(10);
  attr            char(10);
  srcType         char(10);
  crtDatTim       char(13);
  srcChgDatTim    char(13);
  text            char(50);
  isSrcFile       ind;
end-ds;

//  MBRD0200 Format
dcl-ds mbrd0200_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  qFile           char(20);
  mbr             char(10);
  attr            char(10);
  srcType         char(10);
  crtDatTim       char(13);
  srcChgDatTim    char(13);
  text            char(50);
  isSrcFile       ind;
  isRemoteFile    ind;
  isLogicalFile   ind;
  isOdpShareAlw   ind;
  reserved_1      char(2);
  numTotRcds      int(10);
  numDltRcds      int(10);
  dtaSpcSize      int(10);
  accPathSize     int(10);
  numBasedMbr     int(10);
  chgDatTim       char(13);
  savDatTim       char(13);
  rstDatTim       char(13);
  expDate         char(7);
  reserved_2      char(6);
  numDaysUsed     int(10);
  dateLastUsed    char(7);
  useResetDate    char(7);
  reserved_3      char(2);
  dtaSpcSizeMlt   int(10);
  accPathSizeMlt  int(10);
  textCcsid       int(10);
  ofsAddInf       int(10);
  lenAddInf       int(10);
  numTotRcdsU     uns(10);
  numDltRcdsU     uns(10);
  reserved_4      char(6);
end-ds;

/endif
