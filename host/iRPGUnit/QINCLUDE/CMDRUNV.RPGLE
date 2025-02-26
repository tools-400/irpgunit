**FREE
/if not defined(CMDRUNV)
/define CMDRUNV
// ==========================================================================
//  iRPGUnit - RUCALLTST Validity checking program.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// The entry point of RUCALLTST. Parameters are provided by RUCALLTST command.
dcl-pr cmdrunv extpgm('CMDRUNV');
  gi_testsuite    likeds(object_t) const;
  gi_testprocs    likeds(procNms_t) const;
  gi_order        like(order_t) const;
  gi_detail       like(detail_t) const;
  gi_output       like(output_t) const;
  gi_libl         likeds(libl_t) const;
  gi_jobd         likeds(object_t) const;
  gi_rclrsc       like(rclrsc_t) const;
  gi_xmlstmf      like(stmf_t) const;
end-pr;

dcl-pr validateXmlStmf varchar(256) extproc('CMDRUNV_validateXmlStmf');
  i_xmlstmf       like(stmf_t) const;
  i_testsuite     likeds(object_t ) const;
end-pr;

dcl-pr resolvePathVariables like(stmf_t) extproc('CMDRUNV_resolvePathVariables');
  i_path          like(stmf_t) const;
  i_testsuite     likeds(object_t) const;
end-pr;

/include qinclude,CMDRUN
/endif

