      //
      // Prototype for QGYGTLE API.
      //
      // Get List Entries
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgygtle.htm
      //

     D QGYGTLE         pr                  ExtPgm('QGYGTLE')
     D  o_rcvVar                  32766a         options(*varsize)
     D  i_rcvVarLen                  10i 0 const
     D  i_rqsHdl                      4a   const
     D  o_listInfo                   80a
     D  i_nbrRcdToRtn                10i 0 const
     D  i_startRcdIdx                10i 0 const
     D  io_error                  32766a         options(*varsize)
