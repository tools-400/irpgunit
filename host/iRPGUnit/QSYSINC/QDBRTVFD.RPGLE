**FREE
/if not defined(QDBRTVFD)
/define QDBRTVFD

//  Retrieve Database File Description (QDBRTVFD) API
dcl-pr QDBRTVFD extpgm('QDBRTVFD');
  o_rcvVar      char(65535) options(*varsize);
  i_lenRcvVar   int(10) const;
  o_retFileName char(20);
  i_format      char(8) const;
  i_qFile       char(20) const;
  i_rcdFormat   char(10) const;
  i_override    char(1) const;
  i_system      char(10) const;
  i_formatType  char(10) const;
  io_errCode    char(65535) options(*varsize);
end-pr;

// ---------------------------------------------------
//  FILD0100:
// ---------------------------------------------------

//  File Definition Header (Qdb_Qdbfh)
dcl-ds Qdb_Qdbfh_t qualified template;
  Qdbfyret    int(10);
  Qdbfyavl    int(10);
  Qdbfhflg    uns(5);
  Reserved_7  char(4);
  Qdbflbnum   int(5);
  Qdbfknum    int(5);
  Qdbfkmxl    int(5);
  Qdbfkflg    char(1);
  Qdbfkfdm    char(1);
  Reserved_10 char(8);
  Qdbfhaut    char(10);
  Qdbfhupl    char(1);
  Qdbfhmxm    int(5);
  Qdbfwtfi    int(5);
  Qdbfhfrt    int(5);
  Qdbfhmnum   int(5);
  Qdbfapsize  int(5);
  Reserved_11 char(7);
  Qdbfbrwt    int(5);
  Qaaf        char(1);
  Qdbffmtnum  int(5);
  Qdbfhfl2    char(2);
  Qdbfvrm     int(5);
  Qaaf2       char(2);
  Qdbfhcrt    char(13);
  Reserved_18 char(2);
  Qdbfhtxt    char(50);
  Reserved_19 char(13);
  Qdbfsrcf    char(10);
  Qdbfsrcm    char(10);
  Qdbfsrcl    char(10);
  Qdbfkrcv    char(1);
  Reserved_20 char(23);
  Qdbftcid    int(5);
  Qdbfasp     int(5);
  Qdbfnbit    char(1);
  Qdbfmxfnum  int(5);
  Reserved_22 char(76);
  Qdbfodic    int(10);
  Reserved_23 char(14);
  Qdbffigl    int(5);
  Qdbfmxrl    int(5);
  Reserved_24 char(8);
  Qdbfgkct    int(5);
  Qdbfos      int(10);
  Reserved_25 char(8);
  Qdbfocs     int(10);
  Reserved_26 char(4);
  Qdbfpact    char(2);
  Qdbfhrls    char(6);
  Reserved_27 char(20);
  Qdbpfof     int(10);
  Qdblfof     int(10);
  Qdbfnlsb    char(1);
  Qdbflang    char(3);
  Qdbfcnty    char(2);
  Qdbfjorn    int(10);
  Qdbfevid    int(10);
  Reserved_28 char(14);
end-ds;

// Bits of Qdbfhflg
dcl-c QDBFHFPL  x'2000'; // *on: file is a logical database file
dcl-c QDBFHFSU  x'0800'; // *on: file is a source file (*SRC)
dcl-c QDBFHFKY  x'0200'; // *on: file has a keyed sequence access path
dcl-c QDBFHFLC  x'0080'; // *on: record format level identifiers are checked when the file is opened
dcl-c QDBFKFSO  x'0040'; // *on: the file is a select/omit logical file
dcl-c QDBFIGCD  x'0002'; // *on: file's record format(s) contains DBCS or Graphic data fields
dcl-c QDBFIGCL  x'0001'; // *on: file's record format(s) contains DBCS or Graphic literals

