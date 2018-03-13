/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core;

import org.eclipse.osgi.util.NLS;

public class Messages extends NLS {

    private static final String BUNDLE_NAME = "de.tools400.rpgunit.core.messages"; //$NON-NLS-1$

    public static String Obsolete_Bundles_Warning_Message_Text;
    public static String Obsolete_Bundles_Warning_Message_Message;

    public static String AbstractRemoteAction_0;

    public static String Invalid_host_version;

    public static String Can_not_execute_unit_test_due_to_missing_unit_test_runner;
    public static String The_object_A_does_not_contain_any_test_cases;
    public static String The_unit_test_A_has_not_finished_successful_B;
    public static String Number_of_selected_test_cases_exceeds_maximum_of_A_items;
    public static String Run_Unit_Test;

    public static String EditableSourceMember_0;
    public static String EditableSourceMember_1;
    public static String Statement_number;
    public static String Error_message;
    public static String Result;
    public static String Execution_time;
    public static String Program;
    public static String Module;
    public static String Procedure;
    public static String Source_file;
    public static String Source_library;
    public static String Source_member;
    public static String Test_suite;
    public static String Assertions;
    public static String Errors;
    public static String Failures;
    public static String Runs;
    public static String SUCCESS;
    public static String FAILED;
    public static String ERROR;
    public static String No_spooled_file_viewer_installed;
    public static String Could_not_open_the_iSphere_spooled_file_viewer;
    public static String Could_not_open_the_RPGUnit_spooled_file_viewer;

    public static String PreferencesPage2_grpCommandParameters_text;
    public static String PreferencesPage2_lblRunOrder_text;
    public static String PreferencesPage2_cboRunOrder_toolTipText;
    public static String PreferencesPage2_lblLibraryList_text;
    public static String PreferencesPage2_cboLibraryList_toolTipText;
    public static String PreferencesPage2_lblJobDescription_text;
    public static String PreferencesPage2_lblJobDescription_toolTipText;
    public static String PreferencesPage2_lblJobDescription_choice;
    public static String PreferencesPage2_lblJobDescriptionLibrary_text;
    public static String PreferencesPage2_lblJobDescriptionLibrary_toolTipText;
    public static String PreferencesPage2_lblProductLibrary_choice;
    public static String PreferencesPage2_lblReportDetail_text;
    public static String PreferencesPage2_cboReportDetail_toolTipText;
    public static String PreferencesPage2_lblCreateReport_text;
    public static String PreferencesPage2_cboCreateReport_toolTipText;
    public static String PreferencesPage2_lblReclaimResources_text;
    public static String PreferencesPage2_cboReclaimResources_toolTipText;
    public static String PreferencesPage2_grpOverrideCommandParameters_text;
    public static String PreferencesPage2_chkDisableReport_text;
    public static String PreferencesPage2_chkDisableReport_toolTipText;
    public static String PreferencesPage2_grpRuntime_text;
    public static String PreferencesPage2_lblProductLibrary_text;
    public static String PreferencesPage2_lblCheckTestSuite_text;
    public static String PreferencesPage2_cboCheckTestSuite_toolTipText;
    public static String PreferencesPage2_lblJobDescriptionLibrary_choice;
    public static String PreferencesPage2_txtProductLibrary_toolTipText;
    public static String PreferencesPage2_grpDebugParameters_text;
    public static String PreferencesPage2_chkNewConnection_text;
    public static String PreferencesPage2_chkNewConnection_toolTipText;
    public static String PreferencesPage2_chkPosToLineOnOpen_text;
    public static String PreferencesPage2_chkPosToLineOnOpen_toolTipText;
    public static String PreferencesPage2_grpWarnings_text;
    public static String PreferencesPage2_chkResetWarnings_text;
    public static String PreferencesPage2_chkResetWarnings_toolTipText;

    public static String Warning;
    public static String Source_line_number_not_found_Did_you_compile_the_source_member_with_OPTION_SRCSTMT;
    public static String User_defined_attribute_not_retrieved_See_APAR_SE55976_for_details;
    public static String Do_not_ask_me_again;

    public static String RPGUnit_Userspace_for_Result_of_Unit_Test;
    public static String Can_not_execute_unit_test_A_B_due_to_missing_job_description_C;
    public static String Unit_test_A_B_ended_unexpected_with_error_message;

    public static String UIUtils_0;

    static {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages() {
    }

}
