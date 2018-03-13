/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.handlers.HandlerUtil;

import de.tools400.rpgunit.core.jobs.local.RunUnitTestsJob;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public abstract class AbstractRerunUnitTestsHandler extends AbstractUnitTestsHandler {

    protected abstract UnitTestSuite[] getSelectedUseCases(ExecutionEvent anEvent);

    @Override
    public Object execute(ExecutionEvent anEvent) {
        final RPGUnitView tView = getView(anEvent);
        if (tView == null) {
            return null;
        }

        UnitTestSuite[] tResults = getSelectedUseCases(anEvent);
        if (tResults == null || tResults.length == 0) {
            return null;
        }

        Shell tShell = HandlerUtil.getActiveShell(anEvent);

        RunUnitTestsJob tJob = new RunUnitTestsJob(tShell, tView, tResults);
        tJob.schedule();

        return null;
    }
}
