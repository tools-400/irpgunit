/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.dialog;

import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ControlAdapter;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.MenuAdapter;
import org.eclipse.swt.events.MenuEvent;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Text;

import com.ibm.etools.iseries.rse.ui.widgets.IBMiConnectionCombo;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.helpers.ClipboardHelper;
import de.tools400.rpgunit.core.helpers.IntHelper;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.helpers.SystemConnectionHelper;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.swt.widgets.NumericOnlyVerifyListener;
import de.tools400.rpgunit.core.swt.widgets.UpperCaseOnlyVerifier;
import de.tools400.rpgunit.core.upload.ProductLibraryUploader;
import de.tools400.rpgunit.core.upload.StatusMessageReceiver;

public class UploadRPGUnitLibraryDialog extends Dialog implements StatusMessageReceiver {

    private IBMiConnectionCombo systemHostCombo;
    private Text txtFtpPort;
    private Text txtUploadLibrary;
    private Table tableStatus;

    private IBMiConnection iSeriesConnection;
    private int ftpPortNumber;
    private String productLibraryName;

    private Preferences preferences;
    private Button btnOK;
    private Button btnCancel;

    public UploadRPGUnitLibraryDialog(Shell parentShell) {
        super(parentShell);

        preferences = Preferences.getInstance();
    }

