/*******************************************************************************
 * Copyright (c) 2012-2025 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local.properties;

import org.eclipse.ui.part.IPageSite;
import org.eclipse.ui.views.properties.IPropertySheetPage;
import org.eclipse.ui.views.properties.PropertySheetPage;
import org.eclipse.ui.views.properties.PropertySheetSorter;

public class UnitTestPropertyPage extends PropertySheetPage implements IPropertySheetPage {

    @Override
    public void init(IPageSite pageSite) {
        super.init(pageSite);
        setSorter(new UnitTestPropertySheetSorter());
    }

    @Override
    protected void setSorter(PropertySheetSorter sorter) {
        super.setSorter(sorter);
    }

}
