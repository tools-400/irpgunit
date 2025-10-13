/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

/**
 * This Interface defines the IDs of the Eclipse org.eclipse.ui.commands
 * extension point.
 * 
 * @author Thomas Raddatz
 */
public interface Command {
    public String RUN_UNIT_TEST = "de.tools400.rpgunit.core.command.rununittest"; //$NON-NLS-1$

    public String RERUN_ALL_TESTS = "de.tools400.rpgunit.core.command.rerunalltests"; //$NON-NLS-1$

    public String RERUN_SELECTED_TESTS = "de.tools400.rpgunit.core.command.rerunselectedunittests"; //$NON-NLS-1$

    public String TOGGLE_SHOW_FAILURES = "de.tools400.rpgunit.core.command.toggleshowfailures"; //$NON-NLS-1$

    public String TOGGLE_DISABLE_REPORT = "de.tools400.rpgunit.core.command.toggledisablereport"; //$NON-NLS-1$

    public String TOGGLE_ENABLE_DEBUG_MODE = "de.tools400.rpgunit.core.command.toggleenabledebugmode"; //$NON-NLS-1$

    public String TOGGLE_COMPARE_VIEWER = "de.tools400.rpgunit.core.command.togglecompareviewervisible"; //$NON-NLS-1$
}
