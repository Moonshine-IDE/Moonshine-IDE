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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.graphics.ImageSnapshot;
	
	import spark.components.Image;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.fullscreen.events.FullscreenEvent;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import lime.system.Display;
	
	import org.osmf.events.DisplayObjectEvent;
	
	public class FullscreenPlugin extends PluginBase 
	{
		public static const EVENT_FULLSCREEN:String = "fullscreenEvent";
		
		override public function get name():String			{ return "Fullscreen Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Show edit in fullscreen."; }
		
		private var isSectionInFullscreen:Boolean;
		private var isSectionFullscreenInProcess:Boolean;
		private var currentSectionInFullscreenType:String;
		private var sideBarWidth:Number;
		
		private var editorsLastHeight:Number;
		private var editorsPercentHeight:Number;
		private var consoleLastHeight:Number;
		private var consolePercentHeight:Number;
		private var sectionFullscreenCheckTimer:Timer;
			
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
		
		private var startTime:int;
		private var startTime2:int;
		
		protected function handleToggleSectionFullscreen(event:FullscreenEvent):void
		{
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			
			(editors as UIComponent).mouseChildren = false;
			(editors as UIComponent).mouseEnabled = false;
			(console as UIComponent).mouseChildren = false;
			(console as UIComponent).mouseEnabled = false;
			
			editors.addEventListener(Event.RENDER, onRenderEvent);
			
			if (isSectionInFullscreen) 
			{
				this.toggle(event);
				return;
			}
			
			isSectionInFullscreen = true;
			switch (event.value)
			{
				case FullscreenEvent.SECTION_EDITOR:
					// minimize sidebar
					this.sideBarWidth = this.model.mainView.sidebar.width;
					this.model.mainView.sidebar.width = 0;
					
					// maximise editors and minimize console
					editors.percentHeight = 100;
					console["minHeight"] = 0;
					console.height = 0;
					(editors as UIComponent).invalidateDisplayList();
					
					// requisite updates in projectpanelplugin
					dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.HIDE_PROJECT_PANEL, null));
					break;
				case FullscreenEvent.SECTION_BOTTOM:
					// stores present properties before change
					editorsLastHeight = editors.height;
					editorsPercentHeight = editors.percentHeight;
					consoleLastHeight = console.height;
					consolePercentHeight = console.percentHeight;
					
					// minimize sidebar
					this.sideBarWidth = this.model.mainView.sidebar.width;
					this.model.mainView.sidebar.width = 0;
					
					// minimize editors and maximize console
					editors.height = 0;
					console.percentHeight = 100;
					break;
				case FullscreenEvent.SECTION_LEFT:
					break;
			}
		}
		
		private function onSectionFullscreenTimerTick(event:TimerEvent):void
		{
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			
			(editors as UIComponent).mouseChildren = true;
			(editors as UIComponent).mouseEnabled = true;
			(console as UIComponent).mouseChildren = true;
			(console as UIComponent).mouseEnabled = true;
			
			this.sectionFullscreenCheckTimer.stop();
			this.sectionFullscreenCheckTimer.removeEventListener(TimerEvent.TIMER, onSectionFullscreenTimerTick);
			this.isSectionFullscreenInProcess = false;
		}
		
		private function onRenderEvent(event:Event):void
		{
			if (this.sectionFullscreenCheckTimer && this.sectionFullscreenCheckTimer.running)
			{
				this.sectionFullscreenCheckTimer.stop();
				this.sectionFullscreenCheckTimer.removeEventListener(TimerEvent.TIMER, onSectionFullscreenTimerTick);
			}
			
			this.sectionFullscreenCheckTimer = new Timer(1500, 1);
			this.sectionFullscreenCheckTimer.addEventListener(TimerEvent.TIMER, onSectionFullscreenTimerTick);
			this.sectionFullscreenCheckTimer.start();
		}
		
		protected function toggle(event:FullscreenEvent):void
		{	
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_BOTTOM:
					// assign last known sizes to editors and console
					editors.percentHeight = editorsPercentHeight;
					editors.height = editorsLastHeight;
					console.percentHeight = consolePercentHeight;
					console.height = consoleLastHeight;
					break;
				case FullscreenEvent.SECTION_EDITOR:
					break;
				case FullscreenEvent.SECTION_LEFT:
					break;
			}
			
			// requisite changes in projectpanelplugin
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SHOW_PROJECT_PANEL, null));
			// maximise sidebar per last stored size
			this.model.mainView.sidebar.width = this.sideBarWidth;
			
			isSectionInFullscreen = false;
		}
	}	
}