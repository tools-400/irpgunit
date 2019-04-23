      //
      // Prototype for QCMDEXC API.
      //
      // Execute Command
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qcmdexc.htm
      //

     DQCMDEXC          pr                  ExtPgm('QCMDEXC')
     D cmd                        32702a   const options(*varsize)
     D cmdLen                        15p 5 const
