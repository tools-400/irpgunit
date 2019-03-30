/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.preferences;

import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.handler.Command;
import de.tools400.rpgunit.core.handler.UploadRPGUnitLibraryHandler;
import de.tools400.rpgunit.core.model.ibmi.I5ObjectName;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.swt.widgets.UpperCaseOnlyVerifier;
import de.tools400.rpgunit.core.utils.ExceptionHelper;

public class PreferencesPage extends PreferencePage implements IWorkbenchPreferencePage {

    private static final int COLUMN_1_WIDTH = 170;

    private static final int COLUMN_3_WIDTH = 100;

    private static final int INPUT_FIELD_LENGTH = 90;

    private Combo cboRunOrder;

    private Combo cboLibraryList;

    private Text txtJobDesc;

    private Text txtJobDescLib;

    private Combo cboReportDetail;

    private Combo cboCreateReport;

    private Combo cboReclaimResources;

    private Button chkDisableReport;

    private Text txtProductLibrary;

    private Combo cboCheckTestSuite;

    private Button chkNewConnection;

    private Button chkPosToLineOnOpen;

    private Combo cboCaptureJobLog;

    private Button chkShowResultView;

    private Button chkWarnMessages;

    /**
     * Create the preference page.
     */
    public PreferencesPage() {
    }

    /**
     * Create contents of the preference page.
     * 
     * @param parent
     */
    @Override
    public Control createContents(Composite parent) {

        setTitle("iRPGUnit - " + RPGUnitCorePlugin.getDefault().getVersion()); //$NON-NLS-1$

        Composite mainPanel = new Composite(parent, SWT.NULL);
        GridLayout gl_mainPanel = new GridLayout(1, true);
        gl_mainPanel.verticalSpacing = 10;
        mainPanel.setLayout(gl_mainPanel);

        createGroupCommandParameters(mainPanel);
        createGroupOverrideCommandParameters(mainPanel);
        createGroupRuntimeParameters(mainPanel);
        createGroupDebugParameters(mainPanel);
        createGroupUIBehavior(mainPanel);
        createGroupWarningMessages(mainPanel);

        initializeValues();

        updateControlsOnEnterPage();

        return mainPanel;
    }

    private void createGroupCommandParameters(Composite mainPanel) {

        Group grpCommandParameters = new Group(mainPanel, SWT.NULL);
        grpCommandParameters.setText(Messages.PreferencesPage2_grpCommandParameters_text);
        GridLayout gl_grpCommandParameters = new GridLayout(3, false);
        grpCommandParameters.setLayout(gl_grpCommandParameters);
        GridData gd_grpCommandParameters = new GridData(SWT.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false);
        grpCommandParameters.setLayoutData(gd_grpCommandParameters);

        Label lblRunOrder = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblRunOrder = new GridData(SWT.LEFT, SWT.CENTER, false, true, 1, 1);
        gd_lblRunOrder.widthHint = COLUMN_1_WIDTH;
        lblRunOrder.setLayoutData(gd_lblRunOrder);
        lblRunOrder.setText(Messages.PreferencesPage2_lblRunOrder_text);

        cboRunOrder = new Combo(grpCommandParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboRunOrder.setItems(getPreferences().getRunOrderItems());
        cboRunOrder.setToolTipText(Messages.PreferencesPage2_cboRunOrder_toolTipText);
        cboRunOrder.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(grpCommandParameters, SWT.NONE);

        Label lblLibraryList = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblLibraryList = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblLibraryList.widthHint = COLUMN_1_WIDTH;
        lblLibraryList.setLayoutData(gd_lblLibraryList);
        lblLibraryList.setText(Messages.PreferencesPage2_lblLibraryList_text);

        cboLibraryList = new Combo(grpCommandParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboLibraryList.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                String tLibraryListValue = cboLibraryList.getText();
                updateJobDescriptionControlsEnablement(tLibraryListValue);
            }
        });
        cboLibraryList.setItems(getPreferences().getLibraryListItems());
        cboLibraryList.setToolTipText(Messages.PreferencesPage2_cboLibraryList_toolTipText);
        cboLibraryList.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(grpCommandParameters, SWT.NONE);

