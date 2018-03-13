/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import java.util.Iterator;

import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.widgets.Shell;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.model.local.EditableSourceMember;
import de.tools400.rpgunit.core.model.local.IUnitTestItemWithSourceMember;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.warning.WarningMessage;

public class EditRemoteSourceMemberHandler extends AbstractUnitTestsHandler {

    private Shell shell;

    @Override
    public Object execute(ExecutionEvent anEvent) throws ExecutionException {

        shell = getView(anEvent).getSite().getShell();

        IStructuredSelection tSelection = getView(anEvent).getSelectedItems();
        editSourceMember(tSelection);
        return null;
    }

    public void editSourceMember(IStructuredSelection tSelection) {
        for (Iterator<?> tIterator = tSelection.iterator(); tIterator.hasNext();) {
            Object tElement = tIterator.next();

            EditableSourceMember tEditableSourceMember = null;
            int tStatementNumber = 0;
            if (tElement instanceof IUnitTestItemWithSourceMember) {
                IUnitTestItemWithSourceMember tUnitTestItemWithSource = (IUnitTestItemWithSourceMember)tElement;
                tEditableSourceMember = tUnitTestItemWithSource.getEditableSourceMember();
                tStatementNumber = tUnitTestItemWithSource.getStatementNumber();
            }
            if (tEditableSourceMember != null) {
                if (Preferences.getInstance().shallPositionToLine()) {
                    int lineNumber;
                    if (tStatementNumber > 0) {
                        lineNumber = tEditableSourceMember.getSequentialLineNumber(tStatementNumber);
                    } else {
                        lineNumber = 1;
                    }
                    tEditableSourceMember.edit(lineNumber);

                    if (lineNumber == -1) {
                        WarningMessage.openWarning(shell, Preferences.WARN_MESSAGE_SRC_OPTION,
                            Messages.Source_line_number_not_found_Did_you_compile_the_source_member_with_OPTION_SRCSTMT);
                    }
                } else {
                    tEditableSourceMember.edit(1);
                }
            }
        }
    }
}