//  File Scope Array (Qdb_Qdbfb)
dcl-ds Qdb_Qdbfb_t qualified template;
  Reserved_48 char(48);
  Qdbfbf      char(10);
  Qdbfbfl     char(10);
  Qdbft       char(10);
  Reserved_49 char(37);
  Qdbfbgky    int(5);
  Reserved_50 char(2);
  Qdbfblky    int(5);
  Reserved_51 char(2);
  Qdbffogl    int(5);
  Reserved_52 char(3);
  Qdbfsoon    int(5);
  Qdbfsoof    int(10);
  Qdbfksof    int(10);
  Qdbfkyct    int(5);
  Qdbfgenf    int(5);
  Qdbfodis    int(10);
  Reserved_53 char(15) pos(146);
end-ds;

//  Key Specification Array (Qdb_Qdbfk)
dcl-ds Qdb_Qdbfk_t qualified template;
  Qdbfkfld    char(10);
  Reserved_59 char(3);
  Qdbfksq     char(1);
  Reserved_61 char(18);
end-ds;

//  ... Physical File Specific Attributes (Qdb_Qdbfphys)
dcl-ds Qdb_Qdbfphys_t qualified template;
  Qdbfpalc    char(2);
  Qdbfcmps    char(1);
  Reserved_29 char(8);
  Qdbfprnum   int(10);
  Qdbfpri     int(5);
  Qdbfprinum  int(5);
  Qdbforid    int(10);
  Qflags      char(1);
  Qdbfotrg    char(4);
  Qdbftrgn    int(5);
  Qdbfofcs    int(10);
  Qdbfcstn    int(10);
  Qdbfodl     int(10);
  Reserved_32 char(6);
end-ds;

//  ... Constraint Definition Header (Qdb_Qdbf_Constraint)
dcl-ds Qdb_Qdbf_Constraint_t qualified template;
  Qdbf_csto     int(10);
  Qdbf_hlen     int(10);
  Qdbf_type     char(1);
  Qdbf_chkpd    char(1);
  Qdbf_state    char(1);
  Qdbf_abled    char(1);
  Qdbf_add_ts   char(13);
  Qdbf_cst_lin  char(10);
  Qdbf_cst_lp2  int(10);
  Reserved_54   char(25);
  Qdbf_cst_name char(258);
end-ds;

//  ... Constraint Keys (Qdb_Qdbf_Keyn)
dcl-ds Qdb_Qdbf_Keyn_t qualified template;
  Qdbf_kslen    int(10);
  Qdbf_nokys    int(10);
  Qdbf_klen     int(10);
  Revcst_7      char(52);
  Qdbf_narray   char(3840);
end-ds;

//  ... Key Name Array (Qdb_Qdbf_Narray)
dcl-ds Qdb_Qdbf_Narray_t qualified template;
  Qdbf_kname char(10);
  Revcst_6   char(22);
end-ds;

//  ... Referential Constraint Definition (Qdb_Qdbf_Riafk_Afkd)
dcl-ds Qdb_Qdbf_Riafk_Afkd_t qualified template;
  Qdbf_riafk_pkfn  char(10) pos(1);
  Qdbf_riafk_pkln  char(10) pos(11);
  Revcst_3         char(44) pos(21);
  Qdbf_riafk_fkcdr char(1) pos(65);
  Revcst_4         char(1) pos(66);
  Qdbf_riafk_fkcur char(1) pos(67);
  Revcst_5         char(61) pos(68);
end-ds;

//  ... Check Constraint (Qdb_Qdbf_Chk_Cst)
dcl-ds Qdb_Qdbf_Chk_Cst_t qualified template;
  Qdbf_chkcst_len  int(10) pos(1);
  Qdbf_chkexpr_len int(10) pos(5);
  Revcst_8         char(24) pos(9);
  Qdbf_chkexpr     char(1968) pos(33);
end-ds;

// ---------------------------------------------------
//  FILD0200
// ---------------------------------------------------

//  Format Definition Header (Qdb_Qddfmt)
dcl-ds Qdb_Qddfmt_t qualified template;
  bytRet            int(10);
  bytAvl            int(10);
  Reserved_62       char(24);
  Qddfmtf           char(1);
  Qddfxlto          int(10);
  Qddfrcao          int(10);
  Qddfdico          int(10);
  Qddfrcid          int(5);
  Qddfsrcd          int(5);
  Qddfrtcd          int(5);
  Qddfrlcd          int(5);
  Reserved_64       char(7);
  Qddftflgs         char(1);
  Qddflgs           uns(3);
  Reserved_67       char(4);
  Qddfrlen          int(10);
  Qddfname          char(10);
  Qddfseq           char(13);
  Qddftext          char(50);
  Qddffldnum        int(5);
  Qddf_Identity_Off int(10) pos(146);
  // Qddffldx                    char(*)   Start of field definition arra(Qdb_Qddffld)
  Qddffldx char(256) pos(257);
