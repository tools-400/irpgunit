**FREE
/if defined(IFSIO_H)
/eof
/endif

/define IFSIO_H
//*********************************************************************
//  IFS File IO Prototypes.
//*********************************************************************
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
//*********************************************************************

//*********************************************************************
// Some CCSID definitions that I've found useful
//*********************************************************************
dcl-c CP_MSDOS     437;
dcl-c CP_ISO8859_1 819;
dcl-c CP_WINDOWS   1252;
dcl-c CP_UTF8      1208;
dcl-c CP_UCS2      1200;
dcl-c CP_CURJOB    0;

//*********************************************************************
//  Flags for use in open()
//
// More than one can be used -- add them together.
//*********************************************************************
//  00000000000000000000000000000001          Reading Only
dcl-c O_RDONLY       1;
//  00000000000000000000000000000010          Writing Only
dcl-c O_WRONLY       2;
//  00000000000000000000000000000100          Reading & Writing
dcl-c O_RDWR         4;
//  00000000000000000000000000001000          Create File if needed
dcl-c O_CREAT        8;
//  00000000000000000000000000010000          Exclusively create --
dcl-c O_EXCL         16;
//  00000000000000000000000000100000          Assign a CCSID to new
dcl-c O_CCSID        32;
//  00000000000000000000000001000000          Truncate file to 0 bytes
dcl-c O_TRUNC        64;
//  00000000000000000000000100000000          Append to file
dcl-c O_APPEND       256;
//  00000000000000000000010000000000          Synchronous write
dcl-c O_SYNC         1024;
//  00000000000000000000100000000000          Sync write, data only
dcl-c O_DSYNC        2048;
//  00000000000000000001000000000000          Sync read
dcl-c O_RSYNC        4096;
//  00000000000000001000000000000000          No controlling terminal
dcl-c O_NOCTTY       32768;
//  00000000000000010000000000000000          Share with readers only
dcl-c O_SHARE_RDONLY 65536;
//  00000000000000100000000000000000          Share with writers only
dcl-c O_SHARE_WRONLY 131072;
//  00000000000001000000000000000000          Share with read & write
dcl-c O_SHARE_RDWR   262144;
//  00000000000010000000000000000000          Share with nobody.
dcl-c O_SHARE_NONE   524288;
//  00000000100000000000000000000000          Assign a code page
dcl-c O_CODEPAGE     8388608;
//  00000001000000000000000000000000          Open in text-mode
dcl-c O_TEXTDATA     16777216;
/if defined(*V5R2M0)
//  00000010000000000000000000000000          Allow text translation
//                                            on newly created file.
// Note: O_TEXT_CREAT requires all of the following flags to work:
//           O_CREAT+O_TEXTDATA+(O_CODEPAGE or O_CCSID)
dcl-c O_TEXT_CREAT   33554432;
/endif
//  00001000000000000000000000000000          Inherit mode from dir
dcl-c O_INHERITMODE  134217728;
//  00100000000000000000000000000000          Large file access
//                                            (for >2GB files)
dcl-c O_LARGEFILE    536870912;

//*********************************************************************
// Access mode flags for access() and accessx()
//
//   F_OK = File Exists
//   R_OK = Read Access
//   W_OK = Write Access
//   X_OK = Execute or Search
//*********************************************************************
dcl-c F_OK 0;
dcl-c R_OK 4;
dcl-c W_OK 2;
dcl-c X_OK 1;

//*********************************************************************
// class of users flags for accessx()
//
//   ACC_SELF = Check access based on effective uid/gid
//   ACC_INVOKER = Check access based on real uid/gid
//                 ( this is equvalent to calling access() )
//   ACC_OTHERS = Check access of someone not the owner
//   ACC_ALL = Check access of all users
//*********************************************************************
dcl-c ACC_SELF    0;
dcl-c ACC_INVOKER 1;
dcl-c ACC_OTHERS  8;
dcl-c ACC_ALL     32;

//*********************************************************************
//      Mode Flags.
//         basically, the mode parm of open(), creat(), chmod(),etc
//         uses 9 least significant bits to determine the
//         file's mode. (peoples access rights to the file)
//
//           user:       owner    group    other
//           access:     R W X    R W X    R W X
//           bit:        8 7 6    5 4 3    2 1 0
//
// (This is accomplished by adding the flags below to get the mode)
//*********************************************************************
//                                         owner authority
dcl-c S_IRUSR  256;
dcl-c S_IWUSR  128;
dcl-c S_IXUSR  64;
dcl-c S_IRWXU  448;
//                                         group authority
dcl-c S_IRGRP  32;
dcl-c S_IWGRP  16;
dcl-c S_IXGRP  8;
dcl-c S_IRWXG  56;
//                                         other people
dcl-c S_IROTH  4;
dcl-c S_IWOTH  2;
dcl-c S_IXOTH  1;
dcl-c S_IRWXO  7;
//                                         special modes:
//                                         Set effective GID
dcl-c S_ISGID  1024;
//                                         Set effective UID
dcl-c S_ISUID  2048;

