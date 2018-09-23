       // Assertion procedure prototypes.

       // aEqual -- Aphanumeric Equality Assertion
       // Assert that two alphanumeric variables are equal.
       //
       // Example:
       //   aEqual( 'John Smith' : name );

     D aEqual          pr                  extproc('aEqual')
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const varying options(*nopass: *omit)


       // assert -- General Purpose Assertion
       // Assert that a condition is true. If not, a failure message percolates.
       //
       // Examples:
       //   assert( newTime > oldTime : 'newTime is not larger than oldTime' );
       //   assert( %not eof : 'Missing record in file XXX' );

     D assert          pr                  extproc('assert')
     D  condition                      n   const
      /if defined(RPGUNIT_INTERNAL)
     D  msgIfFalse                  256a   const
      /else
     D  msgIfFalse                16384a   const varying options(*Varsize)
      /endif


       // fail -- Fail Primitive
       // Percolate an RPGUnit failure message.
       //
       // Example:
       //   monitor;
       //     call PGM();
       //     fail( 'PGM should have thrown an exception' );
       //   on-error;
       //     // Exception seen. Success.
       //   endmon;

     D fail            pr                  extproc('fail')
      /if defined(RPGUNIT_INTERNAL)
     D  msg                         256a   const
      /else
     D  msg                       16384a   const varying options(*Varsize)
      /endif


       // iEqual -- Integer Equality Assertion
       //
       // Assert that two integer variables are equal.
       // Example:
       //   iEqual( 1000 : balance );

     D iEqual          pr                  extproc('iEqual')
     D  expected                     31s 0 const
     D  actual                       31s 0 const
     D  fieldName                    64a   const varying options(*nopass: *omit)


       // nEqual -- Boolean Equality Assertion
       //
       // Assert that two boolean variables are equal.
       // Example:
       //   iEqual( *ON : isFound );

     D nEqual          pr                  extproc('nEqual')
     D  expected                       n   const
     D  actual                         n   const
     D  fieldName                    64a   const varying options(*nopass: *omit)


       // Setup utility procedure prototypes of module SETUP.

       // clrpfm -- Clear Physical File
       // Clear the content of a physical file in *CURLIB.

     D clrpfm          pr
        // A file name.
     D  w1fileNm                     10a   const
        // An (optional) member name.
     D  w1mbrNm                      10a   const options(*NoPass)


       // rclactgrp -- Reclaim Activation Group
       //
       // Example:
       //   rclactgrp( '*ELIGIBLE' );

     D rclactgrp       pr
     D  w1actGrpNm                   10a   const


       // runCmd -- Run CL Command
       //
       // Example:
       //   runCmd( 'ALCOBJ OBJ((*CURLIB/FILE *FILE *EXCL))' );

     D runCmd          pr                  extproc('runCmd')
     D  w1cmd                     32702a   const varying


       // Other utility procedure prototypes of module UTILS.

       // wait -- Wait
       // Waits for a given number of seconds.

     D waitSeconds     pr                  extproc('waitSeconds')
        // Wait time in seconds
     D  seconds                      10i 0 const
        // Optional. Message sent to *EXT
     D  message                      50a   const varying options(*nopass: *omit)


       // displayStatusMessage - Display status message
       // Displays a status message at the bottom of the screen.

     D displayStatusMessage...
     D                 pr                  extproc('displayStatusMessage')
        // Optional. Message sent to *EXT
     D  message                     132a   const varying


       // restoreStatusMessage - Restore status message
       // Restores the previous status message.

     D restoreStatusMessage...
     D                 pr                  extproc('restoreStatusMessage')


       // clearStatusMessage - Clear status message
       // Removes the status message from the bottom of the screen.

     D clearStatusMessage...
     D                 pr                  extproc('clearStatusMessage')


       // getMonitoredMsg - Get monitored message.
       // returns the escape message that was received
       // within a 'monitor' block.

     D getMonitoredMessage...
     D                 pr                  likeds(MsgInfo_t)
     D                                     extproc('getMonitoredMessage')
     D  doRmvMsg                       n   const options(*nopass)

     D MsgInfo_t       ds                  qualified based(template)
     D  id                            7a
     D  txt                         256a   varying
     D  pgm                          10a
     D  mod                          10a
     D  proc                        256a   varying
     D  specNb                       10a


       // getMemberType - Get member type.
       // returns the source type of a given
       // source file and member.

     D getMemberType...
     D                 pr            10a
     D                                     extproc('getMemberType')
     D  srcFile                      10a   const
     D  srcFileLib                   10a   const
     D  mbr                          10a   const

