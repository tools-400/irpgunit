**FREE
//
// Prototype for QGYCLST API.
//
// Close List
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyclst.htm
//

dcl-pr qgyclst extpgm('QGYCLST');
  i_rqsHdl   char(4) const;
  io_error   char(32766) options(*varsize);
end-pr;
