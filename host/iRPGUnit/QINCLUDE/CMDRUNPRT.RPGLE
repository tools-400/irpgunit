      //
      // Prototypes for RPGUnit command line runner printing facilities.
      //

       // Close the printer file.
     D clsPrt          pr                  extproc('clsPrt')

       // Returns the current spooled file.
     D getSplF         pr                  extproc('getSplF')
     D                                     likeds(SplF_t)

       // Return the printing area width (in characters).
     D getPrtWidth     pr            10i 0 extproc('getPrtWidth')

       // Open the printer file.
     D opnPrt          pr                  extproc('opnPrt')
     D  testPgmNm                          const like(Object_t.nm)

       // Print a line in the printer file.
       // If the line is too long, it will be truncated with no warning.
     D prtLine         pr                  extproc('prtLine')
     D  line                         80a   const

