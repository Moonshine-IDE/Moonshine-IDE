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
package no.doomsday.console.core.bitmap
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	import flash.geom.Point;
	public final class BresenhamSharedData {
		public var x0:int, x1:int, y0:int, y1:int, deltax:int, deltay:int, error:int, ystep:int;
		public var steep:Boolean;
		private var t1:int, t2:int, temp:int;
		public function update(p1:Point, p2:Point):void {
			t1 = p1.y - p2.y;
			t2 = p1.x - p2.x;
			steep = ((t1 ^ (t1 >> 31)) - (t1 >> 31)) > ((t2 ^ (t2 >> 31)) - (t2 >> 31));
			x0 = p2.x;
			x1 = p1.x;
			y0 = p2.y;
			y1 = p1.y;
			
			if (steep) {
				x0 ^= y0;
				y0 ^= x0;
				x0 ^= y0;
				
				x1 ^= y1;
				y1 ^= x1;
				x1 ^= y1;
			}
			if (x0 > x1) {
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
			}
			deltax = x1 - x0;
			temp = y1 - y0;
			deltay = (temp ^ (temp >> 31)) - (temp >> 31);
			error = deltax * .5;
			(y0 < y1) ? ystep = 1 : ystep = -1;
		}
	}
	
}