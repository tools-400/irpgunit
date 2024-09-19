/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import java.util.List;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.CommandCall;
import com.ibm.as400.access.Job;

public final class LibraryListHelper {

    public static LibraryList getLibraryList(AS400 system) throws Exception {

        LibraryList libraryList = new LibraryList();

        String currentLibrary = LibraryListHelper.getCurrentLibrary(system);
        libraryList.setCurrentLibrary(currentLibrary);

        String[] userLibraryList = LibraryListHelper.getUserLibraryList(system);
        libraryList.setUserLibraryList(userLibraryList);

        return libraryList;
    }

    public static void restoreLibraryList(AS400 system, LibraryList libraryList) throws Exception {

        changeLibraryList(system, libraryList.getCurrentLibrary(), libraryList.getUserLibraryList());

    }

    public static void changeLibraryList(AS400 system, String currentLibrary, String... libraryList) throws Exception {

        StringBuilder command = new StringBuilder();
        command.append("CHGLIBL");
        command.append(" LIBL(");
        for (int i = 0; i < libraryList.length; i++) {
            if (i > 0) {
                command.append(" ");
            }
            command.append(libraryList[i]);
        }
        command.append(")");

        command.append(" CURLIB(");
        command.append(currentLibrary);
        command.append(")");

        CommandCall commandCall = new CommandCall(system);

        commandCall.run(command.toString());
    }

    public static String getCurrentLibrary(AS400 system) throws Exception {

        String currentLibrary = null;

        Job[] jobs = system.getJobs(AS400.COMMAND);

        if (jobs.length == 1) {

            if (!jobs[0].getCurrentLibraryExistence()) {
                currentLibrary = "*CRTDFT"; //$NON-NLS-1$
            } else {
                currentLibrary = jobs[0].getCurrentLibrary();
            }

        }

        return currentLibrary;
    }

    public static String[] getUserLibraryList(AS400 system) throws Exception {

        List<String> libraryList = null;

        Job[] jobs = system.getJobs(AS400.COMMAND);

        if (jobs.length == 1) {
            libraryList = new java.util.LinkedList<String>();
            String[] userLibraryList = jobs[0].getUserLibraryList();
            if (userLibraryList.length > 0) {
                for (String libraryName : userLibraryList) {
                    libraryList.add(libraryName);
                }
            }
        }

        return libraryList.toArray(new String[libraryList.size()]);
    }

    public static boolean restoreLibraryList(AS400 system, String currentLibrary, String[] userLibraryList) throws Exception {

        StringBuilder command = new StringBuilder();

        command.append("CHGLIBL LIBL(");
        if (userLibraryList == null) {
            command.append("*SAME");
        } else {
            if (userLibraryList.length == 0) {
                command.append("*NONE");
            } else {
                for (int i = 0; i < userLibraryList.length; i++) {
                    command.append(userLibraryList[i]);
                    if (i != userLibraryList.length - 1) {
                        command.append(" ");
                    }
                }
            }
        }
        command.append(")");

        command.append(" CURLIB(");
        if (currentLibrary == null) {
            command.append("*SAME");
        } else {
            command.append(currentLibrary);
        }
        command.append(")");

        CommandCall commandCall = new CommandCall(system);

        if (commandCall.run(command.toString())) {
            return true;
        } else {
            return false;
        }
    }

    public static boolean setCurrentLibrary(AS400 system, String currentLibrary) throws Exception {

        String command = "CHGCURLIB CURLIB(" + currentLibrary + ")"; //$NON-NLS-1$ //$NON-NLS-2$
        CommandCall commandCall = new CommandCall(system);

        if (commandCall.run(command)) {
            return true;
        } else {
            return false;
        }
    }

    public static class LibraryList {

        private String currentLibrary;
        private String[] userLibraryList;

        public String getCurrentLibrary() {
            return currentLibrary;
        }

        public void setCurrentLibrary(String currentLibrary) {
            this.currentLibrary = currentLibrary;
        }

        public String[] getUserLibraryList() {
            return userLibraryList;
        }

        public void setUserLibraryList(String[] userLibraryList) {
            this.userLibraryList = userLibraryList;
        }

        @Override
        public String toString() {
            StringBuilder buffer = new StringBuilder();

            buffer.append("Current Library: ");
            buffer.append(getCurrentLibrary());

            buffer.append(", User Library List: ");

            String[] libraries = getUserLibraryList();
            for (int i = 0; i < libraries.length; i++) {
                if (i > 0) {
                    buffer.append(" ");
                }
                buffer.append(libraries[i]);
            }

            return buffer.toString();
        }
    }
}
