**FREE
/if not defined (LIBC)
/define LIBC
// ==========================================================================
//  iRPGUnit - Logging Facilities for CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

/include qinclude,ERRORCODE

//-------------------------------------------------------------------------
// Prototypes for C-Functions
//-------------------------------------------------------------------------
//
// string functions
//
dcl-pr strtok pointer extproc('strtok');
  i_string        pointer value  options(*string);
  i_token         pointer value  options(*string);
end-pr;
//
dcl-pr strlen uns(10) extproc('strlen');
  string          pointer value;
end-pr;
//
dcl-pr strcmp int(10) extproc('strcmp');
  string1         pointer value;
  string2         pointer value;
end-pr;
//
dcl-pr strncmp int(10) extproc('strncmp');
  string1         pointer value;
  string2         pointer value;
  count           int(10) value;
end-pr;
//
dcl-pr strcmpi int(10) extproc('strcmpi');
  string1         pointer value;
  string2         pointer value;
end-pr;
//
dcl-pr strcasecmp int(10) extproc('strcasecmp');
  string1         pointer value;
  string2         pointer value;
end-pr;
//
dcl-pr strncasecmp int(10) extproc('strncasecmp');
  string1         pointer value;
  string2         pointer value;
  count           int(10) value;
end-pr;
//
dcl-pr strstr pointer extproc('strstr');
  string1         pointer value;
  string2         pointer value;
end-pr;
//
dcl-pr strcspn uns(10) extproc('strcspn');
  source          pointer value;
  searchchars     pointer value;
end-pr;
//
dcl-pr strspn uns(10) extproc('strspn');
  source          pointer value;
  searchchars     pointer value;
end-pr;
//
dcl-ds requestcontrolblocklower qualified;
  type            int(10) inz(0);
  ccsid           int(10) inz(0);
  case            int(10) inz(0);
  res1            char(10) inz(*allx'00');
end-ds;
//
dcl-ds requestcontrolblockupper qualified;
  type            int(10) inz(1);
  ccsid           int(10) inz(0);
  case            int(10) inz(0);
  res1            char(10) inz(*allx'00');
end-ds;
//
dcl-pr caseconvert extproc('QlgConvertCase');
  reqContBlock    likeds(requestcontrolblockupper) const;
  input           char(1024) options(*varsize) const;
  output          char(1024) options(*varsize);
  len             int(10) const;
  errorCode       likeds(errorCode_t) options(*varsize);
end-pr;

//
// memory functions
//
dcl-pr memcpy pointer extproc('memcpy');
  dest            pointer value;
  source          pointer value;
  count           uns(10) value;
end-pr;
//
dcl-pr memset pointer extproc('memset');
  i_pDest         pointer value;
  i_char          int(10) value;
  i_count         uns(10) value;
end-pr;
//
dcl-pr memmove pointer extproc('memmove');
  pMemDest        pointer value;
  pMemSrc         pointer value;
  memSize         uns(10) value;
end-pr;
//
dcl-pr memcmp int(10) extproc('memcmp');
  pBuf1           pointer value;
  pBuf2           pointer value;
  count           uns(10) value;
end-pr;
//
dcl-pr memicmp int(10) extproc('__memicmp');
  pBuf1           pointer value;
  pBuf2           pointer value;
  count           uns(10) value;
end-pr;
//
dcl-pr memchr pointer extproc('memchr');
  buffer          pointer value;
  char            int(10) value;
  count           uns(10) value;
end-pr;

//
// math functions
//
dcl-pr ceiling float(8) extproc('ceil');
  value           float(8) value;
end-pr;
//
dcl-pr floor float(8) extproc('floor');
  value           float(8) value;
end-pr;

//
// filesystem functions
//
dcl-pr tmpnam pointer extproc('tmpnam');
  buffer          char(39) options(*omit);
end-pr;
//
dcl-pr tmpnamifs pointer extproc('_C_IFS_tmpnam');
  buffer          char(39) options(*omit);
end-pr;

//
// other functions
//
dcl-pr getenv pointer extproc('getenv');
  name            pointer value options(*string : *trim);
end-pr;
//
dcl-pr system int(10) extproc('system');
  command         pointer value options(*string);
end-pr;
//
dcl-pr srand extproc('srand');
  i_seed          uns(10) value;
end-pr;
//
dcl-pr rand int(10) extproc('rand');
end-pr;
//
dcl-pr qsort pointer extproc('qsort');
  memPtr          pointer value;
  numElem         uns(10) value;
  width           uns(10) value;
  pSortFunc       pointer(*proc) value;
end-pr;
//
dcl-pr bsearch pointer extproc('bsearch');
  keyPtr          pointer value;
  memPtr          pointer value;
  numElem         uns(10) value;
  width           uns(10) value;
  pSearchFnc      pointer(*proc) value;
end-pr;
//
dcl-pr time int(10) extproc('time');
  returnValue     pointer;
end-pr;

/if not defined(IFS_H)
//
// error handling
//
dcl-pr errno pointer extproc('__errno');
end-pr;
//
dcl-pr strerr pointer extproc('strerror');
  errNum          int(10) value;
end-pr;
// for backwards compatibility
dcl-pr strerror pointer extproc('strerror');
  errNum          int(10) value;
end-pr;
/endif

/endif

/if not defined(FCNTL_PROTOTYPE)
//
// fcntl() commands
//
dcl-c F_DUPFD    0;
dcl-c F_GETFL    6;
dcl-c F_SETFL    7;
dcl-c F_GETOWN   8;
dcl-c F_SETOWN   9;
//
// fcntl() flags
//
dcl-c O_NONBLOCK 128;
dcl-c O_NDELAY   128;
dcl-c FNDELAY    128;
dcl-c FASYNC     512;

//--------------------------------------------------------------------
//   fcntl()--Change Descriptor Attributes
//
//   int fcntl(int descriptor, int command, ...)
//
//   The third parameter (when used with sockets) is also an
//   integer passed by value.. it specifies an argument for
//   some of the commands.
//
//   commands supported in sockets are:
//          F_GETFL -- Return the status flags for the descriptor
//          F_SETFL -- Set status flags for the descriptor
//                    (Arg =)status flags (ORed) to set.
// (the commands below arent terribly useful in RPG)
//          F_DUPFD -- Duplicate the descriptor
//                    (Arg =)minimum value that new descriptor can be
//          F_GETOWN -- Return the process ID or group ID that's
//                     set to receive SIGIO & SIGURG
//          F_SETOWN -- Set the process ID or group ID that's
//                     to receive SIGIO & SIGURG
//                    (Arg =)process ID (or neg value for group ID)
//
//  returns -1 upon error.
//          successful values are command-specific.
//--------------------------------------------------------------------
dcl-pr fcntl int(10) extproc('fcntl');
  socketDesc      int(10) value;
  command         int(10) value;
  arg             int(10) value options(*nopass);
end-pr;

/define FCNTL_PROTOTYPE
/endif

