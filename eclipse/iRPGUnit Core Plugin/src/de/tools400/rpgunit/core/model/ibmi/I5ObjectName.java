/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

public class I5ObjectName {

    private String name;

    private String library;

    public I5ObjectName(String aName) {
        this(aName, "*LIBL"); //$NON-NLS-1$
    }

    public I5ObjectName(String aName, String aLibrary) {
        name = aName;
        library = aLibrary;
    }

    public String getName() {
        return name;
    }

    public String getLibrary() {
        return library;
    }

    @Override
    public String toString() {
        StringBuilder tValue = new StringBuilder();
        if (library == null) {
            tValue.append("*N"); //$NON-NLS-1$
        } else {
            tValue.append(library.trim());
        }
        tValue.append("/"); //$NON-NLS-1$
        if (name == null) {
            tValue.append("*N"); //$NON-NLS-1$
        } else {
            tValue.append(name.trim());
        }
        return tValue.toString();
    }
}
