      /IF NOT DEFINED(QLICHGLL)
      /DEFINE QLICHGLL
      *
      *  Change Library List (QLICHGLL) API
     D QLICHGLL...
     D                 PR                         extpgm('QLICHGLL')
     D  i_curlib                     11A   const
     D  i_prodlib1                   11A   const
     D  i_prodlib2                   11A   const
     D  i_userLibl                 2750A   const  options(*varsize)
     D  i_numE                       10I 0 const
     D  io_errCode                65535A          options(*varsize)
      *
      /ENDIF
