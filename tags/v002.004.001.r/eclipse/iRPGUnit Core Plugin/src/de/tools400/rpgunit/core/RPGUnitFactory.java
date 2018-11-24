/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core;

import java.io.InputStream;
import java.util.Properties;

import de.tools400.rpgunit.core.ui.view.IRPGUnitViewDelegate;

public final class RPGUnitFactory {

    /**
     * The instance of this Singleton class.
     */
    private static RPGUnitFactory instance;

    private Properties properties;

    private static final String VIEW_DELEGATE = "viewDelegate"; //$NON-NLS-1$

    /**
     * Private constructor to ensure the Singleton pattern.
     */
    private RPGUnitFactory() {
    }

    /**
     * Thread-safe method that returns the instance of this Singleton class.
     */
    public synchronized static RPGUnitFactory getInstance() {
        if (instance == null) {
            instance = new RPGUnitFactory();
            instance.loadProperties();
        }
        return instance;
    }

    public static IRPGUnitViewDelegate produceViewDelegate() {
        String tClassName = null;
        try {
            tClassName = getInstance().properties.getProperty(VIEW_DELEGATE);
            Object tDelegate = Class.forName(tClassName).newInstance();
            return (IRPGUnitViewDelegate)tDelegate;
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Failed to load class: " + tClassName, e); //$NON-NLS-1$
        }
        return null;
    }

    private void loadProperties() {
        try {
            InputStream tStream = RPGUnitFactory.class.getResourceAsStream("rpgunit.properties"); //$NON-NLS-1$
            properties = new Properties();
            properties.load(tStream);
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Unable to load configuration from file 'rpgunit.properties'.", e); //$NON-NLS-1$
        }
    }

}