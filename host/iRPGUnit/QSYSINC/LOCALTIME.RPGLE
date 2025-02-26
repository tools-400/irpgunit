**FREE
/IF NOT DEFINED(LOCALTIME)
/DEFINE LOCALTIME

// localtime() -- Correct Local Time, returns tm_t*
//    The localtime() function converts a time value, in
//    seconds, to a structure of type tm.
dcl-pr localtime pointer extproc('localtime');
  time   int(10) const;
end-pr;

// localtime_r() -- Correct Local Time
//    It is the same as localtime() except that it passes
//    in the place to store the returned structure result.
dcl-pr localtime_r pointer extproc('localtime_r');
  time   int(10) const;
  tm     likeds(tm_t) const;
end-pr;

dcl-ds tm_t qualified  template;
  tm_sec     int(10);
  tm_min     int(10);
  tm_hour    int(10);
  tm_mDay    int(10);
  tm_mon     int(10);
  tm_year    int(10);
  tm_wDay    int(10);
  tm_yDay    int(10);
  tm_isDst   int(10);
end-ds;

/ENDIF
