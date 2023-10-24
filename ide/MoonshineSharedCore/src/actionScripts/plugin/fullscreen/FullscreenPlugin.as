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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.DividerEvent;
	
	import spark.components.Group;
	
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
		private var currentSectionInFullscreenType:String;
		private var sideBarWidth:Number;
		
		private var editorsHeight:Number;
		private var editorsPercentHeight:Number;
		private var consoleHeight:Number;
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
			if (isSectionInFullscreen) 
			{
				this.toggle(event);
				return;
			}
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_EDITOR:
					this.sideBarWidth = this.model.mainView.sidebar.width;
					this.model.mainView.sidebar.width = 0;
					this.model.mainView.bodyPanel.getElementAt(1)["minHeight"] = 0;
					dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.HIDE_PROJECT_PANEL, null));
					
					this.model.mainView.bodyPanel.getElementAt(0).percentHeight = 100;
					//this.model.mainView.bodyPanel.getElementAt(0).height = editorsHeight;
					//this.model.mainView.bodyPanel.getElementAt(1).percentHeight = consolePercentHeight;
					this.model.mainView.bodyPanel.getElementAt(1).height = 0;
					break;
				case FullscreenEvent.SECTION_BOTTOM:
					editorsHeight = this.model.mainView.bodyPanel.getElementAt(0).height;
					editorsPercentHeight = this.model.mainView.bodyPanel.getElementAt(0).percentHeight;
					consoleHeight = this.model.mainView.bodyPanel.getElementAt(1).height;
					consolePercentHeight = this.model.mainView.bodyPanel.getElementAt(1).percentHeight;
					
					this.sideBarWidth = this.model.mainView.sidebar.width;
					this.model.mainView.sidebar.width = 0;
					this.model.mainView.bodyPanel.getElementAt(0).height = 0;
					this.model.mainView.bodyPanel.getElementAt(1).percentHeight = 100;
					
					this.model.mainView.bodyPanel.setStyle('dividerSkin', null);
					this.model.mainView.bodyPanel.setStyle('dividerAlpha', 0);
					this.model.mainView.bodyPanel.setStyle('dividerThickness', 0);
					this.model.mainView.bodyPanel.setStyle('dividerAffordance', 0);
					this.model.mainView.bodyPanel.setStyle('verticalGap', 0);
					break;
				case FullscreenEvent.SECTION_LEFT:
					break;
			}
			
			isSectionInFullscreen = true;
			
			/*if (sectionParentIndex != -1) 
			{
				toggle(event);
				return;	
			}
			
			var fullscreenContainer:Group = this.model.mainView.parent as Group;
			sectionParent = event.value.parent as DisplayObjectContainer;
			for (var i:int; i < sectionParent.numChildren; i++)
			{
				if (sectionParent.getChildAt(i) == event.value)
				{
					sectionParentIndex = i;
					break;
				}
			}
			
			sectionParentProperties = new Object();
			sectionParentProperties.x = event.value.x;
			sectionParentProperties.y = event.value.y;
			sectionParentProperties.width = event.value.width;
			sectionParentProperties.height = event.value.height;
			sectionParentProperties.percentWidth = event.value["percentWidth"];
			sectionParentProperties.percentHeight = event.value["percentHeight"];
			
			event.value.x = 0;
			event.value.y = ConstantsCoreVO.IS_MACOS ? 0 : 21;
			event.value["percentWidth"] = event.value["percentHeight"] = 100;
			
			try
			{
				sectionParent.removeChild(event.value);
			}
			catch (e:Error)
			{
				(sectionParent as IVisualElementContainer).removeElement(event.value as IVisualElement);
			}
			
			fullscreenContainer.addElement(event.value as IVisualElement);*/
			
		}
		
		protected function toggle(event:FullscreenEvent):void
		{	
			/*var fullscreenContainer:Group = this.model.mainView.parent as Group;
			fullscreenContainer.removeElement(event.value as IVisualElement);
			
			for (var i:String in sectionParentProperties)
			{
				event.value[i] = sectionParentProperties[i];
			}
			
			sectionParent.addChildAt(event.value, sectionParentIndex);
			sectionParentIndex = -1;*/
			
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_BOTTOM:
					this.model.mainView.bodyPanel.getElementAt(0).percentHeight = editorsPercentHeight;
					this.model.mainView.bodyPanel.getElementAt(0).height = editorsHeight;
					this.model.mainView.bodyPanel.getElementAt(1).percentHeight = consolePercentHeight;
					this.model.mainView.bodyPanel.getElementAt(1).height = consoleHeight;
					
					
					this.model.mainView.bodyPanel.setStyle('dividerThickness', 7);
					this.model.mainView.bodyPanel.setStyle('dividerAffordance', 4);
					this.model.mainView.bodyPanel.setStyle('verticalGap', 7);
					this.model.mainView.bodyPanel.setStyle('dividerAlpha', 1);
					
					break;
				case FullscreenEvent.SECTION_EDITOR:
					
					break;
				case FullscreenEvent.SECTION_LEFT:
					break;
			}
			
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SHOW_PROJECT_PANEL, null));
			this.model.mainView.sidebar.width = this.sideBarWidth;
			
			isSectionInFullscreen = false;
		}
	}	
}