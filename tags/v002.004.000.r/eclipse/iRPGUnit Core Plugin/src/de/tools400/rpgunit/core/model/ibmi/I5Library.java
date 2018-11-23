/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

import java.util.TreeMap;

import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

public class I5Library extends I5AbstractObject implements Comparable<I5Library> {
    private IBMiConnection conn = null;

    private TreeMap<String, I5Object> objects = new TreeMap<String, I5Object>();

    protected boolean objectsLoaded = false;

    private boolean exist = true;

    public I5Library(String name, IBMiConnection conn) {
        setName(name.toUpperCase());
        setType("*LIB"); //$NON-NLS-1$
        this.conn = conn;
    }

    /**
     * Returns true if the library object exists on the server or if the
     * connection to the server has not been made yet.
     * 
     * @return true if library object exists otherwise false
     */
    public boolean doesExist() {
        return exist;
    }

    /**
     * Sets the library existance state.
     * 
     * @param libraryExist
     */
    public void setExist(boolean libraryExist) {
        this.exist = libraryExist;
    }

    public void addObject(I5Object object) {
        // only the object name as a key does not suffice because in a library
        // there can
        // be objects with the same name but different attributes
        objects.put(object.toString(), object);
    }

    public void removeObject(I5Object object) {
        objects.remove(object.toString());
    }

    public I5Object getObject(String objectString) {
        return objects.get(objectString);
    }

    public I5Object getObject(String name, String suffix) {
        return objects.get(name + "." + suffix); //$NON-NLS-1$
    }

    public I5Object[] getObjects() {
        return objects.values().toArray(new I5Object[objects.values().size()]);
    }

    public IBMiConnection getConnection() {
        return conn;
    }

    public boolean areObjectsLoaded() {
        return objectsLoaded;
    }

    public void setObjectsLoaded(boolean objectsLoaded) {
        this.objectsLoaded = objectsLoaded;
    }

    /**
     * Returns the IFS path.
     * 
     * @return IFS path
     */
    @Override
    public String getPath() {
        return "/QSYS.LIB/" + getName() + ".LIB"; //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Returns a String representation of the library.
     * 
     * @return Library name
     */
    @Override
    public String toString() {
        return getName();
    }

    @Override
    public int compareTo(I5Library aLibrary) {
        if (aLibrary.getName() == null) {
            return 1;
        } else if (getName() == null) {
            return -1;
        }
        return getName().compareToIgnoreCase(aLibrary.getName());
    }
}