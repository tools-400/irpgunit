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
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.ui.handlers.HandlerUtil;

import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public class ToggleShowFailuresHandler extends AbstractHandler {

    @Override
    public Object execute(ExecutionEvent anEvent) throws ExecutionException {
        if (HandlerUtil.getActivePart(anEvent) instanceof RPGUnitView) {
            RPGUnitView view = (RPGUnitView)HandlerUtil.getActivePart(anEvent);
            if (view != null) {
                view.toggleShowFailuresOnly();
            }
        }
        return null;
    }

}
