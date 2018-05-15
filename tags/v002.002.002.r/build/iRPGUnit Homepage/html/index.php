<html>
    <head>
        <meta http-equiv="cache-control" content="no-cache">
        <meta name="description" content="iRPGUnit Plug-in Homepage">
        <meta name="author" content="iRPGUnit Project Team">
        <meta name="keywords" content="iRPGUnit, Plugin, RDP, RDI, Eclipse, AS400">
        <link href="assets/stylesheet.css" rel="stylesheet" type="text/css" />
        <title>iRPGUnit Plug-in</title>
    </head>
    <body>
        <?php
            function parseJarManifest($manifestFileContents) {
               $manifest = array();	
               $lines = explode("\n", $manifestFileContents);
               foreach ($lines as $line) {
                  if (preg_match("/^([^:]+):\s*(.+)$/", $line, $m)) {
                     $manifest[$m[1]] = trim($m[2]);
                  }
               }
               return $manifest;
            }
            $notifier_url = str_replace( ' ' , '%20' , '@VERSION_MANIFEST@' );
            $manifestFileContents = file_get_contents( $notifier_url );
            $manifest = parseJarManifest($manifestFileContents);
            $current_version = $manifest['Bundle-Version'];
        ?>

        <table width="100%" border="0">
        <tr><td align="left" >
        <a href="https://sourceforge.net/projects/irpgunit/"><img src="assets/iRPGUnit.png" alt="iRPGUnit - Unit Tests for i" border="0" style="padding-right: 10px;"/></a>
        </td>
        <td align="left" width="100%" >
        <h1>iRPGUnit Plug-in</h1>
        <p>Hi, this is the home of the iRPGUnit plug-in for IBM Rational Developer for i.</p>
        </td>
        <td valign="bottom" align="right" nowrap>
        <b>Version: <?php echo $current_version; ?></b>
        </td>
        </tr>
        </table>

        <h2 class="release">Introduction</h2>
        <div class="section">
        iRPGUnit is an open source plug-in for IBM Rational Developer for i. It enables you to develop and
        execute repeatable unit tests for RPG programs and service programs. The current version is <?php echo $current_version; ?>.
		<p/>
		The iRPGUnit plug-in uses a fork of the <a href="https://sourceforge.net/projects/rpgunit/"  target="_external">RPGUnit</a>
		library, which was started by Lacton back in September 2006. The enhanced library adds an interface that enables RPGUnit to 
		pass test results to the IBM Rational Developer for i. The development of the library as well as the plug-in was started by 
		Mihael Schmidt at <a href="http://www.rpgnextgen.com/" target="_external">RPG Next Gen</a> and is continued by the current 
		developers. 
		<p/>
		iRPGUnit uses test suites to group test cases. A test case is a method that starts with 'test' and that is hosted
		and exported by a RPG module. A test suite is a service program that consists of one or more modules that exports
		test cases. Typically there is a one to one relation between the test suite service program and the module that
		contains the test cases.
		<p/>
		iRPGUnit features are driven from our ideas and needs, but everybody is encouraged to contribute
		suggestions and manpower to improve the power of iRPGUnit.
		<p/>
		<table  border="0">
		<tr><td valign="top">
			<table border="0" style="border-spacing: 0px 0px; ">
			<tr><td valign="top"><h2>The iRPGUnit Project Team</h2></td></tr>
			<tr><td nowrap><a target="_owner" href="http://www.tools400.de/"><img class="noborder" src="./assets/tools400.png" ></a><br>Tools/400, Thomas Raddatz</td></tr>
	        </table>
	        </td>
	    </tr>
        </table>
		</div>
        <p/>

        <h2 class="release">Features</h2>
        <div class="section">
        Click to enlarge:
        <table class="nomargin">
        <tr>
            <td><a href="./assets/irpgunit_screenshot_1.png"><img class="noborder" src="./assets/irpgunit_screenshot_1_preview.png"></a><br>Execute a test suite</td>
            <td><a href="./assets/irpgunit_screenshot_2.png"><img class="noborder" src="./assets/irpgunit_screenshot_2_preview.png"></a><br>Result of an execute test suite</td>
            <td><a href="./assets/irpgunit_screenshot_3.png"><img class="noborder" src="./assets/irpgunit_screenshot_3_preview.png"></a><br>The failed assertion</td>
        </tr>
        </table>
        <ul>
            <li>Groups test cases in a test suite.</li>
            <li>Executes a test suite or one or more selected test cases.</li>
            <li>Optionally creates a test report.</li>
            <li>Opens the source member with the failing assertion.</li>
        </ul>
        </div>
        <p/>

        <h2 class="release">Installation</h2>
        <div class="section">
        The easiest way to install the iRPGUnit plug-in is using Eclipse Marketplace. Search for <a href="https://marketplace.eclipse.org/content/irpgunit"><i>iRPGUnit</i></a>:
        <p/>
        <table class="nomargin">
        <tr><td><img class="noborder" src="./assets/eclipse_marketplace.png"></td><td><a href="https://marketplace.eclipse.org/">Eclipse Marketplace</a></td></tr>
        </table>
        <p/>
        But you can also use the official update site at SourceForge:
        <p/>
        <table class="nomargin">
        <tr><td><img class="noborder" src="./assets/updatesite.png"></td><td><a href="http://irpgunit.sourceforge.io/eclipse/rdi8.0/">IBM Rational Developer for i - RDi 8.0+</a></td></tr>
        </table>
        Last but not least you can download the local update site as a zip file and install iRPGUnit from there:
        <p/>
        <table class="nomargin">
        <tr><td><img class="noborder" src="./assets/zip_file.png"></td><td><a href="https://sourceforge.net/projects/irpgunit/files/?source=navbar/">SourceForge Files</a></td></tr>
        </table>
        <p/>
        </div>

        <h2 class="release">Help</h2>
        <div class="section">
        <table>
        <tr><td>Visit the iRPGUnit <a target="_help" href="https://irpgunit.sourceforge.io/help/">help</a> page.</td></tr>
        <tr><td>Ask your questions at the <a target="_wdsci-l" href="http://lists.midrange.com/mailman/listinfo/wdsci-l">WDSCI-L</a> mailing list at <a target="_wdsci-l" href="http://www.midrange.com">midrange.com</a>.</td></tr>
        <tr><td>For bug reports open a ticket at the <a href="https://sourceforge.net/p/irpgunit/tickets/">iRPGUnit bug tracker.</a></td></tr>
        </table>
        </div>
        <p/>
		
		<h2 class="release">Trademarks</h2>
        <div class="section">
		The following terms are trademarks of the IBM Corporation in the United States or other countries or both:
		<ul>
		<li>IBM Rational Developer for Power Systems Software 8.0+</li>
		<li>IBM Rational Developer for i 9.1+</li>
		</ul>
		</div>
        <p/>
		
        <br>
        <hr>
        <table border="0" class="copyright">
        <tr><td class="copyright" align="left" width="50%">Version: <?php echo $current_version; ?> - Copyright: @TODAY_YEAR@, iRPGUnit project team</td><td class="copyright" align="right" width="50%">Updated: @TODAY@</td></tr>
        </table>
        <br>
    </body>
</html>