/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

public final class IntHelper {

    /**
     * Parses an Integer value from a given hex string text.
     * 
     * @param someText Text representing an integer value.
     * @return Integer on success, else null.
     */
    public static Integer tryParseHex(String someText) {
        try {
            return Integer.parseInt(someText, 16);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    /**
     * Parses an <code>int</code> value from a given hex string text.
     * 
     * @param someText Text representing an <code>int</code> value.
     * @param defaultValue Default value that is returned on invalid input
     *        values.
     * @return <code>int</code> value on success, else the specified default
     *         value.
     */
    public static Integer tryParseHex(String someText, int defaultValue) {
        Integer integer = tryParseHex(someText);
        if (integer == null) {
            return new Integer(defaultValue);
        }
        return integer;
    }

    /**
     * Parses an Integer value from a given text.
     * 
     * @param someText Text representing an integer value.
     * @return Integer on success, else null.
     */
    public static Integer tryParseInt(String someText) {

        if (someText == null) {
            return null;
        }

        try {
            return Integer.parseInt(someText);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    /**
     * Parses an Integer value from a given text.
     * 
     * @param someText Text representing an integer value.
     * @param defaultValue Default value that is returned on invalid input
     *        values.
     * @return Integer on success, else the specified default value.
     */
    public static Integer tryParseInt(String someText, Integer defaultValue) {
        Integer integer = tryParseInt(someText);
        if (integer == null) {
            return defaultValue;
        }
        return integer;
    }

    /**
     * Parses an <code>int</code> value from a given text.
     * 
     * @param someText Text representing an <code>int</code> value.
     * @param defaultValue Default value that is returned on invalid input
     *        values.
     * @return <code>int</code> value on success, else the specified default
     *         value.
     */
    public static Integer tryParseInt(String someText, int defaultValue) {
        Integer integer = tryParseInt(someText);
        if (integer == null) {
            return new Integer(defaultValue);
        }
        return integer;
    }

}
