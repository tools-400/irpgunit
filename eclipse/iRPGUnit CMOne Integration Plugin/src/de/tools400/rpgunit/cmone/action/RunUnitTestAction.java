package de.tools400.rpgunit.cmone.action;

import java.util.LinkedList;
import java.util.List;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.rse.services.clientserver.messages.SystemMessageException;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Shell;

import com.ibm.etools.iseries.services.qsys.api.IQSYSServiceProgram;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.taskforce.cmoneng.cmonengobject.ICMOneNGObject;
import de.taskforce.cmoneng.cmonengobject.nfs.ICMOneNGNFSObject;
import de.taskforce.cmoneng.connection.model.CMOneNGConnection;
import de.taskforce.cmoneng.extensionpoints.AdditionalParameter;
import de.taskforce.cmoneng.extensionpoints.ICMOneNGObjectAction;
import de.taskforce.cmoneng.general.IValidityCheck;
import de.tools400.rpgunit.cmone.RPGUnitCMOneIntegrationPlugin;
import de.tools400.rpgunit.cmone.Messages;
import de.tools400.rpgunit.cmone.preferences.Preferences;
import de.tools400.rpgunit.core.handler.ISelectionHandler;
import de.tools400.rpgunit.core.handler.RunUnitTestHandler;
import de.tools400.rpgunit.core.model.ibmi.I5Library;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.ui.UIUtils;

public class RunUnitTestAction implements ICMOneNGObjectAction, IValidityCheck {

    public static final String ID = "de.tools400.rpgunit.cmone.action.RunUnitTestAction"; //$NON-NLS-1$

    private static final String RPGUNIT_LABEL = "RPGUNIT"; //$NON-NLS-1$

    private Preferences preferences;

    public RunUnitTestAction() {
        super();

        this.preferences = Preferences.getInstance();
    }

    public boolean showAction(ICMOneNGObject cmoneObject, String mode) {
        return true;
    }

    public Image getImage() {
        return RPGUnitCMOneIntegrationPlugin.getDefault().getImageRegistry().get(RPGUnitCMOneIntegrationPlugin.IMAGE_RUN_RPGUNIT);
    }

    public String getText() {
        return Messages.Run_Unit_Test;
    }

    public boolean isValid(Object object, String action) {

        if (!preferences.isCMOneIntegrationEnabled()) {
            return false;
        }

        if (object instanceof ICMOneNGNFSObject) {

            ICMOneNGNFSObject cmoneObject = (ICMOneNGNFSObject)object;

            if (checkValid(cmoneObject) != null) {
                return true;
            } else {
                return false;
            }
        }

        return false;
    }

    public boolean isValid(ICMOneNGObject[] cmoneObjects) {

        if (!preferences.isCMOneIntegrationEnabled()) {
            return false;
        }

        int menuItemCount = 0;

        for (int idx = 0; idx < cmoneObjects.length; idx++) {
            if (cmoneObjects[idx] instanceof ICMOneNGNFSObject) {
                ICMOneNGNFSObject cmoneNGNFSObject = (ICMOneNGNFSObject)cmoneObjects[idx];
                if (checkValid(cmoneNGNFSObject) != null) {
                    menuItemCount++;
                }
            }
        }

        if (menuItemCount > 0 && menuItemCount == cmoneObjects.length) {
            return true;
        } else {
            return false;
        }
    }

    private ICMOneNGNFSObject checkValid(ICMOneNGNFSObject cmoneObjects) {

        if (!cmoneObjects.getExternalObject().equals("*NONE")) {
            if (cmoneObjects.getObjectType().equals("*SRVPGM")) {
                if (cmoneObjects.getObjectExistence().equals("*YES")) {
                    IBMiConnection connection = getConnection(cmoneObjects);
                    if (connection != null) {
                        return checkServiceProgram(connection, cmoneObjects);
                    }
                }
            }
        }

        return null;
    }

