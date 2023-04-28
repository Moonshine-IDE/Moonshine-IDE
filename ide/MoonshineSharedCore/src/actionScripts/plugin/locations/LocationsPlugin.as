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
package actionScripts.plugin.locations
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	import actionScripts.events.LocationsEvent;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.ArrayCollection;

	import moonshine.plugin.locations.view.LocationsView;

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
			var locations:Array = event.locations;
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
				var location:Object = locations[i];
				collection.add(location);
			}
			collection.filterFunction = null;
			collection.refresh();

			if (!isLocationsViewVisible)
			{
				PopUpManager.addPopUp(locationsViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
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
			var selectedLocation:Object = this.locationsView.selectedLocation;
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
