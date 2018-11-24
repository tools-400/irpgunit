/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.dialog;

import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.action.IObjectInError;

public class ObjectsInErrorListDialog extends Dialog {

    private IObjectInError[] objectsInError;

    private TableViewer tableViewer;

    private static final int COLUMN_IMAGE = 0;
    private static final int COLUMN_OBJECT_NAME = 1;
    private static final int COLUMN_MESSAGE_TEXT = 2;

    public ObjectsInErrorListDialog(Shell shell, IObjectInError[] objectsInError) {
        super(shell);
        this.objectsInError = objectsInError;
    }

    public void setContent(IObjectInError[] objectsInError) {

        this.objectsInError = objectsInError;
    }

    /**
     * Overridden to set the window title.
     */
    @Override
    protected void configureShell(Shell newShell) {
        super.configureShell(newShell);
        newShell.setText(Messages.AbstractRemoteAction_0);
    }

    @Override
    public Control createDialogArea(Composite parent) {

        Composite mainArea = (Composite)super.createDialogArea(parent);

        mainArea.setLayout(new GridLayout());
        mainArea.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

        tableViewer = new TableViewer(mainArea, SWT.SINGLE | SWT.FULL_SELECTION | SWT.H_SCROLL | SWT.V_SCROLL | SWT.BORDER);
        Table table = tableViewer.getTable();
        table.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
        table.setLinesVisible(true);
        table.setHeaderVisible(true);

        addTableColumn(tableViewer, "", 30); //$NON-NLS-1$
        addTableColumn(tableViewer, Messages.Object_name, 170); // $NON-NLS-1$
        addTableColumn(tableViewer, Messages.Error_Message, getInitialSize().x - 30);

        tableViewer.setContentProvider(new ContentProviderMessageItems());
        tableViewer.setLabelProvider(new LabelProviderMessageItems());

        loadScreenValues();

        parent.pack();

        return mainArea;
    }

    private TableColumn addTableColumn(TableViewer table, String label) {
        return addTableColumn(table, label, 70);
    }

    private TableColumn addTableColumn(TableViewer tableViewer, String label, int width) {
        TableColumn column = new TableColumn(tableViewer.getTable(), SWT.NONE);
        column.setWidth(width);
        column.setText(label);

        return column;
    }

    private void loadScreenValues() {

        tableViewer.setInput(objectsInError);
    }

    @Override
    public void okPressed() {
        super.okPressed();
    }

    @Override
    protected Button createButton(Composite parent, int id, String label, boolean defaultButton) {
        if (id == IDialogConstants.CANCEL_ID) {
            return null;
        }
        return super.createButton(parent, id, label, false);
    }

    @Override
    protected boolean isResizable() {
        return true;
    }

    @Override
    protected Point getInitialSize() {
        return new Point(600, 400);
    }

    /**
     * Content provider for the member list table.
     */
    private class ContentProviderMessageItems implements IStructuredContentProvider {

        public Object[] getElements(Object inputElement) {
            if (inputElement instanceof IObjectInError[]) {
                return (IObjectInError[])inputElement;
            }
            return new Object[0];
        }

        public void dispose() {
        }

        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
        }
    }

    /**
     * Content provider for the member list table.
     */
    private class LabelProviderMessageItems extends LabelProvider implements ITableLabelProvider {

        public String getColumnText(Object element, int columnIndex) {

            IObjectInError objectInError = (IObjectInError)element;

            switch (columnIndex) {
            case COLUMN_MESSAGE_TEXT:
                return objectInError.getErrorMessage();

            case COLUMN_OBJECT_NAME:
                return objectInError.getObjectName();

            default:
                return null;
            }
        }

        public Image getColumnImage(Object element, int columnIndex) {

            IObjectInError objectInError = (IObjectInError)element;

            switch (columnIndex) {
            case COLUMN_IMAGE:
                return objectInError.getImage();

            default:
                return null;
            }
        }
    }

}
