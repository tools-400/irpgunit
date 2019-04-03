/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.ui.editor;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.editors.text.TextEditor;

public class SpooledFileEditor extends TextEditor {

    public static final String ID = "de.tools400.rpgunit.spooledfileviewer.ui.editor.SpooledFileEditor"; //$NON-NLS-1$

    private String contentDescription;

    public SpooledFileEditor() {
        super();
        setSourceViewerConfiguration(new SourceViewerConfiguration());
    }

    @Override
    public void dispose() {
        super.dispose();
    }

    @Override
    protected void doSetInput(IEditorInput input) throws CoreException {
        super.doSetInput(input);
        contentDescription = ((SpooledFileEditorInput)input).getContentDescription();
    }

    @Override
    public String getContentDescription() {
        return contentDescription;
    }

}
