**FREE
// ==========================================================================
//  iRPGUnit - Command line runner.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt main(cmdRun);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CMDRUN


//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,CMDRUNSRV
/include qinclude,PGMMSG

//---------------------------------------------------------------------
//   Main Procedure
//---------------------------------------------------------------------

dcl-proc cmdrun;
  dcl-pi *n;
    gi_qTestSuite likeds(object_t) const;
    gi_testProcs  likeds(procNms_t) const;
    gi_order      like(order_t) const;
    gi_detail     like(detail_t) const;
    gi_output     like(output_t) const;
    gi_libL       likeds(libl_t) const;
    gi_qJobD      likeds(object_t) const;
    gi_rclRsc     like(rclrsc_t) const;
    gi_xmlStmf    like(stmf_fl_t) const;
    gi_xmlType    like(xmlType_t) const;
    gi_assertMode like(assertMode_t) const;
  end-pi;

  dcl-s isSuccess ind;
  dcl-s msg varchar(256);

  isSuccess = runTestSuite(*omit: gi_qTestSuite: gi_testProcs:
                           gi_order: gi_detail: gi_assertMode: gi_output:
                           gi_libL: gi_qJobD: gi_rclRsc: %trim(gi_xmlStmf):
                           gi_xmlType: msg);

  if (isSuccess);
    sndCompMsg( msg );
  else;
    sndEscapeMsgAboveCtlBdy( msg );
  endif;

  *inlr = *on;

end-proc;

