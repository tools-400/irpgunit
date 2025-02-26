**FREE
/IF NOT DEFINED(TIME)
/DEFINE TIME

// time -- Determine Current Time
//    The time() function returns the current calendar time.
//    The return value is also stored in the location that
//    is given by timeptr.
dcl-pr time int(10) extproc('time');
  timeptr         pointer value;
end-pr;

/ENDIF
