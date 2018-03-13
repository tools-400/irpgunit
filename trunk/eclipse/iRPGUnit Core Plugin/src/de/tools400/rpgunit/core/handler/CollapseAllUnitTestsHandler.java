/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import org.eclipse.core.commands.ExecutionEvent;

public class CollapseAllUnitTestsHandler extends AbstractUnitTestsHandler {

    /**
     * Expands all RPGUnit tests of the RPGUnit view.
     */
    @Override
    public Object execute(ExecutionEvent anEvent) {
        getView(anEvent).collapseAll();
        return null;
    }
}
