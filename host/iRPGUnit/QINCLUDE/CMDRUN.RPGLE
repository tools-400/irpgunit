**FREE
/if not defined(CMDRUN)
/define CMDRUN
// ==========================================================================
//  iRPGUnit - Command line runner.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Main entry point for the RUCALLTST command processor.
// Coordinates the complete test execution workflow including test suite
// loading, environment setup, test execution, and result reporting.
// Handles all command parameters and orchestrates the testing process.
//
// @param gi_qTestSuite - Test suite service program object to execute
// @param gi_testProcs  - Specific test procedures to run (or *ALL for all tests)
// @param gi_order      - Test execution order (*API or *REVERSE)
// @param gi_detail     - Logging detail level (*BASIC, *ALL, *FAILURE)
// @param gi_output     - Output destination format (*SPOOLFILE, *STDOUT)
// @param gi_libL       - Library list configuration for test execution
// @param gi_jobD       - Job description for environment setup
// @param gi_rclRsc     - Resource reclamation option (*YES, *NO, *ALWAYS)
// @param gi_xmlStmf    - XML output stream file path for test results
// @param gi_xmlType    - Specifies the type of the generated XML stream file.
//                        *TYPE1 = original type created by iRPGUnit <= v5.1.0.r
//                        *TYPE2 = new type that associates a Json object to XML
//                                 element '<failure>'. The Json object includes
//                                 the stack trace as well as the 'expected' and
//                                 'actual' test values.
///
dcl-pr cmdrun extpgm('RUCALLTST');
  gi_qTestSuite   likeds(object_t) const;
  gi_testProcs    likeds(procNms_t) const;
  gi_order        like(order_t) const;
  gi_detail       like(detail_t) const;
  gi_output       like(output_t) const;
  gi_libL         likeds(libl_t) const;
  gi_qJobD        likeds(object_t) const;
  gi_rclRsc       like(rclrsc_t) const;
  gi_xmlStmf      like(stmf_t) const;
  gi_xmlType      like(xmlType_t) const;
  gi_isJUnitStyle ind options(*nopass) const;
end-pr;

/include qinclude,TEMPLATES

/endif
