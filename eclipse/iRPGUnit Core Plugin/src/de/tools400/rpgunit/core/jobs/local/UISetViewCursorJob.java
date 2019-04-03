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
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.ui.progress.UIJob;

import de.tools400.rpgunit.core.ui.view.ICursorProvider;

public class UISetViewCursorJob extends UIJob {

    private ICursorProvider view;

    private Cursor cursor;

    public UISetViewCursorJob(ICursorProvider aView, Cursor aCursor) {
        super("SetViewCursor"); //$NON-NLS-1$
        view = aView;
        cursor = aCursor;
    }

    @Override
    public IStatus runInUIThread(IProgressMonitor aMonitor) {
        view.setCursor(cursor);
        return Status.OK_STATUS;
    }

}
