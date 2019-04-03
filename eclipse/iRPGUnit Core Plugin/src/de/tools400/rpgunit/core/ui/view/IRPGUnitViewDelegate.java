/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.view;

import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.ui.IViewSite;
import org.eclipse.ui.IWorkbenchPartSite;

public interface IRPGUnitViewDelegate {

    public void initialize(IWorkbenchPartSite aWorkbenchPartSite, IViewSite aViewSite);

    public void enableRerunSelectedUnitTestButton(boolean aHasSelectedUnitTestCasesOrUnitTestSuites);

    public void enableRemoveSelectedUnitTestButton(boolean aHasSelectedUnitTestSuites);

    public void enableEditRemoteSourceMemberButton(boolean aHasSelectedItemsWithSourceMember);

    public void enableRerunAllUnitTestsButton(int aNumItems);

    public void enableCollapseAllButton(int aNumItems);

    public void enableExpandAllButton(int aNumItems);

    public void enableToggleDisableReportButton(boolean aCheckedState);

    public void hookContextMenu(TreeViewer aViewer);

    public void configureView(TreeViewer aViewer, ViewerFilter aFilter);

}
