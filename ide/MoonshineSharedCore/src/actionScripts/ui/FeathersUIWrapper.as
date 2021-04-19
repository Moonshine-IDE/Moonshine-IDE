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
package actionScripts.ui
{
	import feathers.core.DefaultToolTipManager;
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.IFocusContainer;
	import feathers.core.IFocusManager;
	import feathers.core.IFocusObject;
	import feathers.core.PopUpManager;
	import feathers.layout.Measurements;

	import flash.Lib;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;

	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.IFocusManagerComplexComponent;
	import mx.managers.IFocusManagerContainer;

	[DefaultProperty("feathersUIControl")]
	public class FeathersUIWrapper extends UIComponent implements IFocusManagerContainer, IFocusManagerComplexComponent
	{
		public function FeathersUIWrapper(feathersUIControl:FeathersControl = null)
		{
			super();
			this.feathersUIControl = feathersUIControl;
			this.addEventListener(Event.ADDED_TO_STAGE, feathersUIWrapper_addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, feathersUIWrapper_removedFromStageHandler);
			this.addEventListener(FocusEvent.FOCUS_IN, feathersUIWrapper_focusInHandler);
			this.addEventListener(FocusEvent.FOCUS_OUT, feathersUIWrapper_focusOutHandler);
		}

		private var _feathersUIFocusManager:IFocusManager;
		private var _feathersUIToolTipManager:DefaultToolTipManager;
		private var _popUpRoot:Sprite;

		public function get defaultButton():IFlexDisplayObject
		{
			return null;
		}

		public function set defaultButton(value:IFlexDisplayObject):void
		{
		}

		public function get hasFocusableContent():Boolean
		{
			if(this._feathersUIControl)
			{
				return this.targetHasFocusabledContent(this._feathersUIControl);
			}
			return false;
		}

		private function targetHasFocusabledContent(target:DisplayObject):Boolean
		{
			if(target is IFocusObject && IFocusObject(target).get_focusEnabled())
			{
				return true;
			}
			if(target is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = DisplayObjectContainer(target);
				if(container is IFocusContainer)
				{
					if(!IFocusContainer(container).get_childFocusEnabled())
					{
						return false;
					}
				}
				var childCount:int = container.numChildren;
				for(var i:int = 0; i < childCount; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					var childHasFocusableContent:Boolean = this.targetHasFocusabledContent(child);
					if(childHasFocusableContent)
					{
						return true;
					}
				}
			}
			return false;
		}

		public function assignFocus(direction:String):void
		{
			if(!this._feathersUIFocusManager)
			{
				return;
			}
			this._feathersUIFocusManager.enabled = true;
			if(this._feathersUIFocusManager.focus == null) {
				var nextFocus:IFocusObject = this._feathersUIFocusManager.findNextFocus(direction == "bottom");
				this._feathersUIFocusManager.focus = nextFocus;
			}
		}

		private var _feathersUIControlMeasurements:Measurements = new Measurements();

		private var _feathersUIControl:FeathersControl;

		public function get feathersUIControl():FeathersControl
		{
			return this._feathersUIControl;
		}

		public function set feathersUIControl(value:FeathersControl):void
		{
			if(this._feathersUIControl == value)
			{
				return;
			}
			if(this._feathersUIControl)
			{
				this._feathersUIControl.removeEventListener(Event.RESIZE, feathersUIControl_resizeHandler);
				this.removeChild(this._feathersUIControl);
			}
			this._feathersUIControl = value;
			if(this._feathersUIControl)
			{
				this._feathersUIControl.initializeNow();
				this._feathersUIControlMeasurements.save(this._feathersUIControl);
				this.addChild(this._feathersUIControl);
				this._feathersUIControl.addEventListener(Event.RESIZE, feathersUIControl_resizeHandler);
			}
			this.invalidateSize();
			this.invalidateDisplayList();
		}

		override protected function measure():void
		{
			if(this._feathersUIControl)
			{
				var oldIgnoreResize:Boolean = this._ignoreResize;
				this._ignoreResize = true;

				if(isNaN(this.explicitWidth))
				{
					if(this._feathersUIControlMeasurements.width == null)
					{
						this._feathersUIControl.resetWidth();
					}
					else
					{
						this._feathersUIControl.width = this._feathersUIControlMeasurements.width as Number;
					}
				}
				else
				{
					this._feathersUIControl.width = this.explicitWidth;
				}
				if(isNaN(this.explicitHeight))
				{
					if(this._feathersUIControlMeasurements.height == null)
					{
						this._feathersUIControl.resetHeight();
					}
					else
					{
						this._feathersUIControl.height = this._feathersUIControlMeasurements.height as Number;
					}
				}
				else
				{
					this._feathersUIControl.height = this.explicitHeight;
				}
				if(isNaN(this.explicitMinWidth))
				{
					if(this._feathersUIControlMeasurements.minWidth == null)
					{
						this._feathersUIControl.resetMinWidth();
					}
					else
					{
						this._feathersUIControl.minWidth = this._feathersUIControlMeasurements.minWidth as Number;
					}
				}
				else
				{
					this._feathersUIControl.minWidth = this.explicitMinWidth;
				}
				if(isNaN(this.explicitMinHeight))
				{
					if(this._feathersUIControlMeasurements.minHeight == null)
					{
						this._feathersUIControl.resetMinHeight();
					}
					else
					{
						this._feathersUIControl.minHeight = this._feathersUIControlMeasurements.minHeight as Number;
					}
				}
				else
				{
					this._feathersUIControl.minHeight = this.explicitMinHeight;
				}
				this._feathersUIControl.validateNow();
				this.measuredWidth = this._feathersUIControl.width;
				this.measuredHeight = this._feathersUIControl.height;
				this.measuredMinWidth = this._feathersUIControl.minWidth;
				this.measuredMinHeight = this._feathersUIControl.minHeight;

				this._ignoreResize = oldIgnoreResize;
			}
			else
			{
				this.measuredWidth = 0;
				this.measuredHeight = 0;
				this.measuredMinWidth = 0;
				this.measuredMinHeight = 0;
			}
		}

		private var _ignoreResize:Boolean = false;

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if(this._feathersUIControl)
			{
				var oldIgnoreResize:Boolean = this._ignoreResize;
				this._ignoreResize = true;

				this._feathersUIControl.x = 0;
				this._feathersUIControl.y = 0;
				this._feathersUIControl.validateNow();
				if(this._feathersUIControl.width != unscaledWidth)
				{
					this._feathersUIControl.width = unscaledWidth;
				}
				if(this._feathersUIControl.height != unscaledHeight)
				{
					this._feathersUIControl.height = unscaledHeight;
				}
				this._feathersUIControl.validateNow();

				this._ignoreResize = oldIgnoreResize;
			}
		}

		protected function feathersUIControl_resizeHandler(event:Event):void
		{
			if(this._ignoreResize)
			{
				return;
			}
			this._feathersUIControlMeasurements.width = this._feathersUIControl.explicitWidth;
			this._feathersUIControlMeasurements.height = this._feathersUIControl.explicitHeight;
			this._feathersUIControlMeasurements.minWidth = this._feathersUIControl.explicitMinWidth;
			this._feathersUIControlMeasurements.minHeight = this._feathersUIControl.explicitMinHeight;
			this._feathersUIControlMeasurements.maxWidth = this._feathersUIControl.explicitMaxWidth;
			this._feathersUIControlMeasurements.maxHeight = this._feathersUIControl.explicitMaxHeight;
			this.invalidateSize();
			this.invalidateDisplayList();
		}

		protected function feathersUIWrapper_addedToStageHandler(event:Event):void
		{
			if(Lib.current == null)
			{
				//when using OpenFL components in AS3, this variable may not
				//have been initialized. Actuate needs it, though.
				Lib.current = this.root as MovieClip;
			}
			if(!this._feathersUIControl)
			{
				return;
			}

			if(this._popUpRoot == null) {
				this._popUpRoot = new Sprite();
				DisplayObjectContainer(this.systemManager).addChild(this._popUpRoot);
				PopUpManager.forStage(this.stage).root = this._popUpRoot;
			}
			
			this._feathersUIFocusManager = FocusManager.addRoot(this._feathersUIControl);
			this._feathersUIFocusManager.enabled = false;
			this._feathersUIToolTipManager = new DefaultToolTipManager(this._feathersUIControl);
		}

		protected function feathersUIWrapper_removedFromStageHandler(event:Event):void
		{
			if(this._feathersUIToolTipManager)
			{
				this._feathersUIToolTipManager.dispose();
				this._feathersUIToolTipManager = null;
			}
			if(this._feathersUIFocusManager)
			{
				FocusManager.removeRoot(this._feathersUIControl);
				this._feathersUIFocusManager = null;
			}
		}

		protected function feathersUIWrapper_focusInHandler(event:FocusEvent):void
		{
			if(event.target != this) {
				return;
			}
			this.assignFocus("top");
		}

		protected function feathersUIWrapper_focusOutHandler(event:FocusEvent):void
		{
			if(this.stage != null && this.stage.focus != null && this.contains(this.stage.focus)) {
				return;
			}
			this._feathersUIFocusManager.focus = null;
			this._feathersUIFocusManager.enabled = false;
		}
	}
}