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
	import flash.display.BitmapData;
	import no.doomsday.console.core.bitmap.BresenhamSharedData;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	
	public final class Bresenham 
	{
		private static const XY:BresenhamSharedData = new BresenhamSharedData();
		public static function line_pixel(p1:Point, p2:Point, target:BitmapData, color:uint = 0x000000):void {
			XY.update(p1, p2);
			var y:int = XY.y0;
			target.lock();
			target.setPixel(p1.x, p1.y, color);
			for (var x:int = XY.x0; x < XY.x1; x++) 
			{	
				if (XY.steep) {
					target.setPixel(y, x, color);
				}else {
					target.setPixel(x, y, color);
				}
				XY.error = XY.error - XY.deltay;
				if (XY.error < 0) {
					y += XY.ystep;
					XY.error += XY.deltax;
				}
			}
			target.setPixel(p2.x, p2.y, color);
			target.unlock();
		}
		public static function line_pixel32(p1:Point, p2:Point, target:BitmapData, color:uint = 0xFF000000):void {
			XY.update(p1, p2);
			var y:int = XY.y0;
			target.lock();
			target.setPixel32(p1.x, p1.y, color);
			for (var x:int = XY.x0; x < XY.x1; x++) 
			{	
				if (XY.steep) {
					target.setPixel32(y, x, color);
				}else {
					target.setPixel32(x, y, color);
				}
				XY.error = XY.error - XY.deltay;
				if (XY.error < 0) {
					y += XY.ystep;
					XY.error += XY.deltax;
				}
			}
			target.setPixel32(p2.x, p2.y, color);
			target.unlock();
		}
		public static function line_stamp(p1:Point, p2:Point, target:BitmapData, stampSource:BitmapData, centerStamp:Boolean = true):void {
			if (centerStamp) {
				var offsetX:int = 0;
				var offsetY:int = 0;
				offsetX = stampSource.width * .5;
				offsetY = stampSource.height * .5;
				p1.offset(-offsetX, -offsetY);
				p2.offset(-offsetX, -offsetY);
			}
			XY.update(p1, p2);
			var y:int = XY.y0;
			var targetPoint:Point = new Point();
			var targetPointInv:Point = new Point();
			target.lock();
			target.copyPixels(stampSource, stampSource.rect, p1, null, null, true);
			for (var x:int = XY.x0; x < XY.x1; x++) 
			{
				targetPoint.x = x;
				targetPoint.y = y;
				targetPointInv.x = y;
				targetPointInv.y = x;
				if (XY.steep) {
					target.copyPixels(stampSource, stampSource.rect, targetPointInv, null, null, true);
				}else {
					target.copyPixels(stampSource, stampSource.rect, targetPoint, null, null, true);
				}
				XY.error = XY.error - XY.deltay;
				if (XY.error < 0) {
					y += XY.ystep;
					XY.error += XY.deltax;
				}
			}
			target.copyPixels(stampSource, stampSource.rect, p2, null, null, true);
			target.unlock();
		}
		public static function circle(p:Point, radius:int,target:BitmapData,color:uint = 0x000000):void {
			var f:int = 1 - radius;
			var ddF_x:int = 1;
			var ddF_y:int = -2 * radius;
			var x:int = 0;
			var y:int = radius;
			var x0:int = p.x;
			var y0:int = p.y;
		 
			target.lock();
			target.setPixel(x0, y0 + radius, color);
			target.setPixel(x0, y0 - radius, color);
			target.setPixel(x0 + radius, y0, color);
			target.setPixel(x0 - radius, y0, color);
		 
			while(x < y){
			  if(f >= 0) 
			  {
				y--;
				ddF_y += 2;
				f += ddF_y;
			  }
			  x++;
			  ddF_x += 2;
			  f += ddF_x;    
			  target.setPixel(x0 + x, y0 + y, color);
			  target.setPixel(x0 - x, y0 + y, color);
			  target.setPixel(x0 + x, y0 - y, color);
			  target.setPixel(x0 - x, y0 - y, color);
			  target.setPixel(x0 + y, y0 + x, color);
			  target.setPixel(x0 - y, y0 + x, color);
			  target.setPixel(x0 + y, y0 - x, color);
			  target.setPixel(x0 - y, y0 - x, color);
			}
			target.unlock();
		}
		public static function circle32(p:Point, radius:int,target:BitmapData,color:uint = 0xFF000000):void {
			var f:int = 1 - radius;
			var ddF_x:int = 1;
			var ddF_y:int = -2 * radius;
			var x:int = 0;
			var y:int = radius;
			var x0:int = p.x;
			var y0:int = p.y;
		 
			target.lock();
			target.setPixel32(x0, y0 + radius, color);
			target.setPixel32(x0, y0 - radius, color);
			target.setPixel32(x0 + radius, y0, color);
			target.setPixel32(x0 - radius, y0, color);
		 
			while(x < y){
			  if(f >= 0) 
			  {
				y--;
				ddF_y += 2;
				f += ddF_y;
			  }
			  x++;
			  ddF_x += 2;
			  f += ddF_x;    
			  target.setPixel32(x0 + x, y0 + y, color);
			  target.setPixel32(x0 - x, y0 + y, color);
			  target.setPixel32(x0 + x, y0 - y, color);
			  target.setPixel32(x0 - x, y0 - y, color);
			  target.setPixel32(x0 + y, y0 + x, color);
			  target.setPixel32(x0 - y, y0 + x, color);
			  target.setPixel32(x0 + y, y0 - x, color);
			  target.setPixel32(x0 - y, y0 - x, color);
			}
			target.unlock();
		}
	}
}
