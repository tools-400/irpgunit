/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.isphere.action;

import biz.isphere.core.preferencepages.IPreferences;
import biz.isphere.core.spooledfiles.SpooledFile;

public class SpooledFileOpenAsPDFAction extends AbstractSpooledFileAction {

    public static final String ID = "de.tools400.rpgunit.isphere.action.SpooledFileOpenAsPDFAction"; //$NON-NLS-1$

    @Override
    public String execute(SpooledFile spooledFile) {
        return spooledFile.open(IPreferences.OUTPUT_FORMAT_PDF);
    }
}
