**free
/if not defined(QWCRDTAA)
/define QWCRDTAA

// Retrieve Data Area (QWCRDTAA) API
dcl-pr QWCRDTAA extpgm('QWCRDTAA');
  o_rcvVar    char(65535) options(*varsize);
  i_lenRcvVar int(10) const;
  i_qDtaAra   char(20) const;
  i_start     int(10) const;
  i_length    int(10) const;
  io_errCode  char(65535) options(*varsize);
end-pr;

// Format of Data Returned (attributes and value)
dcl-ds rtvDtaAra_t qualified template;
  bytRet int(10);
  bytAvl int(10);
  type   char(10);
  lib    char(10);
  length int(10);
  decPos int(10);
  value  char(2000);
end-ds;

// Format of Data Returned (attributes only)
dcl-ds rtvDtaAraA_t qualified template;
  bytRet int(10);
  bytAvl int(10);
  type   char(10);
  lib    char(10);
  length int(10);
  decPos int(10);
end-ds;

/endif
