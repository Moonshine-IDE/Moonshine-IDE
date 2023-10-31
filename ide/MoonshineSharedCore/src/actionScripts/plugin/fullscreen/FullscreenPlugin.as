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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.fullscreen.events.FullscreenEvent;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
	
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
			if (this.isSectionFullscreenInProcess) 
				return;
				
			if (isSectionInFullscreen) 
			{
				this.toggle(event);
				return;
			}
			
			var editors:IVisualElement = this.model.mainView.bodyPanel.getElementAt(0);
			var console:IVisualElement = this.model.mainView.bodyPanel.getElementAt(1);
			isSectionInFullscreen = true;
			this.isSectionFullscreenInProcess = true;
			trace("handleTolggle recall");
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_EDITOR:
					editors.addEventListener(Event.RENDER, onEditorsRenderEvent);
					// minimize sidebar
					this.sideBarWidth = this.model.mainView.sidebar.width;
					this.model.mainView.sidebar.width = 0;
					
					// maximise editors and minimize console
					editors.percentHeight = 100;
					console["minHeight"] = 0;
					console.height = 0;
					
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
		
		private var sectionProcessTimer:Timer;
		private function onEditorsRenderEvent(event:Event):void
		{
			if (sectionProcessTimer)
			{
				trace("sectionTimerStopped");
				sectionProcessTimer.stop();
				sectionProcessTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onSectionProcessTimerCompletes);
			}
			
			trace("sectionTimerReleased");
			sectionProcessTimer = new Timer(2000, 1);
			sectionProcessTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSectionProcessTimerCompletes);
			sectionProcessTimer.start();
		}
		
		private function onSectionProcessTimerCompletes(event:TimerEvent):void
		{
			sectionProcessTimer.stop();
			sectionProcessTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onSectionProcessTimerCompletes);
			this.isSectionFullscreenInProcess = false;
			trace("STOPPED");
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