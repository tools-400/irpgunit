**FREE
/IF DEFINED(QSPRILSP)
/EOF
/ENDIF
/DEFINE QSPRILSP

//  Retrieve Identity of Last Spooled File Created (QSPRILSP) API
dcl-pr qsprilsp extpgm('QSPRILSP');
  o_rcvVar        char(65535) options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  io_errCode      char(65535) options(*varsize);
end-pr;

//  SPRL0100 Format
dcl-ds sprl0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  name            char(10);
  job             char(10);
  user            char(10);
  jobNbr          char(6);
  splfNbr         int(10);
  system          char(8);
  crtDate         char(7);
  reserved_1      char(1);
  crtTime         char(6);
end-ds;

