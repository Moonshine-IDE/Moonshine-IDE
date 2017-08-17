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
		
		private var _prompt:String
		
		private var promptChanged:Boolean;
		
		[Bindable]
		override public function get prompt():String
		{
			return _prompt;
		}
		public function set prompt(v:String):void
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