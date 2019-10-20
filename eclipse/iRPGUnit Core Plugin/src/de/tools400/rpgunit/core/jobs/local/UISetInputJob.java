/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.local;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.progress.UIJob;

import de.tools400.rpgunit.core.ui.view.IInputProvider;

public class UISetInputJob extends UIJob {

    private IInputProvider view;

    private Object input;

    public UISetInputJob(IInputProvider aView, Object anInput) {
        super("SetViewCursor"); //$NON-NLS-1$
        view = aView;
        input = anInput;
    }

    @Override
    public IStatus runInUIThread(IProgressMonitor aMonitor) {
        if (view.getInput() == null) {
            view.setInput(this.input, true);
        } else {
            view.setInput(view.getInput(), false);
        }
        return Status.OK_STATUS;
    }

}
