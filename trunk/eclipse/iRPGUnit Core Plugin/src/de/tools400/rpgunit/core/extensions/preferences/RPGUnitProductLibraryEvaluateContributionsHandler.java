/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.extensions.preferences;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;

public class RPGUnitProductLibraryEvaluateContributionsHandler {

    private static final String EXTENSION_ID = "de.tools400.rpgunit.core.extensions.preferences.IRPGUnitProductLibrary"; //$NON-NLS-1$

    public Object execute(String aLibrary) {
        IExtensionRegistry tRegistry = Platform.getExtensionRegistry();
        evaluate(tRegistry, aLibrary);
        return null;
    }

    private void evaluate(IExtensionRegistry registry, String aLibrary) {

        IConfigurationElement[] config = registry.getConfigurationElementsFor(EXTENSION_ID);
        try {
            for (IConfigurationElement e : config) {
                final Object o = e.createExecutableExtension("class"); //$NON-NLS-1$
                if (o instanceof IRPGUnitProductLibrary) {
                    IRPGUnitProductLibrary tExtension = (IRPGUnitProductLibrary)o;
                    tExtension.propagateProductLibrary(aLibrary);
                }
            }
        } catch (CoreException ex) {
            RPGUnitCorePlugin.logError("Failed to call extension-point: " + EXTENSION_ID, ex); //$NON-NLS-1$
        }
    }
}
