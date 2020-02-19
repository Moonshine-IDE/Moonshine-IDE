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
	import mx.core.UIComponent;
	import feathers.core.FeathersControl;

	[DefaultProperty("feathersUIControl")]
	public class FeathersUIWrapper extends UIComponent
	{
		public function FeathersUIWrapper(feathersUIControl:FeathersControl = null)
		{
			super();
			this.feathersUIControl = feathersUIControl;
		}

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
				this.removeChild(this._feathersUIControl);
			}
			this._feathersUIControl = value;
			if(this._feathersUIControl)
			{
				this.addChild(this._feathersUIControl);
			}
			this.invalidateSize();
			this.invalidateDisplayList();
		}

		override protected function measure():void
		{
			if(this._feathersUIControl)
			{
				if(isNaN(this.explicitWidth))
				{
					this._feathersUIControl.resetWidth();
				}
				else
				{
					this._feathersUIControl.width = this.explicitWidth;
				}
				if(isNaN(this.explicitHeight))
				{
					this._feathersUIControl.resetHeight();
				}
				else
				{
					this._feathersUIControl.height = this.explicitHeight;
				}
				if(isNaN(this.explicitMinWidth))
				{
					this._feathersUIControl.resetMinWidth();
				}
				else
				{
					this._feathersUIControl.minWidth = this.explicitMinWidth;
				}
				if(isNaN(this.explicitMinHeight))
				{
					this._feathersUIControl.resetMinHeight();
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
			}
			else
			{
				this.measuredWidth = 0;
				this.measuredHeight = 0;
				this.measuredMinWidth = 0;
				this.measuredMinHeight = 0;
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if(this._feathersUIControl)
			{
				this._feathersUIControl.x = 0;
				this._feathersUIControl.y = 0;
				this._feathersUIControl.width = unscaledWidth;
				this._feathersUIControl.height = unscaledHeight;
				this._feathersUIControl.validateNow();
			}
		}
	}
}