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
package no.doomsday.utilities.monitoring 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import no.doomsday.console.core.bitmap.Bresenham;
	import no.doomsday.console.core.gui.Window;
	import no.doomsday.console.core.text.TextFormats;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class StatGraph extends Sprite
	{
		private const valueHistory:Vector.<Number> = new Vector.<Number>();
		public var maxValues:int = 60;
		private const values:GraphValueStack = new GraphValueStack(maxValues);
		private const dims:Rectangle = new Rectangle(0, 0, 300, 100);
		private var graphBitmap:BitmapData = new BitmapData(dims.width, dims.height);
		private var tagBitmap:BitmapData = new BitmapData(dims.width, dims.height);
		private var renderStart:Point = new Point();
		private var renderEnd:Point = new Point();
		private var max:Number = 0;
		private var min:Number = 0;
		private var median:Number = dims.height>>1;
		private var graphDisplay:Bitmap = new Bitmap(graphBitmap);
		private var tagDisplay:Bitmap = new Bitmap(tagBitmap);
		private var maxTF:TextField;
		private var midTF:TextField;
		private var minTF:TextField;
		private var queryTF:TextField;
		private var prevQuery:GraphValue;
		private var prevQueryIndex:int;
		private var dirty:Boolean = true;
		private var paused:Boolean;
		private var content:Sprite = new Sprite();
		private var _disposed:Boolean = false;
		private var switchMode:Boolean;
		private var acceptDuplicateValues:Boolean;
		private var _bg:uint = 0x00000000;
		private var _graphColor:uint = 0xFFAAAAAA;
		private var _barColor:uint = 0x88000000;
		public function get disposed():Boolean {
			return _disposed;
		}
		public function StatGraph(booleanMode:Boolean = false,acceptDuplicateValues:Boolean = false,storeHistory:Boolean = true) 
		{
			values.storeHistory = storeHistory;
			content.addChild(tagDisplay);
			content.addChild(graphDisplay);
			
			this.switchMode = booleanMode;
			this.acceptDuplicateValues = acceptDuplicateValues;
			
			maxTF = new TextField();
			midTF = new TextField();
			minTF = new TextField();
			queryTF = new TextField();
			content.addChild(maxTF);
			content.addChild(midTF);
			content.addChild(minTF);
			content.addChild(queryTF);
			var tf:TextFormat = new TextFormat("_sans", 9, 0);
			maxTF.defaultTextFormat = midTF.defaultTextFormat = minTF.defaultTextFormat = queryTF.defaultTextFormat = tf;
			maxTF.mouseEnabled = midTF.mouseEnabled = minTF.mouseEnabled = queryTF.mouseEnabled = false;
			maxTF.autoSize = midTF.autoSize = minTF.autoSize = queryTF.autoSize = TextFieldAutoSize.LEFT;
			queryTF.background = true;	
			queryTF.border = true;
			queryTF.visible = false;
			
			maxTF.x = dims.width;
			minTF.x = dims.width;
			minTF.y = dims.height-13;
			midTF.x = dims.width;
			midTF.y = median - 8;
			content.addEventListener(MouseEvent.MOUSE_DOWN, startSampling);
			content.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			content.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			content.doubleClickEnabled = true;
			
			var menu:ContextMenu = new ContextMenu();
			var item:ContextMenuItem = new ContextMenuItem("Clear");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onDoubleClick);
			menu.customItems.push(item);
			
			if(storeHistory){
				item = new ContextMenuItem("Save xml");
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveXML, false, 0, true);
				menu.customItems.push(item);
			}
			content.contextMenu = menu;
			addChild(content);
			
		}
		public function set current(b:Boolean):void {
			visible = b;
			paused = !b;
			//maxTF.visible = minTF.visible = midTF.visible = b;
			if (b) parent.setChildIndex(this, parent.numChildren - 1);
		}
		public function get current():Boolean {
			return visible;
		}
		private function initialize():void {
			graphBitmap.dispose();
			tagBitmap.dispose();
			median = dims.height >> 1;
			graphBitmap = new BitmapData(dims.width - 50, dims.height);
			tagBitmap = new BitmapData(dims.width - 50, dims.height);
			tagDisplay.bitmapData = tagBitmap;
			graphDisplay.bitmapData = graphBitmap;
			
			maxTF.x = dims.width-50;
			minTF.x = dims.width-50;
			midTF.x = dims.width-50;
			minTF.y = dims.height-13;
			midTF.y = median - 8;
			
			//content.removeChild(tagDisplay);
			//content.removeChild(graphDisplay);
			//graphDisplay = new Bitmap(graphBitmap);
			//tagDisplay = new Bitmap(tagBitmap);
			//content.addChild(tagDisplay);
			//content.addChild(graphDisplay);
			render();
		}
		public function resize(dims:Rectangle):void {
			this.dims.height = dims.height;
			this.dims.width = dims.width;
			initialize();
		}
		public function set graphColor(color:uint):void {
			_graphColor = color;
		}
		public function set barColor(color:uint):void {
			_barColor = color;
		}
		
		private function saveXML(e:ContextMenuEvent):void 
		{
			var xml:XML = getXML();
			new FileReference().save(xml, "Graph.xml");
		}
		public function getXML():XML 
		{
			var out:XML = <graph/>;
			for (var i:int = 0; i < values.allValues.length; i+=2) 
			{
				var node:XML = <event>{values.allValues[i]}</event>;
				node.@time = values.allValues[i + 1];
				out.appendChild(node);
			}
			return out;
		}
		public function kill(e:Event = null):void 
		{
			_disposed = true;
			content.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			content.removeEventListener(MouseEvent.MOUSE_DOWN, startSampling);
			content.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			content.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopSampling);
			graphBitmap.dispose();
			tagBitmap.dispose();
			parent.removeChild(this);
		}
		
		private function onDoubleClick(e:Event):void 
		{
			values.clear();
			min = max = 0;
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			maxValues += e.delta;
			maxValues = Math.max(4, maxValues);
			values.maxValues = maxValues;
			min = max = 0;
			values.forEach(checkMinMax);
		}
		
		private function checkMinMax(value:Number,index:int):void
		{
			if (value < min) min = value;
			if (value > max) max = value;
		}
		private function startSampling(e:Event):void {
			onMouseMove();
			paused = true;
			queryTF.visible = true;
			content.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopSampling);
		}
		private function stopSampling(e:Event):void {
			paused = false;
			queryTF.visible = false;
			content.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopSampling);
		}
		
		private function onMouseMove(e:MouseEvent = null):void 
		{
			try{
				getValueAt(mouseX);
			}catch (e:Error) {
				
			}
		}
		public function add(newValue:Number):Number {
			if (paused || _disposed) return newValue;
			if (switchMode) {
				newValue = toSwitch(newValue);
			}
			if (newValue == values.lastValue&&!acceptDuplicateValues) {
				return newValue;
			}
			
			if (newValue < min) min = newValue;
			if (newValue > max) max = newValue;
			dirty = true;
			values.add(newValue);
			if (visible) render();
			return newValue;
		}
		private function toSwitch(value:Number):int {
			return (value > 0) ? 1 : 0;
		}
		private function render():void
		{	
			if (!dirty) return;
			if(switchMode){
				maxTF.text = "1";
				minTF.text = "0";
				midTF.text = "AVG:" + String(Math.round(values.average));
			}else {
				maxTF.text = String(max.toPrecision(2));
				minTF.text = String(min.toPrecision(2));
				midTF.text = "AVG:" + String(values.average.toPrecision(2));
			}
			
			graphBitmap.lock();
			tagBitmap.lock();
			
			graphBitmap.fillRect(dims, _bg);
			tagBitmap.fillRect(dims, _bg);
			
			renderStart.x = renderStart.y = 0;
			values.forEach(drawLines);
			
			graphBitmap.unlock();
			tagBitmap.unlock();
		}
		
		private function drawLines(value:Number,index:int):void
		{
			var x:int = index / (values.totalValues-1) * (dims.width-50);
			var mul:Number = (value-min) / (max - min);
			var y:int = (1-mul) * (dims.height-1);
			if (index == 0) {
				renderStart.x = 0;
				renderStart.y = y;
			}else {
				renderEnd.x = x;
				renderEnd.y = y
				Bresenham.line_pixel32(renderStart, renderEnd, graphBitmap, _graphColor);
				renderStart.y = median;
				renderStart.x = x;
				//Bresenham.line_pixel32(renderStart, renderEnd, tagBitmap, _barColor);
				renderStart.y = y;
			}
		}
		public function getValueAt(x:int):Number {
			x = Math.min(x, dims.width-50);
			var idx:int = x / (dims.width-50) * (values.totalValues - 1);
			prevQueryIndex = idx;
			prevQuery = values.getValueAt(idx);
			var mul:Number = (prevQuery.value-min) / (max - min);
			var y:int = (1-mul) * (dims.height-25);
			//queryTF.y = median;
			queryTF.y = y;
			queryTF.x = idx / (values.totalValues-1) * (dims.width-50);
			queryTF.text = (prevQuery.creationTime/1000)+"\n"+prevQuery.value.toString();
			return prevQuery.value;
		}
		
	}

}