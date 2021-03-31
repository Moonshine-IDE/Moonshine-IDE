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
package actionScripts.plugin.locations
{
	import actionScripts.events.LocationsEvent;
	import actionScripts.plugin.PluginBase;
	import moonshine.plugin.locations.view.LocationsView;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Location;

	import flash.events.Event;

	import mx.core.UIComponent;
	import flash.display.DisplayObject;
	import mx.managers.PopUpManager;
	import actionScripts.events.OpenLocationEvent;
	import feathers.data.ArrayCollection;
	import actionScripts.ui.FeathersUIWrapper;
	import mx.controls.Alert;

	public class LocationsPlugin extends PluginBase
	{
		public function LocationsPlugin()
		{
			locationsView = new LocationsView()
			locationsView.addEventListener(Event.CLOSE, locationsView_closeHandler);
			locationsViewWrapper = new FeathersUIWrapper(locationsView);
		}

		override public function get name():String { return "Go to Locations Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays a list of locations that may be opened in the workspace."; }

		private var locationsViewWrapper:FeathersUIWrapper;
		private var locationsView:LocationsView;
		private var isLocationsViewVisible:Boolean;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(LocationsEvent.EVENT_SHOW_LOCATIONS, handleShowLocations);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(LocationsEvent.EVENT_SHOW_LOCATIONS, handleShowLocations);
		}

		private function handleShowLocations(event:LocationsEvent):void
		{
			var collection:ArrayCollection = locationsView.locations;
			collection.removeAll();
			var locations:Vector.<Location> = event.locations;
			var itemCount:int = locations.length;

			if(itemCount == 0)
			{
				Alert.show("No locations found", ConstantsCoreVO.MOONSHINE_IDE_LABEL);
				return;
			}
			else if(itemCount == 1)
			{
				//only one location means that we jump straight there
				dispatcher.dispatchEvent(new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, locations[0]));
				return;
			}

			for(var i:int = 0; i < itemCount; i++)
			{
				var location:Location = locations[i];
				collection.add(location);
			}
			collection.filterFunction = null;
			collection.refresh();

			if (!isLocationsViewVisible)
			{
				var parentApp:Object = UIComponent(model.activeEditor).parentApplication;
				PopUpManager.addPopUp(locationsViewWrapper, DisplayObject(parentApp), true);
				PopUpManager.centerPopUp(locationsViewWrapper);
				locationsViewWrapper.assignFocus("top");
				locationsViewWrapper.stage.addEventListener(Event.RESIZE, locationsView_stage_resizeHandler, false, 0, true);

				isLocationsViewVisible = true;

				locationsView.addEventListener(Event.REMOVED_FROM_STAGE, onLocationsViewRemovedFromStage);
			}
		}

		private function onLocationsViewRemovedFromStage(event:Event):void
		{
			locationsView.locations.removeAll();
			isLocationsViewVisible = false;
			locationsView.removeEventListener(Event.REMOVED_FROM_STAGE, onLocationsViewRemovedFromStage);
		}

		private function locationsView_closeHandler(event:Event):void
		{
			var selectedLocation:Location = this.locationsView.selectedLocation;
			if(selectedLocation)
			{
				dispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, selectedLocation));
			}
			locationsViewWrapper.stage.removeEventListener(Event.RESIZE, locationsView_stage_resizeHandler);
			PopUpManager.removePopUp(locationsViewWrapper);
		}

		protected function locationsView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(locationsViewWrapper);
		}
	}
}
