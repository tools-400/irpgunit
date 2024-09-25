**free
/if not defined(QPZRTVFX)
/define QPZRTVFX

// Retrieve Program Temporary Fix Information (QPZRTVFX) API
dcl-pr QPZRTVFX extpgm('QPZRTVFX');
  o_rcvVar      char(65535) options(*varsize);
  i_lenRcvVar   int(10) const;
  i_PTF_inf     char(50) const;
  i_format      char(8) const;
  io_errCode    char(65535) options(*varsize);
end-pr;

dcl-c PTF_LOADED_STATUS_NOT_LOADED          '0';
dcl-c PTF_LOADED_STATUS_LOADED              '1';
dcl-c PTF_LOADED_STATUS_APPLIED             '2';
dcl-c PTF_LOADED_STATUS_PERMANENTLY_APPLIED '3';
dcl-c PTF_LOADED_STATUS_PERMANENTLY_REMOVED '4';
dcl-c PTF_LOADED_STATUS_DAMAGED             '5';
dcl-c PTF_LOADED_STATUS_SUPERSEDED          '6';

dcl-ds PTF_inf_t qualified template;
  ptfID          char(7);
  productID      char(7);
  releaseLvl     char(6);
  dirNmeCCSID    int(10);
  closeDBFiles   char(1);
  reserved_1     char(25);
end-ds;

dcl-ds ptfr0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  ofsAddInf       int(10);
  productID       char(7);
  ptfID           char(7);
  releaseLvl      char(6);
  prdOpt          char(4);
  loadID          char(4);
  loadStat        char(1);
  cvrLtrStat      char(1);
  onOdrStat       char(1);
  savFStat        char(1);
  savF            char(10);
  savFLib         char(10);
  ptfType         char(1);
  iplAct          char(1);
  actPnd          char(1);
  actReq          char(1);
  ptfIsRls        char(1);
  tgtRls          char(6);
  spsdngPtf       char(7);
  currIplSrc      char(1);
  minLvl          char(2);
  maxLvl          char(2);
  fmtInvAvl       char(1);
  statDateTime    char(13);
  licIntCdeGrp    char(7);
  spsByPtfID      char(7);
  currSvrIplSrc   char(1);
  svrIplReq       char(1);
  crtDateTime     char(13);
  tchRfrPTF       char(1);
  tmpAplDateTime  char(13);
end-ds;

/endif
