/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.handler;

import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.services.ISourceProviderService;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitViewSelectionChanged;
import de.tools400.rpgunit.spooledfileviewer.RPGUnitSpooledFileViewer;
import de.tools400.rpgunit.spooledfileviewer.command.states.DisplayReportCommandState;

public class DisplayReportEnabler implements IRPGUnitViewSelectionChanged {

    @Override
    public void selectionChanged(IRPGUnitSpooledFile[] aSpooledFiles) {
        ISourceProviderService sourceProviderService = (ISourceProviderService)PlatformUI.getWorkbench().getService(ISourceProviderService.class);

        // Enable/disable command: DisplayReport
        DisplayReportCommandState tDisplayReportState = (DisplayReportCommandState)sourceProviderService
            .getSourceProvider(DisplayReportCommandState.STATE);
        if (aSpooledFiles != null && aSpooledFiles.length > 0) {
            tDisplayReportState.setEnabled(true);
            RPGUnitSpooledFileViewer.getDefault().getSpooledFilesStore().setSpooledFiles(aSpooledFiles);
        } else {
            RPGUnitSpooledFileViewer.getDefault().getSpooledFilesStore().setSpooledFiles(new IRPGUnitSpooledFile[0]);
            tDisplayReportState.setEnabled(false);
        }
    }

}
