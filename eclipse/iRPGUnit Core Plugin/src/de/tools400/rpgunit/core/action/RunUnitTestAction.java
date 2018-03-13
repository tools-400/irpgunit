/*******************************************************************************
 * Copyright (c) 2013-2017 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.action;

import java.util.Calendar;
import java.util.List;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.action.IAction;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

import com.ibm.etools.iseries.services.qsys.api.IQSYSModule;
import com.ibm.etools.iseries.services.qsys.api.IQSYSProgramBase;
import com.ibm.etools.iseries.services.qsys.api.IQSYSServiceProgram;
import com.ibm.etools.iseries.subsystems.qsys.objects.QSYSRemoteProcedure;
import com.ibm.etools.iseries.subsystems.qsys.objects.QSYSRemoteProgramModule;
import com.ibm.etools.iseries.subsystems.qsys.objects.QSYSRemoteServiceProgram;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.handler.ISelectionHandler;
import de.tools400.rpgunit.core.handler.RunUnitTestHandler;
import de.tools400.rpgunit.core.model.ibmi.I5Library;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.UIUtils;
import de.tools400.rpgunit.core.ui.warning.WarningMessage;

/**
 * An action that runs a command to run a unit test suite on an i5 server. The
 * action is restricted to service programs that have the user defined attribute
 * set to 'RPGUNIT'.
 */
public class RunUnitTestAction extends AbstractRemoteAction<IQSYSServiceProgram> {

    private static final String RPGUNIT_LABEL = "RPGUNIT"; //$NON-NLS-1$

    private static final String TEST_PROC_NAME_PREFIX = "TEST";

    static long lastWarnMsg = 0;

    /**
     * Constructor for RunUnitTestAction.
     */
    public RunUnitTestAction() {
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IActionDelegate#run(org.eclipse.jface.action.IAction)
     */
    @Override
    public void executeAction(IAction action) {
        try {
            ISelectionHandler tHandler = new RunUnitTestHandler();
            tHandler.execute(getSelectedItems());
        } catch (ExecutionException e) {
            UIUtils.displayError(e);
        }
        return;
    }

    @Override
    protected boolean isValidItem(Object anObject) {

        if (!isSupportedObject(anObject)) {
            return false;
        }

        return true;
    }

    private boolean isSupportedObject(Object anObject) {

        if (anObject instanceof IQSYSServiceProgram) {
            return checkServiceProgram((IQSYSServiceProgram)anObject);
        }

        if (anObject instanceof QSYSRemoteProcedure) {
            return checkRemoteProcedure((QSYSRemoteProcedure)anObject);
        }

        return false;
    }

    private boolean checkServiceProgram(IQSYSServiceProgram aServiceprogram) {

        if (Preferences.CHECK_TEST_SUITE_NONE.equals(Preferences.getInstance().getCheckTestSuite())) {
            return true;
        }

        if (Preferences.CHECK_TEST_SUITE_TEXT.equals(Preferences.getInstance().getCheckTestSuite())) {
            return checkTextDescription(aServiceprogram);
        }

        return checkUserDefinedAttribute(aServiceprogram);
    }

    private boolean checkTextDescription(IQSYSServiceProgram aServiceprogram) {

        String tDescription = aServiceprogram.getDescription();
        if (tDescription == null) {
            return false;
        }

        if (!tDescription.toUpperCase().startsWith(RPGUNIT_LABEL)) {
            return false;
        }

        return true;
    }

    private boolean checkUserDefinedAttribute(IQSYSServiceProgram aServiceprogram) {

        String tUserDefinedAttribute = aServiceprogram.getUserDefinedAttribute();
        if (tUserDefinedAttribute == null && ((Calendar.getInstance().getTimeInMillis() - lastWarnMsg) > 1000 || lastWarnMsg == 0)) {
            Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
            WarningMessage.openWarning(shell, Preferences.WARN_MESSAGE_USER_DEFINED_ATTRIBUTE,
                Messages.User_defined_attribute_not_retrieved_See_APAR_SE55976_for_details);
            lastWarnMsg = Calendar.getInstance().getTimeInMillis();
        }

        if (!RPGUNIT_LABEL.equalsIgnoreCase(tUserDefinedAttribute)) {
            // Requires PTF for APAR SE55976
            return false;
        }

        return true;
    }

    private boolean checkRemoteProcedure(QSYSRemoteProcedure aRemoteProcedure) {

        if (!aRemoteProcedure.getProcedureName().toUpperCase().startsWith(TEST_PROC_NAME_PREFIX)) { //$NON-NLS-1$
            return false;
        }

        IQSYSModule tModule = aRemoteProcedure.getParent();
        if (!(tModule instanceof QSYSRemoteProgramModule)) {
            return false;
        }

        QSYSRemoteProgramModule tPgmModule = (QSYSRemoteProgramModule)tModule;
        IQSYSProgramBase tPgm = tPgmModule.getProgram();

        if (!(tPgm instanceof IQSYSServiceProgram)) {
            return false;
        }

        return checkServiceProgram((IQSYSServiceProgram)tPgm);
    }

    @Override
    protected I5ServiceProgram produceRemoteObject(IQSYSServiceProgram aQsysServiceProgramm) {

        String tObjName = aQsysServiceProgramm.getName();
        String tLibName = aQsysServiceProgramm.getLibrary();
        I5Library tLibrary = new I5Library(tLibName, getIBMiConnection(aQsysServiceProgramm));
        I5ServiceProgram tObject = new I5ServiceProgram(tObjName, tLibrary);

        return tObject;
    }

    @Override
    protected I5ServiceProgram produceOrUpdateRemoteObject(List<I5ServiceProgram> aList, QSYSRemoteProcedure aRemoteProcedure) {

        QSYSRemoteProgramModule tModule = (QSYSRemoteProgramModule)aRemoteProcedure.getParent();
        IQSYSServiceProgram tQSYSServiceProgram = (QSYSRemoteServiceProgram)tModule.getProgram();

        I5ServiceProgram tI5ServiceProgram = findServiceProgram(aList, tQSYSServiceProgram.getName(), tQSYSServiceProgram.getLibrary());
        if (tI5ServiceProgram == null) {
            tI5ServiceProgram = produceRemoteObject(tQSYSServiceProgram);
            aList.add(tI5ServiceProgram);
        }

        tI5ServiceProgram.addProcedure(aRemoteProcedure.getProcedureName());

        return tI5ServiceProgram;
    }

    private I5ServiceProgram findServiceProgram(List<I5ServiceProgram> aList, String aName, String aLibrary) {

        for (I5ServiceProgram i5ServiceProgram : aList) {
            if (i5ServiceProgram.getName().equals(aName) && i5ServiceProgram.getLibrary().getName().equalsIgnoreCase(aLibrary)) {
                return i5ServiceProgram;
            }
        }

        return null;
    }

}