//*********************************************************************
// My own special MODE shortcuts for open() (instead of those above)
//*********************************************************************
dcl-c M_RDONLY 292;
dcl-c M_RDWR   438;
dcl-c M_RWX    511;

//*********************************************************************
// "whence" constants for use with seek(), lseek() and others
//*********************************************************************
dcl-c SEEK_SET 0;
dcl-c SEEK_CUR 1;
dcl-c SEEK_END 2;

//*********************************************************************
// flags specified in the f_flags element of the ds_statvfs
//   data structure used by the statvfs() API
//*********************************************************************
dcl-c ST_RDONLY           1;
dcl-c ST_NOSUID           2;
dcl-c ST_CASE_SENSITITIVE 4;
dcl-c ST_CHOWN_RESTRICTED 8;
dcl-c ST_THREAD_SAFE      16;
dcl-c ST_DYNAMIC_MOUNT    32;
dcl-c ST_NO_MOUNT_OVER    64;
dcl-c ST_NO_EXPORTS       128;
dcl-c ST_SYNCHRONOUS      256;

//*********************************************************************
// Constants used by pathconf() API
//*********************************************************************
dcl-c PC_CHOWN_RESTRICTED 0;
dcl-c PC_LINK_MAX         1;
dcl-c PC_MAX_CANON        2;
dcl-c PC_MAX_INPUT        3;
dcl-c PC_NAME_MAX         4;
dcl-c PC_NO_TRUNC         5;
dcl-c PC_PATH_MAX         6;
dcl-c PC_PIPE_BUF         7;
dcl-c PC_VDISABLE         8;
dcl-c PC_THREAD_SAFE      9;

//*********************************************************************
// Constants used by sysconf() API
//*********************************************************************
dcl-c SC_CLK_TCK          2;
dcl-c SC_NGROUPS_MAX      3;
dcl-c SC_OPEN_MAX         4;
dcl-c SC_STREAM_MAX       5;
dcl-c SC_CCSID            10;
dcl-c SC_PAGE_SIZE        11;
dcl-c SC_PAGESIZE         12;

//*********************************************************************
// File Information Structure (stat)
//   struct stat {
//     mode_t         st_mode;       /* File mode                       */
//     ino_t          st_ino;        /* File serial number              */
//     nlink_t        st_nlink;      /* Number of links                 */
//     unsigned short st_reserved2;  /* Reserved                    @B4A*/
//     uid_t          st_uid;        /* User ID of the owner of file    */
//     gid_t          st_gid;        /* Group ID of the group of file   */
//     off_t          st_size;       /* For regular files, the file
//                                      size in bytes                   */
//     time_t         st_atime;      /* Time of last access             */
//     time_t         st_mtime;      /* Time of last data modification  */
//     time_t         st_ctime;      /* Time of last file status change */
//     dev_t          st_dev;        /* ID of device containing file    */
//     size_t         st_blksize;    /* Size of a block of the file     */
//     unsigned long  st_allocsize;  /* Allocation size of the file     */
//     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
//     char           st_reserved3;  /* Reserved                    @B4A*/
//     unsigned short st_codepage;   /* Object data codepage            */
//     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
//     dev_t          st_rdev;       /* Device ID (if character special */
//                                   /* or block special file)      @B4A*/
//     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5C*/
//     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
//     dev64_t        st_dev64;      /* ID of device containing file -  */
//                                   /* 64 bit form.                @B4A*/
//     char           st_reserved1[36]; /* Reserved                 @B4A*/
//     unsigned int   st_ino_gen_id; /* File serial number generation id
//  };
//                                                                  @A2A*/
//*********************************************************************
dcl-ds statds qualified template;
  st_mode         uns(10);
  st_ino          uns(10);
  st_nlink        uns(5);
  st_reserved2    uns(5);
  st_uid          uns(10);
  st_gid          uns(10);
  st_size         int(10);
  st_atime        int(10);
  st_mtime        int(10);
  st_ctime        int(10);
  st_dev          uns(10);
  st_blksize      uns(10);
  st_allocsize    uns(10);
  st_objtype      char(11);
  st_reserved3    char(1);
  st_codepage     uns(5);
  st_ccsid        uns(5);
  st_rdev         uns(10);
  st_nlink32      uns(10);
  st_rdev64       uns(20);
  st_dev64        uns(20);
  st_reserved1    char(36);
  st_ino_gen_id   uns(10);
end-ds;


