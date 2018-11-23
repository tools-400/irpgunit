/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.local;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.progress.UIJob;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;

public class UIDisplayErrorJob extends UIJob {

    private Shell shell;

    private String title;

    private String message;

    public UIDisplayErrorJob(Shell aShell, String aTitle, String aMessage) {
        super("SetViewCursor"); //$NON-NLS-1$
        shell = aShell;
        title = aTitle;
        message = aMessage;
    }

    @Override
    public IStatus runInUIThread(IProgressMonitor aMonitor) {
        RPGUnitCorePlugin.logError(message);
        MessageDialog.openError(shell, title, message);
        return Status.OK_STATUS;
    }

}
