      //
      // Prototype for JOBLOG.
      //

       // Assert that the job log of the current job contains the given message id.
     D assertJobLogContains...
     D                 pr                  extproc('assertJobLogContains')
        // A message identifier (e.g., 'MCH1211').
     D  msgId                         7a   const
        // A timestamp to limit how far in the past the procedure should look in the job log.
     D  timeLimit                      z   const

       // Returns the full current timestamp, without rounding the microseconds like
       // %timestamp does.
     D getFullTimeStamp...
     D                 pr              z   extproc('getFullTimeStamp')
