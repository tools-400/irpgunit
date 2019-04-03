/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import java.util.ArrayList;

import org.eclipse.core.commands.ExecutionEvent;

import de.tools400.rpgunit.core.model.local.UnitTestSuite;

public class RemoveSelectedUnitTestsHandler extends AbstractUnitTestsHandler {

    @Override
    public Object execute(ExecutionEvent anEvent) {
        UnitTestSuite[] tSelectedUnitTestSuites = getView(anEvent).getSelectedUnitTestCases();

        ArrayList<UnitTestSuite> tUnitTestSuites = new ArrayList<UnitTestSuite>();
        for (UnitTestSuite tUnitTestSuite : tSelectedUnitTestSuites) {
            if (!tUnitTestSuite.isSelected()) {
                tUnitTestSuites.add(tUnitTestSuite);
            }
        }

        UnitTestSuite[] tUnitTestSuiteArray = new UnitTestSuite[tUnitTestSuites.size()];
        getView(anEvent).setInput(tUnitTestSuites.toArray(tUnitTestSuiteArray), false);

        return null;
    }

}
