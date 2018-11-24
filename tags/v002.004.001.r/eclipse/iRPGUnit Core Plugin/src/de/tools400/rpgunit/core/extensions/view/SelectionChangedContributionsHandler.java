/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.extensions.view;

import java.util.ArrayList;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeSelection;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestReportFile;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;

public class SelectionChangedContributionsHandler {

    private static final String EXTENSION_ID = "de.tools400.rpgunit.core.extensions.view.IRPGUnitViewSelectionChanged"; //$NON-NLS-1$

    public Object execute(SelectionChangedEvent anEvent) {
        IExtensionRegistry tRegistry = Platform.getExtensionRegistry();
        evaluate(tRegistry, anEvent);
        return null;
    }

    private void evaluate(IExtensionRegistry registry, SelectionChangedEvent anEvent) {
        if (anEvent.getSelection().isEmpty()) {
            return;
        }

        if (!(anEvent.getSelection() instanceof TreeSelection)) {
            return;
        }

        TreeSelection tSelection = (TreeSelection)anEvent.getSelection();
        ArrayList<IRPGUnitSpooledFile> tSpooledFile = new ArrayList<IRPGUnitSpooledFile>();
        for (Object tTreeItem : tSelection.toArray()) {
            IRPGUnitSpooledFile tReportFile = null;
            if (tTreeItem instanceof UnitTestSuite) {
                tReportFile = ((UnitTestSuite)tTreeItem).getSpooledFile();
            } else if (tTreeItem instanceof UnitTestCase) {
                UnitTestCase tTestCase = (UnitTestCase)tTreeItem;
                if (tTestCase.hasStatistics()) {
                    tReportFile = tTestCase.getUnitTestSuite().getSpooledFile();
                }
            }
            if (tReportFile != null) {
                tSpooledFile.add(tReportFile);
            }
        }

        IConfigurationElement[] config = registry.getConfigurationElementsFor(EXTENSION_ID);
        try {
            for (IConfigurationElement e : config) {
                final Object o = e.createExecutableExtension("class"); //$NON-NLS-1$
                if (o instanceof IRPGUnitViewSelectionChanged) {
                    IRPGUnitViewSelectionChanged tHandler = (IRPGUnitViewSelectionChanged)o;
                    IRPGUnitSpooledFile[] tSpooledFiles = new UnitTestReportFile[tSpooledFile.size()];
                    tSpooledFile.toArray(tSpooledFiles);
                    tHandler.selectionChanged(tSpooledFiles);
                }
            }
        } catch (CoreException ex) {
            RPGUnitCorePlugin.logError("Failed to call extension-point: " + EXTENSION_ID, ex); //$NON-NLS-1$
        }
    }
}
