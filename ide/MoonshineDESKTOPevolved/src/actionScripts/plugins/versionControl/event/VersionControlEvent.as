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
package actionScripts.plugins.versionControl.event
{
	import flash.events.Event;
	
	public class VersionControlEvent extends Event
	{
		public static const OPEN_MANAGE_REPOSITORIES_GIT:String = "openManageRepositoriesGit";
		public static const OPEN_MANAGE_REPOSITORIES_SVN:String = "openManageRepositoriesSVN";
		public static const CLOSE_MANAGE_REPOSITORIES:String = "closeManageRepositories";
		public static const OPEN_ADD_REPOSITORY:String = "openAddRepositoryView";
		public static const ADD_EDIT_REPOSITORY:String = "addOrEditRepository";
		public static const LOAD_REMOTE_SVN_LIST:String = "loadRemoteSvnList";
		public static const CLONE_CHECKOUT_REQUESTED:String = "cloneCheckoutRequested";
		public static const CLONE_CHECKOUT_COMPLETED:String = "cloneCheckoutCompleted";
		public static const RESTORE_DEFAULT_REPOSITORIES:String = "restoreDefaultRepositories";
		public static const OSX_XCODE_PERMISSION_GIVEN:String = "osxXcodePermissionGiven";
		public static const REPOSITORY_AUTH_CANCELLED:String = "repositoryAuthenticationProcessCancelled";
		
		public var value:Object;
		
		public function VersionControlEvent(type:String, value:Object=null, bubble:Boolean=false, cancelable:Boolean=true)
		{
			this.value = value;
			super(type, bubble, cancelable);
		}
	}
}