//*********************************************************************
// File Information Structure, Large File Enabled (stat64)
//   struct stat64 {                                                    */
//     mode_t         st_mode;       /* File mode                       */
//     ino_t          st_ino;        /* File serial number              */
//     uid_t          st_uid;        /* User ID of the owner of file    */
//     gid_t          st_gid;        /* Group ID of the group of fileA2A*/
//     off64_t        st_size;       /* For regular files, the file     */
//                                      size in bytes                   */
//     time_t         st_atime;      /* Time of last access             */
//     time_t         st_mtime;      /* Time of last data modification2A*/
//     time_t         st_ctime;      /* Time of last file status changeA*/
//     dev_t          st_dev;        /* ID of device containing file    */
//     size_t         st_blksize;    /* Size of a block of the file     */
//     nlink_t        st_nlink;      /* Number of links                 */
//     unsigned short st_codepage;   /* Object data codepage            */
//     unsigned long long st_allocsize; /* Allocation size of the file2A*/
//     unsigned int   st_ino_gen_id; /* File serial number generationAid*/
//                                                                      */
//     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
//     char           st_reserved2[5]; /* Reserved                  @B4A*/
//     dev_t          st_rdev;       /* Device ID (if character specialA*/
//                                   /* or block special file)      @B4A*/
//     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
//     dev64_t        st_dev64;      /* ID of device containing file@-2A*/
//                                   /* 64 bit form.                @B4A*/
//     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5A*/
//     char           st_reserved1[26]; /* Reserved            @B4A @B5C*/
//     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
//  };                                                                  */
//
//*********************************************************************
dcl-ds statds64 qualified template;
  st_mode         uns(10);
  st_ino          uns(10);
  st_uid          uns(10);
  st_gid          uns(10);
  st_size         int(20);
  st_atime        int(10);
  st_mtime        int(10);
  st_ctime        int(10);
  st_dev          uns(10);
  st_blksize      uns(10);
  st_nlink        uns(5);
  st_codepage     uns(5);
  st_allocsize    uns(20);
  st_ino_gen_id   uns(10);
  st_objtype      char(11);
  st_reserved2    char(5);
  st_rdev         uns(10);
  st_rdev64       uns(20);
  st_dev64        uns(20);
  st_nlink32      uns(10);
  st_reserved1    char(26);
  st_ccsid        uns(5);
end-ds;

//*********************************************************************
// ds_statvfs - data structure to receive file system info
//
//   f_bsize   = file system block size (in bytes)
//   f_frsize  = fundamental block size in bytes.
//                if this is zero, f_blocks, f_bfree and f_bavail
//                are undefined.
//   f_blocks  = total number of blocks (in f_frsize)
//   f_bfree   = total free blocks in filesystem (in f_frsize)
//   f_bavail  = total blocks available to users (in f_frsize)
//   f_files   = total number of file serial numbers
//   f_ffree   = total number of unused file serial numbers
//   f_favail  = number of available file serial numbers to users
//   f_fsid    = filesystem ID.  This will be 4294967295 if it's
//                too large for a 10U 0 field. (see f_fsid64)
//   f_flag    = file system flags (see below)
//   f_namemax = max filename length.  May be 4294967295 to
//                indicate that there is no maximum.
//   f_pathmax = max pathname legnth.  May be 4294967295 to
//                indicate that there is no maximum.
//   f_objlinkmax = maximum number of hard-links for objects
//                other than directories
//   f_dirlinkmax = maximum number of hard-links for directories
//   f_fsid64  = filesystem id (in a 64-bit integer)
//   f_basetype = null-terminated string containing the file
//                  system type name.  For example, this might
//                  be "root" or "Network File System (NFS)"
//
//  Since f_basetype is null-terminated, you should read it
//  in ILE RPG with:
//       myString = %str(%addr(ds_statvfs.f_basetype))
//*********************************************************************
dcl-ds ds_statvfs qualified template;
  f_bsize         uns(10);
  f_frsize        uns(10);
  f_blocks        uns(20);
  f_bfree         uns(20);
  f_bavail        uns(20);
  f_files         uns(10);
  f_ffree         uns(10);
  f_favail        uns(10);
  f_fsid          uns(10);
  f_flag          uns(10);
  f_namemax       uns(10);
  f_pathmax       uns(10);
  f_objlinkmax    int(10);
  f_dirlinkmax    int(10);
  f_reserved1     char(4);
  f_fsid64        uns(20);
  f_basetype      char(80);
end-ds;


//*********************************************************************
// Group Information Structure (group)
//
//  struct group {
//        char    *gr_name;        /* Group name.                      */
//        gid_t   gr_gid;          /* Group id.                        */
//        char    **gr_mem;        /* A null-terminated list of pointers
//                                    to the individual member names.  */
//  };
//
//*********************************************************************
dcl-ds group qualified template;
  gr_name         pointer;
  gr_gid          uns(10);
  gr_mem          pointer dim(256);
