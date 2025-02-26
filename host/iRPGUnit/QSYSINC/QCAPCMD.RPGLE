**FREE
/if not defined(QCAPCMD)
/define QCAPCMD
//
// Prototype for QCAPCMD API.
//
// Execute Command
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qcapcmd.htm
//

dcl-pr qcapcmd
       extpgm('QCAPCMD');
  cmd             char(32702) const  options(*varsize);
  cmdLen          int(10) const;
  optCtrlBlk      char(32767) const  options(*varsize);
  optCtrlBlkLen   int(10) const;
  optCtrlBlkFmt   char(8) const;
  chgCmd          char(32702) options(*varsize);
  chgCmdLen       int(10) const;
  chgCmdLenAvl    int(10);
  *N              char(32767) options(*varsize);
end-pr;

dcl-ds qcapcmd_optCtrlBlk_t qualified template;
  typeCmdPrc      int(10) inz(1);         // QCMDCHK API
  dbcs_data       char(1) inz('0');       // ignore DBCS
  prmtAction      char(1) inz('0');       // never prompt
  cmdStrSyntax    char(1) inz('0');       // AS/400 Syntax
  msgRtvKey       char(4) inz(*blanks);   // no msg key
  res_01          char(9) inz(*allx'00');
end-ds;

/endif
