      //
      // Prototype for QleActBndPgm API.
      //
      // "Activate Bound Program".
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qleactbp.htm
      //

      // (RETURN) Activation mark.
     DQleActBndPgm     pr            10i 0 extproc('QleActBndPgm')
       // (INPUT) Pointer to bound program.
     D srvPgm_p                        *   const procptr
       // (OUTPUT) Activation mark.
     D actMark                       10i 0 options(*omit)
       // (OUTPUT) Activation information.
     D actInfo                       64a   options(*omit)
       // (INPUT) Length of activation information.
     D actInfoLen                    10i 0 const options(*omit)
       // (I/O) Error code.
     D errors                     32767a   options(*varsize: *omit) noopt

