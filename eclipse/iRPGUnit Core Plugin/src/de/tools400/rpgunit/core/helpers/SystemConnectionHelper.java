/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.rse.core.model.IHost;

import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

public class SystemConnectionHelper {

    /**
     * Returns an array of connection names sorted by connection name.
     * 
     * @return sorted list of connection names
     */
    public static String[] getConnectionNames() {

        List<String> connectionNames = new LinkedList<String>();

        IBMiConnection[] connections = getConnections();
        for (IBMiConnection connection : connections) {
            connectionNames.add(connection.getConnectionName());
        }

        return connectionNames.toArray(new String[connectionNames.size()]);
    }

    /**
     * Returns an array of hosts sorted by connection name.
     * 
     * @return sorted list of hosts
     */
    public static IHost[] getHosts() {

        IBMiConnection[] connections = getConnections();

        List<IHost> hosts = new LinkedList<IHost>();
        for (IBMiConnection connection : connections) {
            hosts.add(connection.getHost());
        }

        return hosts.toArray(new IHost[hosts.size()]);
    }

    /**
     * Returns an array of IBMiConnections sorted by connection name.
     * 
     * @return sorted list of IBMiConnections
     */
    private static IBMiConnection[] getConnections() {

        IBMiConnection[] connections = IBMiConnection.getConnections();

        Arrays.sort(connections, new Comparator<IBMiConnection>() {

            public int compare(IBMiConnection o1, IBMiConnection o2) {

                if (o2 == null || o2.getConnectionName() == null) {
                    return 1;
                } else if (o1 == null || o1.getConnectionName() == null) {
                    return -1;
                } else {
                    return o1.getConnectionName().compareToIgnoreCase(o2.getConnectionName());
                }

            }
        });

        return connections;
    }
}
