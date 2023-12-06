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

        boolean isUploadedFine = false;;

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
                                    if (!updateLibrary(libraryName)){
                                        MessageDialog.openError(shell, Messages.Warning, Messages.bind(Messages.Library_RPGUNIT_has_been_restored_to_A_but_objects_could_not_be_updated_Try_to_run_command_UPDLIB_A_by_hand_and_check_the_job_log, libraryName));
                                        isUploadedFine = false;
                                    } else {
                                        setStatus(Messages.bind(Messages.Successfully_restored_iRPGUnit_library, libraryName));
                                        isUploadedFine = true;
                                    }
                                }

                            } catch (Exception e) {
                                setError(Messages.bind(Messages.Could_not_send_save_file_to_host_A, hostName), e);
                                isUploadedFine = false;
                            } finally {

                                setStatus(Messages.bind(Messages.Deleting_object_A_B_of_type_C, new String[] { workLibrary, saveFileName, "*FILE" }));
                                deleteSaveFile(workLibrary, saveFileName, true);
                            }

                        }
                    }
                }
            }

            return isUploadedFine;

        } finally {
            disconnect();
        }
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
                        setError(Messages.bind(Messages.Could_not_connect_to_host_A, hostName));
                        return false;
                    }
                } catch (Exception e) {
                    setError(Messages.bind(Messages.Could_not_connect_to_host_A, hostName), e);
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
                RPGUnitCorePlugin.logError("Failed loading job log.", e);
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
                final int chunkSize = 20;
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

    private boolean updateLibrary(String libraryName) {

        if (SAVED_LIBRARY.equals(libraryName)) {
            return true;
        }

        setStatus(Messages.bind(Messages.Updating_objects_of_library_A, libraryName));

        if (!executeCommand(libraryName + "/UPDLIB LIB(" + libraryName + ")", true).equals("")) {
            return false;
        }
        
        return true;
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
