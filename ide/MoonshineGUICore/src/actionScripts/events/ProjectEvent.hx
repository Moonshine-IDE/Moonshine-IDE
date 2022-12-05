////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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

package actionScripts.events;

import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class ProjectEvent extends Event {
	public static final SHOW_PROJECT_VIEW:String = "showProjectViewEvent";

	public static final ADD_PROJECT:String = "addProjectEvent";
	public static final CLOSE_PROJECT:String = "closeProjectEvent";
	public static final OPEN_PROJECT_AWAY3D:String = "openProjectEventAway3D";
	public static final REMOVE_PROJECT:String = "removeProjectEvent";
	public static final SHOW_PREVIOUSLY_OPENED_PROJECTS:String = "showPreviouslyOpenedProjects";
	public static final SCROLL_FROM_SOURCE:String = "scrollFromSource";
	public static final EVENT_SAVE_PROJECT_CREATION_FOLDERS:String = "event-save-project-creation-folders";

	public static final TREE_DATA_UPDATES:String = "TREE_DATA_UPDATES";
	public static final PROJECT_FILES_UPDATES:String = "PROJECT_FILES_UPDATES";

	public static final SAVE_PROJECT_SETTINGS:String = "SAVE_PROJECT_SETTINGS";
	public static final EVENT_IMPORT_FLASHBUILDER_PROJECT:String = "importFBProjectEvent";
	public static final EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG:String = "importProjectDirect";
	public static final SEARCH_PROJECTS_IN_DIRECTORIES:String = "searchForProjectsInDirectories";

	public static final EVENT_IMPORT_PROJECT_ARCHIVE:String = "importProjectArchive";
	public static final EVENT_GENERATE_APACHE_ROYALE_PROJECT:String = "generateApacheRoyaleProject";
	public static final EVENT_EXPORT_TO_EXTERNAL_PROJECT:String = "exportToExternalProject";
	public static final LAST_OPENED_AS_FB_PROJECT:String = "LAST_OPENED_AS_FB_PROJECT";
	public static final LAST_OPENED_AS_FD_PROJECT:String = "LAST_OPENED_AS_FD_PROJECT";

	public static final FLEX_SDK_UDPATED:String = "FLEX_SDK_UDPATED";
	public static final FLEX_SDK_UDPATED_OUTSIDE:String = "FLEX_SDK_UDPATED_OUTSIDE";
	public static final SET_WORKSPACE:String = "SET_WORKSPACE";
	public static final WORKSPACE_UPDATED:String = "WORKSPACE_UPDATED";
	public static final ACCESS_MANAGER:String = "ACCESS_MANAGER";
	public static final ACTIVE_PROJECT_CHANGED:String = "ACTIVE_PROJECT_CHANGED";

	public static final CHECK_GIT_PROJECT:String = "checkGitRepository";
	public static final CHECK_SVN_PROJECT:String = "checkSVNRepository";
	public static final LANGUAGE_SERVER_OPENED:String = "languageServerOpenedAgainstProject";
	public static final LANGUAGE_SERVER_CLOSED:String = "languageServerClosedAgainstProject";
	public static final LANGUAGE_SERVER_REGISTER_CAPABILITY:String = "languageServerRegisterCapabilityAgainstProject";
	public static final LANGUAGE_SERVER_UNREGISTER_CAPABILITY:String = "languageServerRegisterCapabilityAgainstProject";

	public static final OPEN_CUSTOM_COMMANDS_ON_SDK:String = "openCustomCommandsInterfaceForSDKtype";

	public var anObject:Dynamic;
	public var extras:Array<String>;
	public var project:ProjectVO;

	public function new(type:String, project:Dynamic = null, ...args:String) {
		if (Std.isOfType(project, ProjectVO)) {
			this.project = cast(project, ProjectVO);
		} else {
			anObject = project;
		}

		extras = args;
		super(type, false, false);
	}
}