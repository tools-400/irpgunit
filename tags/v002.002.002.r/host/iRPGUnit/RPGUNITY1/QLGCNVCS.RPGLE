      /if not defined(QlgConvertCase)
      /define QlgConvertCase

      // Convert Case (QLGCNVCS, QlgConvertCase) API
     D QlgConvertCase  PR                         extproc('QlgConvertCase')
     D  i_reqCtrlBlk              32767A   const  options(*varsize)
     D  i_inData                  32767A   const  options(*varsize)
     D  o_outData                 32767A          options(*varsize)
     D  i_length                     10I 0 const
     D  io_ErrCode                32767A          options(*nopass: *varsize)

      // Type of request.       ->   reqCtrlBlk.type
     D cCVTCASE_TYPE_ccsid...
     D                 C                   const(1)
     D cCVTCASE_TYPE_table...
     D                 C                   const(2)
     D cCVTCASE_TYPE_userDef...
     D                 C                   const(3)

      // CCSID of input data.   ->   reqCtrlBlk.ccsid
     D cCVTCASE_CCSID_Job...
     D                 C                   const(0)

      // Case request.          ->   reqCtrlBlk.case
     D cCVTCASE_toUpper...
     D                 C                   const(0)
     D cCVTCASE_toLower...
     D                 C                   const(1)

      // Request control block, CCSID format.
     D reqCtrlBlk_ccsid_t...
     D                 DS                  qualified           based(pDummy)
     D  type                         10i 0
     D  ccsid                        10i 0
     D  case                         10i 0
     D  reserved                     10a

      // Request control block, table object format.
     D reqCtrlBlk_table_t...
     D                 DS                  qualified           based(pDummy)
     D  type                         10i 0
     D  dbcs_ind                     10i 0
     D  qTable                       20a
     D   table_name                  10a   overlay(qTable)
     D   table_lib                   10a   overlay(qTable: *next)

      // Request control block, user-defined format.
     D reqCtrlBlk_user_t...
     D                 DS                  qualified           based(pDummy)
     D  type                         10i 0
     D  dbcs_ind                     10i 0
     D  reserved_1                   10i 0
     D  length                       10i 0
      * userDefinedTable           char(*)

      /endif
