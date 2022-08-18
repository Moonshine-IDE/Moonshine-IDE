package classes.joditeditor
{
	import org.apache.royale.core.UIBase;

	COMPILE::JS {
		import org.apache.royale.events.Event;
		import org.apache.royale.html.elements.Textarea;
	}

	[Event(name="textChange", type="org.apache.royale.events.Event")]
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

		private var _options:Object;

		public function set options(value:Object):void
		{
			_options = value;
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

		private var _readonly:Boolean = false;

		public function set readonly(value:Boolean):void
		{
			this._readonly = value;
		}

		private var _data:String = "";
		public function get data():String
		{
			if (myEditor)
			{
				return myEditor.value;	
			}
			
			return _data;
		}

		public function set data(value:String):void
		{
			if (!value)
			{
				value = "";
			}
			_data = value;

			if (!myEditor)
			{
				return;
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
						toolbar: _toolbarVisible,
						readonly: _readonly
					};

					if (_buttons)
					{
						config.buttons = _buttons;
					}

					for (var p:String in _options)
					{
						if (!config[p])
						{
							config[p] = _options[p];
						}
					}
					
					myEditor = new window["Jodit"](textArea.element, config);
					myEditor.value = _data;
					myEditor.events.on("change", function(event:Object):void {
						dispatchEvent(new Event("textChange"));
					});
					
					cancelAnimationFrame(animateFrameReqId);
				});
			}
		}
	}
}
