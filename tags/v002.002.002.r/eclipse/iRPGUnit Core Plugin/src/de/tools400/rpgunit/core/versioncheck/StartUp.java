/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.versioncheck;

import org.eclipse.ui.IStartup;

import de.tools400.rpgunit.core.preferences.Preferences;

public class StartUp implements IStartup {

    public void earlyStartup() {

        // Dummy read to enforce preferences update
        Preferences.getInstance().getProductLibrary();

        PluginCheck.check();

    }

}
