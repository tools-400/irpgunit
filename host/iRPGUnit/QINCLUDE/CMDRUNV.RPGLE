**FREE
/if not defined(CMDRUNV)
/define CMDRUNV
// ==========================================================================
//  iRPGUnit - RUCALLTST Validity checking program.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Command validity checking entry point for RUCALLTST command.
// Validates all command parameters before test execution begins,
// ensuring proper syntax, object existence, authority, and parameter
// compatibility. Prevents runtime errors by catching configuration
// issues early in the command processing lifecycle.
//
// @param gi_testsuite - Test suite service program object to validate
// @param gi_testprocs - Test procedure names to verify exist
// @param gi_order     - Execution order parameter validation
// @param gi_detail    - Detail level parameter validation
// @param gi_output    - Output format parameter validation
// @param gi_libl      - Library list configuration validation
// @param gi_jobd      - Job description object validation
// @param gi_rclrsc    - Reclaim resources parameter validation
// @param gi_xmlstmf   - XML stream file path validation
///
dcl-pr cmdrunv extpgm('CMDRUNV');
  gi_testsuite likeds(object_t) const;
  gi_testprocs likeds(procNms_t) const;
  gi_order     like(order_t) const;
  gi_detail    like(detail_t) const;
  gi_output    like(output_t) const;
  gi_libl      likeds(libl_t) const;
  gi_jobd      likeds(object_t) const;
  gi_rclrsc    like(rclrsc_t) const;
  gi_xmlstmf   like(stmf_t) const;
end-pr;

///
// Validates XML stream file path and returns normalized path.
// Ensures the XML output file path is syntactically correct,
// accessible for writing, and properly formatted. Resolves
// path variables and validates directory existence and authority.
//
// @param i_xmlstmf   - XML stream file path to validate and normalize
// @param i_testsuite - Test suite object for context in variable resolution
//
// @return Validated and normalized XML stream file path
///
dcl-pr validateXmlStmf varchar(256) extproc('CMDRUNV_validateXmlStmf');
  i_xmlstmf   like(stmf_t) const;
  i_testsuite likeds(object_t) const;
end-pr;

///
// Resolves embedded variables in file paths using test suite context.
// Substitutes variables like &LIBRARY, &OBJECT, and &TIMESTAMP
// with actual values derived from the test suite configuration.
// Enables dynamic path generation for output files.
//
// @param i_path      - Path containing variables to resolve
// @param i_testsuite - Test suite object providing variable values
//
// @return Resolved path with all variables substituted with actual values
///
dcl-pr resolvePathVariables like(stmf_t) extproc('CMDRUNV_resolvePathVariables');
  i_path      like(stmf_t) const;
  i_testsuite likeds(object_t) const;
end-pr;

/include qinclude,CMDRUN
/endif
