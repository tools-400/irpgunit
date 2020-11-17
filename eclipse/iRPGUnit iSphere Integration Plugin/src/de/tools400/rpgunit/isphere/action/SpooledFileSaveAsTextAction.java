/*******************************************************************************
 * Copyright (c) 2013-2020 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.isphere.action;

import biz.isphere.core.internal.exception.CanceledByUserException;
import biz.isphere.core.preferencepages.IPreferences;
import biz.isphere.core.spooledfiles.SpooledFile;

public class SpooledFileSaveAsTextAction extends AbstractSpooledFileAction {

    public static final String ID = "de.tools400.rpgunit.isphere.action.SpooledFileSaveAsTextAction"; //$NON-NLS-1$

    @Override
    public String execute(SpooledFile spooledFile) throws CanceledByUserException {
        return spooledFile.saveWithCancelOption(getShell(), IPreferences.OUTPUT_FORMAT_TEXT);
    }
}
