**FREE

//  Change Object Description (QLICOBJD) API
dcl-pr qlicobjd extpgm('QLICOBJD');
  rtnLib          char(10);
  qObj            char(20) const;
  type            char(10) const;
  chgObjInf       char(32767) const options(*varsize);
  errcode         char(32767) const options(*varsize);
end-pr;