    private ICMOneNGNFSObject checkServiceProgram(IBMiConnection connection, ICMOneNGNFSObject cmoneNFSObject) {

        de.tools400.rpgunit.core.preferences.Preferences corePreferences = de.tools400.rpgunit.core.preferences.Preferences.getInstance();

        try {

            IQSYSServiceProgram qsysServiceProgram = loadServiceProgram(connection, cmoneNFSObject);

            if (de.tools400.rpgunit.core.preferences.Preferences.CHECK_TEST_SUITE_NONE.equals(corePreferences.getCheckTestSuite())) {
                return null;
            } else if (de.tools400.rpgunit.core.preferences.Preferences.CHECK_TEST_SUITE_TEXT.equals(corePreferences.getCheckTestSuite())) {
                if (checkTextDescription(qsysServiceProgram)) {
                    return cmoneNFSObject;
                }
            } else if (de.tools400.rpgunit.core.preferences.Preferences.CHECK_TEST_SUITE_ATTRIBUTE.equals(corePreferences.getCheckTestSuite())) {
                if (checkUserDefinedAttribute(qsysServiceProgram)) {
                    return cmoneNFSObject;
                }
            }

        } catch (Throwable e) {
            e.printStackTrace();
        }

        return null;
    }

    private boolean checkTextDescription(IQSYSServiceProgram qsysServiceProgram) {

        String tDescription = qsysServiceProgram.getDescription();
        if (tDescription == null || tDescription.trim().length() == 0) {
            return false;
        }

        if (!tDescription.toUpperCase().startsWith(RPGUNIT_LABEL)) {
            return false;
        }

        return true;
    }

    private boolean checkUserDefinedAttribute(IQSYSServiceProgram qsysServiceProgram) {

        String tUserDefinedAttribute = qsysServiceProgram.getUserDefinedAttribute();

        if (tUserDefinedAttribute == null || !RPGUNIT_LABEL.equalsIgnoreCase(tUserDefinedAttribute)) {
            // Requires PTF for APAR SE55976
            return false;
        }

        return true;
    }

    public void run(Shell shell, ICMOneNGObject[] cmoneNGObjects) {

        IBMiConnection ibmiConnection = getConnection(cmoneNGObjects[0]);
        if (ibmiConnection != null) {

            if (ibmiConnection != null) {

                List<I5ServiceProgram> servicePrograms = new LinkedList<I5ServiceProgram>();

                for (int idx = 0; idx < cmoneNGObjects.length; idx++) {
                    if (cmoneNGObjects[idx] instanceof ICMOneNGNFSObject) {
                        ICMOneNGNFSObject cmoneNGNFSObject = (ICMOneNGNFSObject)cmoneNGObjects[idx];
                        I5ServiceProgram serviceProgram = produceServiceProgram(ibmiConnection, cmoneNGNFSObject);
                        if (serviceProgram != null) {
                            servicePrograms.add(serviceProgram);
                        }
                    }
                }

                if (!servicePrograms.isEmpty()) {

                    try {
                        ISelectionHandler tHandler = new RunUnitTestHandler();
                        tHandler.execute(new StructuredSelection(servicePrograms));
                    } catch (ExecutionException e) {
                        UIUtils.displayError(e);
                    }

                }

            }

        }

    }

    private IQSYSServiceProgram loadServiceProgram(IBMiConnection connection, ICMOneNGNFSObject cmoneNFSObject)
        throws SystemMessageException, InterruptedException {

        String object = cmoneNFSObject.getObject();
        String library = cmoneNFSObject.getObjectLibrary();

        return (IQSYSServiceProgram)connection.getObject(library, object, "*SRVPGM", null);
    }

    private I5ServiceProgram produceServiceProgram(IBMiConnection connection, ICMOneNGNFSObject cmoneNFSObject) {

        String name = cmoneNFSObject.getObject();

        String library = cmoneNFSObject.getObjectLibrary();
        I5Library i5Library = new I5Library(library, connection);

        return new I5ServiceProgram(name, i5Library);
    }

    private IBMiConnection getConnection(ICMOneNGObject cmoneNGObject) {

        CMOneNGConnection connection = CMOneNGConnection.load(cmoneNGObject.getConnection());
        if (connection == null) {
            return null;
        }

        String rseProfil = connection.getPropertiesEngine().getProperty("RSEProfil");
        String rseConnection = connection.getPropertiesEngine().getProperty("RSEConnection");

        return IBMiConnection.getConnection(rseProfil, rseConnection);
    }

    public void doubleClick(Shell shell, ICMOneNGObject cmoneNGObject) {
    }

    public void setAdditionalParameter(AdditionalParameter additionalParameter) {
    }

    public String identify() {
        return "*RPGUNIT";
    }

    public boolean isEditor() {
        return false;
    }

    public String getEditorMode() {
        return "";
    }

}
