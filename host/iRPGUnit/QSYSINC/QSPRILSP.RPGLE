      /IF DEFINED(QSPRILSP)
      /EOF
      /ENDIF
      /DEFINE QSPRILSP
      *
      *  Retrieve Identity of Last Spooled File Created (QSPRILSP) API
     D QSPRILSP...
     D                 PR                  extpgm('QSPRILSP')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_lenRcvVar                  10I 0 const
     D  i_format                      8A   const
     D  io_errCode                65535A          options(*varsize)
      *
      *  SPRL0100 Format
     D sprl0100_t...
     D                 DS                  qualified           based(pDummy)
     D  bytRet                 1      4I 0
     D  bytAvl                 5      8I 0
     D  name                   9     18A
     D  job                   19     28A
     D  user                  29     38A
     D  jobNbr                39     44A
     D  splfNbr               45     48I 0
     D  system                49     56A
     D  crtDate               57     63A
     D  reserved_1            64     64A
     D  crtTime               65     70A
      *
