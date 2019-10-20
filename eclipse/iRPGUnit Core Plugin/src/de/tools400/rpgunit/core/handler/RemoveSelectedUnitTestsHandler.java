/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.jface.viewers.IStructuredSelection;

import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.ui.view.RPGUnitView;

public class RemoveSelectedUnitTestsHandler extends AbstractUnitTestsHandler {

    @Override
    public Object execute(ExecutionEvent anEvent) {

        RPGUnitView tView = getView(anEvent);

        IStructuredSelection tSelectedItems = tView.getSelectedItems();
        Iterator<?> selectedItemsIterator = tSelectedItems.iterator();

        ArrayList<UnitTestSuite> tUnitTestSuitesToBeRemoved = new ArrayList<UnitTestSuite>();
        while (selectedItemsIterator.hasNext()) {
            Object selectedItem = selectedItemsIterator.next();
            if (selectedItem instanceof UnitTestSuite) {
                UnitTestSuite tUnitTestSuite = (UnitTestSuite)selectedItem;
                tUnitTestSuitesToBeRemoved.add(tUnitTestSuite);
            }
        }

        Set<UnitTestSuite> tAvailableUnitTestSuites = new HashSet<UnitTestSuite>(Arrays.asList(tView.getInput()));
        tAvailableUnitTestSuites.removeAll(tUnitTestSuitesToBeRemoved);
        tView.setInput(tAvailableUnitTestSuites.toArray(new UnitTestSuite[tAvailableUnitTestSuites.size()]), false);

        return null;
    }

}
