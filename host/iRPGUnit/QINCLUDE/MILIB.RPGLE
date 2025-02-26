**FREE
/if not defined (IRPGUNIT_MILIB)
/define IRPGUNIT_MILIB

// ==========================================================================
//  MI Library Function Prototypes.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// The following values can be OR'd for the Wait Options parameter
// on the WAITTIME invocation.
dcl-c WAIT_NORMAL       0;     // x'0000'
dcl-c WAIT_MOD_AS_ENTER 32768; // x'8000'
dcl-c WAIT_MOD_AS_LEAVE 16384; // x'4000'
dcl-c WAIT_MPL_SET      8192;  // x'2000'
dcl-c WAIT_SIGNALS      4096;  // x'1000'

// Wait On Time (WAITTIME)
dcl-pr waitTime extproc('waittime');
  pmi_time        const  like(mi_time_t);
  option          int(5) value;
end-pr;

// Use mitime function to form an AS/400 system value for time
dcl-pr mitime pointer extproc('mitime');
  mi_time         const  like(mi_time_t);
  hour            int(10) value;
  min             int(10) value;
  sec             int(10) value;
  hsec            int(10) value;
end-pr;

// The standard definition for time in the MI library (QSYSINC/MIH.MICOMMON):
dcl-s mi_time_t char(8) inz;


//
// Prototype for RslvSP MI instruction.
//
// Resolve System Pointer.
//

dcl-pr rslvsp pointer(*proc) extproc('rslvsp');
  // Object type (in hexadecimal format -- see QLICVTTP API).
  hexType         char(2) value;
  // Object name.
  object          pointer value options(*string);
  // Library name.
  lib             pointer value options(*string);
  // Authority.
  auth            char(2) value;
end-pr;


/endif

