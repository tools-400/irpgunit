/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
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
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.commands.IElementUpdater;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.menus.UIElement;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.view.RPGUnitView;

@SuppressWarnings("all")
public class ToggleEnableDebugMode extends AbstractHandler implements IElementUpdater {

    @Override
    public Object execute(ExecutionEvent anEvent) throws ExecutionException {
        if (HandlerUtil.getActivePart(anEvent) instanceof RPGUnitView) {
            IPreferenceStore tPreferenceStore = RPGUnitCorePlugin.getPreferencesStore();
            Boolean tDebugModeEnabled = tPreferenceStore.getBoolean(Preferences.DEBUG_CONNECTION);
            tPreferenceStore.setValue(Preferences.DEBUG_CONNECTION, !tDebugModeEnabled);
        }
        return null;
    }

    @Override
    public void updateElement(UIElement anUIElement, Map aMap) {
        IPreferenceStore tPreferenceStore = RPGUnitCorePlugin.getPreferencesStore();
        Boolean tDebugModeEnabled = tPreferenceStore.getBoolean(Preferences.DEBUG_CONNECTION);
        anUIElement.setChecked(tDebugModeEnabled);
    }
}
