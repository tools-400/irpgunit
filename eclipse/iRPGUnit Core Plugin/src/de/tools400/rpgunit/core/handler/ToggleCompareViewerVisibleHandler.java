/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import java.util.Map;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.IElementUpdater;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.menus.UIElement;

import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public class ToggleCompareViewerVisibleHandler extends AbstractHandler implements IElementUpdater {

    @Override
    public Object execute(ExecutionEvent anEvent) throws ExecutionException {
        if (HandlerUtil.getActivePart(anEvent) instanceof RPGUnitView) {
            RPGUnitView view = (RPGUnitView)HandlerUtil.getActivePart(anEvent);
            if (view != null) {
                view.toggleCompareViewerVisible();
            }
        }
        return null;
    }

    @Override
    public void updateElement(UIElement anUIElement, Map aMap) {

        IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
        if (page != null) {
            // Find the view (only if it's already open)
            IViewPart view = page.findView(RPGUnitView.ID);
            if (view instanceof RPGUnitView) {
                RPGUnitView rpgUnitView = (RPGUnitView)view;
                anUIElement.setChecked(rpgUnitView.isCompareViewerVisible());
            }
        }
    }

}
