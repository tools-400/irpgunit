/*******************************************************************************
 * Copyright (c) 2012-2025 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local.properties;

import org.eclipse.ui.views.properties.IPropertySheetEntry;
import org.eclipse.ui.views.properties.PropertySheetSorter;

public class UnitTestPropertySheetSorter extends PropertySheetSorter {

    @Override
    public void sort(IPropertySheetEntry[] entries) {
        super.sort(entries);
    }

    public int compare(IPropertySheetEntry entryA, IPropertySheetEntry entryB) {
        // Keep the sequence the properties were added.
        return this.getCollator().compare("", "");
    }

    public int compareCategories(String categoryA, String categoryB) {
        // Keep the sequence the properties were added.
        return this.getCollator().compare("", "");
    }
}
