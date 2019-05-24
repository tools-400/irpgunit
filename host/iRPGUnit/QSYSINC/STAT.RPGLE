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

     d stat...
     d                 pr            10i 0 extproc('stat')
     d  path                           *   value options(*string)
     d  stat                               const likeds(st_stat_t)

     d st_stat_t       ds                  qualified based(pDummy)
     d  mode                         10u 0
     d  ino                          10u 0
     d  nlink                         5u 0
     d  reserved2                     2a
     d  uid                          10u 0
     d  gid                          10u 0
     d  size                         10i 0
     d  atime                        10i 0
     d  mtime                        10i 0
     d  ctime                        10i 0
     d  dev                          10u 0
     d  blksize                      10u 0
     d  allocsize                    10u 0
     d  objtype                      11A
     d  reserved3                     1a
     d  codepage                      5u 0
     d  ccsid                         5u 0
     d  rdev                         10u 0
     d  nlink32                      10u 0
     d  rdev64                       20U 0
     d  dev64                        20U 0
     d  reserved1                    36A
     d  ino_gen_id                   10u 0

      /ENDIF
