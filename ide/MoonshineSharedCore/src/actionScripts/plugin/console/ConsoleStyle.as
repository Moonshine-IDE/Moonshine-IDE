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
package actionScripts.plugin.console
{
	public class ConsoleStyle
	{
		// Styles guaranteed to be present for Console history.
		// Use ConsoleTextLineModel to create these.
		public static const NOTICE:uint 	= 10;
		public static const WARNING:uint	= 11;
		public static const ERROR:uint 		= 12;
		public static const WEAK:uint 		= 13;
		public static const SUCCESS:uint	= 14;
		
		// No touching, please.
		internal static var name2style:Object = {};
		
		init();
		private static function init():void
		{
			name2style['notice'] 	= NOTICE;
			name2style['warning'] 	= WARNING;
			name2style['error']		= ERROR;
			name2style['weak'] 		= WEAK;
			name2style['success']	= SUCCESS;
		}
		
		
	}
}