/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.handler;

import de.tools400.rpgunit.core.extensions.preferences.IRPGUnitProductLibrary;
import de.tools400.rpgunit.spooledfileviewer.preferences.Preferences;

public class ReceiveProductLibraryHandler implements IRPGUnitProductLibrary {

    @Override
    public void propagateProductLibrary(String aLibrary) {
        Preferences.getInstance().setProductLibrary(aLibrary);
    }
}
