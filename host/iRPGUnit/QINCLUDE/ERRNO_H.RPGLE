**FREE
//-                                                                            +
// Copyright (c) 2001 Scott C. Klement                                         +
// All rights reserved.                                                        +
//                                                                             +
// Redistribution and use in source and binary forms, with or without          +
// modification, are permitted provided that the following conditions          +
// are met:                                                                    +
// 1. Redistributions of source code must retain the above copyright           +
//    notice, this list of conditions and the following disclaimer.            +
// 2. Redistributions in binary form must reproduce the above copyright        +
//    notice, this list of conditions and the following disclaimer in the      +
//    documentation and/or other materials provided with the distribution.     +
//                                                                             +
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
// SUCH DAMAGE.                                                                +
//                                                                             +
///                                                                            +

//-------------------------------------------------------------------
// error constant definitions
//-------------------------------------------------------------------

// these values come originally from file QCLE/H member ERRNO

// domain error in math function
dcl-c EDOM            3001;
// range error in math function
dcl-c ERANGE          3002;
// truncation on I/O operation
dcl-c ETRUNC          3003;
// file has not been opened
dcl-c ENOTOPEN        3004;
// file not opened for read
dcl-c ENOTREAD        3005;
// file opened for record I/O
dcl-c ERECIO          3008;
// file not opened for write
dcl-c ENOTWRITE       3009;
// stdin cannot be opened
dcl-c ESTDIN          3010;
// stdout cannot be opened
dcl-c ESTDOUT         3011;
// stderr cannot be opened
dcl-c ESTDERR         3012;
// bad offset to seek to
dcl-c EBADSEEK        3013;
// invalid file name specified
dcl-c EBADNAME        3014;
// invalid file mode specified
dcl-c EBADMODE        3015;
// invalid position specifier
dcl-c EBADPOS         3017;
// no record at specified position
dcl-c ENOPOS          3018;
// no ftell if more than 1 member
dcl-c ENUMMBRS        3019;
// no ftell if too many records
dcl-c ENUMRECS        3020;
// invalid function pointer
dcl-c EBADFUNC        3022;
// record not found
dcl-c ENOREC          3026;
// message data invalid
dcl-c EBADDATA        3028;
// bad option on I/O function
dcl-c EBADOPT         3040;
// file not opened for update
dcl-c ENOTUPD         3041;
// file not opened for delete
dcl-c ENOTDLT         3042;
// padding occurred on write operation
dcl-c EPAD            3043;
// bad key length option
dcl-c EBADKEYLN       3044;
// illegal write after read
dcl-c EPUTANDGET      3080;
// illegal read after write
dcl-c EGETANDPUT      3081;
// I/O exception non-recoverable error
dcl-c EIOERROR        3101;
// I/O exception recoverable error
dcl-c EIORECERR       3102;

// The following were taken from QSYSINC/SYS ERRNO:

