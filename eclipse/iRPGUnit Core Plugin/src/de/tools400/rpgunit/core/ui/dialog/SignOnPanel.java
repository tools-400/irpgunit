/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.dialog;

import java.io.IOException;
import java.net.UnknownHostException;

import org.eclipse.jface.action.StatusLineManager;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400SecurityException;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.helpers.StringHelper;

public class SignOnPanel {

    private static final String EMPTY_STRING = ""; //$NON-NLS-1$

    private Text textHost;
    private Text textUser;
    private Text textPassword;
    private StatusLineManager statusLineManager;
    private AS400 as400;

    public SignOnPanel() {
        as400 = null;
    }

    public void createContents(Composite parent, String aHostName, String aUserId) {

        Composite container = new Composite(parent, SWT.NONE);
        container.setLayout(new GridLayout());

        final Composite compositeGeneral = new Composite(container, SWT.NONE);
        compositeGeneral.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
        final GridLayout gridLayoutCompositeGeneral = new GridLayout();
        gridLayoutCompositeGeneral.numColumns = 2;
        compositeGeneral.setLayout(gridLayoutCompositeGeneral);

        createLabel(compositeGeneral, Messages.Label_Host_name_colon, Messages.Tooltip_Host_name);

        textHost = createText(compositeGeneral);
        textHost.setToolTipText(Messages.Tooltip_Host_name);
        textHost.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
        textHost.setText(aHostName);
        if (aHostName.trim().length() > 0) {
            textHost.setEditable(false);
        }

        createLabel(compositeGeneral, Messages.Label_Signon_User_colon, Messages.Tooltip_Signon_User);

        textUser = createText(compositeGeneral);
        textUser.setToolTipText(Messages.Tooltip_Signon_User);
        textUser.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
        textUser.setText(aUserId);

        createLabel(compositeGeneral, Messages.Label_Password_colon, Messages.Tooltip_Password);

        textPassword = createPassword(compositeGeneral);
        textPassword.setToolTipText(Messages.Tooltip_Password);
        textPassword.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
        textPassword.setText(EMPTY_STRING);

        statusLineManager = new StatusLineManager();
        statusLineManager.createControl(container, SWT.NONE);
        Control statusLine = statusLineManager.getControl();
        final GridData gridDataStatusLine = new GridData(SWT.FILL, SWT.CENTER, true, false);
        statusLine.setLayoutData(gridDataStatusLine);

        setFocus();
    }

    private void setFocus() {

        if (StringHelper.isNullOrEmpty(textHost.getText())) {
            textHost.setFocus();
        } else if (StringHelper.isNullOrEmpty(textUser.getText())) {
            textUser.setFocus();
        } else if (StringHelper.isNullOrEmpty(textPassword.getText())) {
            textPassword.setFocus();
        }
    }

    private void createLabel(Composite parent, String text, String tooltip) {

        Label label = new Label(parent, SWT.NONE);
        label.setText(text);
        label.setToolTipText(tooltip);
    }

    private Text createText(Composite parent) {

        Text text = new Text(parent, SWT.BORDER);

        return text;
    }

    private Text createPassword(Composite parent) {

        Text text = new Text(parent, SWT.PASSWORD | SWT.BORDER);

        return text;
    }

    protected void setErrorMessage(String errorMessage) {
        if (errorMessage != null) {
            statusLineManager.setErrorMessage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_ERROR), errorMessage);
        } else {
            statusLineManager.setErrorMessage(null, null);
        }
    }

    public boolean processButtonPressed() {

        textHost.getText().trim();
        textUser.getText().trim();
        textPassword.getText().trim();

        if (textHost.getText().equals(EMPTY_STRING)) {
            setErrorMessage(Messages.Enter_a_host_name);
            textHost.setFocus();
            return false;
        }

        if (textUser.getText().equals(EMPTY_STRING)) {
            setErrorMessage(Messages.Enter_a_user_name);
            textUser.setFocus();
            return false;
        }

        if (textPassword.getText().equals(EMPTY_STRING)) {
            setErrorMessage(Messages.Enter_a_password);
            textPassword.setFocus();
            return false;
        }

        as400 = new AS400(textHost.getText(), textUser.getText(), textPassword.getText());
        try {
            as400.validateSignon();
        } catch (AS400SecurityException e) {
            setErrorMessage(e.getMessage());
            textHost.setFocus();
            return false;
        } catch (UnknownHostException e) {
            setErrorMessage(Messages.bind(Messages.Host_A_not_found_in_configured_RSE_connections, textHost.getText()));
            textHost.setFocus();
            return false;
        } catch (IOException e) {
            setErrorMessage(e.getMessage());
            textHost.setFocus();
            return false;
        }
        return true;
    }

    public AS400 getAS400() {
        return as400;
    }

}
