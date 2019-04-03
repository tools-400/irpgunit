/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.handler;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.SpooledFile;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.spooledfileviewer.RPGUnitSpooledFileViewer;
import de.tools400.rpgunit.spooledfileviewer.ui.editor.SpooledFileEditor;
import de.tools400.rpgunit.spooledfileviewer.ui.editor.SpooledFileEditorInput;

public class DisplayReportHandler extends AbstractHandler {

    @Override
    public Object execute(ExecutionEvent anEvent) throws ExecutionException {

        IRPGUnitSpooledFile[] tReportFiles = RPGUnitSpooledFileViewer.getDefault().getSpooledFilesStore().getSpooledFiles();

        for (IRPGUnitSpooledFile tReportFile : tReportFiles) {
            if (tReportFile != null) {

                try {
                    AS400 tSystem = IBMiConnection.getConnection(tReportFile.getConnectionName()).getAS400ToolboxObject();
                    SpooledFile tSpooledFile = new SpooledFile(tSystem, tReportFile.getName(), tReportFile.getNumber(), tReportFile.getJobName(),
                        tReportFile.getJobUser(), tReportFile.getJobNumber());
                    SpooledFileEditorInput tEditorInput = new SpooledFileEditorInput(tReportFile.getTestSuite(), tSpooledFile);

                    IWorkbenchPage tPage = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
                    SpooledFileEditor tEditor = tEditorInput.findEditor(tPage);
                    if (tEditor != null) {
                        tEditor.setInput(tEditorInput);
                        return null;
                    }

                    if (true) {
                        if (tPage != null) {
                            tPage.openEditor(tEditorInput, SpooledFileEditor.ID);
                        }
                    }

                } catch (Exception e) {
                    RPGUnitSpooledFileViewer.logError("Could not open spooled file: " + tReportFile.getName(), e); //$NON-NLS-1$
                    return null;
                }
            }
        }

        return null;
    }
}
