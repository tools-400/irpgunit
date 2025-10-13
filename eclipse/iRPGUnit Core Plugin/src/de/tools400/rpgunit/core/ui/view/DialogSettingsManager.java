/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.view;

import org.eclipse.jface.dialogs.IDialogSettings;

import de.tools400.rpgunit.core.helpers.BooleanHelper;

public class DialogSettingsManager {

    private IDialogSettings workbenchSettings;
    private Class<?> clazz;

    public DialogSettingsManager(IDialogSettings workbenchSettings, Class<?> clazz) {
        this.workbenchSettings = workbenchSettings;
        this.clazz = clazz;
    }

    /**
     * Retrieves the screen value that was last displayed on the dialog.
     * 
     * @param aKey - key, that is used to retrieve the value from the store
     * @param aDefault - default value, that is returned if then key does not
     *        yet exist
     * @return the screen value that was last shown
     */
    protected boolean loadBooleanValue(String aKey, boolean aDefault) {
        return BooleanHelper.tryParseBoolean(getDialogSettings().get(aKey), aDefault);
    }

    /**
     * Stores a given boolean value to preserve it for the next time the dialog
     * is shown.
     * 
     * @param aKey - key, the value is assigned to
     * @param aValue - the screen value that is stored
     */
    protected void storeValue(String aKey, boolean aValue) {
        getDialogSettings().put(aKey, aValue);
    }

    private IDialogSettings getDialogSettings() {

        String sectionName = clazz.getName();
        IDialogSettings dialogSettings = workbenchSettings.getSection(sectionName);
        if (dialogSettings == null) {
            dialogSettings = workbenchSettings.addNewSection(sectionName);
        }
        return dialogSettings;
    }

}
