/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.local;

import java.util.Arrays;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.viewers.IStructuredSelection;
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
    protected IStatus asyncExecute(UnitTestSuite[] unitTestSuites, IProgressMonitor monitor) {

        monitor.beginTask("Testing ...", unitTestSuites.length);

        DoExecute executer = new DoExecute(unitTestSuites, monitor);
        executer.start();

        while (executer.isAlive()) {

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
            }

        }

        monitor.done();

        return executer.getStatus();
    }

    private class DoExecute extends Thread {

        private UnitTestSuite[] unitTestSuites;
        private IProgressMonitor monitor;

        private IStatus status;

        public DoExecute(UnitTestSuite[] unitTestSuites, IProgressMonitor monitor) {
            this.unitTestSuites = unitTestSuites;
            this.monitor = monitor;
            this.status = null;
        }

        public IStatus getStatus() {
            return status;
        }

        @Override
        public void run() {

            status = Status.OK_STATUS;

            for (UnitTestSuite tUnitTestSuite : unitTestSuites) {

                if (monitor.isCanceled()) {
                    System.out.println("Canceling test suite: " + tUnitTestSuite.getServiceProgram().getName());
                    cancelJob(tUnitTestSuite);
                } else {

                    // TODO: remove thread sleep
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e1) {
                    }

                    System.out.println("Executing test suite (" + tUnitTestSuite.getServiceProgram().getName() + ") ...");
                    I5ServiceProgram tUnitTestServiceProgram = tUnitTestSuite.getServiceProgram();

                    RPGUnitTestRunner tRunner = new RPGUnitTestRunner(tUnitTestServiceProgram.getLibrary().getConnection());
                    if (!tRunner.isAvailable()) {
                        displayError(ERROR_TITLE,
                            Messages.bind(Messages.Can_not_execute_unit_test_due_to_missing_unit_test_runner,
                                new Object[] { tUnitTestServiceProgram.getLibrary(), tUnitTestServiceProgram.getName(), tRunner.toString(),
                                    Preferences.getInstance().getProductLibrary() }));

                        cancelJob(tUnitTestSuite);
                    }

                    try {

                        UnitTestSuite tUnitTestResult = null;

                        if (tUnitTestSuite.isPartiallySelected()) {
                            tUnitTestResult = tRunner.runRemoteUnitTestCases(tUnitTestServiceProgram,
                                Arrays.asList(tUnitTestSuite.getSelectedUnitTestProcedureNames()));
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
                        cancelJob(tUnitTestSuite);

                    } catch (Exception e) {
                        displayError(ERROR_TITLE, Messages.bind(Messages.The_unit_test_A_has_not_finished_successful_B,
                            new Object[] { tUnitTestServiceProgram.toString(), e.getLocalizedMessage() }));
                        cancelJob(tUnitTestSuite);
                    } finally {
                        deselectUnitTestCases(tUnitTestSuite);
                    }

                    System.out.println("... Updating: worked (" + tUnitTestSuite.getServiceProgram().getName() + ")");
                    monitor.worked(1);
                }

            }

        }

        private void cancelJob(UnitTestSuite aUnitTestSuite) {
            aUnitTestSuite.cancel();
            monitor.setCanceled(true);
            status = Status.CANCEL_STATUS;
        }

        private void deselectUnitTestCases(UnitTestSuite aUnitTestSuite) {
            for (UnitTestCase tUnitTestCase : aUnitTestSuite.getUnitTestCases()) {
                if (tUnitTestCase.isSelected()) {
                    tUnitTestCase.setSelected(false);
                }
            }
        }

    }
}