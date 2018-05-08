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
import com.ibm.etools.iseries.services.qsys.api.IQSYSResource;
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
    protected boolean isValidItem(Object anObject, List<IObjectInError> anErrObjList) {

        if (!isSupportedObject(anObject, anErrObjList)) {
            return false;
        }

        return true;
    }

    private boolean isSupportedObject(Object anObject, List<IObjectInError> anErrObjList) {

        String errorMessage = null;

        if (anObject instanceof IQSYSServiceProgram) {
            errorMessage = checkServiceProgram((IQSYSServiceProgram)anObject);
        }

        if (anObject instanceof QSYSRemoteProcedure) {
            errorMessage = checkRemoteProcedure((QSYSRemoteProcedure)anObject);
        }

        if (errorMessage == null) {
            return true;
        }

        anErrObjList.add(new ObjectInError(anObject, errorMessage));

        return false;
    }

    private String checkServiceProgram(IQSYSServiceProgram aServiceprogram) {

        if (Preferences.CHECK_TEST_SUITE_NONE.equals(Preferences.getInstance().getCheckTestSuite())) {
            return null;
        }

        if (Preferences.CHECK_TEST_SUITE_TEXT.equals(Preferences.getInstance().getCheckTestSuite())) {
            return checkTextDescription(aServiceprogram);
        }

        return checkUserDefinedAttribute(aServiceprogram);
    }

    private String checkTextDescription(IQSYSServiceProgram aServiceprogram) {

        String tDescription = aServiceprogram.getDescription();
        if (tDescription == null || tDescription.trim().length() == 0) {
            return Messages.Description_of_service_program_is_missing;
        }

        if (!tDescription.toUpperCase().startsWith(RPGUNIT_LABEL)) {
            return Messages.bind(Messages.Description_of_service_program_does_not_start_with_A, RPGUNIT_LABEL);
        }

        return null;
    }

    private String checkUserDefinedAttribute(IQSYSServiceProgram aServiceprogram) {

        String tUserDefinedAttribute = aServiceprogram.getUserDefinedAttribute();
        if (tUserDefinedAttribute == null && ((Calendar.getInstance().getTimeInMillis() - lastWarnMsg) > 1000 || lastWarnMsg == 0)) {
            Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
            WarningMessage.openWarning(shell, Preferences.WARN_MESSAGE_USER_DEFINED_ATTRIBUTE,
                Messages.User_defined_attribute_not_retrieved_See_APAR_SE55976_for_details);
            lastWarnMsg = Calendar.getInstance().getTimeInMillis();
        }

        if (!RPGUNIT_LABEL.equalsIgnoreCase(tUserDefinedAttribute)) {
            // Requires PTF for APAR SE55976
            return Messages.bind(Messages.User_defined_attribute_of_service_program_is_not_set_to_A, RPGUNIT_LABEL);
        }

        return null;
    }

    private String checkRemoteProcedure(QSYSRemoteProcedure aRemoteProcedure) {

        if (!aRemoteProcedure.getProcedureName().toUpperCase().startsWith(TEST_PROC_NAME_PREFIX)) { // $NON-NLS-1$
            return Messages.bind(Messages.Procedure_name_does_not_start_with_A, TEST_PROC_NAME_PREFIX);
        }

        IQSYSModule tModule = aRemoteProcedure.getParent();
        if (!(tModule instanceof QSYSRemoteProgramModule)) {
            return Messages.Module_is_not_a_QSYSRemoteProgramModule;
        }

        QSYSRemoteProgramModule tPgmModule = (QSYSRemoteProgramModule)tModule;
        IQSYSProgramBase tPgm = tPgmModule.getProgram();

        if (!(tPgm instanceof IQSYSServiceProgram)) {
            return Messages.Object_is_not_a_IQSYSServiceProgram;
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

    private class ObjectInError implements IObjectInError {

        private Object object;
        private String message;

        public ObjectInError(Object object, String message) {
            this.object = object;
            this.message = message;
        }

        @Override
        public String getErrorMessage() {

            if (object instanceof IQSYSResource) {
                IQSYSResource tResource = (IQSYSResource)object;
                return "-  " + tResource.getFullName() + " (" + tResource.getType() + "):\n" + message; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            } else if (object instanceof QSYSRemoteProcedure) {
                QSYSRemoteProcedure tProcedure = (QSYSRemoteProcedure)object;
                return "-  " + tProcedure.getProcedureName() + "():\n" + message; //$NON-NLS-1$ //$NON-NLS-2$
            }

            return "-  " + object.toString() + ":\n" + message; //$NON-NLS-1$ //$NON-NLS-2$
        }

    }
}
