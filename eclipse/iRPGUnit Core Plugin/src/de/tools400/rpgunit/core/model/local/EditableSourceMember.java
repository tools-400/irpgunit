/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.eclipse.core.resources.IFile;
import org.eclipse.osgi.util.NLS;
import org.eclipse.rse.services.clientserver.messages.SystemMessageException;

import com.ibm.etools.iseries.rse.ui.resources.QSYSEditableRemoteSourceFileMember;
import com.ibm.etools.iseries.services.qsys.api.IQSYSMember;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.ui.UIUtils;

public class EditableSourceMember implements IEditableSource {
    private IBMiConnection connection;

    private String sourceFile;

    private String sourceLibrary;

    private String sourceMember;

    private EditableSourceMember(IBMiConnection aConnection, String aSourceFile, String aSourceLibrary, String aSourceMember) {
        connection = aConnection;
        sourceFile = aSourceFile;
        sourceLibrary = aSourceLibrary;
        sourceMember = aSourceMember;
    }

    public static EditableSourceMember getSourceMember(IBMiConnection aConnection, String aSourceFile, String aSourceLibrary, String aSourceMember) {
        if (aConnection == null || !isMemberSet(aSourceFile, aSourceLibrary, aSourceMember)) {
            return null;
        }
        return new EditableSourceMember(aConnection, aSourceFile, aSourceLibrary, aSourceMember);
    }

    private static boolean isMemberSet(String aSourceFile, String aSourceLibrary, String aSourceMember) {
        if (aSourceFile == null || aSourceLibrary == null || aSourceMember == null) {
            return false;
        }
        if (aSourceFile.length() == 0 || aSourceLibrary.length() == 0 || aSourceMember.length() == 0) {
            return false;
        }
        return true;
    }

    public void edit(int aLineNumber) {

        try {
            QSYSEditableRemoteSourceFileMember tEditableMember = getEditableSourceMember();
            if (tEditableMember == null || !tEditableMember.exists()) {
                UIUtils.displayError(NLS.bind(Messages.EditableSourceMember_0, toString()));
                return;
            }
            // Open source in EDIT mode
            tEditableMember.open(UIUtils.getShell(), false, aLineNumber);
        } catch (Exception e) {
            UIUtils.displayError(NLS.bind(Messages.EditableSourceMember_1, toString(), e.getLocalizedMessage()));
            RPGUnitCorePlugin.logError("Could not open source member: " + toString(), e); //$NON-NLS-1$
        } finally {
        }
    }

    public int getSequentialLineNumber(int aSequenceNumber) {

        InputStream tInpStream = null;
        BufferedReader tReader = null;

        try {

            int tLineNumber = -1;

            QSYSEditableRemoteSourceFileMember tEditableMember = getEditableSourceMember();
            if (tEditableMember == null) {
                return tLineNumber;
            }

            IFile tLocalResource = tEditableMember.getAndCreateLocalResource();
            if (tLocalResource == null) {
                return tLineNumber;
            }

            tInpStream = tLocalResource.getContents();
            tReader = new BufferedReader(new InputStreamReader(tInpStream));
            int tCount = 0;
            String line;
            while ((line = tReader.readLine()) != null) {
                tCount++;
                Integer lineNbr = Integer.parseInt(line.substring(0, 6));
                if (lineNbr == null) {
                    break;
                }
                if (lineNbr.intValue() == aSequenceNumber) {
                    tLineNumber = tCount;
                    break;
                }
            }

            return tLineNumber;

        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Failed to get sequential source line number for member: " + toString(), e); //$NON-NLS-1$
        } finally {
            try {
                if (tReader != null) {
                    tReader.close();
                }
            } catch (IOException e) {
            }
            try {
                if (tInpStream != null) {
                    tInpStream.close();
                }
            } catch (IOException e) {
            }
        }

        return -1;
    }

    private QSYSEditableRemoteSourceFileMember getEditableSourceMember() throws SystemMessageException, InterruptedException {

        IQSYSMember tMember = connection.getMember(sourceLibrary, sourceFile, sourceMember, null);
        if (tMember == null || !tMember.exists()) {
            return null;
        }

        return new QSYSEditableRemoteSourceFileMember(tMember);
    }

    @Override
    public String toString() {
        return sourceLibrary + "/" + sourceFile + "." + sourceMember; //$NON-NLS-1$ //$NON-NLS-2$
    }
}
