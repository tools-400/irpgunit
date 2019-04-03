/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui;

import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.rse.ui.SystemBasePlugin;
import org.eclipse.swt.widgets.Shell;

import de.tools400.rpgunit.core.Messages;

public final class UIUtils {

    public static void displayError(Exception anException) {
        displayError(anException.getLocalizedMessage());
    }

    public static void displayError(String aMessage) {
        displayError(Messages.UIUtils_0, aMessage);
    }

    public static void displayError(String aTitle, String aMessage) {
        MessageDialog.openError(getShell(), aTitle, aMessage);
    }

    public static Shell getShell() {
        return SystemBasePlugin.getActiveWorkbenchShell();
    }
}
