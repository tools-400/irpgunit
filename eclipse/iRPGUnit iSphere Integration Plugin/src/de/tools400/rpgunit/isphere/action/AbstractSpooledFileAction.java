/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.isphere.action;

import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;

import biz.isphere.core.spooledfiles.SpooledFile;

import com.ibm.etools.iseries.rse.ui.actions.popupmenu.ISeriesAbstractQSYSPopupMenuAction;

import de.tools400.rpgunit.core.extensions.testcase.IRPGUnitTestCaseItem;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.isphere.Messages;
import de.tools400.rpgunit.isphere.factory.ISphereFactory;

public abstract class AbstractSpooledFileAction extends ISeriesAbstractQSYSPopupMenuAction {

    @Override
    public void run() {

        String message = null;

        Object[] selection = getSelectedRemoteObjects();
        for (int i = 0; i < selection.length; i++) {
            if (selection[i] instanceof IRPGUnitTestCaseItem) {
                IRPGUnitTestCaseItem testCaseItem = (IRPGUnitTestCaseItem)selection[i];
                IRPGUnitSpooledFile rpgunitSpooledFile = testCaseItem.getSpooledFile();
                if (rpgunitSpooledFile != null) {
                    SpooledFile spooledFile = ISphereFactory.createSpooledFile(rpgunitSpooledFile);
                    message = execute(spooledFile);
                } else {
                    message = Messages.No_spooled_file_available;
                }
            }
            if (message != null) {
                MessageDialog.openError(Display.getCurrent().getActiveShell(), Messages.Error, message);
                break;
            }
        }

    }

    public abstract String execute(SpooledFile spooledFile);

}
