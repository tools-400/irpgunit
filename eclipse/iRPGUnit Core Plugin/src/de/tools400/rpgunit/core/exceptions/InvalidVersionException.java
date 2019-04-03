/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.exceptions;

import de.tools400.rpgunit.core.Messages;

public class InvalidVersionException extends RuntimeException {

    private static final long serialVersionUID = 8017370341571553806L;

    private int version;

    public InvalidVersionException(int version) {
        this.version = version;
    }

    public int getVersion() {
        return version;
    }

    @Override
    public String getMessage() {
        return Messages.bind(Messages.Invalid_host_version, Integer.toString(version));
    }
}
