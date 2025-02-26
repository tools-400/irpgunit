**FREE
/if not defined (irpgunit_errorcode)
/define irpgunit_errorcode

// ==========================================================================
//  API Error Code Data Structure.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// Reference :
// http://publib.boulder.ibm.com/iseries/v5r2/
// ic2924/index.htm?info/apis/error.htm
// ==========================================================================

dcl-ds errorCode_t qualified template;
  // Bytestprovided. The number of bytes that the calling application
  // provides for the error code.
  bytPrv          int(10) inz(%size(errorCode_t));
  // Bytes available. The length of the error information available to
  // the API to return, in bytes. If this is 0, no error was detected an
  // none of the fields that follow this field in the structure are chand.
  bytAvl          int(10) inz(0);
  // Exception ID. The identifier for the message for the error conditio
  excID           char(7);
  // Reserved
  reserved_1      char(1);
  // Exception data
  excDta          char(240);
end-ds;

// Error Code data structure to force error message percolation.
dcl-ds percolateErrors_t
       qualified template;
  // No bytes provided. If an error occurs, an exception is returned to e caller
  // to indicate that the requested function failed.
  bytPrv          int(10) inz(0);
  bytAvl          int(10) inz(0);
end-ds;

/endif

