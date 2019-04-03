/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.warning;

import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.preferences.Preferences;

public class WarningMessage extends MessageDialog {

    private Button doNotShowAgain;
    private String showWarningKey;

    public WarningMessage(Shell parentShell, String dialogTitle, Image dialogTitleImage, String dialogMessage, int dialogImageType,
        String[] dialogButtonLabels, String showWarningKey) {
        super(parentShell, dialogTitle, dialogTitleImage, dialogMessage, dialogImageType, dialogButtonLabels, 0);
        this.showWarningKey = showWarningKey;
    }

    public static void openWarning(Shell parent, String showWarningKey, String message) {
        if (Preferences.getInstance().isShowWarningMessage(showWarningKey)) {
            open(WARNING, parent, Messages.Warning, message, SWT.NONE, showWarningKey);
        }
    }

    public static boolean open(int kind, Shell parent, String title, String message, int style, String showWarningKey) {
        MessageDialog dialog = new WarningMessage(parent, title, null, message, kind, new String[] { IDialogConstants.OK_LABEL }, showWarningKey);
        return dialog.open() == 0;
    }

    @Override
    public boolean close() {
        if (doNotShowAgain.getSelection()) {
            Preferences.getInstance().setShowWarningMessage(showWarningKey, false);
        }
        return super.close();
    }

    @Override
    protected Control createCustomArea(Composite parent) {
        Composite customArea = new Composite(parent, SWT.NONE);
        GridLayout gridLayout = new GridLayout();
        gridLayout.marginTop = 5;
        customArea.setLayout(gridLayout);
        doNotShowAgain = new Button(customArea, SWT.CHECK);
        doNotShowAgain.setText(Messages.Do_not_ask_me_again);
        return parent;
    }
}
