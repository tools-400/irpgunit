/*******************************************************************************
 * Copyright (c) 2012-2025 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

public class UnitTestLogValue {

    private short length;
    private short originalLength;
    private String dataType;
    private String assertProcedure;
    private String value;

    public UnitTestLogValue(short aLen, short anOrigLen, String aDataType, String anAssertProc, String anIsTruncated, String aValue) {
        this.length = aLen;
        this.originalLength = anOrigLen;
        this.dataType = aDataType;
        this.assertProcedure = anAssertProc;
        this.value = aValue;
    }

    public short getLength() {
        return length;
    }

    public short getOriginalLength() {
        return originalLength;
    }

    public String getDataType() {
        return dataType;
    }

    public String getAssertProcedure() {
        return assertProcedure;
    }

    public String getValue() {
        return value;
    }

    @Override
    public String toString() {
        if (length == 0) {
            return "null";
        } else {
            return "(length=" + length + ", value: '" + value + "')";
        }
    }
}
