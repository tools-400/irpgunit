      /if not defined(QCAPCMD)
      /define QCAPCMD
      //
      // Prototype for QCAPCMD API.
      //
      // Execute Command
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qcapcmd.htm
      //

     D QCAPCMD...
     D                 pr                         extpgm('QCAPCMD')
     D  cmd                       32702A   const  options(*varsize)
     D  cmdLen                       10I 0 const
     D  optCtrlBlk                32767A   const  options(*varsize)
     D  optCtrlBlkLen                10I 0 const
     D  optCtrlBlkFmt                 8A   const
     D  chgCmd                    32702A          options(*varsize)
     D  chgCmdLen                    10I 0 const
     D  chgCmdLenAvl                 10I 0
     D                            32767A          options(*varsize)

     D QCAPCMD_optCtrlBlk_t...
     D                 ds                  qualified template
     D  typeCmdPrc             1      4I 0 inz(1)                               QCMDCHK API
     D  DBCS_data              5      5A   inz('0')                             ignore DBCS
     D  prmtAction             6      6A   inz('0')                             never prompt
     D  cmdStrSyntax           7      7A   inz('0')                             AS/400 Syntax
     D  msgRtvKey              8     11A   inz(*BLANKS)                         no msg key
     D  res_01                12     20A   inz(*ALLx'00')

      /endif