end-ds;


//*********************************************************************
// User Information Structure (passwd)
//
// (Don't let the name fool you, this structure does not contain
//  any password information.  Its named after the UNIX file that
//  contains all of the user info.  That file is "passwd")
//
//   struct passwd {
//        char    *pw_name;            /* User name.                   */
//        uid_t   pw_uid;              /* User ID number.              */
//        gid_t   pw_gid;              /* Group ID number.             */
//        char    *pw_dir;             /* Initial working directory.   */
//        char    *pw_shell;           /* Initial user program.        */
//   };
//
//*********************************************************************
dcl-ds passwd qualified template;
  pw_name         pointer;
  pw_uid          uns(10);
  pw_gid          uns(10);
  pw_dir          pointer;
  pw_shell        pointer;
end-ds;


//*********************************************************************
// File Time Structure (utimbuf)
//
// struct utimbuf {
//    time_t     actime;           /*  access time       */
//    time_t     modtime;          /*  modification time */
// };
//
//*********************************************************************
dcl-ds utimbuf qualified template;
actime          int(10);
modtime         int(10);
end-ds;


//*********************************************************************
// Directory Entry Structure (dirent)
//
// struct dirent {
//   char           d_reserved1[16];  /* Reserved                       */
//   unsigned int   d_fileno_gen_id   /* File number generation ID  @A1C*/
//   ino_t          d_fileno;         /* The file number of the file    */
//   unsigned int   d_reclen;         /* Length of this directory entry
//                                     * in bytes                       */
//   int            d_reserved3;      /* Reserved                       */
//   char           d_reserved4[8];   /* Reserved                       */
//   qlg_nls_t      d_nlsinfo;        /* National Language Information
//                                     * about d_name                   */
//   unsigned int   d_namelen;        /* Length of the name, in bytes
//                                     * excluding NULL terminator      */
//   char           d_name[_QP0L_DIR_NAME]; /* Name...null terminated   */
//
// };
//*********************************************************************
dcl-ds dirent qualified template;
  d_reserv1       char(16);
  d_fileno_gen_id uns(10);
  d_fileno        uns(10);
  d_reclen        uns(10);
  d_reserv3       int(10);
  d_reserv4       char(8);
  d_nlsinfo       char(12);
  d_nls_ccsid     int(10) overlay(d_nlsinfo:1);
  d_nls_cntry     char(2) overlay(d_nlsinfo:5);
  d_nls_lang      char(3) overlay(d_nlsinfo:7);
  d_namelen       uns(10);
  d_name          char(640);
end-ds;

//*********************************************************************
// I/O Vector Structure
//
//     struct iovec {
//        void    *iov_base;
//        size_t  iov_len;
//     }
//*********************************************************************
dcl-ds iovec qualified template;
iov_base        pointer;
iov_len         uns(10);
end-ds;

//--------------------------------------------------------------------
// Determine file accessibility
//
// int access(const char *path, int amode)
//
//--------------------------------------------------------------------
dcl-pr access int(10) extproc('access');
  path            pointer value options(*string);
  amode           int(10) value;
end-pr;


