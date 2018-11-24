/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.ui.editor;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import org.eclipse.core.resources.IStorage;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.PlatformObject;

import com.ibm.as400.access.ObjectDescription;
import com.ibm.as400.access.ObjectList;
import com.ibm.as400.access.PrintObject;
import com.ibm.as400.access.PrintParameterList;
import com.ibm.as400.access.SpooledFile;

import de.tools400.rpgunit.spooledfileviewer.RPGUnitSpooledFileViewer;
import de.tools400.rpgunit.spooledfileviewer.preferences.Preferences;

public class SpooledFileStorage extends PlatformObject implements IStorage {

    private SpooledFile spool = null;

    private String detailedName = null;

    private String userData = null;

    public SpooledFileStorage(SpooledFile aSpooledFile) {
        spool = aSpooledFile;
        detailedName = spool.getName() + " - " + " (" + spool.getJobName() + "/" + spool.getJobNumber() + "/" + spool.getJobUser() + ") - " //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$ //$NON-NLS-5$
            + spool.getNumber();

        try {
            userData = spool.getStringAttribute(SpooledFile.ATTR_USERDATA);
        } catch (Exception e) {
            logException("Could not retrieve user data of spooled file: ", e); //$NON-NLS-1$
        }
    }

    public String getFullQualifiedName() {
        return detailedName;
    }

    @Override
    public String getName() {
        try {
            return getUserData();
        } catch (Exception e) {
            logException("Error getting name from spooled file.", e); //$NON-NLS-1$
            return "*N"; //$NON-NLS-1$
        }
    }

    private String getUserData() {
        return userData;
    }

    @Override
    public InputStream getContents() throws CoreException {

        // get the text (via a transformed input stream) from the spooled file
        try {

            String tWscstName = Preferences.getInstance().getHostPrintTransformWscst();
            String tLibrary = Preferences.getInstance().getProductLibrary();

            ObjectList objects = new ObjectList(spool.getSystem(), tLibrary, tWscstName, "*WSCST"); //$NON-NLS-1$
            objects.load();
            if (!objects.getObjects().hasMoreElements()) {
                return getWscstNotFoundErrorMessageAsStream(tWscstName, tLibrary);
            }
            ObjectDescription tWscstObj = (ObjectDescription)objects.getObjects().nextElement();

            PrintParameterList tPrintParms = new PrintParameterList();
            tPrintParms.setParameter(PrintObject.ATTR_WORKSTATION_CUST_OBJECT, tWscstObj.getPath());
            tPrintParms.setParameter(PrintObject.ATTR_MFGTYPE, "*WSCST"); //$NON-NLS-1$
            return spool.getTransformedInputStream(tPrintParms);
        } catch (Exception e) {
            String tError = logException("Could not get input stream of spooled file: ", e); //$NON-NLS-1$
            return new ByteArrayInputStream(tError.getBytes());
        }
    }

    private InputStream getWscstNotFoundErrorMessageAsStream(String aWscst, String aLibrary) {
        InputStream tInpStream;
        tInpStream = new ByteArrayInputStream(("ERROR: Object " + aWscst + " (" + "*WSCST" + ") in Library " + aLibrary + " not found.").getBytes()); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$ //$NON-NLS-5$
        return tInpStream;
    }

    @Override
    public IPath getFullPath() {
        return null;
    }

    @Override
    public boolean isReadOnly() {
        return true;
    }

    private String logException(String aText, Exception anException) {
        String tText = aText + detailedName + anException.getLocalizedMessage();
        RPGUnitSpooledFileViewer.logError(tText);
        return tText;
    }
}
