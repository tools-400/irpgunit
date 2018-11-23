/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.ui.dialog.UploadRPGUnitLibraryDialog;

public class UploadRPGUnitLibraryHandler {

    public Object execute(String productLibrary) throws ExecutionException {

        UploadRPGUnitLibraryDialog dialog = new UploadRPGUnitLibraryDialog(getShell());

        if (!StringHelper.isNullOrEmpty(productLibrary)) {
            dialog.setProductLibraryName(productLibrary);
        }

        dialog.open();

        return null;
    }

    private Shell getShell() {
        return PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
    }

}
