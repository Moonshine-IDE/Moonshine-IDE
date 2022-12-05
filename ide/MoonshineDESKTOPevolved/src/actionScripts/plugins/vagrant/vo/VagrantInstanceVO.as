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
package actionScripts.plugins.vagrant.vo
{
	[Bindable]
	public class VagrantInstanceVO
	{
		public function VagrantInstanceVO()
		{
		}

		private var _state:String = VagrantInstanceState.UNREACHABLE;
		public function get state():String
		{
			return _state;
		}
		public function set state(value:String):void
		{
			_state = value;
		}

		private var _title:String;
		public function get title():String
		{
			return _title;
		}
		public function set title(value:String):void
		{
			_title = value;
		}

		private var _url:String;
		public function get url():String
		{
			return _url;
		}
		public function set url(value:String):void
		{
			_url = value;
		}

		private var _capabilities:Array;
		public function get capabilities():Array
		{
			return _capabilities;
		}
		public function set capabilities(value:Array):void
		{
			_capabilities = value;
		}

		private var _localPath:String;
		public function get localPath():String
		{
			return _localPath;
		}
		public function set localPath(value:String):void
		{
			_localPath = value;
		}

		public static function getNewInstance(value:Object):VagrantInstanceVO
		{
			var tmpInstance:VagrantInstanceVO = new VagrantInstanceVO();
			if ("state" in value) tmpInstance.state = value.state;
			if ("title" in value) tmpInstance.title = value.title;
			if ("url" in value) tmpInstance.url = value.url;
			if ("capabilities" in value) tmpInstance.capabilities = value.capabilities;
			if ("localPath" in value) tmpInstance.localPath = value.localPath;

			return tmpInstance;
		}
	}
}
