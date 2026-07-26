/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.junit;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Locale;
import java.util.Properties;
import java.util.Set;

import org.junit.Test;

import junit.framework.JUnit4TestAdapter;

/**
 * <b>JUnit 4 Test Case</b>
 * <p>
 * Verifies that all message constants of the iSphere <i>Messages</i> objects
 * have a corresponding message text entry. Also ensure that there are no dead
 * text entries in the property files.
 * <p>
 * This class uses reflection to get the list of message constants. It
 * instantiates a new dedicated class loader to ensure that the static message
 * constants are properly initialized for each locale.
 * 
 * @author Thomas Raddatz
 */
public class CheckNLSMessages {

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(CheckNLSMessages.class);
    }

    private final String defaultLocale = "en";
    private final String[] locales = new String[] { defaultLocale, "de" };

    /**
     * Verifies the NLS messages of the iRPGUnit project.
     * 
     * @throws Exception
     */
    @Test
    public void testNLSMessages() throws Exception {
        checkMessagesForLocales(de.tools400.rpgunit.core.Messages.class, "messages");
        checkMessagesForLocales(de.tools400.rpgunit.cmone.Messages.class, "messages");
        checkMessagesForLocales(de.tools400.rpgunit.isphere.Messages.class, "messages");
        checkMessagesForLocales(de.tools400.rpgunit.spooledfileviewer.Messages.class, "messages");

        System.out.println("** Finished testing NLS messages **");
    }

    /**
     * Verifies the message constants of a given NLS object and properties
     * bundle for all supported locales.
     * 
     * @param clazz - NLS messages class that is checked
     * @param nlsResource - resource base name
     * @throws Exception
     */
    private void checkMessagesForLocales(Class<?> clazz, String nlsResource) throws Exception {
        System.out.println("Testing class: " + clazz.getName());
        for (String locale : locales) {
            Locale.setDefault(new Locale(locale));
            resetNlsSuffixCache();

            Object nlsMessagesObject = getInstance(clazz);
            String resourcePath = getResourcePath(clazz, nlsResource, locale);
            System.out.println("  Locale (" + locale + "):" + resourcePath);

            Properties properties = getPropertyResourceBundle(nlsMessagesObject, resourcePath);
            checkMessagesForLocale(locale, resourcePath, nlsMessagesObject, properties);
        }
    }

    /**
     * Resets the static suffix cache in org.eclipse.osgi.util.NLS so that the
     * next call to initializeMessages re-evaluates Locale.getDefault(). Without
     * this, NLS keeps the suffixes from when its class was first loaded
     * (typically by RDi at startup with osgi.nl=en).
     */
    private void resetNlsSuffixCache() throws Exception {
        Class<?> nlsClass = Class.forName("org.eclipse.osgi.util.NLS");
        Field nlSuffixes = nlsClass.getDeclaredField("nlSuffixes");
        nlSuffixes.setAccessible(true);
        nlSuffixes.set(null, null);
    }

    /**
     * Verifies the message constants of a given NLS object with a given
     * properties bundle of a specific locale.
     * 
     * @param nlsMessagesObject - NLS messages object
     * @param properties - properties resource bundle
     * @param locale
     * @throws IllegalAccessException
     */
    private void checkMessagesForLocale(String locale, String resourcePath, Object nlsMessagesObject, Properties properties) throws Exception {

        Field[] fields = nlsMessagesObject.getClass().getFields();
        String localeInfo = " (" + locale + ") ";

        for (Field field : fields) {

            if (Modifier.isFinal(field.getModifiers())) {
                continue;
            }

            // Prepare
            String nlsMessageConstant = field.getName();
            String messageText = properties.getProperty(nlsMessageConstant);

            // Check
            System.out.println("Testing: " + nlsMessageConstant);
            assertTrue("ERROR:" + localeInfo + "NLS string must not be NULL or empty: " + nlsMessageConstant,
                messageText != null && messageText.trim().length() > 0);
            assertFalse("ERROR:" + localeInfo + "NLS String must not end with spaces: " + nlsMessageConstant, messageText.endsWith(" "));
            assertNotNull("ERROR:" + localeInfo + "Message text must not be [null]. Missing property: " + nlsMessageConstant + "("
                + nlsMessagesObject.getClass().getName() + ")", messageText);
            assertTrue("ERROR:" + localeInfo + "Length of message must be greater than zero. Property: " + nlsMessageConstant,
                messageText.length() > 0);
            try {
                assertEquals(
                    "ERROR:" + localeInfo + "Duplicate constant: " + nlsMessageConstant
                        + "? Assigned message text must match text in properties file: " + messageText + " vs " + field.get(null),
                    messageText, field.get(null));
            } catch (NullPointerException e) {
                assertTrue("ERROR:" + localeInfo + "'static' modifier missing for: " + field.getName(), false);
            }
            properties.remove(nlsMessageConstant);
        }

        if (properties.size() > 0) {
            System.out.println("\nERROR: Unused literals that needs to be removed from: " + resourcePath);
            Set<Object> keys = properties.keySet();
            for (Object key : keys) {
                System.out.println(key);
            }
        }

        assertEquals("ERROR:" + localeInfo + "Properties must be empty. Otherwise there are more properties than message constants.", 0,
            properties.size());
    }

    /**
     * Uses a fresh classloader to create a new object from a fresh class.
     * 
     * @param aClass - class to load
     * @return object created from <i>aClass</i>
     * @throws Exception
     */
    private Object getInstance(Class<?> aClass) throws Exception {

        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        URL[] urls = getClassLoaderUrls(classLoader);

        // Child-first: loads the target class fresh from urls so that the
        // static
        // NLS initializer re-runs for each locale, while platform dependencies
        // (e.g. org.eclipse.osgi.util.NLS) are resolved via the parent chain.
        URLClassLoader loader = new URLClassLoader(urls, classLoader) {
            @Override
            protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
                synchronized (getClassLoadingLock(name)) {
                    Class<?> c = findLoadedClass(name);
                    if (c == null) {
                        try {
                            c = findClass(name);
                        } catch (ClassNotFoundException e) {
                            c = getParent().loadClass(name);
                        }
                    }
                    if (resolve) {
                        resolveClass(c);
                    }
                    return c;
                }
            }
        };
        Class<?> clazz = loader.loadClass(aClass.getName());

        Constructor<?> constructor = clazz.getDeclaredConstructor(new Class[0]);
        constructor.setAccessible(true);
        Object object = constructor.newInstance(new Object[0]);

        return object;
    }

    /**
     * Gets URLs from classloader, handling both Java 8 (URLClassLoader) and
     * Java 9+ (built-in app classloader).
     */
    private URL[] getClassLoaderUrls(ClassLoader classLoader) {

        if (classLoader instanceof URLClassLoader) {
            // Java 8 and earlier
            return ((URLClassLoader)classLoader).getURLs();
        }

        // Ant non-forked mode: AntClassLoader is not a URLClassLoader but
        // exposes getClasspath()
        try {
            Method getClasspath = classLoader.getClass().getMethod("getClasspath");
            String antClasspath = (String)getClasspath.invoke(classLoader);
            if (antClasspath != null && !antClasspath.isEmpty()) {
                String[] paths = antClasspath.split(System.getProperty("path.separator"));
                URL[] urls = new URL[paths.length];
                for (int i = 0; i < paths.length; i++) {
                    urls[i] = new java.io.File(paths[i]).toURI().toURL();
                }
                return urls;
            }
        } catch (Exception ignored) {
            // Not an AntClassLoader, fall through to java.class.path
        }

        // Java 9+: Use java.class.path system property
        String classPath = System.getProperty("java.class.path");
        String[] paths = classPath.split(System.getProperty("path.separator"));
        URL[] urls = new URL[paths.length];

        for (int i = 0; i < paths.length; i++) {
            try {
                urls[i] = new java.io.File(paths[i]).toURI().toURL();
            } catch (java.net.MalformedURLException e) {
                throw new RuntimeException("Invalid classpath entry: " + paths[i], e);
            }
        }
        return urls;
    }

    /**
     * Produces the NLS resource path.
     * 
     * @param clazz - class used to produce the path
     * @param nlsResource - resource base name
     * @param locale - locale for which the path is produced for
     * @return resource path for the given locale
     */
    private String getResourcePath(Class<?> clazz, String nlsResource, String locale) {
        String resourcePath = "/" + clazz.getPackage().getName().replace('.', '/') + "/";
        resourcePath = resourcePath + nlsResource;
        if (defaultLocale.equalsIgnoreCase(locale)) {
            // do not add locale and use the simple name
        } else {
            resourcePath = resourcePath + "_" + locale;
        }
        resourcePath = resourcePath + ".properties";
        return resourcePath;
    }

    /**
     * Returns the NLS messages of a given NLS messages object and locale
     * specific resource.
     * 
     * @param nlsMessagesObject - NLS messages object whose locale specific
     *        messages are returned
     * @param resourcePath - path to the locale specific messages
     * @return NLS messages
     * @throws IOException
     */
    private Properties getPropertyResourceBundle(Object nlsMessagesObject, String resourcePath) throws IOException {
        Properties properties = new Properties();
        properties.load(nlsMessagesObject.getClass().getResourceAsStream(resourcePath));
        return properties;
    }
}
