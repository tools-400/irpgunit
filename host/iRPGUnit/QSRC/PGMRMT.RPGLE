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
  go_returnCode   int(10);
  gi_userSpace    const  likeds(object_t);
  gi_testSuite    const  likeds(object_t);
  gi_procNames    const  likeds(procNms_t);
  gi_order        const  like(order_t);
  gi_detail       const  like(detail_t);
  gi_output       const  like(output_t);
  gi_libl         const  likeds(libl_t);
  gi_qJobD        const  likeds(object_t);
  gi_rclRsc       const  like(rclrsc_t);
  gi_xmlStmf      const  like(stmf_fl_t) options(*nopass);
end-pi;

dcl-s xmlStmf like(stmf_t);
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

go_returnCode =
     rpgunit_runTestSuite(
        gi_userSpace: gi_testSuite: gi_procNames: gi_order
        : gi_detail: gi_output: gi_libl: gi_qJobD: gi_rclRsc: xmlStmf);

*inlr = *on;