//--------------------------------------------------------------------
// Determine file accessibility for a class of users
//
// int accessx(const char *path, int amode, int who);
//
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr accessx int(10) extproc('accessx');
path            pointer value options(*string);
amode           int(10) value;
who             int(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Change Directory
//
// int chdir(const char *path)
//--------------------------------------------------------------------
dcl-pr chdir int(10) extproc('chdir');
  path            pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Change file authorizations
//
// int chmod(const char *path, mode_t mode)
//--------------------------------------------------------------------
dcl-pr chmod int(10) extproc('chmod');
path            pointer value options(*string);
mode            uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Change Owner/Group of File
//
// int chown(const char *path, uid_t owner, gid_t group)
//--------------------------------------------------------------------
dcl-pr chown int(10) extproc('chown');
  path            pointer value options(*string);
  owner           uns(10) value;
  group           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Close a file
//
// int close(int fildes)
//
// Note:  Because the same close() API is used for IFS, sockets,
//        and pipes, it's conditionally defined here.  If it's
//        done the same in the sockets & pipe /copy members,
//        there will be no conflict.
//--------------------------------------------------------------------
/if not defined(CLOSE_PROTOTYPE)
dcl-pr close int(10) extproc('close');
fildes          int(10) value;
end-pr;
/define CLOSE_PROTOTYPE
/endif

//--------------------------------------------------------------------
// Close a directory
//
// int closedir(DIR *dirp)
//--------------------------------------------------------------------
dcl-pr closedir int(10) extproc('closedir');
dirp            pointer value;
end-pr;

//--------------------------------------------------------------------
// Create or Rewrite File
//
// int creat(const char *path, mode_t mode)
//
// DEPRECATED:  Use open() instead.
//--------------------------------------------------------------------
dcl-pr creat int(10) extproc('creat');
  path            pointer value options(*string);
  mode            uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Duplicate open file descriptor
//
// int dup(int fildes)
//--------------------------------------------------------------------
dcl-pr dup int(10) extproc('dup');
fildes          int(10) value;
end-pr;

//--------------------------------------------------------------------
// Duplicate open file descriptor to another descriptor
//
// int dup2(int fildes, int fildes2)
//--------------------------------------------------------------------
dcl-pr dup2 int(10) extproc('dup2');
fildes          int(10) value;
fildes2         int(10) value;
end-pr;

//--------------------------------------------------------------------
// Determine file accessibility for a class of users by descriptor
//
// int faccessx(int filedes, int amode, int who)
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr faccessx int(10) extproc('faccessx');
fildes          int(10) value;
amode           int(10) value;
who             int(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Change Current Directory by Descriptor
//
// int fchdir(int fildes)
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr fchdir int(10) extproc('fchdir');
  fildes          int(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Change file authorizations by descriptor
//
// int fchmod(int fildes, mode_t mode)
//--------------------------------------------------------------------
dcl-pr fchmod int(10) extproc('fchmod');
fildes          int(10) value;
mode            uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Change Owner and Group of File by Descriptor
//
// int fchown(int fildes, uid_t owner, gid_t group)
//--------------------------------------------------------------------
dcl-pr fchown int(10) extproc('fchown');
  fildes          int(10) value;
  owner           uns(10) value;
  group           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Perform File Control
//
// int fcntl(int fildes, int cmd, . . .)
//
// Note:  Because the same fcntl() API is used for IFS and sockets,
//        it's conditionally defined here.  If it's defined with
//        the same conditions in the sockets /copy member, there
//        will be no conflict.
//--------------------------------------------------------------------
/if not defined(FCNTL_PROTOTYPE)
dcl-pr fcntl int(10) extproc('fcntl');
fildes          int(10) value;
cmd             int(10) value;
arg             int(10) value options(*nopass);
end-pr;
/define FCNTL_PROTOTYPE
/endif

//--------------------------------------------------------------------
// Get configurable path name variables by descriptor
//
// long fpathconf(int fildes, int name)
//--------------------------------------------------------------------
dcl-pr fpathconf int(10) extproc('fpathconf');
fildes          int(10) value;
name            int(10) value;
end-pr;

//--------------------------------------------------------------------
// Get File Information by Descriptor
//
// int fstat(int fildes, struct stat *buf)
//--------------------------------------------------------------------
dcl-pr fstat int(10) extproc('fstat');
  fildes          int(10) value;
  buf             likeds(statds);
end-pr;

//--------------------------------------------------------------------
// Get File Information by Descriptor, Large File Enabled
//
// int fstat64(int fildes, struct stat *buf)
//--------------------------------------------------------------------
dcl-pr fstat64 int(10) extproc('fstat64');
fildes          int(10) value;
buf             likeds(statds64);
end-pr;

//--------------------------------------------------------------------
// fstatvfs() -- Get file system status by descriptor
//
//  fildes = (input) file descriptor to use to locate file system
//     buf = (output) data structure containing file system info
//
// Returns 0 if successful, -1 upon error.
// (error information is returned via the "errno" variable)
//--------------------------------------------------------------------
dcl-pr fstatvfs int(10) extproc('fstatvfs64');
  fildes          int(10) value;
  buf             like(ds_statvfs);
end-pr;

//--------------------------------------------------------------------
// Synchronize Changes to file
//
// int fsync(int fildes)
//--------------------------------------------------------------------
dcl-pr fsync int(10) extproc('fsync');
fildes          int(10) value;
end-pr;

//--------------------------------------------------------------------
// Truncate file
//
// int ftruncate(int fildes, off_t length)
//--------------------------------------------------------------------
dcl-pr ftruncate int(10) extproc('ftruncate');
fildes          int(10) value;
length          int(10) value;
end-pr;

//--------------------------------------------------------------------
// Truncate file, large file enabled
//
// int ftruncate64(int fildes, off64_t length)
//--------------------------------------------------------------------
dcl-pr ftruncate64 int(10) extproc('ftruncate64');
  fildes          int(10) value;
  length          int(20) value;
end-pr;

//--------------------------------------------------------------------
// Get current working directory
//
// char *getcwd(char *buf, size_t size)
//--------------------------------------------------------------------
dcl-pr getcwd pointer extproc('getcwd');
buf             pointer value;
size            uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Get effective group ID
//
// gid_t getegid(void)
//--------------------------------------------------------------------
dcl-pr getegid uns(10) extproc('getegid');
end-pr;

//--------------------------------------------------------------------
// Get effective user ID
//
// uid_t geteuid(void)
//--------------------------------------------------------------------
dcl-pr geteuid uns(10) extproc('geteuid');
end-pr;

//--------------------------------------------------------------------
// Get Real Group ID
//
// gid_t getgid(void)
//--------------------------------------------------------------------
dcl-pr getgid uns(10) extproc('getgid');
end-pr;

//--------------------------------------------------------------------
// Get group information from group ID
//
// struct group *getgrgid(gid_t gid)
//--------------------------------------------------------------------
dcl-pr getgrgid pointer extproc('getgrgid');
gid             uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Get group info using group name
//
// struct group  *getgrnam(const char *name)
//--------------------------------------------------------------------
dcl-pr getgrnam pointer extproc('getgrnam');
  name            pointer value;
end-pr;

//--------------------------------------------------------------------
// Get group IDs
//
// int getgroups(int gidsetsize, gid_t grouplist[])
//--------------------------------------------------------------------
dcl-pr getgroups pointer extproc('getgroups');
gidsetsize      int(10) value;
grouplist       uns(10) dim(256) options(*varsize);
end-pr;

//--------------------------------------------------------------------
// Get user information by user-name
//
// (Don't let the name mislead you, this does not return the password,
//  the user info database on unix systems is called "passwd",
//  therefore, getting the user info is called "getpw")
//
// struct passwd *getpwnam(const char *name)
//--------------------------------------------------------------------
dcl-pr getpwnam pointer extproc('getpwnam');
  name            pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Get user information by user-id number
//
// (Don't let the name mislead you, this does not return the password,
//  the user info database on unix systems is called "passwd",
//  therefore, getting the user info is called "getpw")
//
// struct passwd *getpwuid(uid_t uid)
//--------------------------------------------------------------------
dcl-pr getpwuid pointer extproc('getpwuid');
uid             uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Get Real User-ID
//
// uid_t getuid(void)
//--------------------------------------------------------------------
dcl-pr getuid uns(10) extproc('getuid');
end-pr;

//--------------------------------------------------------------------
// Perform I/O Control Request
//
// int ioctl(int fildes, unsigned long req, ...)
//--------------------------------------------------------------------
dcl-pr ioctl int(10) extproc('ioctl');
  fildes          int(10) value;
  req             uns(10) value;
  arg             pointer value;
end-pr;

//--------------------------------------------------------------------
// Change Owner/Group of symbolic link
//
// int lchown(const char *path, uid_t owner, gid_t group)
//
// NOTE: for non-symlinks, this behaves identically to chown().
//       for symlinks, this changes ownership of the link, whereas
//       chown() changes ownership of the file the link points to.
//--------------------------------------------------------------------
dcl-pr lchown int(10) extproc('lchown');
path            pointer value options(*string);
owner           uns(10) value;
group           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Create Hard Link to File
//
// int link(const char *existing, const char *new)
//--------------------------------------------------------------------
dcl-pr link int(10) extproc('link');
  existing        pointer value options(*string);
  new             pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Set File Read/Write Offset
//
// off_t lseek(int fildes, off_t offset, int whence)
//--------------------------------------------------------------------
dcl-pr lseek int(10) extproc('lseek');
fildes          int(10) value;
offset          int(10) value;
whence          int(10) value;
end-pr;

//--------------------------------------------------------------------
// Set File Read/Write Offset, Large File Enabled
//
// off64_t lseek64(int fildes, off64_t offset, int whence)
//--------------------------------------------------------------------
dcl-pr lseek64 int(20) extproc('lseek64');
fildes          int(10) value;
offset          int(20) value;
whence          int(10) value;
end-pr;

//--------------------------------------------------------------------
// Get File or Link Information
//
// int lstat(const char *path, struct stat *buf)
//
// NOTE: for non-symlinks, this behaves identically to stat().
//       for symlinks, this gets information about the link, whereas
//       stat() gets information about the file the link points to.
//--------------------------------------------------------------------
dcl-pr lstat int(10) extproc('lstat');
  path            pointer value options(*string);
  buf             likeds(statds);
end-pr;

//--------------------------------------------------------------------
// Get File or Link Information, Large File Enabled
//
// int lstat64(const char *path, struct stat64 *buf)
//
// NOTE: for non-symlinks, this behaves identically to stat().
//       for symlinks, this gets information about the link, whereas
//       stat() gets information about the file the link points to.
//--------------------------------------------------------------------
dcl-pr lstat64 int(10) extproc('lstat64');
path            pointer value options(*string);
buf             likeds(statds64);
end-pr;

//--------------------------------------------------------------------
// Make Directory
//
// int mkdir(const char *path, mode_t mode)
//--------------------------------------------------------------------
dcl-pr mkdir int(10) extproc('mkdir');
path            pointer value options(*string);
mode            uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Make FIFO Special File
//
// int mkfifo(const char *path, mode_t mode)
//--------------------------------------------------------------------
/if defined(*V5R1M0)
dcl-pr mkfifo int(10) extproc('mkfifo');
path            pointer value options(*string);
mode            uns(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Open a File
//
// int open(const char *path, int oflag, . . .);
//--------------------------------------------------------------------
dcl-pr open int(10) extproc('open');
path            pointer value options(*string);
openflags       int(10) value;
mode            uns(10) value options(*nopass);
ccsid           uns(10) value options(*nopass);
/if defined(*V5R2M0)
txtcreatid      uns(10) value options(*nopass);
/endif
end-pr;

//--------------------------------------------------------------------
// Open a File, Large File Enabled
//
// int open64(const char *path, int oflag, . . .);
//
// NOTE: This is identical to calling open(), except that the
//       O_LARGEFILE flag is automatically supplied.
//--------------------------------------------------------------------
dcl-pr open64 int(10) extproc('open64');
filename        pointer value options(*string);
openflags       int(10) value;
mode            uns(10) value options(*nopass);
codepage        uns(10) value options(*nopass);
/if defined(*V5R2M0)
txtcreatid      uns(10) value options(*nopass);
/endif
end-pr;

//--------------------------------------------------------------------
// Open a Directory
//
// DIR *opendir(const char *dirname)
//--------------------------------------------------------------------
dcl-pr opendir pointer extproc('opendir');
dirname         pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Get configurable path name variables
//
// long pathconf(const char *path, int name)
//--------------------------------------------------------------------
dcl-pr pathconf int(10) extproc('pathconf');
path            pointer value options(*string);
name            int(10) value;
end-pr;

//--------------------------------------------------------------------
// Create interprocess channel
//
// int pipe(int fildes[2]);
//--------------------------------------------------------------------
dcl-pr pipe int(10) extproc('pipe');
fildes          int(10) dim(2);
end-pr;

//--------------------------------------------------------------------
// Read from Descriptor with Offset
//
// ssize_t pread(int filedes, void *buf, size_t nbyte, off_t offset);
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr pread int(10) extproc('pread');
  fildes          int(10) value;
  buf             pointer value;
  nbyte           uns(10) value;
  offset          int(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Read from Descriptor with Offset, Large File Enabled
//
// ssize_t pread64(int filedes, void *buf, size_t nbyte,
//                 size_t nbyte, off64_t offset);
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr pread64 int(10) extproc('pread64');
fildes          int(10) value;
buf             pointer value;
nbyte           uns(10) value;
offset          int(20) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Write to Descriptor with Offset
//
// ssize_t pwrite(int filedes, const void *buf,
//                size_t nbyte, off_t offset);
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr pwrite int(10) extproc('pwrite');
fildes          int(10) value;
buf             pointer value;
nbyte           uns(10) value;
offset          int(10) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Write to Descriptor with Offset, Large File Enabled
//
// ssize_t pwrite64(int filedes, const void *buf,
//                  size_t nbyte, off64_t offset);
//--------------------------------------------------------------------
/if defined(*V5R2M0)
dcl-pr pwrite64 int(10) extproc('pwrite64');
fildes          int(10) value;
buf             pointer value;
nbyte           uns(10) value;
offset          int(20) value;
end-pr;
/endif

//--------------------------------------------------------------------
// Perform Miscellaneous file system functions
//--------------------------------------------------------------------
dcl-pr qp0fptos extpgm('QP0FPTOS');
function        char(32) const;
exten1          char(6) const options(*nopass);
exten2          char(3) const options(*nopass);
end-pr;

//--------------------------------------------------------------------
// Read From a File
//
// ssize_t read(int fildes, void *buffer, size_t bytes);
//--------------------------------------------------------------------
dcl-pr read int(10) extproc('read');
  fildes          int(10) value;
  buf             pointer value;
  bytes           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Read Directory Entry
//
// struct dirent *readdir(DIR *dirp)
//--------------------------------------------------------------------
dcl-pr readdir pointer extproc('readdir');
dirp            pointer value;
end-pr;

//--------------------------------------------------------------------
// Read Value of Symbolic Link
//
// int readlink(const char *path, char *buf, size_t bufsiz)
//--------------------------------------------------------------------
dcl-pr readlink int(10) extproc('readlink');
path            pointer value options(*string);
buf             pointer value;
bufsiz          uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Read From Descriptor using Multiple Buffers
//
// int readv(int fildes, struct iovec *io_vector[], int vector_len);
//--------------------------------------------------------------------
dcl-pr readv int(10) extproc('readv');
fildes          int(10) value;
io_vector       like(iovec) dim(256) options(*varsize);
vector_len      int(10) value;
end-pr;

//--------------------------------------------------------------------
// Rename File or Directory
//
// int rename(const char *old, const char *new)
//
//  Note: By defailt, if a file with the new name already exists,
//        rename will fail with an error.  If you define
//        RENAMEUNLINK and a file with the new name already exists
//        it will be unlinked prior to renaming.
//--------------------------------------------------------------------
/if defined(RENAMEUNLINK)
dcl-pr rename int(10) extproc('Qp0lRenameUnlink');
  old             pointer value options(*string);
  new             pointer value options(*string);
end-pr;
/else
dcl-pr rename int(10) extproc('Qp0lRenameKeep');
old             pointer value options(*string);
new             pointer value options(*string);
end-pr;
/endif

//--------------------------------------------------------------------
// Reset Directory Stream to Beginning
//
// void rewinddir(DIR *dirp)
//--------------------------------------------------------------------
dcl-pr rewinddir extproc('rewinddir');
  dirp            pointer value;
end-pr;


//--------------------------------------------------------------------
// Remove Directory
//
// int rmdir(const char *path)
//--------------------------------------------------------------------
dcl-pr rmdir int(10) extproc('rmdir');
path            pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Get File Information
//
// int stat(const char *path, struct stat *buf)
//--------------------------------------------------------------------
dcl-pr stat int(10) extproc('stat');
path            pointer value options(*string);
buf             likeds(statds);
end-pr;


//--------------------------------------------------------------------
// Get File Information, Large File Enabled
//
// int stat(const char *path, struct stat64 *buf)
//--------------------------------------------------------------------
dcl-pr stat64 int(10) extproc('stat64');
path            pointer value options(*string);
buf             likeds(statds64);
end-pr;


//--------------------------------------------------------------------
// statvfs() -- Get file system status
//
//    path = (input) pathname of a link ("file") in the IFS.
//     buf = (output) data structure containing file system info
//
// Returns 0 if successful, -1 upon error.
// (error information is returned via the "errno" variable)
//--------------------------------------------------------------------
dcl-pr statvfs int(10) extproc('statvfs64');
  path            pointer value options(*string);
  buf             like(ds_statvfs);
end-pr;

//--------------------------------------------------------------------
// Make Symbolic Link
//
// int symlink(const char *pname, const char *slink)
//--------------------------------------------------------------------
dcl-pr symlink int(10) extproc('symlink');
pname           pointer value options(*string);
slink           pointer value options(*string);
end-pr;

//--------------------------------------------------------------------
// Get system configuration variables
//
// long sysconf(int name)
//--------------------------------------------------------------------
dcl-pr sysconf int(10) extproc('sysconf');
name            int(10) value;
end-pr;

//--------------------------------------------------------------------
// Set Authorization Mask for Job
//
// mode_t umask(mode_t cmask)
//--------------------------------------------------------------------
dcl-pr umask uns(10) extproc('umask');
cmask           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Remove Link to File.  (Deletes Directory Entry for File, and if
//    this was the last link to the file data, the file itself is
//    also deleted)
//
// int unlink(const char *path)
//--------------------------------------------------------------------
dcl-pr unlink int(10) extproc('unlink');
  path            pointer value options(*string:*trim);
end-pr;

//--------------------------------------------------------------------
// Set File Access & Modification Times
//
// int utime(const char *path, const struct utimbuf *times)
//--------------------------------------------------------------------
dcl-pr utime int(10) extproc('utime');
path            pointer value options(*string);
times           likeds(utimbuf) options(*omit);
end-pr;

//--------------------------------------------------------------------
// Write to a file
//
// ssize_t write(int fildes, const void *buf, size_t bytes)
//--------------------------------------------------------------------
dcl-pr write int(10) extproc('write');
fildes          int(10) value;
buf             pointer value;
bytes           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Write to a file using (with type A field in prototype)
//
// ssize_t write(int fildes, const void *buf, size_t bytes)
//--------------------------------------------------------------------
dcl-pr writea int(10) extproc('write');
fildes          int(10) value;
buf             char(65535) const options(*varsize);
bytes           uns(10) value;
end-pr;

//--------------------------------------------------------------------
// Write to descriptor using multiple buffers
//
// int writev(int fildes, struct iovec *iovector[], int vector_len);
//--------------------------------------------------------------------
dcl-pr writev int(10) extproc('writev');
  fildes          int(10) value;
  io_vector       like(iovec) dim(256) options(*varsize);
  vector_len      int(10) value;
end-pr;


dcl-pr remove int(10) extproc('remove');
path            pointer value options(*string);
end-pr;

