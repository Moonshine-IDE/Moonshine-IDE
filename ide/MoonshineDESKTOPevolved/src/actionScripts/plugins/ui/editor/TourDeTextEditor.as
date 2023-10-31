////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ui.editor
{
	import flash.events.Event;

	import mx.containers.VDividedBox;
	import mx.controls.SWFLoader;
	import mx.events.DividerEvent;

	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.BasicTextEditor;

	import components.containers.TourDeHTMLLinkDisplay;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.events.TextEditorChangeEvent;

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
			editor = new TextEditor("", true);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 50;
			editorWrapper.percentWidth = 100;
			editorWrapper.bottom = 0;
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
		}
		
		override protected function createChildren():void
		{
			if (!isWebsiteLink)
			{
				swfLoader = new SWFLoader();
				swfLoader.trustContent = false;
				swfLoader.scaleContent = false;
				swfLoader.percentHeight = 45;
				swfLoader.percentWidth = 100;
			}
			else
			{
				htmlLinkDisplay = new TourDeHTMLLinkDisplay;
				htmlLinkDisplay.htmlSource = swfSource;
				htmlLinkDisplay.percentHeight = 30; 
				htmlLinkDisplay.percentWidth = 100;
			}
			
			var vDivider: VDividedBox = new VDividedBox();
			vDivider.percentWidth = vDivider.percentHeight = 100;
			vDivider.setStyle('dividerThickness', 2);
			vDivider.setStyle('dividerAffordance', 2);
			vDivider.setStyle('verticalGap', 12);
			vDivider.setStyle('dividerBarColor', 0x444444);
			vDivider.setStyle('backgroundColor', 0x444444);
			addElement(vDivider);
			
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
			
			vDivider.addElement(editorWrapper);
			
			super.createChildren();
		}
		
		private function onDividerRelease(event:DividerEvent):void
		{
			if (event.delta == 0 || isNaN(event.delta)) return;
			var positiveDelta:Number = event.delta > 0 ? event.delta : -event.delta;
			var newHeight:Number = (event.delta < 0) ?
					swfLoader.height - positiveDelta :
					swfLoader.height + positiveDelta;

			Object(swfLoader.content).setActualSize(swfLoader.width, newHeight);
		}
		
		private function onContentLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onContentLoaded);
			Object(swfLoader.content).setActualSize(swfLoader.width, swfLoader.height);
		}
	}
}