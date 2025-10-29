package components.views.project;

import actionScripts.valueObjects.ConstantsCoreVO;

class ProjectTreeContextMenuItem {
	public static final OPEN:String = "Open";
	public static final OPEN_WITH:String = "Open With";
	public static final VAGRANT_GROUP:String = "Vagrant";
	public static final CONFIGURE_VAGRANT:String = "Configure Vagrant";
	public static final CONFIGURE_EXTERNAL_EDITORS:String = "Customize Editors";
	public static final OPEN_FILE_FOLDER:String = "Open File/Folder";
	public static final NEW:String = "New";
	public static final NEW_FOLDER:String = "New Folder";
	public static final COPY_PATH:String = "Copy Path";
	public static final OPEN_PATH_IN_TERMINAL:String = "Open in "+ (ConstantsCoreVO.IS_MACOS ? "Terminal" : "Command Line");
	public static final OPEN_PATH_IN_POWERSHELL:String = "Open in PowerShell";
	public static final SHOW_IN_EXPLORER:String = "Show in Explorer";
	public static final SHOW_IN_FINDER:String = "Show in Finder";
	public static final DUPLICATE_FILE:String = "Duplicate";
	public static final COPY_FILE:String = "Copy";
	public static final PASTE_FILE:String = "Paste";
	public static final MARK_AS_HIDDEN:String = "Mark as Hidden";
	public static final MARK_AS_VISIBLE:String = "Mark as Visible";
	public static final RENAME:String = "Rename";
	public static final SET_AS_DEFAULT_APPLICATION:String = "Set as Default Application";
	public static final DELETE:String = "Delete";
	public static final DELETE_FILE_FOLDER:String = "Delete File/Folder";
	public static final REFRESH:String = "Refresh";
	public static final RUN_ANT_SCRIPT:String = "Run Ant Script";
	public static final SETTINGS:String = "Settings";
	public static final PROJECT_SETUP:String = "Project Setup";
	public static final CLOSE:String = "Close";
	public static final DELETE_PROJECT:String = "Delete Project";
	public static final PREVIEW:String = "Preview";
}