        Label lblJobDescription = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblJobDescription = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblJobDescription.widthHint = COLUMN_1_WIDTH;
        lblJobDescription.setLayoutData(gd_lblJobDescription);
        lblJobDescription.setText(Messages.PreferencesPage2_lblJobDescription_text);

        txtJobDesc = new Text(grpCommandParameters, SWT.BORDER);
        txtJobDesc.addVerifyListener(new UpperCaseOnlyVerifier());
        txtJobDesc.addModifyListener(new ModifyListener() {
            @Override
            public void modifyText(ModifyEvent arg0) {
                String tJobDescriptionName = ((Text)arg0.widget).getText();
                updateJobDescriptionLibraryControlValueAndEnablement(tJobDescriptionName);
            }
        });
        txtJobDesc.setToolTipText(Messages.PreferencesPage2_lblJobDescription_toolTipText);
        GridData gd_txtJobDesc = new GridData(SWT.LEFT, SWT.CENTER, true, false, 1, 1);
        gd_txtJobDesc.minimumWidth = INPUT_FIELD_LENGTH;
        gd_txtJobDesc.widthHint = INPUT_FIELD_LENGTH;
        txtJobDesc.setLayoutData(gd_txtJobDesc);

        Label lblNewLabel = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblNewLabel = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblNewLabel.widthHint = COLUMN_3_WIDTH;
        lblNewLabel.setLayoutData(gd_lblNewLabel);
        lblNewLabel.setText(Messages.PreferencesPage2_lblJobDescription_choice);

        Label lblJobDescriptionLibrary = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblJobDescriptionLibrary = new GridData(SWT.LEFT, SWT.CENTER, false, true, 1, 1);
        gd_lblJobDescriptionLibrary.widthHint = COLUMN_1_WIDTH;
        lblJobDescriptionLibrary.setLayoutData(gd_lblJobDescriptionLibrary);
        lblJobDescriptionLibrary.setText(Messages.PreferencesPage2_lblJobDescriptionLibrary_text);

        txtJobDescLib = new Text(grpCommandParameters, SWT.BORDER);
        txtJobDescLib.addVerifyListener(new UpperCaseOnlyVerifier());
        txtJobDescLib.setToolTipText(Messages.PreferencesPage2_lblJobDescriptionLibrary_toolTipText);
        GridData gd_txtJobDescLib = new GridData(SWT.LEFT, SWT.CENTER, true, false, 1, 1);
        gd_txtJobDescLib.minimumWidth = INPUT_FIELD_LENGTH;
        gd_txtJobDescLib.widthHint = INPUT_FIELD_LENGTH;
        txtJobDescLib.setLayoutData(gd_txtJobDescLib);

        Label lblNamelibl = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblNamelibl = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblNamelibl.widthHint = COLUMN_3_WIDTH;
        lblNamelibl.setLayoutData(gd_lblNamelibl);
        lblNamelibl.setText(Messages.PreferencesPage2_lblJobDescriptionLibrary_choice);

        Label lblReportDetail = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblReportDetail = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblReportDetail.widthHint = COLUMN_1_WIDTH;
        lblReportDetail.setLayoutData(gd_lblReportDetail);
        lblReportDetail.setText(Messages.PreferencesPage2_lblReportDetail_text);