end-ds;

// Bits of Qddflgs
dcl-c QDDFRVAR  x'40'; // *on: Variable length fields
dcl-c QDDFRGPH  x'20'; // *on: Graphic fields
dcl-c QDDFRDTT  x'0F'; // *on: Date, time, or timestamp fields
dcl-c QDDFRNUL  x'08'; // *on: Null capable fields
dcl-c QDDFRSID  x'04'; // *on: Common coded character set identifier flag
dcl-c QDDFESID  x'02'; // *on: Explicit coded character set identifier flag

//  Field Header (Qdb_Qddffld)
dcl-ds Qdb_Qddffld_t qualified template;
  Qddfdefl     int(10);
  Qddffldi     char(30);
  Qddfflde     char(30);
  Qddfftyp     char(2);
  Qddffiob     char(1);
  Qddffobo     int(10);
  Qddffibo     int(10);
  Qddffldb     int(5);
  Qddffldd     int(5);
  Qddffldp     int(5);
  //  ...
  Qddffldst2   uns(3) pos(86);
  //  ...
  Qddflalc     uns(5) pos(92);
  Qddfdttf     char(1);
  Qddfdtts     char(1);
  Qddfcsid     uns(5);
  //  ...
  Qddfdftd     uns(10) pos(195);
  //  ...
  Qddftxtd     int(10) pos(209);
  Reserved_102 char(2);
  Qddfrefd     int(10);
  Qddfedtl     int(5);
  Qddfedtd     int(10);
  Reserved_76  int(5);
  Qddfchd      int(10);
  //  ...
  Qddfxals     int(10) pos(237);
end-ds;

//  Reference Information (Qdb_Qddfrefi)
dcl-ds Qdb_Qddfrefi_t qualified template;
  Qddfrcde    char(1);
  Qddfrfil    char(10);
  Qddfrlib    char(10);
  Qddfrfmt    char(10);
  Qddfrfld    char(30);
  Reserved_78 char(19);
end-ds;

//  Edit Code/Edit Word Information (Qdb_Qddfedcw)
dcl-ds Qdb_Qddfedcw_t qualified template;
  Qddfecdi    char(2);
  Qddfecde    char(1) overlay(Qddfecdi);
  Qddfecdx    char(1) overlay(Qddfecdi:2);
  Reserved_79 char(14);
  Qddfewd     char(64);
end-ds;

//  Field Text (Qdb_Qddfftxt)
dcl-ds Qdb_Qddfftxt_t qualified template;
  Qddfftxt char(50);
end-ds;

//  Alias name structure (Qdb_Qddfalis)
dcl-ds Qdb_Qddfalis_t qualified template;
  Qddfalsl    int(5);
  Reserved_85 char(14);
  Qddfalsn    char(258);
end-ds;

//  Default Value Description Information (Qdb_Qddfdft)
dcl-ds Qdb_Qddfdft_t qualified template;
  Qddfdftl    int(5);
  Qddfdfta    uns(3);
  Reserved_87 char(13);
  Qddfdftv    char(32724);
end-ds;

dcl-c QDDFDFTA_GRAPHIC   128; // DBCS/graphic d
dcl-c QDDFDFTA_HEX        32; // Hex default.
dcl-c QDDFDFTA_NULL        4; // Null default.
dcl-c QDDFDFTA_DATE_TIME   2; // Current date/t
dcl-c QDDFDFTA_DFT_KEYWORD 1; // DFT/DFTVAL spe

//  Column Heading Information (Qdb_Qddfcolh)
dcl-ds Qdb_Qddfcolh_t qualified template;
  Qddfch1 char(20);
  Qddfch2 char(20);
  Qddfch3 char(20);
end-ds;

/endif
