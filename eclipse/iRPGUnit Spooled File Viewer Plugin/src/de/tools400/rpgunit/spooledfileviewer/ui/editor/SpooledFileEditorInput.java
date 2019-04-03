/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.ui.editor;

import org.eclipse.core.resources.IStorage;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.PlatformObject;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IPersistableElement;
import org.eclipse.ui.IStorageEditorInput;
import org.eclipse.ui.IWorkbenchPage;

import com.ibm.as400.access.SpooledFile;

import de.tools400.rpgunit.spooledfileviewer.RPGUnitSpooledFileViewer;

public class SpooledFileEditorInput extends PlatformObject implements IStorageEditorInput {
    private String testSuite;

    private SpooledFileStorage storage;

    public SpooledFileEditorInput(String aTestSuite, SpooledFile aSpooledFile) {
        testSuite = aTestSuite;
        storage = new SpooledFileStorage(aSpooledFile);
    }

    @Override
    public IStorage getStorage() throws CoreException {
        return storage;
    }

    @Override
    public boolean exists() {
        return false;
    }

    @Override
    public String getName() {
        return storage.getFullQualifiedName();
    }

    @Override
    public IPersistableElement getPersistable() {
        return null;
    }

    @Override
    public String getToolTipText() {
        return storage.getFullQualifiedName();
    }

    @Override
    public ImageDescriptor getImageDescriptor() {
        return null;
    }

    public String getContentDescription() {
        return storage.getFullQualifiedName();
    }

    public boolean isSameSpooledFile(IEditorInput anEditorInput) throws CoreException {
        if (anEditorInput == this) {
            return true;
        }
        if (!(anEditorInput instanceof SpooledFileEditorInput)) {
            return false;
        }
        SpooledFileEditorInput tEditorInput = (SpooledFileEditorInput)anEditorInput;
        if (testSuite == null || tEditorInput.getTestSuite() == null) {
            return false;
        }
        return getTestSuite().equals(tEditorInput.getTestSuite());
    }

    public String getTestSuite() {
        return testSuite;
    }

    public SpooledFileEditor findEditor(IWorkbenchPage aPage) {
        if (aPage == null) {
            return null;
        }

        IEditorReference[] tEditors = aPage.getEditorReferences();
        for (IEditorReference tEditorReference : tEditors) {
            try {
                if (isSameSpooledFile(tEditorReference.getEditorInput())) {
                    IEditorPart tEditor = tEditorReference.getEditor(true);
                    if (tEditor instanceof SpooledFileEditor) {
                        return (SpooledFileEditor)tEditor;
                    }
                }
            } catch (Exception e) {
                RPGUnitSpooledFileViewer.logError("Could not find 'SpooledFileEditor'.", e); //$NON-NLS-1$
            }
        }
        return null;
    }
}