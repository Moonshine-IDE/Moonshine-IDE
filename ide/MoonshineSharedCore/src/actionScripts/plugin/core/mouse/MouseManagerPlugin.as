////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.core.mouse
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.IContentWindowReloadable;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import moonshine.editor.text.TextEditor;
	import actionScripts.ui.FeathersUIWrapper;

	public class MouseManagerPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Mouse Manager Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Mouse Manager Plugin."; }
		
		private var lastKnownEditor:TextEditor;
		private var isApplicationDeactivated:Boolean;
		
		override public function activate():void
		{
			super.activate();
			
			// we need to watch all the focus change event to
			// track and keep one cursor at a time
			FlexGlobals.topLevelApplication.systemManager.addEventListener(FocusEvent.FOCUS_IN, onCursorUpdated);
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			
			// removeElement from FlexGlobals.topLevelApplication do not return focus to TextEditor
			FlexGlobals.topLevelApplication.addEventListener(FlexEvent.UPDATE_COMPLETE, onTopLevelUpdated);
		}
		
		private function onTopLevelUpdated(event:FlexEvent):void
		{
			if (isApplicationDeactivated) return;
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, true);
		}
		
		private function onCursorUpdated(event:FocusEvent):void
		{
			// this should handle any non-input type of component focus
			if (!(event.target is TextEditor) && !event.target.hasOwnProperty("text") && !event.target.hasOwnProperty("selectable"))
			{
				return;
			}
			
			if (lastKnownEditor && lastKnownEditor != event.target) 
			{
				setFocusToTextEditor(lastKnownEditor, false);
			}
			
			// we mainly need to manage TextEditor focus
			// since this only differ with general focus cursor
			if (event.target is TextEditor)
			{
				setFocusToTextEditor(event.target as TextEditor, true);
				lastKnownEditor = event.target as TextEditor;
			}
			else
			{
				lastKnownEditor = null;
			}
		}
		
		private function onApplicationLostFocus(event:Event):void
		{
			FlexGlobals.topLevelApplication.stage.removeEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.ACTIVATE, onApplicationReturnFocus);
			isApplicationDeactivated = true;
			
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, false);
		}
		
		private function onApplicationReturnFocus(event:Event):void
		{
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			FlexGlobals.topLevelApplication.stage.removeEventListener(Event.ACTIVATE, onApplicationReturnFocus);
			isApplicationDeactivated = false;
			
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, true);
			if (model.activeEditor && (model.activeEditor is IContentWindowReloadable))
			{
				(model.activeEditor as IContentWindowReloadable).checkFileIfChanged();
			}
		}
		
		private function setFocusToTextEditor(editor:TextEditor, value:Boolean):void
		{
			if (value) {
				FeathersUIWrapper(editor.parent).setFocus();
			}
		}
	}
}