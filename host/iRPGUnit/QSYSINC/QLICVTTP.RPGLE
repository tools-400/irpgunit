**FREE
//
// Prototype for QLICVTTP API.
//
// "Convert an object type from the external symbolic format to the internal hexadecimal
// format and vice versa."
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qlicvttp.htm
//

dcl-pr qlicvttp extpgm('QLICVTTP');
  cvtType         char(10) const;
  objType         char(10) const;
  hexType         char(2);
  error           char(32767) options(*varsize:*omit) noopt;
end-pr;
