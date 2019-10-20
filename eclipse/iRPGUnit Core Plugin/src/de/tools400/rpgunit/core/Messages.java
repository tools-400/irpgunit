/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
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
    public static String Transfer_RPGUnit_Library;
    public static String ActionLabel_Copy;
    public static String ActionLabel_Copy_all;
    public static String DialogTitle_Sign_On;

    public static String Invalid_host_version;

    public static String Can_not_execute_unit_test_due_to_missing_unit_test_runner;
    public static String The_object_A_does_not_contain_any_test_cases;
    public static String The_unit_test_A_has_not_finished_successful_B;
    public static String Number_of_selected_test_cases_exceeds_maximum_of_A_items;
    public static String Description_of_service_program_is_missing;
    public static String Description_of_service_program_does_not_start_with_A;
    public static String User_defined_attribute_of_service_program_is_not_set_to_A;
    public static String Procedure_name_does_not_start_with_A;
    public static String Module_is_not_a_QSYSRemoteProgramModule;
    public static String Object_is_not_a_IQSYSServiceProgram;
    public static String Run_Unit_Test;
    public static String Host_of_first_selected_object_not_found;
    public static String Host_not_found;
    public static String Cannot_execute_test_cases_from_different_connections;
    public static String Object_type_A_not_supported;

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
    public static String CANCELED;
    public static String SUCCESS;
    public static String FAILED;
    public static String ERROR;
    public static String NOT_YET_RUN;
    public static String No_spooled_file_viewer_installed;
    public static String Could_not_open_the_iSphere_spooled_file_viewer;
    public static String Could_not_open_the_RPGUnit_spooled_file_viewer;
    public static String Error_Message;
    public static String Object_name;
    public static String Please_select_a_connection;
    public static String Please_specify_a_valid_FTP_port_number;
    public static String Please_enter_a_valid_library_name;
    public static String Ready_to_transfer_library_A_to_host_B_using_port_C;
    public static String Server_job_colon;
    public static String Enter_a_host_name;
    public static String Enter_a_user_name;
    public static String Enter_a_password;
    public static String Host_A_not_found_in_configured_RSE_connections;
    public static String Unit_test_ended_with_errors;
    public static String A_program_B_module_C_procedure_D_statement_E_FORMATTED;
    public static String A_program_B_module_C_procedure_D_statement_E_UNFORMATTED;
    public static String Sending;
    public static String Receiving;
    public static String A_Result_of_iRPGUnit_Test_Case_B_served_by_server_job_C;
    public static String Capture_Joblog_OFF;
    public static String Capture_Joblog_ERRORS_ON_ERROR;
    public static String Capture_Joblog_ALL_ON_ERROR;
    public static String Capture_Joblog_ALL;

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
    public static String PreferencesPage2_lblXmlStmf_text;
    public static String PreferencesPage2_txtXmlStmf_toolTipText;
    public static String PreferencesPage2_grpOverrideCommandParameters_text;
    public static String PreferencesPage2_chkDisableReport_text;
    public static String PreferencesPage2_chkDisableReport_toolTipText;
    public static String PreferencesPage2_chkDisableXmlStmf_text;
    public static String PreferencesPage2_chkDisableXmlStmf_toolTipText;
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
    public static String PreferencesPage2_grpUIBehavior_text;
    public static String PreferencesPage2_chkShowResultView_toolTipText;
    public static String PreferencesPage2_chkShowResultView_text;
    public static String PreferencesPage2_grpWarnings_text;
    public static String PreferencesPage2_chkResetWarnings_text;
    public static String PreferencesPage2_chkResetWarnings_toolTipText;
    public static String PreferencesPage2_btnUploadLibrary_toolTipText;
    public static String PreferencesPage2_lblCaptureJobLog_text;
    public static String PreferencesPage2_cboCaptureJobLog_toolTipText;
    public static String PreferencesPage2_chkFormatJobLog_text;
    public static String PreferencesPage2_chkFormatJobLog_toolTipText;

    public static String Label_Host_name_colon;
    public static String Tooltip_Host_name;
    public static String Label_Signon_User_colon;
    public static String Tooltip_Signon_User;
    public static String Label_Password_colon;
    public static String Tooltip_Password;

    public static String Tooltip_Connection_name;
    public static String Label_FTP_port_number_colon;
    public static String Tooltip_FTP_port_number;
    public static String Label_UploadLibrary;
    public static String Tooltip_UploadLibrary;
    public static String Label_AspDeviceName;
    public static String Tooltip_AspDeviceName;
    public static String Label_UploadButton;
    public static String Tooltip_UploadButton;
    public static String Label_CloseButton;
    public static String Tooltip_CloseButton;

    public static String DialogTitle_Delete_Object;
    public static String Connected_to_host_A;
    public static String Could_not_connect_to_host_A;
    public static String Could_not_set_asp_device_name_to_A;
    public static String Checking_library_A_for_existence;
    public static String Library_A_does_already_exist;
    public static String Question_Do_you_want_to_delete_library_A;
    public static String Deleting_library_A;
    public static String Checking_file_B_in_library_A_for_existence;
    public static String File_B_in_library_A_does_already_exist;
    public static String Creating_save_file_B_in_library_A;
    public static String Could_not_create_save_file_B_in_library_A;
    public static String Sending_save_file_to_host_A;
    public static String Could_not_send_save_file_to_host_A;
    public static String Using_Ftp_port_number;
    public static String Restoring_library_A;
    public static String Could_not_restore_library_A;
    public static String Disconnected_from_host_A;
    public static String JobLog_Headline;

    public static String Question_Do_you_want_to_delete_object_A_B_type_C;
    public static String Deleting_object_A_B_of_type_C;

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
