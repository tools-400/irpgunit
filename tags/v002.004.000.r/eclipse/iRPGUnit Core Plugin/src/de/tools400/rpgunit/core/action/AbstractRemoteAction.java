/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.action;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.rse.core.model.IHost;
import org.eclipse.rse.core.subsystems.ISubSystem;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;

import com.ibm.etools.iseries.services.qsys.api.IQSYSServiceProgram;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;
import com.ibm.etools.iseries.subsystems.qsys.objects.IRemoteObjectContextProvider;
import com.ibm.etools.iseries.subsystems.qsys.objects.QSYSRemoteProcedure;

import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.ui.UIUtils;
import de.tools400.rpgunit.core.ui.dialog.ObjectsInErrorListDialog;

public abstract class AbstractRemoteAction<T> implements IObjectActionDelegate {

    private StructuredSelection _selectedItems;

    private List<IObjectInError> _errObj;

    public AbstractRemoteAction() {
        _selectedItems = new StructuredSelection();
        _errObj = new ArrayList<IObjectInError>();
    }

    @Override
    public void selectionChanged(org.eclipse.jface.action.IAction action, org.eclipse.jface.viewers.ISelection selection) {
        List<I5ServiceProgram> tList = new ArrayList<I5ServiceProgram>();
        _errObj = new ArrayList<IObjectInError>();

        Iterator<?> theSet = ((IStructuredSelection)selection).iterator();

        while (theSet.hasNext()) {
            Object obj = theSet.next();
            if (obj instanceof IQSYSServiceProgram && isValidItem(obj, _errObj)) {
                tList.add(produceRemoteObject((IQSYSServiceProgram)obj));
            } else if (obj instanceof QSYSRemoteProcedure && isValidItem(obj, _errObj)) {
                produceOrUpdateRemoteObject(tList, (QSYSRemoteProcedure)obj);
            }
            _selectedItems = new StructuredSelection(tList);
        }
    }

    @Override
    public void run(IAction anAction) {
        if (_errObj.size() > 0) {
            displayInvalidObjects(_errObj);
        } else {
            executeAction(anAction);
        }
    }

    @Override
    public void setActivePart(IAction action, IWorkbenchPart targetPart) {
        return;
    }

    protected IBMiConnection getIBMiConnection(Object aRemoteObject) {
        if (!(aRemoteObject instanceof IRemoteObjectContextProvider)) {
            return null;
        }
        // get the Command subsystem associated with the current host
        IHost tHost = getHost(aRemoteObject);
        return IBMiConnection.getConnection(tHost);
    }

    protected ISelection getSelectedItems() {
        return _selectedItems;
    }

    protected abstract boolean isValidItem(Object anObject, List<IObjectInError> anErrObjList);

    protected abstract I5ServiceProgram produceRemoteObject(IQSYSServiceProgram aRemoteObject);

    protected abstract I5ServiceProgram produceOrUpdateRemoteObject(List<I5ServiceProgram> aList, QSYSRemoteProcedure aRemoteObject);

    protected abstract void executeAction(IAction action);

    protected IHost getHost(Object anObject) {
        try {
            if (!(anObject instanceof IRemoteObjectContextProvider)) {
                return null;
            }
            ISubSystem tSubSystem = ((IRemoteObjectContextProvider)anObject).getRemoteObjectContext().getObjectSubsystem().getCmdSubSystem();
            return tSubSystem.getHost();
        } catch (Exception e) {
            return null;
        }
    }

    protected void displayInvalidObjects(List<IObjectInError> anObjects) {

        ObjectsInErrorListDialog dialog = new ObjectsInErrorListDialog(UIUtils.getShell(), anObjects.toArray(new IObjectInError[anObjects.size()]));
        dialog.open();

        // StringBuffer tObjects = new StringBuffer();
        // for (Iterator<IObjectInError> tIter = anObjects.iterator();
        // tIter.hasNext();) {
        //
        // IObjectInError tObject = tIter.next();
        //
        // if (tObjects.length() > 0) {
        // tObjects.append("\n"); //$NON-NLS-1$
        // }
        //
        // tObjects.append(tObject.getErrorMessage());
        //
        // if (tObject instanceof IQSYSResource) {
        // IQSYSResource tResource = (IQSYSResource)tObject;
        // tObjects.append("- " + tResource.getFullName() + " (" +
        // tResource.getType() + ")"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        // } else if (tObject instanceof QSYSRemoteProcedure) {
        // QSYSRemoteProcedure tProcedure = (QSYSRemoteProcedure)tObject;
        // tObjects.append("- " + tProcedure.getProcedureName() + "()");
        // //$NON-NLS-1$ //$NON-NLS-2$
        // }
        // }
        //
        // UIUtils.displayError(Messages.AbstractRemoteAction_0 +
        // tObjects.toString());
    }
}
