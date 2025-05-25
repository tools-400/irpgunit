/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.osgi.util.NLS;
import org.eclipse.rse.core.RSECorePlugin;
import org.eclipse.rse.core.subsystems.ISubSystem;
import org.eclipse.rse.files.ui.resources.SystemEditableRemoteFile;
import org.eclipse.rse.services.clientserver.messages.SystemMessageException;
import org.eclipse.rse.subsystems.files.core.subsystems.IRemoteFile;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.PlatformUI;

import com.ibm.etools.iseries.subsystems.ifs.files.IFSFileServiceSubSystem;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.ui.UIUtils;

public class EditableSourceStreamFile implements IEditableSource {
    private IBMiConnection connection;

    private String sourceStreamFile;

    private EditableSourceStreamFile(IBMiConnection aConnection, String aSourceStreamFile) {
        connection = aConnection;
        sourceStreamFile = aSourceStreamFile;
    }

    public static EditableSourceStreamFile getSourceStreamFile(IBMiConnection aConnection, String aSourceStreamFile) {
        if (aConnection == null || !isStreamFileSet(aSourceStreamFile)) {
            return null;
        }
        return new EditableSourceStreamFile(aConnection, aSourceStreamFile);
    }

    private static boolean isStreamFileSet(String aSourceStreamFile) {
        if (aSourceStreamFile == null) {
            return false;
        }
        if (aSourceStreamFile.length() == 0) {
            return false;
        }
        return true;
    }

    public void edit(int aLineNumber) {

        try {
            String editor = "com.ibm.etools.systems.editor";
            IEditorDescriptor editorDescriptor = PlatformUI.getWorkbench().getEditorRegistry().findEditor(editor);

            SystemEditableRemoteFile tEditableStreamFile = getEditableSourceMember(sourceStreamFile, editorDescriptor);
            if (tEditableStreamFile == null || !tEditableStreamFile.exists()) {
                UIUtils.displayError(NLS.bind(Messages.EditableSourceStreamFile_0, toString()));
                return;
            }
            // Open source in EDIT mode
            tEditableStreamFile.open(UIUtils.getShell(), false);
        } catch (Exception e) {
            UIUtils.displayError(NLS.bind(Messages.EditableSourceStreamFile_1, toString(), e.getLocalizedMessage()));
            RPGUnitCorePlugin.logError("Could not open source stream file: " + toString(), e); //$NON-NLS-1$
        } finally {
        }
    }

    public int getSequentialLineNumber(int aSequenceNumber) {

        return aSequenceNumber;
    }

    private SystemEditableRemoteFile getEditableSourceMember(String sourceStreamFile, IEditorDescriptor editorDescriptor) {

        IRemoteFile remoteFile = getRemoteStreamFile(sourceStreamFile);
        SystemEditableRemoteFile editableRemoteFile = new SystemEditableRemoteFile(remoteFile, editorDescriptor);

        return editableRemoteFile;
    }

    private IRemoteFile getRemoteStreamFile(String sourceStreamFile) {

        IRemoteFile remoteFile = null;

        ISubSystem[] sses = RSECorePlugin.getTheSystemRegistry().getSubSystems(connection.getHost());

        for (int i = 0; i < sses.length; i++) {

            if ((sses[i] instanceof IFSFileServiceSubSystem)) {

                IFSFileServiceSubSystem fileServiceSubSystem = (IFSFileServiceSubSystem)sses[i];

                NullProgressMonitor monitor = new NullProgressMonitor();

                try {

                    remoteFile = fileServiceSubSystem.getRemoteFileObject(sourceStreamFile, monitor);

                } catch (SystemMessageException e) {
                } catch (Exception e) {
                }

                break;

            }

        }

        return remoteFile;
    }

    @Override
    public String toString() {
        return sourceStreamFile;
    }
}
