/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

import org.eclipse.ui.IActionFilter;

import com.ibm.as400.access.QSYSObjectPathName;

public class I5Object extends I5AbstractObject implements IActionFilter, Comparable<I5Object> {
    public String type = null; // making the type public for the action filter
                               // interface

    public String attr = null;

    private String userDefinedAttribute = null;

    private I5Library lib = null;

    private String sourceFile = null;

    private String sourceLibrary = null;

    private String sourceMember = null;

    public I5Object(String name, String type, I5Library lib) {
        setName(name.toUpperCase());
        setLibrary(lib);
        setType(type.toUpperCase());
    }

    public String getAttribute() {
        return attr;
    }

    public void setAttribute(String attr) {
        this.attr = attr;
    }

    public void setLibrary(I5Library lib) {
        this.lib = lib;
    }

    public I5Library getLibrary() {
        return lib;
    }

    @Override
    public String getType() {
        return this.type;
    }

    @Override
    public void setType(String type) {
        this.type = type;
    }

    public String getSourceFile() {
        return sourceFile;
    }

    public void setSourceFile(String sourceFile) {
        this.sourceFile = sourceFile;
    }

    public String getSourceLibrary() {
        return sourceLibrary;
    }

    public void setSourceLibrary(String sourceLibrary) {
        this.sourceLibrary = sourceLibrary;
    }

    public String getSourceMember() {
        return sourceMember;
    }

    public void setSourceMember(String sourceMember) {
        this.sourceMember = sourceMember;
    }

    /**
     * Returns the IFS path.
     * 
     * @return IFS path
     */
    @Override
    public String getPath() {
        String type = getType();
        if (type.startsWith("*")) { //$NON-NLS-1$
            type = type.substring(1);
        }
        return "/QSYS.LIB/" + getLibrary().getName() + ".LIB/" + getName() + "." + type; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    public QSYSObjectPathName getPathName() {
        return new QSYSObjectPathName(getPath());
    }

    /**
     * Returns a String representation of the object. For files and programs: If
     * the remote object has an attribute which is not blank the suffix of the
     * object name is the attribute. If the attribute is blank the suffix for
     * the object is the type. Other objects: The suffix for the object name is
     * always the type.
     * 
     * @return Description of the remote object
     */
    @Override
    public String toString() {
        StringBuilder tValue = new StringBuilder();
        if (getLibrary() != null && getLibrary().getName() != null) {
            tValue.append(getLibrary().getName());
            tValue.append("/"); //$NON-NLS-1$
        }

        tValue.append(getName());

        if (type.length() > 0) {
            tValue.append("."); //$NON-NLS-1$
            if (attr != null && attr.length() > 0 && (type.equals("*FILE") || type.equals("*PGM"))) { //$NON-NLS-1$ //$NON-NLS-2$
                tValue.append(attr);
            } else if (type.startsWith("*")) { //$NON-NLS-1$
                tValue.append(type.substring(1));
            } else {
                tValue.append(type);
            }
        }

        return tValue.toString();
    }

    /**
     * Test if the attribute of the object are equal to the passed value. The
     * type (type) and the attribute (attr) of the object are available for
     * testing.
     * 
     * @return true if the tested attribute equals the passed value else false
     */
    @Override
    public boolean testAttribute(Object target, String name, String value) {
        if (name.equals("type") && type.equals(value)) //$NON-NLS-1$
            return true;
        else if (name.equals("attr") && attr.equals(value)) //$NON-NLS-1$
            return true;
        else if (name.equals("userDefinedAttribute") && userDefinedAttribute != null && userDefinedAttribute.equals(value)) //$NON-NLS-1$
            return true;
        else
            return false;
    }

    public void setUserDefinedAttribute(String userDefinedAttribute) {
        this.userDefinedAttribute = userDefinedAttribute;
    }

    public String getUserDefinedAttribute() {
        return userDefinedAttribute;
    }

    @Override
    public int compareTo(I5Object anObject) {

        if (anObject == null) {
            return 1;
        }

        if (getLibrary() == null) {
            if (anObject.getLibrary() == null) {
                return 0;
            } else {
                return -1;
            }
        }

        int tResult = getLibrary().compareTo(anObject.getLibrary());
        if (tResult != 0) {
            return tResult;
        }

        if (getName() == null) {
            if (anObject.getName() == null) {
                return 0;
            } else {
                return -1;
            }
        }

        return getName().compareToIgnoreCase(anObject.getName());
    }
}