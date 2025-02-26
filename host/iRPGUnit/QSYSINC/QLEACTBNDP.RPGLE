**FREE
//
// Prototype for QleActBndPgm API.
//
// "Activate Bound Program".
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qleactbp.htm
//

// (RETURN) Activation mark.
dcl-pr qleactbndpgm int(10) extproc('QleActBndPgm');
  pSrvPgm         pointer(*proc) const;         // (INPUT) Pointer to bound program.
  actMark         int(10) options(*omit);       // (OUTPUT) Activation mark.
  actInfo         char(64) options(*omit);      // (OUTPUT) Activation information.
  actInfoLen      int(10) const options(*omit); // (INPUT) Length of activation information.
  errors          char(32767) options(*varsize: *omit) noopt; // (I/O) Error code.
end-pr;

