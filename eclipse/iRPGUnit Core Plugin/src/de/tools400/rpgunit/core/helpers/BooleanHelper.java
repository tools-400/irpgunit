/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

public final class BooleanHelper {

    /**
     * Parses a Boolean value from a given text.
     * 
     * @param aSomeText Text representing a boolean value.
     * @return Boolean on success, else null.
     */
    public static Boolean tryParseBoolean(String aSomeText) {
        try {
            return Boolean.parseBoolean(aSomeText);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    /**
     * Parses a Boolean value from a given text.
     * 
     * @param aSomeText Text representing a boolean value.
     * @param aDefaultValue Default value that is returned on invalid input
     *        values.
     * @return Boolean on success, else the specified default value.
     */
    public static Boolean tryParseBoolean(String aSomeText, Boolean aDefaultValue) {
        Boolean tBoolean = tryParseBoolean(aSomeText);
        if (tBoolean == null) {
            return aDefaultValue;
        }
        return tBoolean;
    }

    /**
     * Parses a <code>boolean</code> value from a given text.
     * 
     * @param aSomeText Text representing a <code>boolean</code> value.
     * @param aDefaultValue Default value that is returned on invalid input
     *        values.
     * @return <code>boolean</code> value on success, else the specified default
     *         value.
     */
    public static Boolean tryParseBoolean(String aSomeText, boolean aDefaultValue) {
        if (aSomeText == null) {
            return aDefaultValue;
        }
        Boolean tBoolean = tryParseBoolean(aSomeText);
        if (tBoolean == null) {
            return new Boolean(aDefaultValue);
        }
        return tBoolean;
    }

}
