**FREE
/IF NOT DEFINED(STAT)
/DEFINE START

/include qsysinc,localtime

// stat() -- Get File Information
//    The stat() function gets status information about a specified
//    file and places it in the area of memory pointed to by the buf
//    argument.
// Return value:
//  0  stat() was successful. The information is returned in buf.
// -1  stat() was not successful. The errno global variable is set to
//            indicate the error.

dcl-pr stat int(10) extproc('stat');
  path            pointer value options(*string);
  stat            const likeds(st_stat_t);
end-pr;

dcl-ds st_stat_t qualified template;
  mode            uns(10);
  ino             uns(10);
  nlink           uns(5);
  reserved2       char(2);
  uid             uns(10);
  gid             uns(10);
  size            int(10);
  atime           int(10);
  mtime           int(10);
  ctime           int(10);
  dev             uns(10);
  blksize         uns(10);
  allocsize       uns(10);
  objType         char(11);
  reserved3       char(1);
  codepage        uns(5);
  ccsid           uns(5);
  rdev            uns(10);
  nlink32         uns(10);
  rdev64          uns(20);
  dev64           uns(20);
  reserved1       char(36);
  ino_gen_id      uns(10);
end-ds;

/ENDIF
