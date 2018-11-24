
       //
       // API error code structure
       //
       // Reference :
       // http://publib.boulder.ibm.com/iseries/v5r2/
       // ic2924/index.htm?info/apis/error.htm

     D errorCode       ds                  qualified
        // Bytes provided. The number of bytes that the calling application
        // provides for the error code.
     D  bytesP                       10i 0 inz(%size(errorCode))
        // Bytes available. The length of the error information available to
        // the API to return, in bytes. If this is 0, no error was detected and
        // none of the fields that follow this field in the structure are changed.
     D  bytesA                       10i 0 inz(0)
        // Exception ID. The identifier for the message for the error condition.
     D  msgID                         7a
        // Reserved
     D                                1a
        // Exception data
     D  msgData                     240a

       // Error Code data structure to force error message percolation.
     D percolateErrors...
     D                 ds                  qualified
        // No bytes provided. If an error occurs, an exception is returned to the caller
        // to indicate that the requested function failed.
     D  bytesP                       10i 0 inz(0)

