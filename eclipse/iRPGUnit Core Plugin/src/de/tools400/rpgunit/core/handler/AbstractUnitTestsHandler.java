/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public abstract class AbstractUnitTestsHandler extends AbstractHandler {

    protected RPGUnitView getView(ExecutionEvent anEvent) {
        return getView(getWindow(anEvent));
    }

    private IWorkbenchWindow getWindow(ExecutionEvent anEvent) {
        IWorkbenchWindow tWindow = HandlerUtil.getActiveWorkbenchWindow(anEvent);
        return tWindow;
    }

    private RPGUnitView getView(IWorkbenchWindow aWindow) {
        RPGUnitView tView = null;
        try {
            tView = (RPGUnitView)aWindow.getActivePage().findView(RPGUnitView.ID);
            return tView;
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Could not get handle of RPGUnit view.", e); //$NON-NLS-1$
            return null;
        }
    }
}