    /**
     * Overridden to set the window title.
     */
    @Override
    protected void configureShell(Shell newShell) {
        super.configureShell(newShell);
        newShell.setText(Messages.Transfer_RPGUnit_Library);
        newShell.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TRANSFER_LIBRARY));
    }

    @Override
    public Control createDialogArea(Composite parent) {

        Composite mainArea = (Composite)super.createDialogArea(parent);

        mainArea.setLayout(new GridLayout(2, false));
        mainArea.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 2, 1));

        systemHostCombo = new IBMiConnectionCombo(mainArea, SWT.NONE, null, true, true);
        systemHostCombo.setLayoutData(new GridData(SWT.FILL, SWT.DEFAULT, true, false, 3, 1));
        systemHostCombo.setToolTipText(Messages.Tooltip_Connection_name);
        systemHostCombo.getCombo().setToolTipText(Messages.Tooltip_Connection_name);

        Label lblFtpPort = new Label(mainArea, SWT.NONE);
        lblFtpPort.setText(Messages.Label_FTP_port_number_colon);
        lblFtpPort.setToolTipText(Messages.Tooltip_FTP_port_number);

        txtFtpPort = new Text(mainArea, SWT.BORDER);
        GridData gdFtpPort = new GridData();
        gdFtpPort.widthHint = 40;
        txtFtpPort.setLayoutData(gdFtpPort);
        txtFtpPort.setToolTipText(Messages.Tooltip_FTP_port_number);
        txtFtpPort.setTextLimit(5);
        txtFtpPort.addVerifyListener(new NumericOnlyVerifyListener());

        Label lblUploadLibrary = new Label(mainArea, SWT.NONE);
        lblUploadLibrary.setText(Messages.Label_UploadLibrary);
        lblUploadLibrary.setToolTipText(Messages.PreferencesPage2_txtProductLibrary_toolTipText);

        txtUploadLibrary = new Text(mainArea, SWT.BORDER);
        GridData gdProductLibrary = new GridData();
        gdProductLibrary.widthHint = 120;
        txtUploadLibrary.setLayoutData(gdProductLibrary);
        txtUploadLibrary.setToolTipText(Messages.Tooltip_UploadLibrary);
        txtUploadLibrary.setTextLimit(10);
        txtUploadLibrary.addVerifyListener(new UpperCaseOnlyVerifier());

        tableStatus = new Table(mainArea, SWT.BORDER | SWT.MULTI);
        final GridData gd_tableStatus = new GridData(SWT.FILL, SWT.FILL, true, true, 2, 1);
        tableStatus.setLayoutData(gd_tableStatus);

        final TableColumn columnStatus = new TableColumn(tableStatus, SWT.NONE);

        tableStatus.addControlListener(new ControlAdapter() {
            @Override
            public void controlResized(ControlEvent event) {
                Table table = (Table)event.getSource();
                if (table.getClientArea().width > 0) {
                    // Resize the column to the width of the table
                    columnStatus.setWidth(table.getClientArea().width);
                }
            }
        });

        tableStatus.addKeyListener(new KeyListener() {
            public void keyReleased(KeyEvent event) {
            }

            public void keyPressed(KeyEvent event) {
                if ((event.stateMask & SWT.CTRL) != SWT.CTRL) {
                    return;
                }
                if (event.keyCode == 'a') {
                    tableStatus.selectAll();
                }
                if (event.keyCode == 'c') {
                    ClipboardHelper.setTableItemsText(tableStatus.getSelection());
                }
            }
        });

        Menu menuTableStatusContextMenu = new Menu(tableStatus);
        menuTableStatusContextMenu.addMenuListener(new TableContextMenu(tableStatus));
        tableStatus.setMenu(menuTableStatusContextMenu);

        loadScreenValues();

        parent.pack();

        return mainArea;
    }

    @Override
    protected Control createContents(Composite parent) {

        Control control = super.createContents(parent);

        if (systemHostCombo.getISeriesConnection() == null) {
            systemHostCombo.setFocus();
        } else {
            getShell().getDefaultButton().setFocus();
        }

        validateInput();

        addInputValidationListeners();

        return control;
    }

    private void addInputValidationListeners() {
        systemHostCombo.addSelectionListener(new SelectionListener() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                validateInput();
            }

            @Override
            public void widgetDefaultSelected(SelectionEvent event) {
                widgetSelected(event);
            }
        });

        txtFtpPort.addModifyListener(new ModifyListener() {
            @Override
            public void modifyText(ModifyEvent arg0) {
                validateInput();
            }
        });

        txtUploadLibrary.addModifyListener(new ModifyListener() {
            @Override
            public void modifyText(ModifyEvent arg0) {
                validateInput();
            }
        });
    }

    @Override
    protected void createButtonsForButtonBar(Composite parent) {
        super.createButtonsForButtonBar(parent);

        btnOK = getButton(IDialogConstants.OK_ID);
        btnOK.setText(Messages.Label_UploadButton);
        btnOK.setToolTipText(Messages.Tooltip_UploadButton);

        btnCancel = getButton(IDialogConstants.CANCEL_ID);
        btnCancel.setText(Messages.Label_CloseButton);
        btnCancel.setToolTipText(Messages.Tooltip_CloseButton);

        getShell().setDefaultButton(btnCancel);
    }

    private void loadScreenValues() {

        systemHostCombo.setConnections(SystemConnectionHelper.getHosts());
        systemHostCombo.setItems(SystemConnectionHelper.getConnectionNames());
        selectConnection(null);

        if (ftpPortNumber > 0) {
            txtFtpPort.setText(Integer.toString(ftpPortNumber));
        } else {
            txtFtpPort.setText(Integer.toString(preferences.getDefaultUploadFtpPortNumber()));
        }

        if (!StringHelper.isNullOrEmpty(productLibraryName)) {
            txtUploadLibrary.setText(productLibraryName);
        } else {
            txtUploadLibrary.setText(preferences.getUploadLibraryName());
        }
    }

    private void storeScreenValues() {

        preferences.setUploadConnectionName(systemHostCombo.getISeriesConnection().getConnectionName());
        preferences.setUploadFtpPortNumber(ftpPortNumber);
        preferences.setUploadLibraryName(productLibraryName);
    }

    private void selectConnection(String hostName) {

        int connectionIndex = -1;
        if (hostName != null) {
            connectionIndex = findConnection(hostName);
        }

        if (connectionIndex < 0) {
            connectionIndex = findConnection(preferences.getUploadConnectionName());
        }

        systemHostCombo.setSelectionIndex(connectionIndex);
    }

    private int findConnection(String hostName) {

        if (hostName != null) {
            String[] hostNames = systemHostCombo.getItems();
            for (int i = 0; i < hostNames.length; i++) {
                if (hostName.equals(hostNames[i])) {
                    return i;
                }
            }
        }

        return -1;
    }

    public void setProductLibraryName(String library) {

        if (!isSpecialValue(library)) {
            this.productLibraryName = library;
        } else {
            this.productLibraryName = null;
        }
    }

    @Override
    public void okPressed() {

        storeScreenValues();

        ProductLibraryUploader uploader = new ProductLibraryUploader(getShell(), iSeriesConnection, ftpPortNumber, productLibraryName);
        uploader.setStatusMessageReceiver(this);

        try {

            systemHostCombo.setEnabled(false);
            txtFtpPort.setEnabled(false);
            txtUploadLibrary.setEnabled(false);
            btnOK.setEnabled(false);
            btnCancel.setEnabled(false);

            if (!uploader.run()) {
                return;
            }

        } finally {
            systemHostCombo.setEnabled(true);
            txtFtpPort.setEnabled(true);
            txtUploadLibrary.setEnabled(true);
            btnOK.setEnabled(false);
            btnCancel.setEnabled(true);
        }
    }

    public void validateInput() {

        btnOK.setEnabled(true);
        tableStatus.removeAll();

        productLibraryName = null;
        iSeriesConnection = null;
        ftpPortNumber = -1;

        if (systemHostCombo.getISeriesConnection() == null) {
            setStatus(Messages.Please_select_a_connection);
            btnOK.setEnabled(false);
        }

        if (IntHelper.tryParseInt(txtFtpPort.getText(), -1) <= 0) {
            setStatus(Messages.Please_specify_a_valid_FTP_port_number);
            btnOK.setEnabled(false);
        }

        if (StringHelper.isNullOrEmpty(txtUploadLibrary.getText()) || isSpecialValue(txtUploadLibrary.getText())) {
            setStatus(Messages.Please_enter_a_valid_library_name);
            btnOK.setEnabled(false);
        }

        if (btnOK.isEnabled()) {
            productLibraryName = txtUploadLibrary.getText();
            iSeriesConnection = systemHostCombo.getISeriesConnection();
            ftpPortNumber = IntHelper.tryParseInt(txtFtpPort.getText());
            setStatus(Messages.bind(Messages.Ready_to_transfer_library_A_to_host_B_using_port_C,
                new Object[] { productLibraryName, iSeriesConnection.getHostName(), ftpPortNumber }));
        }

    }

    private boolean isSpecialValue(String value) {

        if (value.startsWith("*")) { //$NON-NLS-1$
            return true;
        }

        return false;
    }

    public void setStatus(String status) {

        TableItem itemStatus = new TableItem(tableStatus, SWT.BORDER);
        itemStatus.setText(status);
        tableStatus.update();
    }

    @Override
    protected boolean isResizable() {
        return true;
    }

    @Override
    protected Point getInitialSize() {
        return new Point(600, 400);
    }

    /**
     * Class that implements the context menu for the table rows.
     */
    private class TableContextMenu extends MenuAdapter {

        private Table table;
        private MenuItem menuItemCopySelected;

        public TableContextMenu(Table table) {
            this.table = table;
        }

        @Override
        public void menuShown(MenuEvent event) {
            destroyMenuItems();
            createMenuItems();
        }

        private Menu getMenu() {
            return table.getMenu();
        }

        private void destroyMenuItems() {
            if (!((menuItemCopySelected == null) || (menuItemCopySelected.isDisposed()))) {
                menuItemCopySelected.dispose();
            }
        }

        private void createMenuItems() {

            createMenuItemCopySelected();
        }

        private void createMenuItemCopySelected() {

            menuItemCopySelected = new MenuItem(getMenu(), SWT.NONE);
            menuItemCopySelected.setText(Messages.ActionLabel_Copy);
            menuItemCopySelected.addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent e) {
                    ClipboardHelper.setTableItemsText(table.getItems());
                }
            });
        }
    }
}
