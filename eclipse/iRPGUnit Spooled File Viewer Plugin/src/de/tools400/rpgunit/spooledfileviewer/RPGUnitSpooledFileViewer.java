/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer;

import org.eclipse.core.runtime.Status;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.tools400.rpgunit.spooledfileviewer.model.SpooledFilesStore;

/**
 * The activator class controls the plug-in life cycle
 */
public class RPGUnitSpooledFileViewer extends AbstractUIPlugin {

    // The plug-in ID
    public static final String PLUGIN_ID = "de.tools400.rpgunit.spooledfileviewer"; //$NON-NLS-1$

    // The shared instance
    private static RPGUnitSpooledFileViewer plugin;

    // The current spooled file, set by class 'DisplayReportEnabler'.
    private SpooledFilesStore spooledFiles = null;

    /**
     * The constructor
     */
    public RPGUnitSpooledFileViewer() {
        spooledFiles = new SpooledFilesStore();
    }

    public SpooledFilesStore getSpooledFilesStore() {
        return spooledFiles;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
     * )
     */
    @Override
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
     * )
     */
    @Override
    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance
     * 
     * @return the shared instance
     */
    public static RPGUnitSpooledFileViewer getDefault() {
        return plugin;
    }

    /**
     * Convenience method to log informational messages to the application log.
     * 
     * @param message Message
     */
    public static void logInfo(String message) {
        plugin.getLog().log(new Status(Status.INFO, PLUGIN_ID, message));
    }

    /**
     * Convenience method to log error messages to the application log.
     * 
     * @param message Message
     */
    public static void logError(String message) {
        logError(message, null);
    }

    /**
     * Convenience method to log error messages to the application log.
     * 
     * @param message Message
     * @param e The exception that has produced the error
     */
    public static void logError(String message, Exception e) {
        plugin.getLog().log(new Status(Status.ERROR, PLUGIN_ID, Status.ERROR, message, e));
    }
}
