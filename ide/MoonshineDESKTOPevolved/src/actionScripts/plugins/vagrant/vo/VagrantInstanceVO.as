////////////////////////////////////////////////////////////////////////////////
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
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

		private var _state:String;
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
