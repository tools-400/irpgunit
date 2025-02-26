**FREE
/IF NOT DEFINED(STRFTIME)
/DEFINE STRFTIME

/include qsysinc,localtime

// strftime -- Convert to Formatted Time
//    strftime() returns the number of bytes placed into the
//    array pointed to by 'dest'.
dcl-pr strftime int(10) extproc('strftime');
  dest            pointer value;
  maxsize         int(10) value;
  format          pointer value options(*string);
  timeptr         const  likeds(tm_t);
end-pr;

/ENDIF
