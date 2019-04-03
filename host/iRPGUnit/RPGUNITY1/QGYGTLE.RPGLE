      //
      // Prototype for QGYGTLE API.
      //
      // Get List Entries
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgygtle.htm
      //

     DQGYGTLE          pr                  ExtPgm('QGYGTLE')
     D listEnt                    32766a   options(*varsize)
     D listEntLen                    10i 0 const
     D rqsHdl                         4a   const
     D listInfo                      80a
     D nbOfRcdToRtn                  10i 0 const
     D startingRcdIdx                10i 0 const
     D error                      32766a   options(*varsize: *omit) noopt
