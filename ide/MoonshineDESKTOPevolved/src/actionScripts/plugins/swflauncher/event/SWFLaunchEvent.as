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
package actionScripts.plugins.swflauncher.event
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.valueObjects.ProjectVO;

	public class SWFLaunchEvent extends Event
	{
		public static const EVENT_LAUNCH_SWF:String = "launchSwfEvent";
		public static const EVENT_UNLAUNCH_SWF:String = "unLaunchSwfEvent";
		
		public var file:File;
		public var project:ProjectVO;
		public var sdk:File;
		public var url:String;
		
		public function SWFLaunchEvent(type:String, file:File, project:ProjectVO=null, sdk:File=null)
		{
			this.file = file;
			this.project = project; 
			this.sdk = sdk;
			
			super(type, false, true);
		}
		
	}
}