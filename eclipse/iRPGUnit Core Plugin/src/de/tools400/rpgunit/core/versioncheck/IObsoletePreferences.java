/*******************************************************************************
 * Copyright (c) 2012-2014 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.versioncheck;

public interface IObsoletePreferences {

    public static final String RPGUNIT_PREFERENCES_IMPORT_DONE = "rpgunit.preferences.import.done"; //$NON-NLS-1$

    /* Command Parameters */
    public static final String RUN_ORDER = "rpgunit.rmtpgm.order"; //$NON-NLS-1$
    public static final String LIBRARY_LIST = "rpgunit.rmtpgm.libraryList"; //$NON-NLS-1$
    public static final String JOBD_NAME = "rpgunit.rmtpgm.jobDescription.name"; //$NON-NLS-1$
    public static final String JOBD_LIBRARY = "rpgunit.rmtpgm.jobDescription.library"; //$NON-NLS-1$
    public static final String REPORT_DETAIL = "rpgunit.rmtpgm.detail"; //$NON-NLS-1$
    public static final String OUTPUT = "rpgunit.rmtpgm.output"; //$NON-NLS-1$
    public static final String RECLAIM_RESOURCES = "rpgunit.rmtpgm.reclaimResources"; //$NON-NLS-1$

    /* Override Command Parameters */
    public static final String REPORT_DISABLED = "rpgunit.report.disabled"; //$NON-NLS-1$

    /* Runtime */
    public static final String PRODUCT_LIBRARY = "rpgunit.system.productLibrary"; //$NON-NLS-1$
    public static final String CHECK_TEST_SUITE = "rpgunit.checkTestSuite"; //$NON-NLS-1$

    /* Debug */
    public static final String DEBUG_CONNECTION_NEW = "rpgunit.report.connection"; //$NON-NLS-1$
    public static final String DEBUG_POSITION_TO_LINE = "rpgunit.report.positionToLine"; //$NON-NLS-1$

    /* Warning Messages */
    public static final String WARN_MESSAGE_SRC_OPTION = "rpgunit.warnings.source.option.srcstmt"; //$NON-NLS-1$
    public static final String WARN_MESSAGE_USER_DEFINED_ATTRIBUTE = "rpgunit.warnings.serviceprogram.userdefinedattribute"; //$NON-NLS-1$

}
