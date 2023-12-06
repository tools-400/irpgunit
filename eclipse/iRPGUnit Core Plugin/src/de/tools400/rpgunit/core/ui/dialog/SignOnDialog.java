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
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;

import com.ibm.as400.access.AS400;

import de.tools400.rpgunit.core.Messages;

public class SignOnDialog extends Dialog {

    private String hostName;
    private String userId;

    private SignOnPanel signOn;

    public SignOnDialog(Shell parentShell, String aHostName) {
        this(parentShell, aHostName, "");
    }

    public SignOnDialog(Shell parentShell, String aHostName, String aUserId) {
        super(parentShell);
        hostName = aHostName;
        userId = aUserId;
    }

    @Override
    protected Control createDialogArea(Composite parent) {
        Composite container = (Composite)super.createDialogArea(parent);
        container.setLayout(new FillLayout(SWT.VERTICAL));

        signOn = new SignOnPanel();
        signOn.createContents(container, hostName, userId);

        return container;
    }

    @Override
    protected void okPressed() {
        if (signOn.processButtonPressed()) {
            super.okPressed();
        }
    }

    @Override
    protected void createButtonsForButtonBar(Composite parent) {
        createButton(parent, IDialogConstants.OK_ID, IDialogConstants.OK_LABEL, true);
        createButton(parent, IDialogConstants.CANCEL_ID, IDialogConstants.CANCEL_LABEL, false);
    }

    @Override
    protected void configureShell(Shell newShell) {
        super.configureShell(newShell);
        newShell.setText(Messages.DialogTitle_Sign_On);
    }

    public AS400 getAS400() {
        return signOn.getAS400();
    }

    /**
     * Overridden to make this dialog resizable.
     */
    @Override
    protected boolean isResizable() {
        return true;
    }

    /**
     * Overridden to provide a default size.
     */
    @Override
    protected Point getInitialSize() {
        Point point = getShell().computeSize(250, SWT.DEFAULT, true);
        return point;
    }

}
