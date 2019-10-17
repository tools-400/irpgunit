/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.view;

import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IViewSite;
import org.eclipse.ui.IWorkbenchPartSite;
import org.eclipse.ui.services.ISourceProviderService;

import de.tools400.rpgunit.core.command.states.CollapseAllTestsCommandState;
import de.tools400.rpgunit.core.command.states.EditRemoteSourceMemberCommandState;
import de.tools400.rpgunit.core.command.states.ExpandAllTestsCommandState;
import de.tools400.rpgunit.core.command.states.RemoveSelectedUnitTestsCommandState;
import de.tools400.rpgunit.core.command.states.RerunAllUnitTestsCommandState;
import de.tools400.rpgunit.core.command.states.RerunSelectedUnitTestsCommandState;

public class RPGUnitViewDelegateRdi implements IRPGUnitViewDelegate {

    private IWorkbenchPartSite workbenchPartSite;

    private IViewSite viewSite;

    public RPGUnitViewDelegateRdi() {
        workbenchPartSite = null;
        viewSite = null;
    }

    @Override
    public void initialize(IWorkbenchPartSite aWorkbenchPartSite, IViewSite aViewSite) {
        workbenchPartSite = aWorkbenchPartSite;
        viewSite = aViewSite;
    }

    public ISourceProviderService getSourceProviderService() {
        ISourceProviderService sourceProviderService = (ISourceProviderService)workbenchPartSite.getWorkbenchWindow()
            .getService(ISourceProviderService.class);
        return sourceProviderService;
    }

    @Override
    public void enableRerunSelectedUnitTestButton(boolean aHasSelectedUnitTestCasesOrUnitTestSuites) {
        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: RerunSelectedUnitTests
        RerunSelectedUnitTestsCommandState tSelectedProvider = (RerunSelectedUnitTestsCommandState)sourceProviderService
            .getSourceProvider(RerunSelectedUnitTestsCommandState.STATE);
        if (aHasSelectedUnitTestCasesOrUnitTestSuites) {
            tSelectedProvider.setEnabled(true);
        } else {
            tSelectedProvider.setEnabled(false);
        }
    }

    @Override
    public void enableRemoveSelectedUnitTestButton(boolean aHasSelectedUnitTestSuites) {
        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: RemoveSelectedUnitTests
        RemoveSelectedUnitTestsCommandState tSelectedProvider = (RemoveSelectedUnitTestsCommandState)sourceProviderService
            .getSourceProvider(RemoveSelectedUnitTestsCommandState.STATE);
        if (aHasSelectedUnitTestSuites) {
            tSelectedProvider.setEnabled(true);
        } else {
            tSelectedProvider.setEnabled(false);
        }
    }

    @Override
    public void enableEditRemoteSourceMemberButton(boolean aHasSelectedItemsWithSourceMember) {
        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: EditRemoteSourceMember
        EditRemoteSourceMemberCommandState tSelectedProvider = (EditRemoteSourceMemberCommandState)sourceProviderService
            .getSourceProvider(EditRemoteSourceMemberCommandState.STATE);
        if (aHasSelectedItemsWithSourceMember) {
            tSelectedProvider.setEnabled(true);
        } else {
            tSelectedProvider.setEnabled(false);
        }
    }

    @Override
    public void enableRerunAllUnitTestsButton(int aNumItems) {

        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: RerunAllUnitTests
        RerunAllUnitTestsCommandState tAllProvider = (RerunAllUnitTestsCommandState)sourceProviderService
            .getSourceProvider(RerunAllUnitTestsCommandState.STATE);
        if (aNumItems > 0) {
            tAllProvider.setEnabled(true);
        } else {
            tAllProvider.setEnabled(false);
        }
    }

    @Override
    public void enableCollapseAllButton(int aNumItems) {

        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: CollapseAllUnitTests/ExpandAllUnitTests
        CollapseAllTestsCommandState tAllProvider = (CollapseAllTestsCommandState)sourceProviderService
            .getSourceProvider(CollapseAllTestsCommandState.STATE);
        if (aNumItems > 0) {
            tAllProvider.setEnabled(true);
        } else {
            tAllProvider.setEnabled(false);
        }
    }

    @Override
    public void enableExpandAllButton(int aNumItems) {

        ISourceProviderService sourceProviderService = getSourceProviderService();

        // Enable/disable command: CollapseAllUnitTests/ExpandAllUnitTests
        ExpandAllTestsCommandState tAllProvider = (ExpandAllTestsCommandState)sourceProviderService
            .getSourceProvider(ExpandAllTestsCommandState.STATE);
        if (aNumItems > 0) {
            tAllProvider.setEnabled(true);
        } else {
            tAllProvider.setEnabled(false);
        }
    }

    @Override
    public void enableToggleDisableReportButton(boolean aCheckedState) {
        // See: PreferencesPage.updateDisableReportButton()
    }

    @Override
    public void hookContextMenu(TreeViewer aViewer) {
        MenuManager menuManager = new MenuManager();
        Menu tMenu = menuManager.createContextMenu(aViewer.getControl());
        aViewer.getControl().setMenu(tMenu);

        workbenchPartSite.registerContextMenu(menuManager, aViewer);
        workbenchPartSite.setSelectionProvider(aViewer);
    }

    @Override
    public void configureView(TreeViewer aViewer, ViewerFilter aFilter) {
        aViewer.setFilters(new ViewerFilter[] { aFilter });
    }

}
