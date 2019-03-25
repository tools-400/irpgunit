/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.view;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.ITreeViewerListener;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeExpansionEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.viewers.ViewerSorter;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.ui.part.ViewPart;

import com.ibm.etools.iseries.rse.ui.actions.popupmenu.ISeriesAbstractQSYSPopupMenuAction;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.RPGUnitFactory;
import de.tools400.rpgunit.core.extensions.testcase.UpdateTestResultContributionsHandler;
import de.tools400.rpgunit.core.extensions.view.SelectionChangedContributionsHandler;
import de.tools400.rpgunit.core.handler.EditRemoteSourceMemberHandler;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.IUnitTestTreeItem;
import de.tools400.rpgunit.core.model.local.UnitTestCallStackEntry;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestExecutionTimeFormatter;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.model.local.UnitTestViewerRoot;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.warning.WarningMessage;
import de.tools400.rpgunit.core.utils.ExceptionHelper;
import de.tools400.rpgunit.core.versioncheck.PluginCheck;

public class RPGUnitView extends ViewPart implements ICursorProvider, IInputProvider {

    public static final String ID = "de.tools400.rpgunit.core"; //$NON-NLS-1$

    private Color red = null;

    private Color green = null;

    private Color grey = null;

    private Composite errorPanel = null;

    private boolean showFailuresOnly = false;

    private Composite mainPanel = null;

    private HeaderControl header;

    private TreeViewer viewer;

    private int numItems = 0;

    private IRPGUnitViewDelegate viewDelegate = null;

