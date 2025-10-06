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
/include qinclude,CMDRUNV
/include qinclude,PGMMSG
/include qinclude,RMTRUNSRV

/include qinclude,SDS

//----------------------------------------------------------------------
//   Main Procedure
//----------------------------------------------------------------------

dcl-pi pgmrmt;
  go_returnCode int(10);
  gi_userSpace  likeds(object_t) const;
  gi_testSuite  likeds(object_t) const;
  gi_procNames  likeds(procNms_t) const;
  gi_order      like(order_t) const;
  gi_detail     like(detail_t) const;
  gi_output     like(output_t) const;
  gi_libl       likeds(libl_t) const;
  gi_qJobD      likeds(object_t) const;
  gi_rclRsc     like(rclrsc_t) const;
  gi_xmlStmf    like(stmf_fl_t) options(*nopass) const;
  gi_xmlType    like(xmlType_fl_t) options(*nopass) const;
end-pi;

dcl-s xmlStmf like(stmf_t);
dcl-s xmlType like(xmlType_t);
dcl-s errMsg varchar(256);

registerStartPgm(sds.pgmLib: sds.pgmname);

if (%parms() >= %parmnum(gi_xmlStmf) and %addr(gi_xmlStmf) <> *null);
  xmlStmf = %trimr(gi_xmlStmf);
  if (xmlStmf <> '');
    errMsg = validateXmlStmf(xmlStmf: gi_testSuite);
    if (errMsg <> '');
      sndEscapeMsgAboveCtlBdy( errMsg  );
    endif;
  endif;
else;
  xmlStmf = '';
endif;

if (%parms() >= %parmnum(gi_xmlType) and %addr(gi_xmlType) <> *null);
  xmlType = %trimr(gi_xmlType);
else;
  xmlType = XML_TYPE_1;
endif;

go_returnCode =
     rpgunit_runTestSuite(
        gi_userSpace: gi_testSuite: gi_procNames: gi_order
        : gi_detail: gi_output: gi_libl: gi_qJobD: gi_rclRsc: xmlStmf: xmlType);

*inlr = *on;

