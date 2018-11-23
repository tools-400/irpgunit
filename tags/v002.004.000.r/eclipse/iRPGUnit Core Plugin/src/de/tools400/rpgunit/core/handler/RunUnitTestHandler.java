/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.rse.ui.SystemBasePlugin;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchWindow;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.jobs.local.RunUnitTestsJob;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.view.IInputProvider;
import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public class RunUnitTestHandler implements ISelectionHandler {

    /**
     * Executes the selected RPGUnit Test Suites from the Remote Explorer.
     */
    @Override
    public Object execute(ISelection aSelection) throws ExecutionException {
        IWorkbenchWindow tWindow = SystemBasePlugin.getActiveWorkbenchWindow();
        Shell tShell = SystemBasePlugin.getActiveWorkbenchShell();
        return execute(tWindow, tShell, aSelection);
    }

    private Object execute(IWorkbenchWindow aWindow, Shell aShell, ISelection aSelection) throws ExecutionException {
        if (aSelection instanceof IStructuredSelection) {

            RPGUnitView tView = getView(aWindow);
            if (tView == null) {
                return null;
            }

            ((IInputProvider)tView).setInput(null);

            RunUnitTestsJob tJob = new RunUnitTestsJob(aShell, tView, (IStructuredSelection)aSelection);
            tJob.schedule();
        }

        return null;
    }

    protected RPGUnitView getView(IWorkbenchWindow aWindow) {
        RPGUnitView tView = null;
        try {

            if (Preferences.getInstance().isShowResultView()) {
                tView = (RPGUnitView)aWindow.getActivePage().showView(RPGUnitView.ID);
            } else {
                tView = (RPGUnitView)aWindow.getActivePage().findView(RPGUnitView.ID);
                if (tView == null) {
                    IWorkbenchPart activePart = aWindow.getActivePage().getActivePart();
                    tView = (RPGUnitView)aWindow.getActivePage().showView(RPGUnitView.ID);
                    if (activePart != null) {
                        aWindow.getActivePage().bringToTop(activePart);
                    }
                }
            }

        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Could not get handle of RPGUnit view.", e); //$NON-NLS-1$
            return null;
        }
        return tView;
    }
}
