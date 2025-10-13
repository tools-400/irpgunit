/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core;

import java.net.URL;

import org.eclipse.core.runtime.Status;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.resource.ImageRegistry;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.osgi.framework.Constants;

/**
 * The activator class controls the plug-in life cycle
 */
public class RPGUnitCorePlugin extends AbstractUIPlugin {

    public static final String IMAGE_RPGUNIT = "rpgunit16.png"; //$NON-NLS-1$
    public static final String IMAGE_RPGUNIT_OK = "rpgunit16ok.png"; // $NON-NLS-1$
    public static final String IMAGE_RPGUNIT_ERROR = "rpgunit16error.png"; //$NON-NLS-1$
    public static final String IMAGE_RPGUNIT_CANCELED = "rpgunit16canceled.png"; //$NON-NLS-1$

    public static final String IMAGE_ASSERTION = "assertions16.png"; //$NON-NLS-1$
    public static final String IMAGE_FAILURE = "failure16.png"; //$NON-NLS-1$
    public static final String IMAGE_ERROR = "error16.png"; //$NON-NLS-1$

    public static final String IMAGE_TEST_NOT_YET_RUN = "test_not_yet_run16.gif"; //$NON-NLS-1$
    public static final String IMAGE_TEST_CANCELED = "test_canceled16.gif"; //$NON-NLS-1$
    public static final String IMAGE_TEST_SUCCESS = "test_success16.gif"; //$NON-NLS-1$
    public static final String IMAGE_TEST_FAILED = "test_failed16.gif"; //$NON-NLS-1$
    public static final String IMAGE_TEST_ERROR = "test_error16.gif"; //$NON-NLS-1$

    public static final String IMAGE_COPY = "copy_not_hoovered.png"; //$NON-NLS-1$
    public static final String IMAGE_COPY_HOOVERED = "copy_hoovered.png"; //$NON-NLS-1$

    public static final String IMAGE_SRVPGM = "srvpgm.gif"; //$NON-NLS-1$
    public static final String IMAGE_PROCEDURE = "procedure.gif"; //$NON-NLS-1$

    public static final String IMAGE_TRANSFER_LIBRARY = "transfer_library16.gif"; //$NON-NLS-1$

    public static final String ICONS_PATH = "icons/";

    // The plug-in ID
    public static final String PLUGIN_ID = "de.tools400.rpgunit.core"; //$NON-NLS-1$

    // The shared instance
    private static RPGUnitCorePlugin plugin;

    // URL, where the plug-in is installed
    private static URL installURL;

    /**
     * The constructor
     */
    public RPGUnitCorePlugin() {
        return;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.
     * BundleContext )
     */
    @Override
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
        installURL = context.getBundle().getEntry("/");
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.
     * BundleContext )
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
    public static RPGUnitCorePlugin getDefault() {
        return plugin;
    }

    /**
     * Returns the release that is required for installing the RPGUNIT library.
     * <p>
     * The minimum required release is 7.5. RPGUNIT can also be installed on 7.4
     * or 7.3 in case the following PTFs have been applied:
     * <p>
     * <b>7.3</b>
     * <ul>
     * <li>ILE RPG runtime: SI71535</li>
     * <li>ILE RPG compiler: SI71534</li>
     * </ul>
     * <p>
     * <b>7.4</b>
     * <ul>
     * <li>ILE RPG runtime: SI71537</li>
     * <li>ILE RPG compiler: SI71536</li>
     * </ul>
     * 
     * @return minimum required release
     */
    public static String getMinOS400Release() {
        return "7.5";
    }

    public static URL getInstallURL() {
        return installURL;
    }

    public static IPreferenceStore getPreferencesStore() {
        return getDefault().getPreferenceStore();
    }

    /**
     * Returns the version of the plug-in, as assigned to "Bundle-Version" in
     * "MANIFEST.MF".
     * 
     * @return Version of the plug-in.
     */
    public String getVersion() {
        String version = (String)getBundle().getHeaders().get(Constants.BUNDLE_VERSION);
        if (version == null) {
            version = "0.0.0"; //$NON-NLS-1$
        }

        // try {
        // Pattern pattern = Pattern
        // .compile("^([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})(?:\\.v[0-9]{0,12})?");
        // Matcher matcher = pattern.matcher(version);
        // if (matcher.find()) {
        // version = matcher.group(1);
        // }
        // } catch (Throwable e) {
        // // Ignore errors and return original version string
        // }

        return version;
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
        plugin.getLog().log(new Status(Status.ERROR, PLUGIN_ID, Status.ERROR, "RPGUnit: " + message, e)); //$NON-NLS-1$
    }

    /**
     * Returns an image descriptor for the image file at the given plug-in
     * relative path
     * 
     * @param fileName the image path
     * @return the image descriptor
     */
    public static ImageDescriptor getImageDescriptor(String fileName) {
        return imageDescriptorFromPlugin(PLUGIN_ID, ICONS_PATH + fileName);
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.plugin.AbstractUIPlugin#initializeImageRegistry(org.
     * eclipse .jface.resource.ImageRegistry)
     */
    @Override
    protected void initializeImageRegistry(ImageRegistry reg) {
        super.initializeImageRegistry(reg);

        // add images
        reg.put(IMAGE_RPGUNIT, getImageDescriptor(IMAGE_RPGUNIT));
        reg.put(IMAGE_RPGUNIT_OK, getImageDescriptor(IMAGE_RPGUNIT_OK));
        reg.put(IMAGE_RPGUNIT_ERROR, getImageDescriptor(IMAGE_RPGUNIT_ERROR));
        reg.put(IMAGE_RPGUNIT_CANCELED, getImageDescriptor(IMAGE_RPGUNIT_CANCELED));

        reg.put(IMAGE_TEST_NOT_YET_RUN, getImageDescriptor(IMAGE_TEST_NOT_YET_RUN));
        reg.put(IMAGE_TEST_CANCELED, getImageDescriptor(IMAGE_TEST_CANCELED));
        reg.put(IMAGE_TEST_SUCCESS, getImageDescriptor(IMAGE_TEST_SUCCESS));
        reg.put(IMAGE_TEST_FAILED, getImageDescriptor(IMAGE_TEST_FAILED));
        reg.put(IMAGE_TEST_ERROR, getImageDescriptor(IMAGE_TEST_ERROR));

        reg.put(IMAGE_COPY, getImageDescriptor(IMAGE_COPY));
        reg.put(IMAGE_COPY_HOOVERED, getImageDescriptor(IMAGE_COPY_HOOVERED));

        reg.put(IMAGE_ASSERTION, getImageDescriptor(IMAGE_ASSERTION));
        reg.put(IMAGE_FAILURE, getImageDescriptor(IMAGE_FAILURE));
        reg.put(IMAGE_ERROR, getImageDescriptor(IMAGE_ERROR));

        reg.put(IMAGE_SRVPGM, getImageDescriptor(IMAGE_SRVPGM));
        reg.put(IMAGE_PROCEDURE, getImageDescriptor(IMAGE_PROCEDURE));
        reg.put(IMAGE_TRANSFER_LIBRARY, getImageDescriptor(IMAGE_TRANSFER_LIBRARY));

        // additional icons used in 'plugin.xml':
        // --------------------------------------
        // collapse_all16.png
        // delete_testcase16.png
        // disable_report.png
        // edit16.gif
        // enable_debug.png
        // expand_all16.png
        // rerun16.gif
        // rpgunit16.png
        // run16.gif
        // toggle16.png
    }
}
