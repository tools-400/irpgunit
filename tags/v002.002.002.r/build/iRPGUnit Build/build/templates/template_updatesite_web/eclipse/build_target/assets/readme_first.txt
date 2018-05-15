
RPGUnit Installation
====================


Step 1: Installation of RPGUnit on the i5
-----------------------------------------

First you need to transfer save file RPGUnit_v* to your i5 and restore 
library RPGUNIT. Then compile and execute program A_INSTALL to create the 
required objects.

If you encounter problems with the save file, perhaps a problem with the 
release level, you may consider to upload the source members.


Option 1: Upload source members
-------------------------------

Execute the following batch script to upload the RPGUnit source members 
to library RPGUNIT:

  upload_src.bat HOST USER PASSWORD


Option 2.a: Upload save file
----------------------------

Execute the following batch script to upload the RPGUnit save file 
to library RPGUNIT:

  upload_savf.bat HOST USER PASSWORD

  
Option 2.b: Upload save file by hand
------------------------------------

Please create an empty save file on your i5 before sending the file from 
your PC: 

  Create save file:
    CRTSAVF FILE(QGPL/RPGUNIT)

Now use FTP to transfer the save file to your i5: 

  Open a DOS box:
    XP, Win7: Start -> Execute -> cmd.exe

  Start an FTP session to your i5:
    FTP your.i5.com

  Transfer save file:
    binary
    put RPGUnit_v* QGPL/RPGUNIT
  
  Terminate FTP session:
    quite

Now logon to your i5 and restore library RPGUNIT from the save file and 
add the library to your library list: 

  RSTLIB SAVLIB(RPGUNIT) DEV(*SAVF) SAVF(QGPL/RPGUNIT)
  ADDLIBLE RPGUNIT

Compile and execute install program A_INSTALL to create the RPGUnit 
objects: 

  CRTBNDCL PGM(RPGUNIT/A_INSTALL) SRCFILE(RPGUNIT/RPGUNIT1) SRCMBR(*PGM)
  CALL PGM(RPGUNIT/A_INSTALL) PARM('RPGUNIT')

Finished. 


Step 2: Installation of the RPGUnit plugin
------------------------------------------

Option 1: Using the update site
-------------------------------

The URL of the RPGUnit plugin site is: 

  https://irpgunit.sourceforge.io/eclipse/rdi8.0/

Option 2: Using the 'dropins' folder
------------------------------------

Go to the 'dropins' folder of your Rational Developer for Power (RDP) 
installation. Usually that is: 

  c:\Program Files\IBM\SDP\dropins\ 

Copy folder 'RPGUnit Plugin' from the zip file to the 'dropins' folder 
on your PC. Now the structure of your 'dropins' should look like that: 

  c:\Program Files\IBM\SDP\dropins\
   +-- RPGUnit Plugin
        +-- eclipse
             +-- plugins
                  +-- de.tools400.rpgunit.core.help_*.jar
                      de.tools400.rpgunit.core_*.jar
                      de.tools400.rpgunit.isphere_*.jar
                      de.tools400.rpgunit.spooledfileviewer_*.jar
             +-- features
                  +-- de.tools400.rpgunit.core.help_*.jar
                      de.tools400.rpgunit.core_*.jar
                      de.tools400.rpgunit.isphere_*.jar
                      de.tools400.rpgunit.spooledfileviewer_*.jar</span>

Instead of copying the jar to the 'dropins' folder, you may also use a 
folder of your choice and link to it. For that you need to add a plain 
text file 'de.tools400.rdp.rpgunit.link' with the following content to 
the 'dropins' folder: 

  path=DRIVE:/path/to/folder/RPGUnit Plugin/

Please make sure to use a slash (/) instand of a back slash (\) and do 
not forget the last back slash behind 'RPGUnit Plugin'. Given that you 
created the 'RPGUnit Plugin' folder in 'My Documents', the the folder 
structure should look like this: 

  C:/Users/Joe/My Documents/
   +-- RPGUnit Plugin
        +-- eclipse
             +-- plugins
                  +-- de.tools400.rpgunit.core.help_*.jar
                      de.tools400.rpgunit.core_*.jar
                      de.tools400.rpgunit.isphere_*.jar
                      de.tools400.rpgunit.spooledfileviewer_*.jar
             +-- features
                  +-- de.tools400.rpgunit.core.help_*.jar
                      de.tools400.rpgunit.core_*.jar
                      de.tools400.rpgunit.isphere_*.jar
                      de.tools400.rpgunit.spooledfileviewer_*.jar

Finished. Please restart RPD to use the plugin.
