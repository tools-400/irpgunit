/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySheetEntry;
import org.eclipse.ui.views.properties.PropertyDescriptor;

import de.tools400.rpgunit.core.helpers.StringHelper;

public abstract class AbstractUnitTestObject {

    protected IPropertyDescriptor createPropertyDescriptor(String id, String displayName, boolean advanced, String category) {

        IPropertyDescriptor propertyDescriptor = createPropertyDescriptor(id, displayName, advanced);
        if (category != null) {
            ((PropertyDescriptor)propertyDescriptor).setCategory(category);
        }
        return propertyDescriptor;
    }

    protected IPropertyDescriptor createPropertyDescriptor(String id, String displayName, boolean advanced) {

        PropertyDescriptor descriptor = new PropertyDescriptor(id, displayName);
        if (advanced) {
            descriptor.setFilterFlags(new String[] { IPropertySheetEntry.FILTER_ID_EXPERT });
        }

        return descriptor;
    }

    protected boolean isPropertyEmpty(String property) {

        if (StringHelper.isNullOrEmpty(property)) {
            return true;
        }

        if ("*N".equals(property)) {
            return true;
        }

        return false;
    }
}
