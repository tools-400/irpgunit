**FREE
/if not defined LIBC
/define LIBC

//-------------------------------------------------------------------------
// Prototypes for C-Functions
//-------------------------------------------------------------------------

/include qinclude,ERRORCODE

//
// string functions
//
dcl-pr strtok pointer extproc('strtok');
  i_string        pointer value  options(*string);
  i_token         pointer value  options(*string);
end-pr;

dcl-pr strlen uns(10) extproc('strlen');
  string          pointer value;
end-pr;

dcl-ds requestControlBlockLower qualified;
  type            int(10) inz(0);
  ccsid           int(10) inz(0);
  case            int(10) inz(0);
  res1            char(10) inz(*ALLX'00');
end-ds;

dcl-ds requestControlBlockUpper qualified;
  type            int(10) inz(1);
  ccsid           int(10) inz(0);
  case            int(10) inz(0);
  res1            char(10) inz(*ALLX'00');
end-ds;

dcl-pr caseConvert extproc('QlgConvertCase');
  reqContBlock    likeds(requestControlBlockUpper) const;
  input           char(1024) const options(*varsize);
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

dcl-pr memset pointer extproc('memset');
  i_pDest         pointer value;
  i_char          int(10) value;
  i_count         uns(10) value;
end-pr;

dcl-pr memmove pointer extproc('memmove');
  pMemDest        pointer value;
  pMemSrc         pointer value;
  memSize         uns(10) value;
end-pr;

dcl-pr memcmp int(10) extproc('memcmp');
  pBuf1           pointer value;
  pBuf2           pointer value;
  count           uns(10) value;
end-pr;

dcl-pr memicmp int(10) extproc('__memicmp');
  pBuf1           pointer value;
  pBuf2           pointer value;
  count           uns(10) value;
end-pr;

//
// math functions
//
dcl-pr ceiling float(8) extproc('ceil');
  value           float(8) value;
end-pr;

dcl-pr floor float(8) extproc('floor');
  value           float(8) value;
end-pr;

//
// other functions
//
dcl-pr tmpnam pointer extproc('tmpnam');
  buffer          char(39) options(*omit);
end-pr;

dcl-pr tmpnamIFS pointer extproc('_C_IFS_tmpnam');
  buffer          char(39) options(*omit);
end-pr;

dcl-pr system int(10) extproc('system');
  command         pointer value options(*string);
end-pr;

dcl-pr srand extproc('srand');
  i_seed          uns(10) value;
end-pr;

dcl-pr rand int(10) extproc('rand');
end-pr;

dcl-pr qsort pointer extproc('qsort');
  memPtr          pointer value;
  numElem         uns(10) value;
  width           uns(10) value;
  pSortFunc       pointer(*proc) value;
end-pr;

dcl-pr bsearch pointer extproc('bsearch');
  keyPtr          pointer value;
  memPtr          pointer value;
  numElem         uns(10) value;
  width           uns(10) value;
  pSearchFnc      pointer(*proc) value;
end-pr;

/endif

