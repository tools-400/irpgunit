      //
      // Prototype for QLICVTTP API.
      //
      // "Convert an object type from the external symbolic format to the internal hexadecimal
      // format and vice versa."
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qlicvttp.htm
      //

     DQLICVTTP         PR                  ExtPgm('QLICVTTP')
     D cvtType                       10a   const
     D objType                       10a   const
     D hexType                        2a
     D error                      32767a   options(*VARSIZE:*OMIT) noopt
