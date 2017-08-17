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
package actionScripts.plugins.ui.editor
{
	import flash.events.Event;
	
	import mx.containers.VDividedBox;
	import mx.controls.SWFLoader;
	import mx.events.DividerEvent;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.TextEditor;
	
	import components.containers.TourDeHTMLLinkDisplay;

	public class TourDeTextEditor extends BasicTextEditor
	{
		protected var swfSource:String;
		protected var swfLoader:SWFLoader;
		
		private var htmlLinkDisplay: TourDeHTMLLinkDisplay;
		private var isWebsiteLink: Boolean;
		
		public function TourDeTextEditor(swfSource:String)
		{
			super();
			setStyle("backgroundColor", 0x444444);
			this.swfSource = swfSource;
			if (swfSource.indexOf(".swf") == -1) isWebsiteLink = true;
		}
		
		public function disposeFootprint():void
		{
			if (file.fileBridge.nativePath.indexOf("ThirdParty") != -1)
			{
				try {
					file.fileBridge.deleteFile();
				} catch (e:Error) {
					file.fileBridge.moveToTrashAsync();
				}
			}
		}
		
		override public function get label():String
		{
			var ch:String = "TDF:";
			if (!file)
				return ch+defaultLabel;
			return ch+file.fileBridge.name;
		}
		
		override protected function initializeChildrens():void
		{
			editor = new TextEditor(true);
			editor.percentHeight = 50;
			editor.percentWidth = 100;
			editor.bottom = 0;
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
			
			text = "";
		}
		
		override protected function createChildren():void
		{
			if (!isWebsiteLink)
			{
				swfLoader = new SWFLoader();
				swfLoader.trustContent = false;
				swfLoader.scaleContent = false;
				swfLoader.percentHeight = 50;
				swfLoader.percentWidth = 100;
			}
			else
			{
				htmlLinkDisplay = new TourDeHTMLLinkDisplay;
				htmlLinkDisplay.htmlSource = swfSource;
				htmlLinkDisplay.percentHeight = 30; 
				htmlLinkDisplay.percentWidth = 100;
			}
			
			super.createChildren();
			
			var vDivider: VDividedBox = new VDividedBox();
			vDivider.percentWidth = vDivider.percentHeight = 100;
			vDivider.setStyle('dividerThickness', 2);
			vDivider.setStyle('dividerAffordance', 2);
			vDivider.setStyle('verticalGap', 12);
			vDivider.setStyle('dividerBarColor', 0x444444);
			vDivider.setStyle('backgroundColor', 0x444444);
			addChild(vDivider);
			
			if (!isWebsiteLink)
			{
				vDivider.addEventListener(DividerEvent.DIVIDER_RELEASE, onDividerRelease, false, 0, true);
				vDivider.addChild(swfLoader);
				if (swfSource) swfLoader.load(swfSource);
				swfLoader.addEventListener(Event.COMPLETE, onContentLoaded, false, 0, true);
			}
			else
			{
				vDivider.addChild(htmlLinkDisplay);
			}
			
			vDivider.addChild(editor);
		}
		
		private function onDividerRelease(event:DividerEvent):void
		{
			if (event.delta == 0 || isNaN(event.delta)) return;
			var newHeight:Number = (event.delta < 0) ? swfLoader.height - Math.abs(event.delta) : swfLoader.height + Math.abs(event.delta);
			Object(swfLoader.content).setActualSize(swfLoader.width, newHeight);
		}
		
		private function onContentLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onContentLoaded);
			Object(swfLoader.content).setActualSize(swfLoader.width, swfLoader.height);
		}
	}
}