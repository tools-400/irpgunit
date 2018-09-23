/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.extensions.testcase;

import java.util.ArrayList;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.model.local.UnitTestReportFile;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;

public class UpdateTestResultContributionsHandler {

    private static final String EXTENSION_ID = "de.tools400.rpgunit.core.extensions.testcase.IRPGUnitUpdateTestResult"; //$NON-NLS-1$

    public Object execute(UnitTestSuite[] anEvent) {
        IExtensionRegistry tRegistry = Platform.getExtensionRegistry();
        evaluate(tRegistry, anEvent);
        return null;
    }

    private void evaluate(IExtensionRegistry registry, UnitTestSuite[] tUnitTestSuites) {
        if (tUnitTestSuites == null) {
            return;
        }

        ArrayList<IRPGUnitSpooledFile> tSpooledFile = new ArrayList<IRPGUnitSpooledFile>();
        for (UnitTestSuite tUnitTestSuite : tUnitTestSuites) {
            if (tUnitTestSuite.hasStatistics()) {
                tSpooledFile.add(tUnitTestSuite.getSpooledFile());
            }
        }

        IConfigurationElement[] config = registry.getConfigurationElementsFor(EXTENSION_ID);
        try {
            for (IConfigurationElement e : config) {
                final Object o = e.createExecutableExtension("class"); //$NON-NLS-1$
                if (o instanceof IRPGUnitUpdateTestResult) {
                    IRPGUnitUpdateTestResult tHandler = (IRPGUnitUpdateTestResult)o;
                    IRPGUnitSpooledFile[] tSpooledFiles = new UnitTestReportFile[tSpooledFile.size()];
                    tSpooledFile.toArray(tSpooledFiles);
                    tHandler.updateTestResult(tSpooledFiles);
                }
            }
        } catch (CoreException ex) {
            RPGUnitCorePlugin.logError("Failed to call extension-point: " + EXTENSION_ID, ex); //$NON-NLS-1$
        }
    }
}
