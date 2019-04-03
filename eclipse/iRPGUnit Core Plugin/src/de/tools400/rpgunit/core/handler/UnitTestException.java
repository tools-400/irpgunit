/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.handler;

public class UnitTestException extends Exception {
    private static final long serialVersionUID = 7491316398879050049L;

    public enum Type {
        loadError,
        noTestCases,
        reclaimError,
        unexpectedError;
    }

    private Type type;

    private String message;

    public UnitTestException(Type type) {
        super();
        this.type = type;
    }

    public UnitTestException(String message, Type type) {
        super(message);
        this.type = type;
    }

    public Type getType() {
        return type;
    }

    @Override
    public String getMessage() {
        if (message != null)
            return message;
        else
            return super.getMessage();
    }
}
