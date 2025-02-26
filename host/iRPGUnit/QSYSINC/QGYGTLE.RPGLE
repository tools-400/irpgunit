**FREE
//
// Prototype for QGYGTLE API.
//
// Get List Entries
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgygtle.htm
//

dcl-pr qgygtle extpgm('QGYGTLE');
  o_rcvVar        char(32766) options(*varsize);
  i_rcvVarLen     int(10) const;
  i_rqsHdl        char(4) const;
  o_listInfo      char(80);
  i_nbrRcdToRtn   int(10) const;
  i_startRcdIdx   int(10) const;
  io_error        char(32766) options(*varsize);
end-pr;
