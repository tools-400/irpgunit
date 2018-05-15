/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.local;

import java.util.ArrayList;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.part.ViewPart;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.handler.UnitTestException;
import de.tools400.rpgunit.core.jobs.ibmi.RPGUnitTestRunner;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.preferences.Preferences;

public class RunUnitTestsJob extends AbstractRunUnitTestsJob {

    private static final String ERROR_TITLE = Messages.Run_Unit_Test;

    /**
     * Constructs a RunUnitTestsJob object for a selection of the RPGUnit view.
     * 
     * @param aShell - the active shell
     * @param aView - view to display the result
     * @param aUnitTestSuites - selected unit tests of the RPGUnit view
     */
    public RunUnitTestsJob(Shell aShell, ViewPart aView, UnitTestSuite[] aUnitTestSuites) {
        super(aShell, aView, aUnitTestSuites);
    }

    /**
     * Constructs a RunUnitTestsJob object for a selection of the RSE tree.
     * 
     * @param aShell - the active shell
     * @param aView - view to display the result
     * @param aSelection - selected items of the RSE tree
     */
    public RunUnitTestsJob(Shell aShell, ViewPart aView, IStructuredSelection aSelection) {
        super(aShell, aView, aSelection);
    }

    @Override
    protected IStatus execute() {

        setCursor(new Cursor(null, SWT.CURSOR_WAIT));

        try {

            resetStatistics();

            for (UnitTestSuite tUnitTestSuite : getUnitTestSuites()) {

                if (tUnitTestSuite.isSelected() || tUnitTestSuite.isPartiallySelected()) {

                    I5ServiceProgram tUnitTestServiceProgram = tUnitTestSuite.getServiceProgram();

                    RPGUnitTestRunner tRunner = new RPGUnitTestRunner(tUnitTestServiceProgram.getLibrary().getConnection());
                    if (!tRunner.isAvailable()) {
                        displayError(
                            ERROR_TITLE,
                            Messages.bind(Messages.Can_not_execute_unit_test_due_to_missing_unit_test_runner,
                                new Object[] { tUnitTestServiceProgram.getLibrary(), tUnitTestServiceProgram.getName(), tRunner.toString(),
                                    Preferences.getInstance().getProductLibrary() }));

                        return Status.CANCEL_STATUS;
                    }

                    try {

                        UnitTestSuite tUnitTestResult = null;

                        if (tUnitTestSuite.isPartiallySelected()) {
                            ArrayList<String> tUnitTestCasesSelected = new ArrayList<String>();

                            for (UnitTestCase tUnitTestCase : tUnitTestSuite.getUnitsTestCases()) {
                                if (tUnitTestCase.isSelected()) {
                                    tUnitTestCasesSelected.add(tUnitTestCase.getProcedure());
                                }
                            }
                            tUnitTestResult = tRunner.runRemoteUnitTestCase(tUnitTestServiceProgram, tUnitTestCasesSelected);
                        } else {
                            tUnitTestResult = tRunner.runRemoteUnitTestSuite(tUnitTestServiceProgram);
                        }

                        if (tUnitTestResult != null) {
                            tUnitTestSuite.updateUnitTestResult(tUnitTestResult);
                        }

                    } catch (UnitTestException ute) {
                        if (ute.getType() == UnitTestException.Type.noTestCases) {
                            displayError(ERROR_TITLE,
                                Messages.bind(Messages.The_object_A_does_not_contain_any_test_cases, tUnitTestServiceProgram.getName()));
                        } else {
                            displayError(ERROR_TITLE, ute.getLocalizedMessage());
                        }
                        return Status.CANCEL_STATUS;

                    } catch (Exception e) {
                        displayError(
                            ERROR_TITLE,
                            Messages.bind(Messages.The_unit_test_A_has_not_finished_successful_B, new Object[] { tUnitTestServiceProgram.toString(),
                                e.getLocalizedMessage() }));
                        return Status.CANCEL_STATUS;
                    }
                } else {
                    tUnitTestSuite.setRuns(0);
                }
            }

            returnResultToView(getUnitTestSuites());

            return Status.OK_STATUS;

        } finally {
            setCursor(new Cursor(null, SWT.CURSOR_ARROW));
        }
    }
}