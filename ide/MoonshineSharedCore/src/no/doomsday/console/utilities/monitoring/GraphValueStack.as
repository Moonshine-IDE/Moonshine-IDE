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
package no.doomsday.console.utilities.monitoring
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class GraphValueStack
	{
		public var storeHistory:Boolean = false;
		public var allValues:Vector.<Number> = new Vector.<Number>;
		private var values:GraphValue = new GraphValue();
		private var head:GraphValue = values;
		private var count:int = 0;
		private var _maxValues:int = 0;
		private var _lastValue:Number;
		private var startTime:int;
		public function get totalValues():int { return count; };
		public function GraphValueStack(maxValues:int) 
		{
			_maxValues = maxValues;
		}
		public function add(n:Number):void {
			if (!startTime) {
				startTime = getTimer();
			}
			var v:GraphValue = new GraphValue();
			_lastValue = n;
			v.value = n;
			v.creationTime = getTimer()-startTime;
			if (storeHistory) allValues.push(v.creationTime, n);
			head.next = v;
			head = v;
			count++;
			if (count > _maxValues) {
				values = values.next;
				count--;
			}
		}
		public function clear():void {
			allValues = new Vector.<Number>;
			values.next = null;
			head = values;
			count = 0;
		}
		public function extend():void {
			add(_lastValue);
		}
		public function get average():Number {
			if (count > 0) return sum / count;
			return 0;
		}
		public function get sum():Number {
			var v:GraphValue = values;
			var total:Number = 0;
			while (v.next) {
				v = v.next;
				total += v.value;
			}
			return total;
		}
		public function getValueAt(index:int):GraphValue {
			var v:GraphValue = values;
			var idx:int = 0;
			while (v.next) {
				v = v.next;
				if (idx == index) {
					return v;
				}
				idx++;
			}
			throw new Error("The index " + index + " is out of range");
		}
		
		public function get maxValues():int { return _maxValues; }
		
		public function set maxValues(value:int):void 
		{
			_maxValues = value;
			while (count > _maxValues) {
				values = values.next;
				count--;
			}
		}
		
		public function forEach(func:Function):void {
			var v:GraphValue = values;
			var idx:int = 0;
			while (v.next) {
				v = v.next;
				func(v.value,idx)
				idx++;
			}
		}
		
		public function toString():String {
			var out:String;
			var v:GraphValue = values;
			var total:Number = 0;
			while (v.next) {
				v = v.next;
				if (!out) {
					out = v.value.toString()+"\n";
				}else{
					out += v.value + "\n";
				}
			}
			if (!out) out = "";
			return out;
		}
		
		public function get lastValue():Number { return _lastValue; }
		
	}

}