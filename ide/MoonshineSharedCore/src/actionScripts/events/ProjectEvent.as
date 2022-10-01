////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.events
{
	import flash.events.Event;
	
	import actionScripts.valueObjects.ProjectVO;
	
	public class ProjectEvent extends Event
	{
		public static const SHOW_PROJECT_VIEW:String = "showProjectViewEvent";
		
		public static const ADD_PROJECT:String = "addProjectEvent";
		public static const CLOSE_PROJECT:String = "closeProjectEvent";
		public static const OPEN_PROJECT_AWAY3D:String = "openProjectEventAway3D";
		public static const REMOVE_PROJECT:String = "removeProjectEvent";
		public static const SHOW_PREVIOUSLY_OPENED_PROJECTS:String = "showPreviouslyOpenedProjects";
		public static const SCROLL_FROM_SOURCE:String = "scrollFromSource";
		public static const EVENT_SAVE_PROJECT_CREATION_FOLDERS:String = "event-save-project-creation-folders";
		
		public static const TREE_DATA_UPDATES: String = "TREE_DATA_UPDATES";
		public static const PROJECT_FILES_UPDATES: String = "PROJECT_FILES_UPDATES";
		
		public static const SAVE_PROJECT_SETTINGS:String = "SAVE_PROJECT_SETTINGS";
		public static const EVENT_IMPORT_FLASHBUILDER_PROJECT:String = "importFBProjectEvent";
		public static const EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG:String = "importProjectDirect";
		public static const SEARCH_PROJECTS_IN_DIRECTORIES:String = "searchForProjectsInDirectories";
		
		public static const EVENT_IMPORT_PROJECT_ARCHIVE:String = "importProjectArchive";
		public static const EVENT_GENERATE_APACHE_ROYALE_PROJECT:String = "generateApacheRoyaleProject";
		public static const LAST_OPENED_AS_FB_PROJECT:String = "LAST_OPENED_AS_FB_PROJECT";
		public static const LAST_OPENED_AS_FD_PROJECT:String = "LAST_OPENED_AS_FD_PROJECT";
		
		public static const FLEX_SDK_UDPATED: String = "FLEX_SDK_UDPATED";
		public static const FLEX_SDK_UDPATED_OUTSIDE: String = "FLEX_SDK_UDPATED_OUTSIDE";
		public static const SET_WORKSPACE: String = "SET_WORKSPACE";
		public static const WORKSPACE_UPDATED: String = "WORKSPACE_UPDATED";
		public static const ACCESS_MANAGER: String = "ACCESS_MANAGER";
		public static const ACTIVE_PROJECT_CHANGED:String = "ACTIVE_PROJECT_CHANGED";
		
		public static const CHECK_GIT_PROJECT:String = "checkGitRepository";
		public static const CHECK_SVN_PROJECT:String = "checkSVNRepository";
		public static const LANGUAGE_SERVER_OPENED:String = "languageServerOpenedAgainstProject";
		public static const LANGUAGE_SERVER_CLOSED:String = "languageServerClosedAgainstProject";
		public static const LANGUAGE_SERVER_REGISTER_CAPABILITY:String = "languageServerRegisterCapabilityAgainstProject";
		public static const LANGUAGE_SERVER_UNREGISTER_CAPABILITY:String = "languageServerRegisterCapabilityAgainstProject";
		
		public static const OPEN_CUSTOM_COMMANDS_ON_SDK:String = "openCustomCommandsInterfaceForSDKtype";
		
		public var project:ProjectVO;
		public var anObject:Object;
		public var extras:Array;
		
		public function ProjectEvent(type:String, project:Object=null, ...args)
		{
			if (project is ProjectVO)
			{
				this.project = project as ProjectVO;
            }
			else
			{
				anObject = project;
            }

			extras = args;
			super(type, false, false);
		}
		
	}
}