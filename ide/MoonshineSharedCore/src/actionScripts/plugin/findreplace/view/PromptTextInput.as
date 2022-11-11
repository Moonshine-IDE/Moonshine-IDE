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
package actionScripts.plugin.findreplace.view
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import spark.components.RichText;
	import spark.components.TextInput;
	
	/*
		Original skin by Andy Mcintosh
		http://github.com/andymcintosh/SparkComponents/
	*/
	
	public class PromptTextInput extends TextInput
	{	
		[SkinPart(required="true")]
		public var promptView:RichText;
		public var marginRight:int = 4;
		
		private var _prompt:String;
		
		private var promptChanged:Boolean;
		
		[Bindable]
		override public function get prompt():String
		{
			return _prompt;
		}

		override public function set prompt(v:String):void
		{
			_prompt = v;	
			promptChanged = true;
			
			invalidateProperties();
		}
		
		[Bindable]
		override public function set text(val:String):void
		{
			super.text = val;
			
			updatePromptVisiblity();
		}
		override public function get text():String
		{
			return super.text;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (promptChanged)
			{
				if (promptView)
				{
					promptView.text = prompt;	
				}
				
				promptChanged = false;
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (partName == 'textDisplay')
			{
				instance.addEventListener(FocusEvent.FOCUS_IN, updatePromptVisiblity);
				instance.addEventListener(FocusEvent.FOCUS_OUT, updatePromptVisiblity);
				instance.addEventListener(Event.CHANGE, updatePromptVisiblity);
				instance.styleName = "uiTextWhite";
				instance.right = marginRight;
			}
			
			if (instance == promptView)
			{	
				promptView.text = prompt;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (partName == 'textDisplay')
			{
				instance.removeEventListener(FocusEvent.FOCUS_IN, updatePromptVisiblity);
				instance.removeEventListener(FocusEvent.FOCUS_OUT, updatePromptVisiblity);
				instance.removeEventListener(Event.CHANGE, updatePromptVisiblity);
			}
		}
		
		private function updatePromptVisiblity(event:Event=null):void
		{
			if (!promptView) return;
			
			if (text != "")
			{
				promptView.visible = false;
			} 
			else 
			{
				promptView.visible = true;
			}
		}
	
	}
}