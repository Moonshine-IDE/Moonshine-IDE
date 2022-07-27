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
package actionScripts.plugin.genericproj.vo
{
	import actionScripts.utils.SerializeUtil;

	public class GenericProjectBuildOptions
	{
		public var antBuildPath:String;

		public function GenericProjectBuildOptions()
		{
		}

		public function parse(build:XMLList):void
		{
			parseOptions(build.option);
		}

		public function toXML():XML
		{
			var build:XML = <build/>;

			var pairs:Object = {
				antBuildPath: SerializeUtil.serializeString(antBuildPath)
			}

			build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));
			return build;
		}

		protected function parseOptions(options:XMLList):void
		{
			antBuildPath = SerializeUtil.deserializeString(options.@antBuildPath);
		}
	}
}
