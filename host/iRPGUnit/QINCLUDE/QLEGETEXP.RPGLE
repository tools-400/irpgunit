      //
      // Prototype for QleGetExp API.
      //
      // Get export pointer.
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qlegetexp.htm
      //

     DQleGetExp        pr              *   extproc('QleGetExp') procptr
     D actMark                       10i 0 const options(*omit)
     D expNo                         10i 0 const options(*omit)
     D expNmLen                      10i 0 const options(*omit)
     D expNm                      32767a   const options(*varsize: *omit)
     D expPtr                          *   options(*omit) procptr
     D expType                       10i 0 options(*omit)
     D error                      32767a   options(*varsize: *omit) noopt
