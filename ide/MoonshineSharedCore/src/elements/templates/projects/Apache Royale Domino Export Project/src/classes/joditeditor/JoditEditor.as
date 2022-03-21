package classes.joditeditor
{
	import org.apache.royale.core.UIBase;

	COMPILE::JS {
		import org.apache.royale.events.Event;
		import org.apache.royale.html.elements.Textarea;
			}
	
	COMPILE::JS
	public class JoditEditor extends org.apache.royale.core.UIBase
	{
		private var _joditId:String;
		private var textArea:Textarea;
		private var myEditor:Object;
	
		private var animateFrameReqId:Number;

		public function JoditEditor()
		{
			super();
			
			addEventListener("beadsAdded", onJoditEditorInitComplete);
		}
		
		private var _buttons:String;
		
		public function set buttons(value:String):void
		{
			_buttons = value;	
		}		
		
		private var _toolbarVisible:Boolean = true;
		
		public function set toolbarVisible(value:Boolean):void
		{
			this._toolbarVisible = value;
		}
		
		public function get data():String
		{
			if (!myEditor)
			{
				return "";
			}
			return myEditor.value;
		}

		public function set data(value:String):void
		{
			if (!myEditor)
			{
				return;
			}
			if (!value)
			{
				value = "";
			}			
			
			myEditor.value = value;
		}
		
		override public function addedToParent():void 
		{ 
			this.textArea = new Textarea();			
			_joditId = Math.random().toString(36).substr(2, 9);
                                    
            textArea.id = _joditId;
            textArea.name = _joditId;
            			
			this.addElement(textArea);
			
			super.addedToParent(); 
		} 
			
		private function onJoditEditorInitComplete(event:Event):void
		{
			this.removeEventListener("beadsAdded", onJoditEditorInitComplete);
	
			COMPILE::JS
			{
				animateFrameReqId = requestAnimationFrame(function():void {
					var config:Object = { 
						toolbar: _toolbarVisible
					};		
					
					if (_buttons)
					{
						config.buttons = _buttons;
					}		
								
					myEditor = new window["Jodit"](textArea.element, config);
					cancelAnimationFrame(animateFrameReqId);
				});				
			}
		}
	}
}