    @Override
    public void createPartControl(Composite parent) {

        setTitleImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_RPGUNIT));

        mainPanel = new Composite(parent, SWT.NONE);
        GridLayout layout = new GridLayout(1, false);
        layout.marginWidth = 0;
        layout.marginHeight = 0;
        mainPanel.setLayout(layout);

        header = new HeaderControl(mainPanel);

        viewer = new UnitTestTreeViewer(mainPanel);
        viewer.setAutoExpandLevel(1);
        viewer.getTree().setHeaderVisible(false);
        viewer.getTree().setLinesVisible(true);
        viewer.getControl().setLayoutData(new GridData(GridData.FILL_BOTH));

        viewer.setContentProvider(new UnitTestContentProvider());
        viewer.setLabelProvider(new UnitTestTreeLabelProvider());

        viewer.setSorter(new UnitTestSorter());
        viewer.addSelectionChangedListener(new UnitTestSelectionChangedListener());
        viewer.addTreeListener(new UnitTestTreeViewerListener());
        viewer.addDoubleClickListener(new UnitTestDoubleClickListener());

        IRPGUnitViewDelegate tDelegate = getViewDelegate();
        tDelegate.initialize(getSite(), getViewSite());
        tDelegate.configureView(viewer, new FailureFilter());

        tDelegate.hookContextMenu(viewer);

        tDelegate.enableRerunAllUnitTestsButton(numItems);
        tDelegate.enableRerunSelectedUnitTestButton(hasSelectedUnitTestCasesOrUnitTestSuites());
        tDelegate.enableRemoveSelectedUnitTestButton(hasSelectedUnitTestSuites());
        tDelegate.enableEditRemoteSourceMemberButton(hasSelectedItemsWithSourceMember());
        tDelegate.enableCollapseAllButton(numItems);
        tDelegate.enableExpandAllButton(numItems);

        getSite().setSelectionProvider(viewer);
    }

    /**
     * Handler procedure: Button "Collapse All RPGUnit Tests"
     */
    public void collapseAll() {
        setTreeItemsExpandedStatus(viewer, viewer.getTree().getItems(), false);
    }

    /**
     * Handler procedure: Button "Expand All RPGUnit Tests"
     */
    public void expandAll() {
        setTreeItemsExpandedStatus(viewer, viewer.getTree().getItems(), true);
    }

    /**
     * Handler procedure: Button "Show Failures Only"
     */
    public void toggleShowFailuresOnly() {
        showFailuresOnly = !showFailuresOnly;
        viewer.refresh(true);

        IRPGUnitViewDelegate tDelegate = getViewDelegate();
        tDelegate.enableRerunAllUnitTestsButton(numItems);
    }

    /**
     * Handler procedure: Button "Rerun All RPGUnit Test Cases"
     */
    public UnitTestSuite[] getAllUnitTestCases() {
        if (getViewerInput() == null) {
            UnitTestSuite[] tResults = new UnitTestSuite[] {};
            return tResults;
        }

        setIsSelectedOfAllTestCases(true);
        return getViewerInput().getTestResults();
    }

    public IStructuredSelection getSelectedItems() {
        return (IStructuredSelection)viewer.getSelection();
    }

    /**
     * Handler procedure: Button "Rerun Selected RPGUnit Test Cases"
     */
    public UnitTestSuite[] getSelectedUnitTestCases() {

        UnitTestSuite[] tResults = new UnitTestSuite[] {};

        if (getViewerInput() == null) {
            return tResults;
        }

        ISelection tSelectedObject = viewer.getSelection();
        if (!(tSelectedObject instanceof IStructuredSelection)) {
            return tResults;
        }

        setIsSelectedOfAllTestCases(false);
        UnitTestSuite[] tAllUnitTestCases = getViewerInput().getTestResults();

        IStructuredSelection tSelectedItems = (IStructuredSelection)tSelectedObject;

        /*
         * Flag all selected test cases as "is selected".
         */
        Map<I5ServiceProgram, UnitTestSuite> tSelectedUnitTestSuites = new HashMap<I5ServiceProgram, UnitTestSuite>();

        Iterator<?> tIter = tSelectedItems.iterator();
        while (tIter.hasNext()) {
            Object tItem = tIter.next();
            if (tItem instanceof UnitTestCase) {
                UnitTestCase tTestCase = (UnitTestCase)tItem;
                I5ServiceProgram tSrvPgm = tTestCase.getServiceprogram();
                if (!tSelectedUnitTestSuites.containsKey(tSrvPgm)) {
                    tSelectedUnitTestSuites.put(tSrvPgm, tTestCase.getUnitTestSuite());
                }
                tTestCase.setIsSelected(true);
            }
        }

        /*
         * Flag all selected test suites as "is selected".
         */
        tIter = tSelectedItems.iterator();
        while (tIter.hasNext()) {
            Object tItem = tIter.next();
            if (tItem instanceof UnitTestSuite) {
                UnitTestSuite tUnitTestSuite = (UnitTestSuite)tItem;
                I5ServiceProgram tSrvPgm = tUnitTestSuite.getServiceProgram();
                if (!tSelectedUnitTestSuites.containsKey(tSrvPgm)) {
                    tSelectedUnitTestSuites.put(tSrvPgm, tUnitTestSuite);
                }
                tUnitTestSuite.setIsSelected(true);
            }
        }

        // UnitTestSuite[] tSelectedUnitTestSuitesArray = new
        // UnitTestSuite[tSelectedUnitTestSuites.size()];
        // return
        // tSelectedUnitTestSuites.values().toArray(tSelectedUnitTestSuitesArray);
        return tAllUnitTestCases;
    }

    @Override
    public void setFocus() {
        viewer.getControl().setFocus();
    }

    @Override
    public void setInput(Object aTestResults, boolean showViewWarning) {

        UnitTestSuite[] testResults = (UnitTestSuite[])aTestResults;

        updateHeader(header, testResults);
        updateViewer(viewer, testResults);

        IRPGUnitViewDelegate tDelegate = getViewDelegate();
        tDelegate.enableRerunAllUnitTestsButton(numItems);
        tDelegate.enableRerunSelectedUnitTestButton(hasSelectedUnitTestCasesOrUnitTestSuites());
        tDelegate.enableRemoveSelectedUnitTestButton(hasSelectedUnitTestSuites());
        tDelegate.enableEditRemoteSourceMemberButton(hasSelectedItemsWithSourceMember());
        tDelegate.enableCollapseAllButton(numItems);
        tDelegate.enableExpandAllButton(numItems);

        UpdateTestResultContributionsHandler tHandler = new UpdateTestResultContributionsHandler();
        tHandler.execute(testResults);

        // Fire "selectionChanged" event to update selected spooled files of
        // spooled file viewer. First deselect the selection to clear the
        // properties view. Then set the selection to update the report in the
        // spooled file viewer.
        ISelection selection = viewer.getSelection();
        viewer.setSelection(null);
        if (selection != null) {
            viewer.setSelection(selection);
        }

        if (testResults != null && showViewWarning) {
            if (header.hasErrors() && !Preferences.getInstance().isShowResultView()) {
                WarningMessage.openWarning(getSite().getShell(), Preferences.WARN_MESSAGE_UNIT_TEST_ENDED_WITH_ERRORS,
                    Messages.Unit_test_ended_with_errors);
            }
        }
    }

    @Override
    public Object getInput() {
        return null;
    }

    @Override
    public void setCursor(Cursor aCursor) {
        mainPanel.setCursor(aCursor);
    }

    public IRPGUnitViewDelegate getViewDelegate() {
        if (viewDelegate == null) {
            viewDelegate = RPGUnitFactory.produceViewDelegate();
            viewDelegate.initialize(getSite(), getViewSite());
        }
        return viewDelegate;
    }

    protected boolean hasSelectedUnitTestSuites() {

        if (getViewerInput() == null) {
            return false;
        }

        ISelection tSelectedObject = viewer.getSelection();
        if (!(tSelectedObject instanceof IStructuredSelection)) {
            return false;
        }

        boolean hasItems = false;
        IStructuredSelection tSelectedItems = (IStructuredSelection)tSelectedObject;
        for (Object tSelectedItem : tSelectedItems.toArray()) {
            if (tSelectedItem instanceof UnitTestSuite) {
                hasItems = true;
            } else {
                return false;
            }
        }
        return hasItems;
    }

    protected boolean hasSelectedUnitTestCasesOrUnitTestSuites() {

        if (getViewerInput() == null) {
            return false;
        }

        ISelection tSelectedObject = viewer.getSelection();
        if (!(tSelectedObject instanceof IStructuredSelection)) {
            return false;
        }

        boolean hasItems = false;
        IStructuredSelection tSelectedItems = (IStructuredSelection)tSelectedObject;
        for (Object tSelectedItem : tSelectedItems.toArray()) {
            if ((tSelectedItem instanceof UnitTestSuite) || (tSelectedItem instanceof UnitTestCase)) {
                hasItems = true;
            } else {
                return false;
            }
        }
        return hasItems;
    }

    protected boolean hasSelectedItemsWithSourceMember() {

        if (getViewerInput() == null) {
            return false;
        }

        ISelection tSelectedObject = viewer.getSelection();
        if (!(tSelectedObject instanceof IStructuredSelection)) {
            return false;
        }

        boolean hasItems = false;
        IStructuredSelection tSelectedItems = (IStructuredSelection)tSelectedObject;
        for (Object tSelectedItem : tSelectedItems.toArray()) {
            if ((tSelectedItem instanceof UnitTestSuite) || (tSelectedItem instanceof UnitTestCase)
                || (tSelectedItem instanceof UnitTestCallStackEntry)) {
                hasItems = true;
            } else {
                return false;
            }
        }
        return hasItems;
    }

    private void setTreeItemsExpandedStatus(TreeViewer aViewer, TreeItem[] tTreeItems, boolean anExpanded) {
        for (TreeItem tTreeItem : tTreeItems) {
            setTreeItemExpandedStatus(aViewer, tTreeItem, anExpanded);
            setTreeItemsExpandedStatus(aViewer, tTreeItem.getItems(), anExpanded);
        }
    }

    private void updateHeader(HeaderControl aHeader, UnitTestSuite[] testResults) {
        if (testResults == null) {
            aHeader.clear();
        } else {
            aHeader.update(testResults);
        }
    }

    private void updateViewer(TreeViewer aViewer, UnitTestSuite[] testResults) {
        if (testResults == null) {
            aViewer.setInput(null);
            aViewer.refresh();
            return;
        }

        aViewer.setInput(new UnitTestViewerRoot(testResults));
        updateTreeItemsExpandedStatus(aViewer, aViewer.getTree().getItems());
        aViewer.refresh(true);
    }

    private void updateTreeItemsExpandedStatus(TreeViewer aViewer, TreeItem[] tTreeItems) {
        for (TreeItem tTreeItem : tTreeItems) {
            if (tTreeItem.getData() instanceof IUnitTestTreeItem) {
                IUnitTestTreeItem tStatistics = (IUnitTestTreeItem)tTreeItem.getData();
                if (tStatistics.hasStatistics()) {
                    if (tStatistics.isError() || tStatistics.isFailure()) {
                        setTreeItemExpandedStatus(aViewer, tTreeItem, true);
                    } else {
                        setTreeItemExpandedStatus(aViewer, tTreeItem, false);
                    }
                } else {
                    setTreeItemExpandedStatus(aViewer, tTreeItem, tStatistics.isExpanded());
                    updateTreeItemsExpandedStatus(aViewer, tTreeItem.getItems());
                }
            }
        }
    }

    private void setTreeItemExpandedStatus(TreeViewer aViewer, TreeItem aTreeItem, boolean anExpanded) {
        aTreeItem.setExpanded(anExpanded);
        if (aTreeItem.getData() instanceof IUnitTestTreeItem) {
            IUnitTestTreeItem tStatistics = (IUnitTestTreeItem)aTreeItem.getData();
            tStatistics.setExpanded(aTreeItem.getExpanded());
        }
        aViewer.refresh();
    }

    /**
     * ^Sets the "isSelected" flag of all test cases shown in the tree viewer.
     * 
     * @param anIsSelected
     * @return
     */
    private void setIsSelectedOfAllTestCases(boolean anIsSelected) {

        UnitTestSuite[] tAllUnitTestSuits = getViewerInput().getTestResults();
        for (int i = 0; i < tAllUnitTestSuits.length; i++) {
            UnitTestSuite tUnitTestResult = tAllUnitTestSuits[i];
            tUnitTestResult.removeNonExecutableTestCases();
            tUnitTestResult.setIsSelected(anIsSelected);
        }

        setInput(tAllUnitTestSuits, false);
    }

    private UnitTestViewerRoot getViewerInput() {
        return (UnitTestViewerRoot)viewer.getInput();
    }

    /*
     * Internal classes.
     */

    class UnitTestTreeViewer extends TreeViewer {

        public UnitTestTreeViewer(Composite parent) {
            super(parent);
        }

        @Override
        public void refresh(boolean updateLabels) {
            numItems = 0;
            super.refresh(updateLabels);
        };

    }

    class UnitTestTreeLabelProvider extends LabelProvider {

        private UnitTestExecutionTimeFormatter executionTimeFormatter;

        public UnitTestTreeLabelProvider() {
            executionTimeFormatter = new UnitTestExecutionTimeFormatter();
        }

        @Override
        public Image getImage(Object element) {
            if (element instanceof UnitTestCase) {
                UnitTestCase test = (UnitTestCase)element;
                if (test.isSuccessful()) {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_SUCCESS);
                } else if (test.isFailure()) {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_FAILED);
                } else {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_ERROR);
                }
            } else if (element instanceof UnitTestSuite) {
                if (((UnitTestSuite)element).getNumberErrors() > 0) {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_ERROR);
                } else if (((UnitTestSuite)element).getNumberFailures() > 0) {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_FAILED);
                } else {
                    return RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_TEST_SUCCESS);
                }
            } else {
                return null;
            }
        }

        @Override
        public String getText(Object element) {
            if (element instanceof UnitTestCase) {
                UnitTestCase tTestCase = (UnitTestCase)element;
                String tText = tTestCase.getProcedure();
                if (tTestCase.isError() || tTestCase.isFailure()) {
                    tText = tText + " [Stmt: " + tTestCase.getStatementNumberText() + "]"; //$NON-NLS-1$ //$NON-NLS-2$
                }
                if (tTestCase.hasStatistics()) {
                    tText = tText + " " + formatExecutionTime(tTestCase.getExecutionTime()); //$NON-NLS-1$
                }
                if (tTestCase.isError() || tTestCase.isFailure()) {
                    tText = tText + "  - " + tTestCase.getMessage().trim(); //$NON-NLS-1$
                }
                return tText;
            } else if (element instanceof UnitTestSuite) {
                UnitTestSuite tUnitTestSuite = (UnitTestSuite)element;
                I5ServiceProgram object = tUnitTestSuite.getServiceProgram();
                String tText;
                if (object.getDescription() != null && object.getDescription().trim().length() > 0) {
                    tText = object.getName() + " [" + object.getDescription() + "]"; //$NON-NLS-1$ //$NON-NLS-2$
                } else {
                    tText = object.getName();
                }
                if (tUnitTestSuite.hasStatistics()) {
                    tText = tText + formatExecutionTime(tUnitTestSuite.getTotalExecutionTime());
                }
                return tText;
            } else if (element instanceof UnitTestCallStackEntry) {
                UnitTestCallStackEntry tCallStackEntry = (UnitTestCallStackEntry)element;
                String tText = tCallStackEntry.getProcedure().trim() + " ( " + tCallStackEntry.getProgram().trim() + "->" //$NON-NLS-1$ //$NON-NLS-2$
                    + tCallStackEntry.getModule().trim() + ":" + tCallStackEntry.getStatementNumberText().trim() + ")"; //$NON-NLS-1$ //$NON-NLS-2$
                return tText;
            } else {
                return ""; //$NON-NLS-1$
            }
        }

        private String formatExecutionTime(long executionTime) {
            String text = " (" + executionTimeFormatter.formatExecutionTime(executionTime) + " s)"; //$NON-NLS-1$ //$NON-NLS-2$
            return text;
        }
    }

    class UnitTestContentProvider implements ITreeContentProvider {
        private Object[] noElements = new Object[0];

        @Override
        public Object[] getChildren(Object parentElement) {
            if (parentElement instanceof UnitTestViewerRoot) {
                return ((UnitTestViewerRoot)parentElement).getTestResults();
            } else if (parentElement instanceof UnitTestSuite) {
                return ((UnitTestSuite)parentElement).getUnitsTestCases();
            } else if (parentElement instanceof UnitTestCase) {
                return ((UnitTestCase)parentElement).getCallStack().toArray();
            } else {
                return noElements;
            }
        }

        @Override
        public Object getParent(Object element) {
            if (element instanceof UnitTestSuite) {
                return viewer.getInput();
            } else if (element instanceof UnitTestCase) {
                return ((UnitTestCase)element).getUnitTestSuite();
            } else if (element instanceof UnitTestCallStackEntry) {
                return ((UnitTestCallStackEntry)element).getUnitTestCase();
            } else {
                return null;
            }
        }

        @Override
        public boolean hasChildren(Object element) {
            return getChildren(element).length > 0;
        }

        @Override
        public Object[] getElements(Object inputElement) {
            return getChildren(inputElement);
        }

        @Override
        public void dispose() {

        }

        @Override
        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

        }

    }

    class FailureFilter extends ViewerFilter {

        @Override
        public boolean select(Viewer viewer, Object parentElement, Object element) {
            boolean isSelected = false;
            if (showFailuresOnly) {
                if (element instanceof UnitTestCase) {
                    if (((UnitTestCase)element).isSuccessful())
                        isSelected = false;
                    else
                        isSelected = true;
                } else if (element instanceof UnitTestSuite) {
                    if (((UnitTestSuite)element).getNumberFailures() > 0)
                        isSelected = true;
                    else if (((UnitTestSuite)element).getNumberErrors() > 0)
                        isSelected = true;
                    else
                        isSelected = false;
                } else
                    isSelected = true;
            } else {
                isSelected = true;
            }
            if (isSelected) {
                numItems++;
            }
            return isSelected;
        }
    }

    class UnitTestSelectionChangedListener implements ISelectionChangedListener {
        @Override
        public void selectionChanged(SelectionChangedEvent anEvent) {
            IRPGUnitViewDelegate tDelegate = getViewDelegate();
            tDelegate.enableRerunSelectedUnitTestButton(hasSelectedUnitTestCasesOrUnitTestSuites());
            tDelegate.enableRemoveSelectedUnitTestButton(hasSelectedUnitTestSuites());
            tDelegate.enableEditRemoteSourceMemberButton(hasSelectedItemsWithSourceMember());

            callRegisteredMenuExtensions(anEvent);
        }

        private void callRegisteredMenuExtensions(SelectionChangedEvent anEvent) {
            SelectionChangedContributionsHandler tHandler = new SelectionChangedContributionsHandler();
            tHandler.execute(anEvent);
        }
    }

    class UnitTestTreeViewerListener implements ITreeViewerListener {

        @Override
        public void treeCollapsed(TreeExpansionEvent anEvent) {
            updateTreeItem(anEvent, false);
        }

        @Override
        public void treeExpanded(TreeExpansionEvent anEvent) {
            updateTreeItem(anEvent, true);
        }

        /**
         * Updates the "expanded" status of a TreeItem, when the tree node is
         * expanded or collapsed by hand.
         * 
         * @param anEvent
         * @param anExpanded
         */
        private void updateTreeItem(TreeExpansionEvent anEvent, boolean anExpanded) {
            Object tElement = anEvent.getElement();
            if (tElement instanceof UnitTestSuite) {
                ((UnitTestSuite)tElement).setExpanded(anExpanded);
            } else if (tElement instanceof UnitTestCase) {
                ((UnitTestCase)tElement).setExpanded(anExpanded);
            }
        }
    }

    class UnitTestDoubleClickListener implements IDoubleClickListener {

        private static final String RPGUNIT_ISPHERE_INTEGRATION_PLUGIN_ID = "de.tools400.rpgunit.isphere"; //$NON-NLS-1$
        private static final String ISPHERE_SPOOLED_FILE_VIEWER_ACTION = "de.tools400.rpgunit.isphere.action.SpooledFileOpenAsTextAction"; //$NON-NLS-1$

        private static final String RPGUNIT_SPOOLED_FILE_VIEWER_PLUGIN_ID = "de.tools400.rpgunit.spooledfileviewer"; //$NON-NLS-1$
        private static final String RPGUNIT_SPOOLED_FILE_VIEWER_HANDLER = "de.tools400.rpgunit.spooledfileviewer.handler.DisplayReportHandler"; //$NON-NLS-1$

        @Override
        public void doubleClick(DoubleClickEvent anEvent) {
            if (anEvent.getSelection() instanceof IStructuredSelection) {
                IStructuredSelection tSelection = (IStructuredSelection)anEvent.getSelection();
                Object tElement = tSelection.getFirstElement();
                if (tElement instanceof UnitTestSuite) {
                    String message;
                    if (PluginCheck.hasPlugin(RPGUNIT_SPOOLED_FILE_VIEWER_PLUGIN_ID)) {
                        message = launchRPGUnitSpooledFileViewer(anEvent);
                    } else if (PluginCheck.hasPlugin(RPGUNIT_ISPHERE_INTEGRATION_PLUGIN_ID)) {
                        message = launchISphereSpooledFileViewer(anEvent);
                    } else {
                        message = Messages.No_spooled_file_viewer_installed;
                    }
                    if (message != null) {
                        MessageDialog.openError(getSite().getShell(), Messages.ERROR, message);
                    }
                } else {
                    EditRemoteSourceMemberHandler tHandler = new EditRemoteSourceMemberHandler();
                    tHandler.editSourceMember(tSelection);
                }
            }
        }

        private String launchISphereSpooledFileViewer(DoubleClickEvent anEvent) {
            try {
                Object objAction = null;
                Class<?> clazz = PluginCheck.loadClass(RPGUNIT_ISPHERE_INTEGRATION_PLUGIN_ID, ISPHERE_SPOOLED_FILE_VIEWER_ACTION);
                if (clazz != null) {
                    objAction = clazz.newInstance();
                }
                if (objAction instanceof ISeriesAbstractQSYSPopupMenuAction) {
                    ISeriesAbstractQSYSPopupMenuAction action = (ISeriesAbstractQSYSPopupMenuAction)objAction;
                    action.selectionChanged(new Action() {
                        @Override
                        public boolean isEnabled() {
                            return true;
                        }
                    }, anEvent.getSelection());
                    action.run();
                    return null;
                } else {
                    throw new ClassNotFoundException("Unexpected object type: " + objAction.getClass().getName()); //$NON-NLS-1$
                }
            } catch (Throwable e) {
                return Messages.bind(Messages.Could_not_open_the_iSphere_spooled_file_viewer, ExceptionHelper.getLocalizedMessage(e));
            }
        }

        private String launchRPGUnitSpooledFileViewer(DoubleClickEvent anEvent) {
            try {
                Object objHandler = null;
                Class<?> clazz = PluginCheck.loadClass(RPGUNIT_SPOOLED_FILE_VIEWER_PLUGIN_ID, RPGUNIT_SPOOLED_FILE_VIEWER_HANDLER);
                if (clazz != null) {
                    objHandler = clazz.newInstance();
                }
                if (objHandler instanceof AbstractHandler) {
                    AbstractHandler handler = (AbstractHandler)objHandler;
                    handler.execute(null);
                    return null;
                } else {
                    throw new ClassNotFoundException("Unexpected object type: " + objHandler.getClass().getName()); //$NON-NLS-1$
                }
            } catch (Throwable e) {
                return Messages.bind(Messages.Could_not_open_the_RPGUnit_spooled_file_viewer, ExceptionHelper.getLocalizedMessage(e));
            }
        }

    }

    class UnitTestSorter extends ViewerSorter {
        @Override
        public int compare(Viewer viewer, Object e1, Object e2) {

            if (e1 instanceof UnitTestCallStackEntry) {
                if (!(e2 instanceof UnitTestCallStackEntry)) {
                    throw new IllegalAccessError("Unexpected comparison of UnitTestCallStackEntry with " + e1.getClass().getSimpleName()); //$NON-NLS-1$
                }
                System.out.println(((UnitTestCallStackEntry)e1).getProcedure());
                return 0;
            }

            /*
             * Sort by category
             */
            int cat1 = category(e1);
            int cat2 = category(e2);
            if (cat1 != cat2) {
                return cat1 - cat2;
            }
            return super.compare(viewer, e1, e2);
        }
    }

    class HeaderControl extends Composite {
        private Label runs;

        private Label errors;

        private Label failures;

        private Label assertions;

        private boolean hasErrors;

        public HeaderControl(Composite parent) {
            super(parent, SWT.NONE);

            init();
        }

        protected void clear() {
            runs.setText("0"); //$NON-NLS-1$
            errors.setText("0"); //$NON-NLS-1$
            failures.setText("0"); //$NON-NLS-1$
            assertions.setText("0"); //$NON-NLS-1$

            hasErrors = false;

            this.update();
        }

        private void init() {

            hasErrors = false;

            red = getDisplay().getSystemColor(SWT.COLOR_DARK_RED);
            green = getDisplay().getSystemColor(SWT.COLOR_DARK_GREEN);
            grey = getDisplay().getSystemColor(SWT.COLOR_WIDGET_BACKGROUND);

            Composite header = this; // new Composite(mainPanel, SWT.NONE);
            header.setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL | GridData.GRAB_HORIZONTAL));
            FillLayout fl_header = new FillLayout(SWT.HORIZONTAL);
            fl_header.marginWidth = 2;
            fl_header.marginHeight = 2;
            header.setLayout(fl_header);

            Composite statistics = new Composite(header, SWT.NONE);
            GridLayout gl_statistics = new GridLayout(5, false);
            gl_statistics.verticalSpacing = 5;
            statistics.setLayout(gl_statistics);

            Composite col1 = new Composite(statistics, SWT.NONE);
            GridData gd_col1 = new GridData();
            configureStatisticColumnGridData(gd_col1);
            col1.setLayoutData(gd_col1);
            RowLayout rl_col1 = new RowLayout(SWT.HORIZONTAL);
            col1.setLayout(rl_col1);
            Label label = new Label(col1, SWT.NONE);
            label.setText(Messages.Runs + ":"); //$NON-NLS-1$
            runs = new Label(col1, SWT.NONE);
            runs.setText("0"); //$NON-NLS-1$

            Composite col2 = new Composite(statistics, SWT.NONE);
            GridData gd_col2 = new GridData(SWT.LEFT, SWT.CENTER, true, false, 1, 1);
            configureStatisticColumnGridData(gd_col2);
            col2.setLayoutData(gd_col2);
            RowLayout rl_col2 = new RowLayout(SWT.HORIZONTAL);
            col2.setLayout(rl_col2);
            label = new Label(col2, SWT.NONE);
            label.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_ERROR));
            label = new Label(col2, SWT.NONE);
            label.setText(Messages.Errors + ":"); //$NON-NLS-1$
            errors = new Label(col2, SWT.NONE);
            errors.setText("0"); //$NON-NLS-1$

            Composite col3 = new Composite(statistics, SWT.NONE);
            GridData gd_col3 = new GridData(SWT.LEFT, SWT.CENTER, true, false, 1, 1);
            configureStatisticColumnGridData(gd_col3);
            col3.setLayoutData(gd_col3);
            RowLayout rl_col3 = new RowLayout(SWT.HORIZONTAL);
            col3.setLayout(rl_col3);
            label = new Label(col3, SWT.NONE);
            label.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_FAILURE));
            label = new Label(col3, SWT.NONE);
            label.setText(Messages.Failures + ":"); //$NON-NLS-1$
            failures = new Label(col3, SWT.NONE);
            failures.setText("0"); //$NON-NLS-1$

            Composite col4 = new Composite(statistics, SWT.NONE);
            GridData gd_col4 = new GridData(SWT.LEFT, SWT.CENTER, true, false, 1, 1);
            configureStatisticColumnGridData(gd_col4);
            col4.setLayoutData(gd_col4);
            RowLayout rl_col4 = new RowLayout(SWT.HORIZONTAL);
            col4.setLayout(rl_col4);
            label = new Label(col4, SWT.NONE);
            label.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_ASSERTION));
            label = new Label(col4, SWT.NONE);
            label.setText(Messages.Assertions + ":"); //$NON-NLS-1$
            assertions = new Label(col4, SWT.NONE);
            assertions.setText("0"); //$NON-NLS-1$

            Composite col5 = new Composite(statistics, SWT.BORDER | SWT.NO_FOCUS);
            col5.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, true, false, 1, 1));
            GridLayout gl_col5 = new GridLayout(1, false);
            gl_col5.marginWidth = 0;
            gl_col5.marginHeight = 0;
            col5.setLayout(gl_col5);

            errorPanel = new Composite(col5, SWT.NONE);
            GridData gd_errorPanel = new GridData(GridData.HORIZONTAL_ALIGN_FILL | GridData.GRAB_HORIZONTAL);
            gd_errorPanel.widthHint = 400;
            gd_errorPanel.minimumWidth = 10;
            gd_errorPanel.heightHint = 18;
            errorPanel.setLayoutData(gd_errorPanel);

        }

        private void configureStatisticColumnGridData(GridData aGridData) {
            aGridData.horizontalAlignment = SWT.LEFT;
            aGridData.verticalAlignment = SWT.CENTER;
            aGridData.grabExcessHorizontalSpace = true;
            aGridData.grabExcessVerticalSpace = false;
            aGridData.horizontalSpan = 1;
            aGridData.verticalSpan = 1;
            aGridData.minimumWidth = 80;
        }

        private boolean hasErrors() {
            return hasErrors;
        }

        private void update(UnitTestSuite[] results) {
            int numberRuns = 0;
            int numberErrors = 0;
            int numberFailures = 0;
            int numberAssertions = 0;
            int numberTestCases = 0;

            for (UnitTestSuite unitTestResult : results) {
                numberRuns += unitTestResult.getRuns();
                numberErrors += unitTestResult.getNumberErrors();
                numberFailures += unitTestResult.getNumberFailures();
                numberAssertions += unitTestResult.getNumberAssertions();
                numberTestCases += unitTestResult.getNumberTestCases();
            }

            runs.setText(String.valueOf(numberRuns) + "/" + String.valueOf(numberTestCases)); //$NON-NLS-1$
            errors.setText(String.valueOf(numberErrors));
            failures.setText(String.valueOf(numberFailures));
            assertions.setText(String.valueOf(numberAssertions));

            if (numberErrors > 0 || numberFailures > 0) {
                errorPanel.setBackground(red);
                hasErrors = true;
            } else if (numberRuns > 0) {
                errorPanel.setBackground(green);
                hasErrors = false;
            } else {
                errorPanel.setBackground(grey);
                hasErrors = false;
            }

            if (hasErrors) {
                setTitleImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_RPGUNIT_ERROR));
            } else {
                setTitleImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_RPGUNIT_OK));
            }

            this.update();
            getShell().layout(true, true);
        }
    }

}
