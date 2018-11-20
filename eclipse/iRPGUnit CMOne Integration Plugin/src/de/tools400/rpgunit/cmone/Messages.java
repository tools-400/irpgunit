/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.cmone;

import org.eclipse.osgi.util.NLS;

public class Messages extends NLS {

    private static final String BUNDLE_NAME = "de.tools400.rpgunit.cmone.messages"; //$NON-NLS-1$

    public static String Run_Unit_Test;

    public static String CMOnePreferencesPage_grpIntegrationParameters_text;
    public static String CMOnePreferencesPage_chkEnableIntegration_toolTipText;
    public static String CMOnePreferencesPage_chkEnableIntegration_text;

    static {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages() {
    }

}