//  Permission denied.
dcl-c EACCES          3401;
//  Not a directory.
dcl-c ENOTDIR         3403;
//  No space available.
dcl-c ENOSPC          3404;
//  Improper link.
dcl-c EXDEV           3405;
//  Operation would have caused the process
dcl-c EWOULDBLOCK     3406;
//  Operation would have caused the process
dcl-c EAGAIN          3406;
//  Interrupted function call.
dcl-c EINTR           3407;
//  The address used for an argument was no
dcl-c EFAULT          3408;
//  Operation timed out
dcl-c ETIME           3409;
//  No such device or address
dcl-c ENXIO           3415;
//  Socket closed
dcl-c ECLOSED         3417;
//  Address already in use.
dcl-c EADDRINUSE      3420;
//  Address not available.
dcl-c EADDRNOTAVAIL   3421;
//  The type of socket is not supported in
dcl-c EAFNOSUPPORT    3422;
//  Operation already in progress.
dcl-c EALREADY        3423;
//  Connection ended abnormally.
dcl-c ECONNABORTED    3424;
//  A remote host refused an attempted conn
dcl-c ECONNREFUSED    3425;
//  A connection with a remote socket was r
dcl-c ECONNRESET      3426;
//  Operation requires destination address.
dcl-c EDESTADDRREQ    3427;
//  A remote host is not available.
dcl-c EHOSTDOWN       3428;
//  A route to the remote host is not avail
dcl-c EHOSTUNREACH    3429;
//  Operation in progress.
dcl-c EINPROGRESS     3430;
//  A connection has already been establish
dcl-c EISCONN         3431;
//  Message size out of range.
dcl-c EMSGSIZE        3432;
//  The network is not currently available.
dcl-c ENETDOWN        3433;
//  A socket is connected to a host that is
dcl-c ENETRESET       3434;
//  Cannot reach the destination network.
dcl-c ENETUNREACH     3435;
//  There is not enough buffer space for th
dcl-c ENOBUFS         3436;
//  The protocol does not support the speci
dcl-c ENOPROTOOPT     3437;
//  Requested operation requires a connecti
dcl-c ENOTCONN        3438;
//  The specified descriptor does not refer
dcl-c ENOTSOCK        3439;
//  Operation not supported.
dcl-c ENOTSUP         3440;
//  Operation not supported.
dcl-c EOPNOTSUPP      3440;
//  The socket protocol family is not suppo
dcl-c EPFNOSUPPORT    3441;
//  No protocol of the specified type and d
dcl-c EPROTONOSUPPORT 3442;
//  The socket type or protocols are not co
dcl-c EPROTOTYPE      3443;
//  An error indication was sent by the pee
dcl-c ERCVDERR        3444;
//  Cannot send data after a shutdown.
dcl-c ESHUTDOWN       3445;
//  The specified socket type is not suppor
dcl-c ESOCKTNOSUPPORT 3446;
//  A remote host did not respond within th
dcl-c ETIMEDOUT       3447;
//  The protocol required to support the sp
dcl-c EUNATCH         3448;
//  Descriptor not valid.
dcl-c EBADF           3450;
//  Too many open files for this process.
dcl-c EMFILE          3452;
//  Too many open files in the system.
dcl-c ENFILE          3453;
//  Broken pipe.
dcl-c EPIPE           3455;
//  File exists.
dcl-c EEXIST          3457;
//  Resource deadlock avoided.
dcl-c EDEADLK         3459;
//  Storage allocation request failed.
dcl-c ENOMEM          3460;
//  The synchronization object no longer ex
dcl-c EOWNERTERM      3462;
// The synchronization object was destroyed
dcl-c EDESTROYED      3463;
//  Operation terminated.
dcl-c ETERM           3464;
//  Maximum link count for a file was excee
dcl-c EMLINK          3468;
//  Seek request not supported for object.
dcl-c ESPIPE          3469;
//  Function not implemented.
dcl-c ENOSYS          3470;
//  Specified target is a directory.
dcl-c EISDIR          3471;
//  Read-only file system.
dcl-c EROFS           3472;
//  Unknown system state.
dcl-c EUNKNOWN        3474;
//  Iterator is invalid.
dcl-c EITERBAD        3475;
//  A damaged object was encountered.
dcl-c EDAMAGE         3484;
//  A loop exists in the symbolic links.
dcl-c ELOOP           3485;
//  A path name is too long.
dcl-c ENAMETOOLONG    3486;
//  No locks available
dcl-c ENOLCK          3487;
//  Directory not empty.
dcl-c ENOTEMPTY       3488;
//  System resources not available to compl
dcl-c ENOSYSRSC       3489;
//  Conversion error.
dcl-c ECONVERT        3490;
//  Argument list too long.
dcl-c E2BIG           3491;
//  Conversion stopped due to input charact
dcl-c EILSEQ          3492;
// Object has soft damage.
dcl-c ESOFTDAMAGE     3497;
//  User not enrolled in system distributio
dcl-c ENOTENROLL      3498;
//  Object is suspended.
dcl-c EOFFLINE        3499;
// Object is a read only object.
dcl-c EROOBJ          3500;
// Area being read from or written to is lo
dcl-c ELOCKED         3506;
// Object too large.
dcl-c EFBIG           3507;
// The semaphore, shared memory, or message
dcl-c EIDRM           3509;
// The queue does not contain a message of
dcl-c ENOMSG          3510;
// File ID conversion of a directory failed
dcl-c EFILECVT        3511;
// A File ID could not be assigned when lin
dcl-c EBADFID         3512;
// A File ID could not be assigned when lin
dcl-c ESTALE          3513;
// No such process.
dcl-c ESRCH           3515;
// Process not enabled for signals.
dcl-c ENOTSIGINIT     3516;
// No child process.
dcl-c ECHILD          3517;
// The operation would have exceeded the ma
dcl-c ETOOMANYREFS    3523;
// Function not allowed.
dcl-c ENOTSAFE        3524;
// Object is too large to process.
dcl-c EOVERFLOW       3525;
// Journal damaged.
dcl-c EJRNDAMAGE      3526;
// Journal inactive.
dcl-c EJRNINACTIVE    3527;
// Journal space or system storage error.
dcl-c EJRNRCVSPC      3528;
// Journal is remote.
dcl-c EJRNRMT         3529;
// New journal receiver is needed.
dcl-c ENEWJRNRCV      3530;
// New journal is needed.
dcl-c ENEWJRN         3531;
// Object already journaled.
dcl-c EJOURNALED      3532;
// Entry too large to send.
dcl-c EJRNENTTOOLONG  3533;
// Object is a Datalink object.
dcl-c EDATALINK       3534;

// The following values are defined by POSIX ISO/IEC 9945-1:1990
//  (these were also taken from QCLE/H member ERRNO)

// invalid argument
dcl-c EINVAL          3021;
// input/output error
dcl-c EIO             3006;
// no such device
dcl-c ENODEV          3007;
// resource busy
dcl-c EBUSY           3029;
// no such file or library
dcl-c ENOENT          3025;
// operation not permitted
dcl-c EPERM           3027;

//-------------------------------------------------------------------
// prototype definitions
//-------------------------------------------------------------------
dcl-pr c__errno pointer extproc('__errno');
end-pr;

dcl-pr pError extproc('perror');
  comment     pointer value options(*string);
end-pr;

