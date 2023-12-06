/*******************************************************************************
 * Copyright (c) 2013-2023 iRPGUnit Project Team
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

    public static final String TYPE_CURRENT = Preferences.LIBRARY_LIST_CURRENT;
    public static final String TYPE_JOBD = Preferences.LIBRARY_LIST_JOBD;
    public static final String TYPE_SPECIFIED = "*SPECIFIED"; //$NON-NLS-1$

    public static I5LibraryList getDefaultList() {
        String[] libraries = Preferences.getInstance().getLibraryList();
        return new I5LibraryList(libraries);
    }

    public I5LibraryList(String[] libraries) {
        this.libraryList = libraries;
    }

    /**
     * Checks, whether the library list is one of the following types:
     * 
     * @param types
     * @return
     */
    public boolean isTypeOf(String type) {

        if (libraryList == null || libraryList.length == 0) {
            return false;
        }

        String firstLibrary = libraryList[0];
        if (firstLibrary == null) {
            return false;
        }

        if (TYPE_CURRENT.equals(type)) {
            if (TYPE_CURRENT.equals(firstLibrary)) {
                return true;
            }
        } else if (TYPE_JOBD.equals(type)) {
            if (TYPE_JOBD.equals(firstLibrary)) {
                return true;
            }
        } else if (TYPE_SPECIFIED.equals(type)) {
            if (!firstLibrary.startsWith("*")) { //$NON-NLS-1$
                return true;
            }
        } else {
            throw new IllegalArgumentException("Illegal value of parameter 'type': " + type); // $NON-NLS-N$
        }

        return false;
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
