/*******************************************************************************
 * Copyright (c) 2013-2020 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.upload;

import java.io.File;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400FTP;
import com.ibm.as400.access.AS400Message;
import com.ibm.as400.access.CommandCall;
import com.ibm.as400.access.FTP;
import com.ibm.as400.access.Job;
import com.ibm.as400.access.JobLog;
import com.ibm.as400.access.QueuedMessage;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.helpers.JobLogHelper;
import de.tools400.rpgunit.core.helpers.LibraryListHelper;
import de.tools400.rpgunit.core.helpers.LibraryListHelper.LibraryList;
import de.tools400.rpgunit.core.helpers.OS400Helper;
import de.tools400.rpgunit.core.helpers.OS400Release;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.dialog.SignOnDialog;
import de.tools400.rpgunit.core.utils.ExceptionHelper;

public class ProductLibraryUploader {

    private static final String REMOTE_WORK_LIBRARY = "QGPL"; //$NON-NLS-1$
    private static final String LOCAL_SAVE_FILE_FOLDER = "Server"; //$NON-NLS-1$
    private static final String SAVE_FILE_NAME = "RPGUNIT.SAVF"; //$NON-NLS-1$
    private static final String SAVED_LIBRARY = "RPGUNIT"; //$NON-NLS-1$
    private static final String REMOTE_LIBRARY_TEXT = "iRPGUnit"; //$NON-NLS-1$

    private static final int RECOMPILE_NOT_REQUIRED = 1;
    private static final int RECOMPILE_CANCELED = 2;
    private static final int RECOMPILE_CONFIRMED = 3;

    private Shell shell;
    private IBMiConnection iSeriesConnection;
    private String hostName;
    private int ftpPort;
    private String libraryName;
    private String aspDeviceName;

    private AS400 as400;
    private CommandCall commandCall;

    private QueuedMessage[] jobLog;
    private byte[] startingMessageKey;

    private StatusMessageReceiver statusMessageReceiver;

    public ProductLibraryUploader(Shell shell, IBMiConnection iSeriesConnection, int ftpPort, String libraryName, String aspDeviceName) {

        this.shell = shell;
        this.iSeriesConnection = iSeriesConnection;
        this.hostName = iSeriesConnection.getHostName();
        this.ftpPort = ftpPort;
        this.libraryName = libraryName;
        this.aspDeviceName = aspDeviceName;
    }

    public void setStatusMessageReceiver(StatusMessageReceiver statusMessageReceiver) {
        this.statusMessageReceiver = statusMessageReceiver;
    }

    public boolean run() {

        boolean isUploadedFine = false;

        try {

            if (!connect()) {
                return false;
            }

            String workLibrary = REMOTE_WORK_LIBRARY;
            String saveFileName = libraryName;

            if (!setASPDeviceName(aspDeviceName)) {
                setError(Messages.bind(Messages.Could_not_set_asp_device_name_to_A, aspDeviceName));
            } else {
                setStatus(Messages.bind(Messages.Checking_library_A_for_existence, libraryName));
                if (!checkLibraryPrecondition(libraryName, aspDeviceName)) {
                    setError(Messages.bind(Messages.Library_A_does_already_exist, libraryName));
                } else {
                    setStatus(Messages.bind(Messages.Checking_file_B_in_library_A_for_existence, new String[] { workLibrary, saveFileName }));
                    if (!checkSaveFilePrecondition(workLibrary, saveFileName)) {
                        setError(Messages.bind(Messages.File_B_in_library_A_does_already_exist, new String[] { workLibrary, saveFileName }));
                    } else {

                        setStatus(Messages.bind(Messages.Creating_save_file_B_in_library_A, new String[] { workLibrary, saveFileName }));
                        if (!createSaveFile(workLibrary, saveFileName, true)) {
                            setError(Messages.bind(Messages.Could_not_create_save_file_B_in_library_A, new String[] { workLibrary, saveFileName }));
                        } else {

                            try {

                                setStatus(Messages.bind(Messages.Sending_save_file_to_host_A, hostName));
                                setStatus(Messages.bind(Messages.Using_Ftp_port_number, new Integer(ftpPort)));
                                AS400FTP client = new AS400FTP(as400);

                                URL fileUrl = FileLocator.toFileURL(RPGUnitCorePlugin.getInstallURL());
                                File file = new File(fileUrl.getPath() + LOCAL_SAVE_FILE_FOLDER + File.separator + SAVE_FILE_NAME);
                                client.setPort(ftpPort);
                                client.setDataTransferType(FTP.BINARY);
                                if (client.connect()) {
                                    client.put(file, "/QSYS.LIB/" + workLibrary + ".LIB/" + saveFileName + ".FILE");
                                    client.disconnect();
                                }

                                setStatus(Messages.bind(Messages.Restoring_library_A, libraryName));
                                if (!restoreLibrary(workLibrary, saveFileName, libraryName, aspDeviceName)) {
                                    setError(Messages.bind(Messages.Could_not_restore_library_A, libraryName));
                                } else {

                                    LibraryList oldLibraryList = null;

                                    try {

                                        oldLibraryList = setLibraryList(as400, libraryName);

                                        int recompileRequiredStatus = getRecompileRequiredStatus(libraryName);
                                        if (recompileRequiredStatus == RECOMPILE_CANCELED) {
                                            setStatus(Messages.Operation_canceled_by_the_user);
                                            return false;
                                        }

                                        if (recompileRequiredStatus == RECOMPILE_CONFIRMED) {
                                            if (!recompileLibrary(as400, libraryName)) {
                                                isUploadedFine = false;
                                            } else {
                                                isUploadedFine = true;
                                            }
                                        } else {
                                            if (!updateLibrary(libraryName)) {
                                                MessageDialog.openError(shell, Messages.Warning, Messages.bind(
                                                    Messages.Library_RPGUNIT_has_been_restored_to_A_but_objects_could_not_be_updated_Try_to_run_command_UPDLIB_A_by_hand_and_check_the_job_log,
                                                    libraryName));
                                                isUploadedFine = false;
                                            } else {
                                                isUploadedFine = true;
                                            }
                                        }

                                        if (isUploadedFine) {
                                            setStatus(Messages.bind(Messages.Successfully_restored_iRPGUnit_library, libraryName));
                                        }

                                    } catch (Exception e) {
                                        setError(
                                            Messages.bind(Messages.Could_not_update_library_A_after_restore_Reason_B, libraryName, e.getStackTrace()),
                                            e);
                                        isUploadedFine = false;
                                    } finally {
                                        try {
                                            restoreLibraryList(as400, oldLibraryList);
                                        } catch (Exception e) {
                                            setError(Messages.bind(Messages.Could_not_restore_library_list_Reason_A, e.getLocalizedMessage()), e);
                                            isUploadedFine = false;
                                        }

                                    }
                                }

                            } catch (Exception e) {
                                setError(Messages.bind(Messages.Could_not_send_save_file_to_host_A_Reason_B, hostName, e.getLocalizedMessage()), e);
                                isUploadedFine = false;
                            } finally {
                                setStatus(Messages.bind(Messages.Deleting_object_A_B_of_type_C, new String[] { workLibrary, saveFileName, "*FILE" }));
                                deleteSaveFile(workLibrary, saveFileName, true);
                            }

                        }
                    }
                }
            }

        } finally {
            disconnect();
        }

        return isUploadedFine;
    }

    private LibraryList setLibraryList(AS400 system, String libraryName) throws Exception {

        LibraryList oldLibraryList = LibraryListHelper.getLibraryList(system);

        setStatus(Messages.bind(Messages.Retrieved_current_library_list_A, oldLibraryList.toString()));

        setStatus(Messages.bind(Messages.Changing_library_list_to_A, oldLibraryList));

        LibraryListHelper.changeLibraryList(as400, libraryName, "QGPL"); //$NON-NLS-1$

        return oldLibraryList;
    }

    private void restoreLibraryList(AS400 system, LibraryList oldLibraryList) throws Exception {

        setStatus(Messages.bind(Messages.Restoring_library_list_to_A, oldLibraryList.toString()));

        LibraryListHelper.changeLibraryList(system, oldLibraryList.getCurrentLibrary(), oldLibraryList.getUserLibraryList());
    }

    public QueuedMessage[] getJobLog() {

        if (jobLog == null) {
            jobLog = new QueuedMessage[0];
        }

        return jobLog;
    }

    private boolean connect() {

        startingMessageKey = null;

        SignOnDialog signOnDialog = new SignOnDialog(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(), hostName,
            iSeriesConnection.getUserID());
        if (signOnDialog.open() == Dialog.OK) {
            as400 = signOnDialog.getAS400();
            if (as400 != null) {
                try {
                    as400.connectService(AS400.COMMAND);
                    commandCall = new CommandCall(as400);
                    if (commandCall != null) {
                        setStatus(Messages.bind(Messages.Connected_to_host_A, hostName));
                        setStatus(Messages.Server_job_colon + " " + commandCall.getServerJob().toString());
                        startingMessageKey = JobLogHelper.getNewestMessageKey(commandCall.getServerJob());
                        return true;
                    } else {
                        setError(Messages.bind(Messages.Could_not_connect_to_host_A_Reason_B, hostName, "unknown"));
                    }
                } catch (Exception e) {
                    setError(Messages.bind(Messages.Could_not_connect_to_host_A_Reason_B, hostName, e.getLocalizedMessage()), e);
                }
            }
        }
        return false;
    }

    private void disconnect() {

        if (as400 != null && as400.isConnected()) {
            try {
                jobLog = JobLogHelper.getJobLog(commandCall.getServerJob(), startingMessageKey);
            } catch (Exception e) {
                jobLog = null;
                setError(Messages.bind(Messages.Could_not_load_the_job_log_Reason_A, e.getLocalizedMessage()), e);
            }
            as400.disconnectAllServices();
            setStatus(Messages.bind(Messages.Disconnected_from_host_A, hostName));
        }
    }

    private boolean setASPDeviceName(String aspDeviceName) {

        if (!isASPDeviceSpecified(aspDeviceName)) {
            return true;
        }

        String cpfMsg = executeCommand("SETASPGRP ASPGRP(" + aspDeviceName + ")", true);
        if (cpfMsg.equals("")) {
            return true;
        }

        return false;
    }

    private boolean checkLibraryPrecondition(String libraryName, String aspDeviceName) {

        while (libraryExists(libraryName)) {
            if (!MessageDialog.openQuestion(shell, Messages.DialogTitle_Delete_Object,
                Messages.bind(Messages.Library_A_does_already_exist, libraryName) + "\n\n"
                    + Messages.bind(Messages.Question_Do_you_want_to_delete_library_A, libraryName))) {
                return false;
            }
            setStatus(Messages.bind(Messages.Deleting_library_A, libraryName));
            deleteLibrary(libraryName, aspDeviceName, true);
        }

        return true;
    }

    private boolean libraryExists(String libraryName) {

        if (!checkLibrary(as400, libraryName)) {
            return false;
        }

        return true;
    }

    private boolean deleteLibrary(String libraryName, String aspDeviceName, boolean logErrors) {

        String cpfMsg;

        cpfMsg = executeCommand(produceDeleteLibraryCommand(libraryName, aspDeviceName), logErrors);
        if (!cpfMsg.equals("")) {
            return false;
        }

        return true;
    }

    private boolean checkSaveFilePrecondition(String workLibrary, String saveFileName) {

        while (saveFileExists(workLibrary, saveFileName)) {
            if (!MessageDialog.openQuestion(shell, Messages.DialogTitle_Delete_Object,
                Messages.bind(Messages.File_B_in_library_A_does_already_exist, new String[] { workLibrary, saveFileName }) + "\n\n" + Messages
                    .bind(Messages.Question_Do_you_want_to_delete_object_A_B_type_C, new String[] { workLibrary, saveFileName, "*FILE" }))) {
                return false;
            }
            setStatus(Messages.bind(Messages.Deleting_object_A_B_of_type_C, new String[] { workLibrary, saveFileName, "*FILE" }));
            deleteSaveFile(workLibrary, saveFileName, true);
        }

        return true;
    }

    private boolean saveFileExists(String workLibrary, String saveFileName) {

        if (!checkFile(as400, workLibrary, saveFileName)) {
            return false;
        }

        return true;
    }

    private boolean deleteSaveFile(String workLibrary, String saveFileName, boolean logErrors) {

        if (!executeCommand("DLTF FILE(" + workLibrary + "/" + saveFileName + ")", logErrors).equals("")) {
            return false;
        }

        return true;
    }

    private boolean createSaveFile(String workLibrary, String saveFileName, boolean logErrors) {

        if (!executeCommand("CRTSAVF FILE(" + workLibrary + "/" + saveFileName + ") TEXT('" + REMOTE_LIBRARY_TEXT + "')", logErrors).equals("")) {
            return false;
        }

        return true;
    }

    private boolean restoreLibrary(String workLibrary, String saveFileName, String libraryName, String aspDeviceName) throws Exception {

        AS400 system = commandCall.getSystem();
        Job serverJob = commandCall.getServerJob();
        JobLog jobLog = new JobLog(system, serverJob.getName(), serverJob.getUser(), serverJob.getNumber());
        jobLog.setListDirection(false);

        Date startingMessageDate = null;
        QueuedMessage[] startingMessages = jobLog.getMessages(0, 1);
        if (startingMessages != null) {
            startingMessageDate = startingMessages[0].getDate().getTime();
        }

        String cpfMsg = executeCommand(produceRestoreLibraryCommand(workLibrary, saveFileName, libraryName, aspDeviceName), true);
        if (!cpfMsg.equals("")) {
            if (cpfMsg.equals("CPF3773")) {

                List<QueuedMessage> countNotRestored = new LinkedList<QueuedMessage>();
                List<QueuedMessage> countIgnored = new LinkedList<QueuedMessage>();

                QueuedMessage[] messages;
                final int chunkSize = 50;
                int offset = 0;

                jobLog = new JobLog(system, serverJob.getName(), serverJob.getUser(), serverJob.getNumber());
                jobLog.setListDirection(false);
                while ((messages = jobLog.getMessages(offset, chunkSize)) != null && messages.length > 0 && startingMessageDate != null) {
                    for (QueuedMessage message : messages) {

                        // CPF3756 - &2 &1 not restored to &3.
                        if ("CPF3756".equals(message.getID())) {
                            countNotRestored.add(message);
                        }

                        // CPF7086 - Cannot restore journal &1 to library &4.
                        // CPF707F - Cannot restore receiver &1 into library &2.
                        if ("CPF7086".equals(message.getID()) || "CPF707F".equals(message.getID())) {
                            countIgnored.add(message);
                        }

                        if (message.getDate().getTime().compareTo(startingMessageDate) < 0) {
                            startingMessageDate = null;
                            break;
                        }
                    }
                    offset = offset + chunkSize;
                }

                for (int i = countNotRestored.size() - 1; i >= 0; i--) {
                    QueuedMessage notRestoredMessage = countNotRestored.get(i);
                    setStatus(countNotRestored.get(i) + ": " + notRestoredMessage.getText());
                }
            }
            return false;
        }

        return true;
    }

    private boolean recompileLibrary(AS400 system, String libraryName) throws Exception {

        String command;

        String targetRelease = OS400Helper.getRelease(as400);
        setStatus(Messages.bind(Messages.Recompiling_objects_of_library_A_for_release_B, libraryName, targetRelease));
        command = String.format("STRREXPRC SRCMBR(A_INSTALL) SRCFILE(%s/QBUILD) PARM('INSTALL %s NONE %s DISABLE_ASSERT_EQUAL')", libraryName,
            libraryName, targetRelease);
        if (!executeCommand(command, true).equals("")) {
            setError(Messages.bind(Messages.Failed_calling_B_INSTALL_in_library_A, libraryName, "QBUILD"));
            return false;
        }

        boolean isError = false;

        command = "CHGCMDDFT CMD(" + libraryName + "/RUCRTRPG) NEWDFT('DEFINE(DISABLE_ASSERT_EQUAL)')";
        if (!executeCommand(command, true).equals("")) {
            setError(Messages.bind(Messages.Could_not_change_command_default_of_command_A, "RUCRTRPG"));
            isError = true;
        }

        command = "CHGCMDDFT CMD(" + libraryName + "/RUCRTCBL) NEWDFT('DEFINE(DISABLE_ASSERT_EQUAL)')";
        if (!executeCommand(command, true).equals("")) {
            setError(Messages.bind(Messages.Could_not_change_command_default_of_command_A, "RUCRTCBL"));
            isError = true;
        }

        return !isError;
    }

    private boolean updateLibrary(String libraryName) {

        if (SAVED_LIBRARY.equals(libraryName)) {
            return true;
        }

        setStatus(Messages.bind(Messages.Updating_objects_of_library_A, libraryName));

        // CHGCMD CMD(RPGUNIT42/UPDLIB) PGM(*REXX) REXSRCFILE(RPGUNIT42/QBUILD)

        String command = String.format("CHGCMD CMD(%s/UPDLIB) PGM(*REXX) REXSRCFILE(%s/QBUILD) HLPPNLGRP(%s/UPDLIBHLP)", libraryName, libraryName,
            libraryName);
        if (!executeCommand(command, true).equals("")) {
            return false;
        }

        if (!executeCommand(libraryName + "/UPDLIB LIB(" + libraryName + ")", true).equals("")) {
            return false;
        }

        return true;
    }

    private int getRecompileRequiredStatus(String libraryName) throws Exception {

        String currentOS400Release = OS400Helper.getRelease(as400);
        String currentOS400ReleaseShort = OS400Helper.getReleaseShort(as400);
        String pluginVersion = RPGUnitCorePlugin.getDefault().getVersion();
        String requiredOS400Release = RPGUnitCorePlugin.getMinOS400Release();

        int requiredStatus;
        if (OS400Release.V7R4M0.compareTo(currentOS400Release) < 0) {
            // 7.5 or higher
            requiredStatus = RECOMPILE_NOT_REQUIRED;
        } else if (OS400Release.V7R4M0.compareTo(currentOS400Release) == 0) {
            if (testPTFStatus(as400, "SI71537", "SI71536")) {
                requiredStatus = RECOMPILE_NOT_REQUIRED;
            } else {
                String ptf1 = Messages.bind(Messages.PTF_information_2, "ILE RPG runtime: SI71537");
                String ptf2 = Messages.bind(Messages.PTF_information_2, "ILE RPG compiler: SI71536");
                String message = Messages.bind(Messages.PTF_information_1,
                    new String[] { pluginVersion, requiredOS400Release, currentOS400ReleaseShort, ptf1 + ptf2 });
                if (MessageDialog.openConfirm(shell, "", message)) {
                    requiredStatus = RECOMPILE_CONFIRMED;
                } else {
                    requiredStatus = RECOMPILE_CANCELED;
                }
            }
        } else if (OS400Release.V7R3M0.compareTo(currentOS400Release) == 0) {
            if (testPTFStatus(as400, "SI71535", "SI71534")) {
                requiredStatus = RECOMPILE_NOT_REQUIRED;
            } else {
                String ptf1 = Messages.bind(Messages.PTF_information_2, "ILE RPG runtime: SI71535");
                String ptf2 = Messages.bind(Messages.PTF_information_2, "ILE RPG compiler: SI71534");
                String message = Messages.bind(Messages.PTF_information_1,
                    new String[] { pluginVersion, requiredOS400Release, currentOS400ReleaseShort, ptf1 + ptf2 });
                if (MessageDialog.openConfirm(shell, "", message)) {
                    requiredStatus = RECOMPILE_CONFIRMED;
                } else {
                    requiredStatus = RECOMPILE_CANCELED;
                }
            }
        } else {
            requiredStatus = RECOMPILE_NOT_REQUIRED;
        }

        return requiredStatus;
    }

    private boolean testPTFStatus(AS400 system, String... ptfs) {

        int count = 0;

        try {

            Connection jdbcConnection = iSeriesConnection.getJDBCConnection(";prompt=false;big decimal=false", false);

            PreparedStatement preparedStatementSelect = null;
            ResultSet resultSet = null;
            try {

                StringBuilder buffer = new StringBuilder();

                for (int i = 0; i < ptfs.length; i++) {
                    if (i > 0) {
                        buffer.append(", ");
                    }
                    buffer.append("'");
                    buffer.append(ptfs[i]);
                    buffer.append("'");
                }

                //@formatter:off
                String sqlStatement = 
                    "SELECT PTF_IDENTIFIER, PTF_LOADED_STATUS FROM QSYS2.PTF_INFO " +
                       "WHERE PTF_IDENTIFIER IN (" + buffer.toString() + ") AND (" + 
                             "PTF_LOADED_STATUS = 'APPLIED' OR " + 
                             "PTF_LOADED_STATUS = 'PERMANENTLY_APPLIED' OR " + 
                             "PTF_LOADED_STATUS = 'SUPERSEEDED')";
                //@formatter:on

                preparedStatementSelect = jdbcConnection.prepareStatement(sqlStatement, ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_READ_ONLY);

                // preparedStatementSelect.setString(1, buffer.toString());
                resultSet = preparedStatementSelect.executeQuery();

                resultSet.beforeFirst();
                while (resultSet.next()) {
                    count++;
                }

            } catch (SQLException e) {
                setError(Messages.bind(Messages.Could_not_get_PTF_status_Reason_A, e.getLocalizedMessage()), e);
            }
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e1) {
                }
            }
            if (preparedStatementSelect != null) {
                try {
                    preparedStatementSelect.close();
                } catch (SQLException e1) {
                }
            }

        } catch (SQLException e) {
            setError(Messages.bind(Messages.Could_not_get_PTF_status_Reason_A, e.getLocalizedMessage()), e);
        }

        if (count > ptfs.length) {
            return true;
        }

        return false;
    }

    private boolean checkFile(AS400 system, String library, String fileName) {
        return checkObject(library, fileName, "*FILE");
    }

    private boolean checkLibrary(AS400 system, String library) {
        return checkObject("QSYS", library, "*LIB");
    }

    private boolean checkObject(String libraryName, String objectName, String objectType) {
        return checkObject(libraryName, objectName, null, objectType);
    }

    private boolean checkObject(String libraryName, String objectName, String memberName, String objectType) {

        StringBuilder command = new StringBuilder();
        command.append("CHKOBJ OBJ("); //$NON-NLS-1$
        command.append(libraryName);
        command.append("/"); //$NON-NLS-1$
        command.append(objectName);
        command.append(") OBJTYPE("); //$NON-NLS-1$
        command.append(objectType);
        command.append(")"); //$NON-NLS-1$

        if (!StringHelper.isNullOrEmpty(memberName)) {
            command.append(" MBR("); //$NON-NLS-1$
            command.append(memberName);
            command.append(")"); //$NON-NLS-1$
        }

        try {
            String message = executeCommand(command.toString(), false);
            if (StringHelper.isNullOrEmpty(message)) {
                return true;
            }
        } catch (Exception e) {
            setError(ExceptionHelper.getLocalizedMessage(e), e);
        }

        return false;
    }

    private String executeCommand(String command, boolean logError) {

        try {
            commandCall.run(command);
            AS400Message[] messageList = commandCall.getMessageList();
            if (messageList.length > 0) {
                AS400Message escapeMessage = null;
                for (int idx = 0; idx < messageList.length; idx++) {
                    if (messageList[idx].getType() == AS400Message.ESCAPE) {
                        escapeMessage = messageList[idx];
                    }
                }
                if (escapeMessage != null) {
                    if (logError) {
                        for (int idx = 0; idx < messageList.length; idx++) {
                            setStatus(messageList[idx].getID() + ": " + messageList[idx].getText());
                        }
                    }
                    return escapeMessage.getID();
                }
            }
            return "";
        } catch (Exception e) {
            return "CPF0000";
        }
    }

    private String produceRestoreLibraryCommand(String workLibrary, String saveFileName, String libraryName, String aspDeviceName) {

        String command = "RSTLIB SAVLIB(" + SAVED_LIBRARY + ") DEV(*SAVF) SAVF(" + workLibrary + "/" + saveFileName + ") RSTLIB(" + libraryName + ")";
        if (isASPDeviceSpecified(aspDeviceName)) {
            command += " RSTASPDEV(" + aspDeviceName + ")";
        }

        return command;
    }

    private String produceDeleteLibraryCommand(String productLibrary, String aspDevice) {

        String command = "DLTLIB LIB(" + productLibrary + ")";
        if (isASPDeviceSpecified(aspDevice)) {
            command += " ASPDEV(*)";
        }

        return command;
    }

    private boolean isASPDeviceSpecified(String aspDevice) {

        if (StringHelper.isNullOrEmpty(aspDevice)) {
            return false;
        }

        if (Preferences.getInstance().getDefaultAspDeviceName().equals(aspDevice)) {
            return false;
        }

        return true;
    }

    private void setStatus(String message) {
        statusMessageReceiver.setStatus(message);
    }

    private void setError(String message, Exception e) {
        setError(message);
        RPGUnitCorePlugin.logError(message, e);
    }

    private void setError(String message) {
        statusMessageReceiver.setStatus(Messages.ERROR + ": " + message);
    }
}