        cboReportDetail = new Combo(grpCommandParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboReportDetail.setItems(getPreferences().getDetailItems());
        cboReportDetail.setToolTipText(Messages.PreferencesPage2_cboReportDetail_toolTipText);
        cboReportDetail.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(grpCommandParameters, SWT.NONE);

        Label lblCreateReport = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblCreateReport = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblCreateReport.widthHint = COLUMN_1_WIDTH;
        lblCreateReport.setLayoutData(gd_lblCreateReport);
        lblCreateReport.setText(Messages.PreferencesPage2_lblCreateReport_text);

        cboCreateReport = new Combo(grpCommandParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboCreateReport.setItems(getPreferences().getOutputItems());
        cboCreateReport.setToolTipText(Messages.PreferencesPage2_cboCreateReport_toolTipText);
        cboCreateReport.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(grpCommandParameters, SWT.NONE);

        Label lblReclaimResources = new Label(grpCommandParameters, SWT.NONE);
        GridData gd_lblReclaimResources = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lblReclaimResources.widthHint = COLUMN_1_WIDTH;
        lblReclaimResources.setLayoutData(gd_lblReclaimResources);
        lblReclaimResources.setText(Messages.PreferencesPage2_lblReclaimResources_text);

        cboReclaimResources = new Combo(grpCommandParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboReclaimResources.setItems(getPreferences().getReclaimResourcesItems());
        cboReclaimResources.setToolTipText(Messages.PreferencesPage2_cboReclaimResources_toolTipText);
        cboReclaimResources.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(grpCommandParameters, SWT.NONE);
    }

    private void createGroupOverrideCommandParameters(Composite mainPanel) {

        Group grpOverrideCommandParameters = new Group(mainPanel, SWT.NONE);
        grpOverrideCommandParameters.setText(Messages.PreferencesPage2_grpOverrideCommandParameters_text);
        GridLayout gl_grpOverrideCommandParameters = new GridLayout(1, false);
        grpOverrideCommandParameters.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));
        grpOverrideCommandParameters.setLayout(gl_grpOverrideCommandParameters);

        chkDisableReport = new Button(grpOverrideCommandParameters, SWT.CHECK);
        chkDisableReport.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                updateReportControlsEnablement();
            }
        });
        chkDisableReport.setToolTipText(Messages.PreferencesPage2_chkDisableReport_toolTipText);
        chkDisableReport.setText(Messages.PreferencesPage2_chkDisableReport_text);
    }

    private void createGroupRuntimeParameters(Composite mainPanel) {

        Group grpRuntimeParameters = new Group(mainPanel, SWT.NONE);
        grpRuntimeParameters.setText(Messages.PreferencesPage2_grpRuntime_text);
        GridLayout gl_grpRuntime = new GridLayout(4, false);
        grpRuntimeParameters.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));
        grpRuntimeParameters.setLayout(gl_grpRuntime);

        Label lblProductLibrary = new Label(grpRuntimeParameters, SWT.NONE);
        GridData gd_lblProductLibrary = new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1);
        gd_lblProductLibrary.widthHint = COLUMN_1_WIDTH;
        lblProductLibrary.setLayoutData(gd_lblProductLibrary);
        lblProductLibrary.setText(Messages.PreferencesPage2_lblProductLibrary_text);

        txtProductLibrary = new Text(grpRuntimeParameters, SWT.BORDER);
        txtProductLibrary.addVerifyListener(new UpperCaseOnlyVerifier());
        txtProductLibrary.setToolTipText(Messages.PreferencesPage2_txtProductLibrary_toolTipText);
        GridData gd_txtProductLibrary = new GridData(SWT.LEFT, SWT.TOP, false, false, 1, 1);
        gd_txtProductLibrary.minimumWidth = INPUT_FIELD_LENGTH;
        gd_txtProductLibrary.widthHint = INPUT_FIELD_LENGTH;
        txtProductLibrary.setLayoutData(gd_txtProductLibrary);

        Button btnUploadLibrary = new Button(grpRuntimeParameters, SWT.PUSH);
        btnUploadLibrary.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TRANSFER_LIBRARY));
        btnUploadLibrary.setToolTipText(Messages.PreferencesPage2_btnUploadLibrary_toolTipText);
        btnUploadLibrary.setLayoutData(new GridData(GridData.VERTICAL_ALIGN_BEGINNING));
        btnUploadLibrary.addSelectionListener(new SelectionListener() {

            @Override
            public void widgetSelected(SelectionEvent arg0) {
                try {
                    UploadRPGUnitLibraryHandler handler = new UploadRPGUnitLibraryHandler();
                    handler.execute(txtProductLibrary.getText());
                } catch (Exception e) {
                    MessageDialog.openError(getShell(), Messages.ERROR, ExceptionHelper.getLocalizedMessage(e));
                }
            }

            @Override
            public void widgetDefaultSelected(SelectionEvent arg0) {
            }
        });

        Label lblProductLibraryChoice = new Label(grpRuntimeParameters, SWT.NONE);
        GridData gd_lbllibl = new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1);
        gd_lbllibl.widthHint = COLUMN_3_WIDTH;
        lblProductLibraryChoice.setLayoutData(gd_lbllibl);
        lblProductLibraryChoice.setText(Messages.PreferencesPage2_lblProductLibrary_choice);

        Label lblCheckTestSuite = new Label(grpRuntimeParameters, SWT.NONE);
        GridData gd_lblCheckTestSuite = new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1);
        gd_lblCheckTestSuite.widthHint = COLUMN_1_WIDTH;
        lblCheckTestSuite.setLayoutData(gd_lblCheckTestSuite);
        lblCheckTestSuite.setText(Messages.PreferencesPage2_lblCheckTestSuite_text);

        cboCheckTestSuite = new Combo(grpRuntimeParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboCheckTestSuite.setItems(getPreferences().getCheckTestSuiteItems());
        cboCheckTestSuite.setToolTipText(Messages.PreferencesPage2_cboCheckTestSuite_toolTipText);
        cboCheckTestSuite.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 2, 1));
    }

    private void createGroupDebugParameters(Composite mainPanel) {

        Group grpDebugParameters = new Group(mainPanel, SWT.NONE);
        grpDebugParameters.setText(Messages.PreferencesPage2_grpDebugParameters_text);
        grpDebugParameters.setLayout(new GridLayout(2, false));
        grpDebugParameters.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));

        chkNewConnection = new Button(grpDebugParameters, SWT.CHECK);
        chkNewConnection.setLayoutData(new GridData(GridData.BEGINNING, GridData.BEGINNING, false, false, 2, 1));
        chkNewConnection.setToolTipText(Messages.PreferencesPage2_chkNewConnection_toolTipText);
        chkNewConnection.setText(Messages.PreferencesPage2_chkNewConnection_text);

        chkPosToLineOnOpen = new Button(grpDebugParameters, SWT.CHECK);
        chkPosToLineOnOpen.setLayoutData(new GridData(GridData.BEGINNING, GridData.BEGINNING, false, false, 2, 1));
        chkPosToLineOnOpen.setToolTipText(Messages.PreferencesPage2_chkPosToLineOnOpen_toolTipText);
        chkPosToLineOnOpen.setText(Messages.PreferencesPage2_chkPosToLineOnOpen_text);

        Label lblCaptureJobLog = new Label(grpDebugParameters, SWT.NONE);
        lblCaptureJobLog.setText(Messages.PreferencesPage2_lblCaptureJobLog_text);
        lblCaptureJobLog.setToolTipText(Messages.PreferencesPage2_cboCaptureJobLog_toolTipText);

        cboCaptureJobLog = new Combo(grpDebugParameters, SWT.DROP_DOWN | SWT.READ_ONLY);
        cboCaptureJobLog.setItems(getPreferences().getCaptureJoblogItems());
        cboCaptureJobLog.setToolTipText(Messages.PreferencesPage2_cboCaptureJobLog_toolTipText);

    }

    private void createGroupUIBehavior(Composite mainPanel) {

        Group grpUIBehavior = new Group(mainPanel, SWT.NONE);
        grpUIBehavior.setText(Messages.PreferencesPage2_grpUIBehavior_text);
        GridLayout gl_grpUIBehavior = new GridLayout(1, false);
        grpUIBehavior.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));
        grpUIBehavior.setLayout(gl_grpUIBehavior);

        chkShowResultView = new Button(grpUIBehavior, SWT.CHECK);
        chkShowResultView.setToolTipText(Messages.PreferencesPage2_chkShowResultView_toolTipText);
        chkShowResultView.setText(Messages.PreferencesPage2_chkShowResultView_text);
    }

    private void createGroupWarningMessages(Composite mainPanel) {

        Group grpWarningMessages = new Group(mainPanel, SWT.NONE);
        grpWarningMessages.setText(Messages.PreferencesPage2_grpWarnings_text);
        GridLayout gl_grpWarningMessages = new GridLayout(1, false);
        grpWarningMessages.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));
        grpWarningMessages.setLayout(gl_grpWarningMessages);

        chkWarnMessages = new Button(grpWarningMessages, SWT.CHECK);
        chkWarnMessages.setToolTipText(Messages.PreferencesPage2_chkResetWarnings_toolTipText);
        chkWarnMessages.setText(Messages.PreferencesPage2_chkResetWarnings_text);
    }

    /**
     * Initialize the preference page.
     */
    @Override
    public void init(IWorkbench workbench) {
        // Initialize the preference page
        return;
    }

    private void initializeValues() {
        cboRunOrder.setText(getPreferences().getRunOrder());
        cboLibraryList.setText(getPreferences().getLibraryList()[0]);
        txtJobDesc.setText(getPreferences().getJobDescription().getName());
        txtJobDescLib.setText(getPreferences().getJobDescription().getLibrary());
        chkDisableReport.setSelection(getPreferences().isReportDisabled());
        cboReportDetail.setText(getPreferences().getDetail());
        cboCreateReport.setText(getPreferences().getOutput());
        cboReclaimResources.setText(getPreferences().getReclaimResources());
        txtProductLibrary.setText(getPreferences().getProductLibrary());
        cboCheckTestSuite.setText(getPreferences().getCheckTestSuite());
        chkNewConnection.setSelection(getPreferences().mustCreateNewConnection());
        chkPosToLineOnOpen.setSelection(getPreferences().shallPositionToLine());
        cboCaptureJobLog.setText(getPreferences().getCaptureJobLogText());
        chkShowResultView.setSelection(getPreferences().isShowResultView());
        chkWarnMessages.setSelection(false);
    }

    @Override
    protected void performDefaults() {
        super.performDefaults();
        cboRunOrder.setText(getPreferences().getDefaultRunOrder());
        cboLibraryList.setText(getPreferences().getDefaultLibraryList());
        txtJobDesc.setText(getPreferences().getDefaultJobDescription().getName());
        txtJobDescLib.setText(getPreferences().getDefaultJobDescription().getLibrary());
        chkDisableReport.setSelection(getPreferences().getDefaultReportDisabledState());
        cboReportDetail.setText(getPreferences().getDefaultDetail());
        cboCreateReport.setText(getPreferences().getDefaultOutput());
        txtProductLibrary.setText(getPreferences().getDefaultProductLibrary());
        cboCheckTestSuite.setText(getPreferences().getDefaultCheckTestSuite());
        chkNewConnection.setSelection(getPreferences().getDefaultConnectionState());
        chkPosToLineOnOpen.setSelection(getPreferences().getDefaultPositionToLineState());
        cboCaptureJobLog.setText(getPreferences().getDefaultCaptureJobLogText());
        chkShowResultView.setSelection(getPreferences().getDefaultIsShowResultView());
        chkWarnMessages.setSelection(false);

        updateReportControlsEnablement();
    }

    @Override
    public boolean performOk() {
        if (!super.performOk()) {
            return false;
        }

        Preferences tPreferences = getPreferences();

        tPreferences.setRunOrder(cboRunOrder.getText());
        tPreferences.setLibraryList(new String[] { cboLibraryList.getText() });
        I5ObjectName tJobDescription = new I5ObjectName(txtJobDesc.getText(), txtJobDescLib.getText());
        tPreferences.setJobDescription(tJobDescription);
        tPreferences.setDetail(cboReportDetail.getText());
        tPreferences.setOutput(cboCreateReport.getText());
        tPreferences.setReclaimResources(cboReclaimResources.getText());

        tPreferences.setReportDisabled(chkDisableReport.getSelection());

        tPreferences.setProductLibrary(txtProductLibrary.getText());

        tPreferences.setCheckTestSuite(cboCheckTestSuite.getText());

        tPreferences.setDebugConnectionNew(chkNewConnection.getSelection());
        tPreferences.setPositionToLine(chkPosToLineOnOpen.getSelection());
        tPreferences.setCaptureJobLogByText(cboCaptureJobLog.getText());

        if (chkWarnMessages.getSelection()) {
            tPreferences.enableAllWarningMessages();
        }

        tPreferences.setShowResultView(chkShowResultView.getSelection());

        updateDisableReportButton();
        updateEnableDebugModeButton();

        updateWarningMessagesControlsEnablement();

        return true;
    }

    /**
     * Get the preferences store.
     */
    @Override
    protected IPreferenceStore doGetPreferenceStore() {
        return getPreferences().getStore();
    }

    private Preferences getPreferences() {
        return Preferences.getInstance();
    }

    private void updateControlsOnEnterPage() {
        updateWarningMessagesControlsEnablement();
        updateReportControlsEnablement();

        String[] tLibraryList = getPreferences().getLibraryList();
        if (tLibraryList.length == 1) {
            updateJobDescriptionControlsEnablement(tLibraryList[0]);
        } else {
            updateJobDescriptionControlsEnablement(null);
        }

        String tJobDescriptionName = getPreferences().getJobDescription().getName();
        updateJobDescriptionLibraryControlValueAndEnablement(tJobDescriptionName);
    }

    private void updateJobDescriptionLibraryControlValueAndEnablement(String aJobDescriptionName) {
        boolean tEnabled;
        if (Preferences.JOBD_NAME_DFT.equalsIgnoreCase(aJobDescriptionName)) {
            txtJobDescLib.setText(""); //$NON-NLS-1$
            tEnabled = false;
        } else {
            tEnabled = true;
            if ("".equals(txtJobDescLib.getText())) { //$NON-NLS-1$
                txtJobDescLib.setText(Preferences.JOBD_LIBRARY_LIBL);
            }
        }
        setJobDescriptionLibraryEnablement(tEnabled);
    }

    private void updateReportControlsEnablement() {
        boolean tEnabled = !chkDisableReport.getSelection();
        cboReportDetail.setEnabled(tEnabled);
        cboCreateReport.setEnabled(tEnabled);
    }

    private void updateJobDescriptionControlsEnablement(String aFirstLibraryListEntry) {
        boolean tEnabled;
        if (Preferences.LIBRARY_LIST_JOBD.equalsIgnoreCase(aFirstLibraryListEntry)) {
            tEnabled = true;
        } else {
            tEnabled = false;
        }
        setJobDescriptionNameEnablement(tEnabled);
        setJobDescriptionLibraryEnablement(tEnabled);
        return;
    }

    private void setJobDescriptionNameEnablement(boolean anEnable) {
        txtJobDesc.setEnabled(anEnable);
    }

    private void setJobDescriptionLibraryEnablement(boolean anEnable) {
        txtJobDescLib.setEnabled(anEnable);
    }

    private void updateWarningMessagesControlsEnablement() {
        if (getPreferences().isAnyWarningMessageDisabled()) {
            chkWarnMessages.setEnabled(true);
        } else {
            chkWarnMessages.setEnabled(false);
        }
    }

    private void updateDisableReportButton() {
        ICommandService tService = (ICommandService)PlatformUI.getWorkbench().getService(ICommandService.class);
        tService.refreshElements(Command.TOGGLE_DISABLE_REPORT, null);
    }

    private void updateEnableDebugModeButton() {
        ICommandService tService = (ICommandService)PlatformUI.getWorkbench().getService(ICommandService.class);
        tService.refreshElements(Command.TOGGLE_ENABLE_DEBUG_MODE, null);
    }
}
