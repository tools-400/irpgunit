       /if not defined (IRPGUNIT_ERRORCODE)
       /define IRPGUNIT_ERRORCODE

       //
       // API error code structure
       //
       // Reference :
       // http://publib.boulder.ibm.com/iseries/v5r2/
       // ic2924/index.htm?info/apis/error.htm

     D errorCode_t     ds                  qualified template
        // Bytestprovided. The number of bytes that the calling application
        // provides for the error code.
     D  bytPrv                       10i 0 inz(%size(errorCode_t))
        // Bytes available. The length of the error information available to
        // the API to return, in bytes. If this is 0, no error was detected and
        // none of the fields that follow this field in the structure are changed.
     D  bytAvl                       10i 0 inz(0)
        // Exception ID. The identifier for the message for the error condition.
     D  excID                         7a
        // Reserved
     D  reserved_1                    1a
        // Exception data
     D  excDta                      240a

       // Error Code data structure to force error message percolation.
     D percolateErrors_t...
     D                 ds                  qualified template
        // No bytes provided. If an error occurs, an exception is returned to the caller
        // to indicate that the requested function failed.
     D  bytPrv                       10i 0 inz(0)
     D  bytAvl                       10i 0 inz(0)

      /endif

