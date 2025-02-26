**FREE
/if defined(opnlist)
/eof
/endif
/define opnlist
//
// Open list structure
//
// Reference :
// http://publib.boulder.ibm.com/iseries/v5r2/index.htm?info/apis/oli.htm
//

dcl-ds dsOpnList qualified template;
  totalRcdCnt     int(10);
  retRcdCnt       int(10);
  rqsHdl          char(4);
  rcdLen          int(10);
  infoCompInd     char(1);
  crtDateTime     char(13);
  listStatusInd   char(1);
  *N              char(1);
  rtnInfoLen      int(10);
  firstRcdIdx     int(10);
  *N              char(40);
end-ds;

