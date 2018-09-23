/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.preferences;

import org.eclipse.jface.preference.IPreferenceStore;

import de.tools400.rpgunit.spooledfileviewer.RPGUnitSpooledFileViewer;

public final class Preferences {

    /**
     * The instance of this Singleton class.
     */
    private static Preferences instance;

    /**
     * Global preferences of the RPGUnit Spooled File Viewer plugin.
     */
    private static IPreferenceStore preferenceStore;

    /**
     * Base configuration key:
     */
    private static final String RPGUNIT = "rpgunit.spooledfileviewer"; //$NON-NLS-1$

    /**
     * Product library.
     */
    public static final String SYSTEM = RPGUNIT + ".system"; //$NON-NLS-1$

    public static final String PRODUCT_LIBRARY = SYSTEM + ".productLibrary"; //$NON-NLS-1$

    public static final String PRODUCT_LIBRARY_LIBL = "*LIBL"; //$NON-NLS-1$

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
            preferenceStore = RPGUnitSpooledFileViewer.getDefault().getPreferenceStore();
            instance.initialize();
        }
        return instance;
    }

    /*
     * Preferences: GETTER
     */

    public String getProductLibrary() {
        String tProductLibrary = preferenceStore.getString(PRODUCT_LIBRARY);
        return tProductLibrary;
    }

    public String getHostPrintTransformWscst() {
        return "RUWSCST"; //$NON-NLS-1$
    }

    /*
     * Preferences: SETTER
     */

    public void setProductLibrary(String aProduductLibrary) {
        saveProductLibrary(aProduductLibrary);
    }

    public String getDefaultProductLibrary() {
        return PRODUCT_LIBRARY_LIBL;
    }

    public IPreferenceStore getStore() {
        return preferenceStore;
    }

    private void saveProductLibrary(String aProductLibrary) {
        preferenceStore.setValue(PRODUCT_LIBRARY, aProductLibrary);
    }

    /**
     * Initializes the preferences. Adds a property change listener to the
     * Eclipse preferences store to keep track of changes.
     */
    private void initialize() {

    }

}