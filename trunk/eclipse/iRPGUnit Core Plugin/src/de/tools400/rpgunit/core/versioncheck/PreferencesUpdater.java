/*******************************************************************************
 * Copyright (c) 2012-2014 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.versioncheck;

import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import de.tools400.rpgunit.core.model.ibmi.I5ObjectName;
import de.tools400.rpgunit.core.preferences.Preferences;

public final class PreferencesUpdater implements IObsoleteBundles, IObsoletePreferences {

    public static void update() {
        PreferencesUpdater tUpdater = new PreferencesUpdater();
        tUpdater.performSettingsUpdate();
    }

    private void performSettingsUpdate() {
        performUpdate_v2();
    }

    private void performUpdate_v2() {
        // if (!hasBundle(DE_TOOLS400_RPGUNIT_IMPLEMENTATION)) {
        // return;
        // }

        int preferencesVersionNumber = Preferences.getInstance().getPreferencesVersionNumber();
        if (preferencesVersionNumber >= Preferences.VERSION_NUMBER) {
            return;
        }

        String tValue;

        // RPGUnit "Implementation"
        tValue = getValue(CHECK_TEST_SUITE);
        if (tValue != null) {
            Preferences.getInstance().setCheckTestSuite(tValue);
        }

        tValue = getValue(DEBUG_CONNECTION_NEW);
        if (tValue != null) {
            Preferences.getInstance().setDebugConnectionNew(new Boolean(tValue));
        }

        tValue = getValue(REPORT_DETAIL);
        if (tValue != null) {
            Preferences.getInstance().setDetail(tValue);
        }

        I5ObjectName tJobD = new I5ObjectName(getValue(JOBD_NAME), getValue(JOBD_LIBRARY));
        if (tJobD != null) {
            Preferences.getInstance().setJobDescription(tJobD);
        }

        tValue = getValue(LIBRARY_LIST);
        if (tValue != null) {
            Preferences.getInstance().setLibraryList(new String[] { tValue });
        }

        tValue = getValue(OUTPUT);
        if (tValue != null) {
            Preferences.getInstance().setOutput(tValue);
        }

        tValue = getValue(DEBUG_POSITION_TO_LINE);
        if (tValue != null) {
            Preferences.getInstance().setPositionToLine(new Boolean(tValue));
        }

        tValue = getValue(PRODUCT_LIBRARY);
        if (tValue != null) {
            Preferences.getInstance().setProductLibrary(tValue);
        }

        tValue = getValue(RECLAIM_RESOURCES);
        if (tValue != null) {
            Preferences.getInstance().setReclaimResources(tValue);
        }

        tValue = getValue(REPORT_DISABLED);
        if (tValue != null) {
            Preferences.getInstance().setReportDisabled(new Boolean(tValue));
        }

        tValue = getValue(RUN_ORDER);
        if (tValue != null) {
            Preferences.getInstance().setRunOrder(tValue);
        }

        tValue = getValue(WARN_MESSAGE_SRC_OPTION);
        if (tValue != null) {
            Preferences.getInstance().setShowWarningMessage(WARN_MESSAGE_SRC_OPTION, new Boolean(tValue));
        }

        tValue = getValue(WARN_MESSAGE_USER_DEFINED_ATTRIBUTE);
        if (tValue != null) {
            Preferences.getInstance().setShowWarningMessage(WARN_MESSAGE_USER_DEFINED_ATTRIBUTE, new Boolean(tValue));
        }

        Preferences.getInstance().setPreferencesVersionNumber(Preferences.VERSION_NUMBER);
    }

    private String getValue(String aKey) {
        return Platform.getPreferencesService().getString(DE_TOOLS400_RPGUNIT_IMPLEMENTATION, aKey, null, null);
    }

    private int getIntValue(String aKey, int dftValue) {
        String strIntVal = Platform.getPreferencesService().getString(DE_TOOLS400_RPGUNIT_IMPLEMENTATION, aKey, null, null);
        try {
            return Integer.parseInt(strIntVal);
        } catch (Throwable e) {
            return dftValue;
        }
    }

    private boolean hasBundle(String aBundleID) {
        Bundle bundle = Platform.getBundle(aBundleID);
        return bundle != null;
    }
}
