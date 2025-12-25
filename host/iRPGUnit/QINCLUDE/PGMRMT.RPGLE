**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Test Runner.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Remote test runner program for executing iRPGUnit test suites
//
// This is the main entry point for the iRPGUnit plug-in test runner that executes
// unit tests in a separate job environment. It provides comprehensive test execution
// with configurable output formats, library list management, and resource cleanup.
// The program can run individual test procedures or complete test suites with
// detailed reporting and XML output capabilities.
//
// @param go_returnCode - Return code indicating the test status.
//                         0 = Success
//                        -1 = Failure
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
//                        *JENKINS1 = original type created by iRPGUnit <= v5.1.0.r
//                        *JENKINS2 = new type that associates a Json object to XML
//                                    element '<failure>'. The Json object includes
//                                    the stack trace as well as the 'expected' and
//                                    'actual' test values.
// @param gi_onFailure  - Mode of how assertions are processed (*ABORT, *CONTINUE)
///
dcl-pr pgmrmt extpgm('PGMRMT');
  go_returnCode int(10);
  gi_qUserSpace likeds(object_t) const;
  gi_qTestSuite likeds(object_t) const;
  gi_testProcs  likeds(procNms_t) const;
  gi_order      like(order_t) const;
  gi_detail     like(detail_t) const;
  gi_output     like(output_t) const;
  gi_libL       likeds(libl_t) const;
  gi_qJobD      likeds(object_t) const;
  gi_rclRsc     like(rclrsc_t) const;
  gi_xmlStmf    like(stmf_fl_t) options(*nopass) const;
  gi_xmlType    like(xmlType_t) options(*nopass) const;
  gi_onFailure  like(onFailure_t) options(*nopass) const;
end-pr;

