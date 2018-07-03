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
	public class WorkerNativeProcessResult
	{
		public static const OUTPUT_TYPE_ERROR:String = "typeError";
		public static const OUTPUT_TYPE_DATA:String = "typeData";
		public static const OUTPUT_TYPE_CLOSE:String = "typeProcessClose";
		
		public var output:String;
		public var type:String;
		public var queue:Object;
		
		public function WorkerNativeProcessResult(type:String, output:String, queue:Object=null /** type of NativeProcessQueueVO **/)
		{
			this.type = type;
			this.output = output;
			this.queue = queue;
		}
	}
}