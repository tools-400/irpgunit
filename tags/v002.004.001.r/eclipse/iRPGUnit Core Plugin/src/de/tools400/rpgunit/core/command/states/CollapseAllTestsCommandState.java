/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.command.states;

public class CollapseAllTestsCommandState extends AbstractEnabledDisabledStateProvider {
    public final static String STATE = "de.tools400.rpgunit.core.commands.state.collapseallunittests.enabled"; //$NON-NLS-1$

    @Override
    protected String getState() {
        return STATE;
    }
}
