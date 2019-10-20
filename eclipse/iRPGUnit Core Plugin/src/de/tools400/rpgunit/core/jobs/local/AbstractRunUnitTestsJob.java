/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.local;

import java.util.Collection;
import java.util.Iterator;
import java.util.TreeSet;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.part.ViewPart;
import org.eclipse.ui.progress.UIJob;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.ui.view.ICursorProvider;
import de.tools400.rpgunit.core.ui.view.IInputProvider;

public abstract class AbstractRunUnitTestsJob extends Job {

    private Shell shell;

    private ViewPart view;

    private UnitTestSuite[] results;

    private AbstractRunUnitTestsJob(Shell aShell, ViewPart aView) {
        super("Run Unit Tests");
        shell = aShell;
        view = aView;
        results = null;
    }

    /**
     * Constructs a AbstractRunUnitTestsJob object for a selection of the
     * RPGUnit view.
     * 
     * @param aShell - the active shell
     * @param aView - view to display the result
     * @param aResults - selected unit tests of the RPGUnit view
     */
    public AbstractRunUnitTestsJob(Shell aShell, ViewPart aView, UnitTestSuite[] aResults) {
        this(aShell, aView);
        results = aResults;
    }

    /**
     * Constructs a AbstractRunUnitTestsJob object for a selection of the RSE
     * tree.
     * 
     * @param aShell - the active shell
     * @param aView - view to display the result
     * @param aSelection - selected items of the RSE tree
     */
    public AbstractRunUnitTestsJob(Shell aShell, ViewPart aView, IStructuredSelection aSelection) {
        this(aShell, aView);

        Collection<UnitTestSuite> tSelectedObjects = new TreeSet<UnitTestSuite>();

        for (Iterator<?> iter = aSelection.iterator(); iter.hasNext();) {

            Object tObject = iter.next();
            if (tObject instanceof I5ServiceProgram) {
                I5ServiceProgram selectedObject = (I5ServiceProgram)tObject;

                UnitTestSuite tUnitTestSuite = new UnitTestSuite(selectedObject);
                tSelectedObjects.add(tUnitTestSuite);
                tUnitTestSuite.setIncompleteProcedureList(false);

                String[] procedures = selectedObject.getProcedures();
                for (String tProcedureName : procedures) {
                    UnitTestCase tUnitTestCase = new UnitTestCase(tProcedureName);
                    tUnitTestSuite.addUnitTestCase(tUnitTestCase);
                    tUnitTestSuite.setIncompleteProcedureList(true);
                    tUnitTestCase.setSelected(true);
                }
            }
        }

        results = new UnitTestSuite[tSelectedObjects.size()];
        tSelectedObjects.toArray(results);
    }

    @Override
    protected IStatus run(IProgressMonitor monitor) {

        if (!(view instanceof ICursorProvider)) {
            RPGUnitCorePlugin.logError("Illegal argument passed to constructor of " + this.getClass().getSimpleName() //$NON-NLS-1$
                + ". Expect object of type ICursorProvider."); //$NON-NLS-1$
            return Status.CANCEL_STATUS;
        }

        if (!(view instanceof IInputProvider)) {
            RPGUnitCorePlugin.logError("Illegal argument passed to constructor of " + this.getClass().getSimpleName() //$NON-NLS-1$
                + ". Expect object of type IInputProvider."); //$NON-NLS-1$
            return Status.CANCEL_STATUS;
        }

        UnitTestSuite[] unitTestSuites = getUnitTestSuites();

        try {
            resetStatistics();
            setCursor(new Cursor(null, SWT.CURSOR_WAIT));
            IStatus status = asyncExecute(unitTestSuites, monitor);
            return status;
        } finally {
            returnResultToView(unitTestSuites);
            setCursor(new Cursor(null, SWT.CURSOR_ARROW));
        }
    }

    protected UnitTestSuite[] getUnitTestSuites() {
        return results;
    }

    protected void displayError(String aTitle, String aMessage) {
        UIDisplayErrorJob tJob = new UIDisplayErrorJob(shell, aTitle, aMessage);
        tJob.schedule();
    }

    protected void setCursor(Cursor aCursor) {
        if (view instanceof ICursorProvider) {
            UIJob uiUpdateJob = new UISetViewCursorJob((ICursorProvider)view, aCursor);
            uiUpdateJob.schedule();
        }
    }

    protected void returnResultToView(UnitTestSuite[] tUnitTestResults) {
        UISetInputJob tSetInputJob = new UISetInputJob((IInputProvider)view, tUnitTestResults);
        tSetInputJob.schedule();
    }

    protected void resetStatistics() {
        for (UnitTestSuite tUnitTestSuite : getUnitTestSuites()) {
            for (UnitTestCase tUnitTestcase : tUnitTestSuite.getUnitTestCases()) {
                tUnitTestcase.resetStatistics();
            }
        }
    }

    protected abstract IStatus asyncExecute(UnitTestSuite[] unitTestSuites, IProgressMonitor monitor);
}
