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
	
	public class StatusBarEvent extends Event
	{
		public static const PROJECT_BUILD_STARTED:String = "PROJECT_BUILD_STARTED";
		public static const PROJECT_BUILD_ENDED:String = "PROJECT_BUILD_ENDED";
		public static const PROJECT_DEBUG_STARTED:String = "PROJECT_DEBUG_STARTED";
		public static const PROJECT_DEBUG_ENDED:String = "PROJECT_DEBUG_ENDED";
		public static const PROJECT_BUILD_TERMINATE:String = "PROJECT_BUILD_TERMINATE";
		
		public static const LANGUAGE_SERVER_STATUS:String = "LANGUAGE_SERVER_STATUS";
		
		public var projectName:String;
		public var notificationSuffix:String;
		public var isShowStopButton:Boolean;
		
		public function StatusBarEvent(type:String, projectName:String=null, notificationSuffix:String=null, isShowStopButton:Boolean=true)
		{
			this.projectName = projectName;
			this.notificationSuffix = notificationSuffix;
			this.isShowStopButton = isShowStopButton;
			
			super(type, true, false);
		}
	}
}