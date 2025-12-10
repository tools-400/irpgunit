**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Test Runner.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
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

ctl-opt main(pgmrmt);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,PGMRMT

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TEMPLATES
/include qinclude,ASSERT
/include qinclude,PGMMSG
/include qinclude,CMDRUNSRV

/include qinclude,SDS

//----------------------------------------------------------------------
//   Main Procedure
//----------------------------------------------------------------------

dcl-proc pgmrmt;
  dcl-pi *n;
    go_returnCode   int(10);
    gi_qUserSpace   likeds(object_t) const;
    gi_qTestSuite   likeds(object_t) const;
    gi_testProcs    likeds(procNms_t) const;
    gi_order        like(order_t) const;
    gi_detail       like(detail_t) const;
    gi_output       like(output_t) const;
    gi_libL         likeds(libl_t) const;
    gi_qJobD        likeds(object_t) const;
    gi_rclRsc       like(rclrsc_t) const;
    gi_xmlStmf      like(stmf_fl_t) options(*nopass) const;
    gi_xmlType      like(xmlType_fl_t) options(*nopass) const;
    gi_isJUnitStyle ind options(*nopass) const;
  end-pi;

  dcl-c SUCCESS 0;
  dcl-c FAILURE -1;

  dcl-s xmlStmf like(stmf_t);
  dcl-s xmlType like(xmlType_t);
  dcl-s isJUnitStyle ind;

  dcl-s isSuccess ind;
  dcl-s msg varchar(256);

  if (%parms() >= %parmnum(gi_xmlStmf) and %addr(gi_xmlStmf) <> *null);
    xmlStmf = %trimr(gi_xmlStmf);
  else;
    xmlStmf = '';
  endif;

  if (%parms() >= %parmnum(gi_xmlType) and %addr(gi_xmlType) <> *null);
    xmlType = %trimr(gi_xmlType);
  else;
    xmlType = XML_TYPE_1;
  endif;

  if (%parms() >= %parmnum(gi_isJUnitStyle) and %addr(gi_isJUnitStyle) <> *null);
    isJUnitStyle = %trimr(gi_isJUnitStyle);
  else;
    isJUnitStyle = DEFAULT_IS_JUNIT_STYLE;
  endif;

  registerStartPgm(sds.pgmLib: sds.pgmname: isJUnitStyle);

  isSuccess = runTestSuite(gi_qUserSpace: gi_qTestSuite: gi_testProcs:
                           gi_order: gi_detail: gi_output: gi_libL:
                           gi_qJobD: gi_rclRsc: gi_xmlStmf: gi_xmlType:
                           isJUnitStyle: msg);

  if (isSuccess);
    go_returnCode = SUCCESS;
    sndCompMsg( msg );
  else;
    go_returnCode = FAILURE;
    sndCompMsg( msg );
  endif;


  *inlr = *on;

end-proc;
