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
package actionScripts.utils
{
	public class MethodDescriptor
	{
		public var origin:*;
		public var method:String;
		public var parameters:Array;
		
		public function MethodDescriptor(origin:*, method:String, ...param)
		{
			super();

			this.origin = origin;
			this.method = method;
			this.parameters = param;
		}
		
		public function callMethod():void
		{
			origin[method].apply(null, parameters);
		}
		
		public function callConstructorWithParameters():Object
		{
			try
			{
				var paramLength:int = parameters ? parameters.length : 0;
				switch (paramLength) {
					case 0:return new origin();
					case 1:return new origin(parameters[0]);
					case 2:return new origin(parameters[0], parameters[1]);
					case 3:return new origin(parameters[0], parameters[1], parameters[2]);
					case 4:return new origin(parameters[0], parameters[1], parameters[2], parameters[3]);
					case 5:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]);
					case 6:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]);
					case 7:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6]);
					case 8:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7]);
					case 9:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8]);
					case 10:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9]);
					default: throw new Error("Too many parameters to generate new class.");
				}
			}
			catch (e:Error)
			{
				throw new Error("Throws error while creating class with unknown Constructors.");
			}
			
			return null;
		}
	}
}