package de.tools400.rpgunit.core.versioncheck;

import java.util.ArrayList;
import java.util.Dictionary;
import java.util.List;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.progress.UIJob;
import org.osgi.framework.Bundle;
import org.osgi.framework.Version;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.preferences.Preferences;
import de.tools400.rpgunit.core.ui.warning.WarningMessage;

public final class PluginCheck implements IObsoleteBundles {

    private PluginCheck() {
    }

    public static void check() {
        PluginCheck tChecker = new PluginCheck();
        tChecker.performBundleCheck();
    }

    public static boolean hasPlugin(String aPluginID) {
        Bundle bundle = Platform.getBundle(aPluginID);
        if (bundle != null) {
            return true;
        }
        return false;
    }

    public static Class<?> loadClass(String aPluginID, String aClassName) {
        try {
            Bundle bundle = Platform.getBundle(aPluginID);
            if (bundle != null) {
                return bundle.loadClass(aClassName);
            }
        } catch (Throwable e) {
            // Ignore errors
        }
        return null;
    }

    public static Version getVersion(String aPluginID) {

        if (!hasPlugin(aPluginID)) {
            return null;
        }

        Dictionary<?, ?> headers = Platform.getBundle(aPluginID).getHeaders();
        if (headers == null) {
            return null;
        }

        Object version = headers.get("Bundle-Version"); //$NON-NLS-1$
        if (version instanceof String) {
            return new Version((String)version);
        }

        return null;
    }

    private void performBundleCheck() {
        final List<Bundle> tObsoleteBundles = verifyInstalledBundles();
        if (tObsoleteBundles.size() == 0) {
            return;
        }

        new UIJob("OBSOLETE_BUNDLES_WARNING") { //$NON-NLS-1$
            @Override
            public IStatus runInUIThread(IProgressMonitor arg0) {
                Shell parent = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
                WarningMessage.openWarning(parent.getShell(), Preferences.WARN_MESSAGE_OBSOLETE_PLUGINS_V1,
                    Messages.Obsolete_Bundles_Warning_Message_Message + bundlesAsList(tObsoleteBundles));
                return Status.OK_STATUS;
            }

            private String bundlesAsList(List<Bundle> anObsoleteBundles) {
                StringBuilder tList = new StringBuilder();
                for (Bundle tBundle : anObsoleteBundles) {
                    tList.append("\n"); //$NON-NLS-1$
                    tList.append(tBundle.getSymbolicName());
                    // TODO: get version for Eclipse 3.2
                    // tList.append(" (");
                    // tList.append(tBundle.getVersion());
                    // tList.append(")");
                }
                return tList.toString();
            }
        }.schedule();
    }

    private List<Bundle> verifyInstalledBundles() {
        List<Bundle> tObsoleteBundles = new ArrayList<Bundle>();

        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_HELP_BASE);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_HELP_DE);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_HELP_NL_DE);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_IMPLEMENTATION);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_IMPLEMENTATION_NL_DE);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_SPOOLFILEVIEWER);
        checkAndAddObsoleteBundle(tObsoleteBundles, DE_TOOLS400_RPGUNIT_SPOOLFILEVIEWER_NL_DE);

        // Does not work for Eclipse 3.2
        // BundleContext tContext =
        // FrameworkUtil.getBundle(ISphereBasePlugin.class).getBundleContext();
        // String tName;
        // for (Bundle tBundle : tContext.getBundles()) {
        // tName = tBundle.getSymbolicName();
        // if (null != tName && tName.toLowerCase().startsWith("de.taskforce"))
        // {
        // tObsoleteBundles.add(tBundle);
        // }
        // }

        return tObsoleteBundles;
    }

    private void checkAndAddObsoleteBundle(List<Bundle> anObsoleteBundles, String aBundleID) {
        Bundle bundle = Platform.getBundle(aBundleID);
        if (bundle != null) {
            anObsoleteBundles.add(bundle);
        }
    }

}
