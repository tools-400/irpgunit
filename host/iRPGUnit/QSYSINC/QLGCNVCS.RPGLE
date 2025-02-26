**FREE
/if not defined(QlgConvertCase)
/define QlgConvertCase

// Convert Case (QLGCNVCS, QlgConvertCase) API
dcl-pr qlgconvertcase        extproc('QlgConvertCase');
  i_reqCtrlBlk    char(32767) const  options(*varsize);
  i_inData        char(32767) const  options(*varsize);
  o_outData       char(32767) options(*varsize);
  i_length        int(10) const;
  io_errCode      char(32767) options(*nopass: *varsize);
end-pr;

// Type of request.       ->   reqCtrlBlk.type
dcl-c CVTCASE_TYPE_CCSID   1;
dcl-c CVTCASE_TYPE_TABLE   2;
dcl-c CVTCASE_TYPE_USERDEF 3;

// CCSID of input data.   ->   reqCtrlBlk.ccsid
dcl-c CVTCASE_CCSID_JOB    0;

// Case request.          ->   reqCtrlBlk.case
dcl-c CVTCASE_TOUPPER  0;
dcl-c CVTCASE_TOLOWER  1;

// Request control block, CCSID format.
dcl-ds reqCtrlBlk_ccsid_t qualified template;
  type            int(10);
  ccsid           int(10);
  case            int(10);
  reserved        char(10);
end-ds;

// Request control block, table object format.
dcl-ds reqCtrlBlk_table_t qualified template;
  type            int(10);
  dbcs_ind        int(10);
  qTable          char(20);
  table_name      char(10) overlay(qTable);
  table_lib       char(10) overlay(qTable: *next);
end-ds;

// Request control block, user-defined format.
dcl-ds reqCtrlBlk_user_t qualified template;
  type            int(10);
  dbcs_ind        int(10);
  reserved_1      int(10);
  length          int(10);
  // userDefinedTable           char(*)
end-ds;

/endif
