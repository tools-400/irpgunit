/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.cmone.preferences;

import org.eclipse.jface.preference.IPreferenceStore;

import de.tools400.rpgunit.cmone.RPGUnitCMOneIntegrationPlugin;

public final class Preferences {

    /**
     * The instance of this Singleton class.
     */
    private static Preferences instance;

    /**
     * Global preferences of the RPGUnit plug-in.
     */
    private static IPreferenceStore preferenceStore;

    /**
     * Base configuration key:
     */
    private static final String RPGUNIT = "rpgunit"; //$NON-NLS-1$

    /**
     * Preferences version number
     */
    public static final String PREFERENCES_VERSION_NUMBER = de.tools400.rpgunit.core.preferences.Preferences.PREFERENCES_VERSION_NUMBER; // $NON-NLS-1$
    public static final int VERSION_NUMBER = de.tools400.rpgunit.core.preferences.Preferences.VERSION_NUMBER;

    /**
     * Values controlling UI behavior.
     */
    private static final String UI = RPGUNIT + ".ui"; //$NON-NLS-1$

    private static final String CMONE_INTEGRATION_ENABLED = UI + ".cmoneIntegrationEnabled"; //$NON-NLS-1$

    /**
     * Private constructor to ensure the Singleton pattern.
     */
    private Preferences() {
    }

    /**
     * Thread-safe method that returns the instance of this Singleton class.
     */
    public synchronized static Preferences getInstance() {
        if (instance == null) {
            instance = new Preferences();
            preferenceStore = RPGUnitCMOneIntegrationPlugin.getDefault().getPreferenceStore();
        }
        return instance;
    }

    /*
     * Preferences: GETTER
     */

    public boolean isCMOneIntegrationEnabled() {
        boolean tIsDisabled = preferenceStore.getBoolean(CMONE_INTEGRATION_ENABLED);
        return tIsDisabled;
    }

    /*
     * Preferences: SETTER
     */

    public void setCMOneIntegrationEnabled(boolean aDisabled) {
        saveCMOneIntegrationEnabledState(aDisabled);
    }

    /**
     * Is called by
     * {@link PreferencesInitializer#initializeDefaultPreferences()} in order to
     * initialize the preferences default values.
     * <p>
     * This method must <b>never</b> be called from outside the
     * PreferencesInitializer class.
     */
    public void initializeDefaultPreferences() {

        preferenceStore.setDefault(CMONE_INTEGRATION_ENABLED, getDefaultCMOneIntegrationEnabledState());
        preferenceStore.setDefault(PREFERENCES_VERSION_NUMBER, de.tools400.rpgunit.core.preferences.Preferences.getInstance()
            .getPreferencesVersionNumber());
    }

    public boolean getDefaultCMOneIntegrationEnabledState() {
        return true;
    }

    public IPreferenceStore getStore() {
        return preferenceStore;
    }

    private void saveCMOneIntegrationEnabledState(boolean aDisabled) {
        preferenceStore.setValue(CMONE_INTEGRATION_ENABLED, aDisabled);
    }
}