**free
/if not defined(QSZRTVPR)
/define QSZRTVPR

// Retrieve Product Information (QSZRTVPR) API
dcl-pr QSZRTVPR extpgm('QSZRTVPR');
  receiver      char(32767) options(*varsize);
  length        int(10) const;
  format        char(8) const;
  productInfo   char(32767) options(*varsize) const;
  errorCode     char(32767) options(*varsize);
end-pr;

dcl-ds prdi0100_t qualified template;
  productID    char(7);
  releaseLvl   char(6);
  productOpt   char(4);
  loadID       char(10);
end-ds;

dcl-ds prdr0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  reserved_1      int(10);
  productID       char(7);
  releaseLvl      char(6);
  productOpt      char(4);
  loadID          char(4);
  loadType        char(10);
  symLoadState    char(10);
  loadErrInd      char(10);
  loadState       char(2);
  supportedFlag   char(1);
  regType         char(2);
  regValue        char(14);
  reserved_2      char(2);
  offsAddInf      int(10);
  priLangLoadID   char(4);
  minTgtRls       char(6);
  minVRM          char(6);
  reqMetBasOptV   char(1);
  level           char(3);
end-ds;

/endif
