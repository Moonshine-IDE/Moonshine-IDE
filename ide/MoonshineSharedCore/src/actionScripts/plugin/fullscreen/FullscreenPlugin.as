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
package actionScripts.plugin.fullscreen
{
	import flash.display.IBitmapDrawable;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	import mx.graphics.ImageSnapshot;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.fullscreen.events.FullscreenEvent;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class FullscreenPlugin extends PluginBase 
	{
		public static const EVENT_FULLSCREEN:String = "fullscreenEvent";
		
		override public function get name():String			{ return "Fullscreen Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Show edit in fullscreen."; }
		
		private var isSectionInFullscreen:Boolean;
		private var isSectionFullscreenInProcess:Boolean;
		private var sideBarWidth:Number;
		private var currentSectionFullscreenType:String;
			
		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_FULLSCREEN, handleToggleFullscreen);
			dispatcher.addEventListener(FullscreenEvent.EVENT_SECTION_FULLSCREEN, handleToggleSectionFullscreen);
		}
		
		protected function handleToggleFullscreen(event:Event):void
		{
			var stage:Object = FlexGlobals.topLevelApplication.stage;
			if( stage.displayState == StageDisplayState.NORMAL ) 
			{
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} 
			else 
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		protected function handleToggleSectionFullscreen(event:FullscreenEvent):void
		{
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			
			(editors as UIComponent).mouseChildren = false;
			(editors as UIComponent).mouseEnabled = false;
			(console as UIComponent).mouseChildren = false;
			(console as UIComponent).mouseEnabled = false;
			
			currentSectionFullscreenType = event.value;
			this.model.mainView.mainContent.addEventListener(Event.ENTER_FRAME, onComponentPositionChange);
			
			if (isSectionInFullscreen) 
			{
				this.toggle(event);
				return;
			}
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_EDITOR:
					// minimize sidebar
					this.sideBarWidth = this.model.mainView.sidebar.width;
					model.mainView.sidebar.includeInLayout = model.mainView.sidebar.visible = false;
					model.mainView.callLater(function():void
					{
						editors.percentHeight = 100;
						console["minHeight"] = 0;
						console.height = 0;
						
						// requisite updates in projectpanelplugin
						dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.HIDE_PROJECT_PANEL, null));
					});
					break;
				case FullscreenEvent.SECTION_BOTTOM:
					// minimize sidebar
					this.sideBarWidth = this.model.mainView.sidebar.width;
					model.mainView.sidebar.includeInLayout = model.mainView.sidebar.visible = false;
					editors.includeInLayout = editors.visible = false;
					
					// minimize editors and maximize console
					console.percentHeight = 100;
					break;
				case FullscreenEvent.SECTION_LEFT:
					break;
			}
		}
		
		private function onComponentPositionChange(event:Event):void
		{
			switch (currentSectionFullscreenType)
			{
				case FullscreenEvent.SECTION_EDITOR:
					if (!isSectionInFullscreen && this.model.mainView.mainContent.x == 0) 
					{
						endProcess();
						isSectionInFullscreen = true;
					}
					else if (isSectionInFullscreen && this.model.mainView.mainContent.x > 0)
					{
						endProcess();
						isSectionInFullscreen = false;
					}
					break;
				case FullscreenEvent.SECTION_BOTTOM:
					if (!isSectionInFullscreen && this.model.mainView.bodyPanel.getElementAt(1).y == 0) 
					{
						endProcess();
						isSectionInFullscreen = true;						
					}
					else if (isSectionInFullscreen && this.model.mainView.bodyPanel.getElementAt(1).y > 0) 
					{
						endProcess();
						isSectionInFullscreen = false;
					}
					break;
			}
			
			function endProcess():void
			{
				setTimeout(function():void
				{
					var editors:IVisualElement = model.mainView.bodyPanel.getElementAt(0);
					var console:IVisualElement = model.mainView.bodyPanel.getElementAt(1);
					
					model.mainView.mainContent.removeEventListener(Event.ENTER_FRAME, onComponentPositionChange);
					(editors as UIComponent).mouseChildren = true;
					(editors as UIComponent).mouseEnabled = true;
					(console as UIComponent).mouseChildren = true;
					(console as UIComponent).mouseEnabled = true;
					isSectionFullscreenInProcess = false;
				}, 300);
			}
		}
		
		protected function toggle(event:FullscreenEvent):void
		{	
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			
			model.mainView.sidebar.includeInLayout = model.mainView.sidebar.visible = true;
			editors.includeInLayout = editors.visible = true;
			
			// requisite changes in projectpanelplugin
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SHOW_PROJECT_PANEL, null));
			// maximise sidebar per last stored size
			this.model.mainView.sidebar.width = this.sideBarWidth;
		}
	}	
}