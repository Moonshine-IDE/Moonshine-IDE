////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	/**
	 * Implementation of RenameFile interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#file-resource-changes
	 */
	public class RenameFile
	{
		public static const KIND:String = "rename";

		/**
		 * The kind of file operation.
		 */
		public const kind:String = KIND;
		
		/**
		 * The old (existing) location.
		 */
		public var oldUri:String;
		
		/**
		 * The new location.
		 */
		public var newUri:String;

		public function RenameFile(oldUri:String = null, newUri:String = null)
		{
			this.oldUri = oldUri;
			this.newUri = newUri;
		}

		public static function parse(original:Object):RenameFile
		{
			var vo:RenameFile = new RenameFile();
			vo.oldUri = original.oldUri;
			vo.newUri = original.newUri;
			return vo;
		}
	}
}