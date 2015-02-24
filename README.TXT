Tajo Desktop Package Installation 

“Tajo Desktop Package” is stand-alone version of Apache Tajo(TM), packaged by Gruter, Inc. It provides an easy way to set up Tajo DW engine on your Linux and Mac. Enjoy Tajo on your desktop! 


1. Supported OS
    Linux, Mac
     
2. Prerequisites 
    JVM 1.6.0 or higher
    
3. Installation

    3.1. Extract the package file in a directory
 
	$ tar xvfz tajo-x.x.x-desktop-x.x.tar.gz
	$ cd tajo-x.x.x-desktop-x.x
 
    3.2. Configure 
	Set JAVA_HOME, Tajo directories and heap memory size. 

	$ bin/configure.sh
   	
    3.3. Startup
	Start Tajo master and worker(s).

	$ bin/startup.sh

    3.4. Load sample data set (optional)
	The script below will create "tpc_h10m" database and 8 tables. Make sure that Tajo is up and running to run this command.

	$ bin/make-test.sh

    3.5. Run Tajo command-line shell "TSQL"     
    
	$ bin/tsql
	Try \? for help.
	default> 

4. Shutdown
    $ bin/shutdown.sh


For more information on Tajo, refer to Apache Tajo site (http://tajo.apache.org).
