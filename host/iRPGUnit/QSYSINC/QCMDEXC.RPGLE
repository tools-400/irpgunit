**FREE
//
// Prototype for QCMDEXC API.
//
// Execute Command
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qcmdexc.htm
//

dcl-pr qcmdexc extpgm('QCMDEXC');
  cmd      char(32702) const options(*varsize);
  cmdLen   packed(15:5) const;
end-pr;
