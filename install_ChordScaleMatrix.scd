(
/*Platform.ideName;
Platform.classLibraryDir;
Platform.helpDir;
Platform.systemAppSupportDir;
Platform.systemExtensionDir;
Platform.userHomeDir;
Platform.userAppSupportDir;
Platform.userConfigDir;
Platform.userExtensionDir;
Platform.platformDir;
Platform.pathSeparator;
Platform.resourceDir;
//Platform.recordingsDir;
Platform.defaultTempDir;*/

Platform.userExtensionDir.postln;
Platform.userExtensionDir.openOS;

/*// Complete installation
Quarks.updateDirectory;
// OR
Quarks.checkoutDirectory; // do this if you have never checked out any quarks
Quarks.checkoutAll; // if you have not checked out any quarks

// Selective installation
Quarks.checkoutAll;	// if you have not checked out any quarks*/

Quarks.install("https://github.com/jmuxfeldt/TabbedView2");
Quarks.install("https://github.com/jmuxfeldt/TabbedView2_QT");
Quarks.install("cruciallib");
//Quarks.install("dewdrop_lib");
// OR
Quarks.install("ddwCommon");
Quarks.install("ddwGUIEnhancements");
Quarks.install("ddwMIDI");

Quarks.gui;

MethodOverride.printAll;

//Help.gui;

//Object.browse;
)
