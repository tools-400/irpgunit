/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.ExecutionEvent;

import de.tools400.rpgunit.core.model.local.UnitTestSuite;

public class RerunSelectedUnitTestsHandler extends AbstractRerunUnitTestsHandler {

    /**
     * Reruns the selected RPGUnit Test Cases from the RPGUnit view.
     */
    @Override
    protected UnitTestSuite[] getSelectedUseCases(ExecutionEvent anEvent) {
        return getView(anEvent).getSelectedUnitTestCases();
    }
}
