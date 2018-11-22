/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

import java.util.Arrays;

import de.tools400.rpgunit.core.preferences.Preferences;

public class I5LibraryList {

    private String[] libraryList;

    public static I5LibraryList getDefaultList() {
        String[] libraries = Preferences.getInstance().getLibraryList();
        return new I5LibraryList(libraries);
    }

    public I5LibraryList(String[] libraries) {
        this.libraryList = libraries;
    }

    public String[] getLibraries() {
        return libraryList;
    }

    @Override
    public int hashCode() {

        final int prime = 31;
        int result = 1;

        result = prime * result + Arrays.hashCode(libraryList);

        return result;
    }

    @Override
    public boolean equals(Object obj) {

        if (this == obj) {
            return true;
        }

        if (obj == null) {
            return false;
        }

        if (getClass() != obj.getClass()) {
            return false;
        }

        I5LibraryList other = (I5LibraryList)obj;
        if (!Arrays.equals(libraryList, other.libraryList)) {
            return false;
        }

        return true;
    }

    @Override
    public String toString() {

        StringBuilder buffer = new StringBuilder();

        for (String library : libraryList) {
            if (buffer.length() > 0) {
                buffer.append(","); //$NON-NLS-1$
            }
            buffer.append(library);
        }

        return buffer.toString();
    }

}
