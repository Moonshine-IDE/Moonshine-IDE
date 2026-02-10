////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2025. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////

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
	public static final OPEN_PATH_IN_TERMINAL:String = "Open in "+ (ConstantsCoreVO.IS_WINDOWS ? "Command Line" : "Terminal");
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