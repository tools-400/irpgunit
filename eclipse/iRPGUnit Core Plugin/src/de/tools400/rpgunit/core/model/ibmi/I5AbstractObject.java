/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

public abstract class I5AbstractObject {
    private String name = null;

    private String type = null;

    private String description = null;

    public void setName(String name) {
        this.name = name.toUpperCase();
    }

    public String getName() {
        return name;
    }

    public void setType(String type) {
        this.type = type.toUpperCase();
    }

    public String getType() {
        return type;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param description the description to set
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Returns the IFS path of the object.
     * 
     * @return IFS path
     */
    public abstract String getPath();
}