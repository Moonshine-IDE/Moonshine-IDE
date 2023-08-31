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
package actionScripts.plugins.genesis
{
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.events.GenesisEvent;
	import actionScripts.plugins.genesis.utils.ImportGenesisCatalog;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import components.popup.ImportGenesisPopup;

	import flash.desktop.NativeApplication;

	import flash.display.DisplayObject;

	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;

	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import spark.components.Alert;
	import actionScripts.events.ApplicationEvent;

	public class GenesisPlugin extends ConsoleBuildPluginBase
	{
		public static const GENESIS_ID_QUERY_URL:String = "https://api.genesis.directory/v1/apps/";

		public static var NAMESPACE:String = "actionScripts.plugins.genesis::GenesisPlugin";

		override public function get name():String			{ return "Genesis"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Genesis support from Moonshine-IDE"; }
		
		private var importGenesisPopup:ImportGenesisPopup;

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent, false, 0, true);
			dispatcher.addEventListener(GenesisEvent.OPEN_GENESIS_CATALOG_IN_BROWSER, onOpenGenesisCatalogBrowserEvent, false, 0, true);
			dispatcher.addEventListener(ApplicationEvent.INVOKE, onAppInvokeEvent, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent);
			dispatcher.removeEventListener(GenesisEvent.OPEN_GENESIS_CATALOG_IN_BROWSER, onOpenGenesisCatalogBrowserEvent);
			dispatcher.removeEventListener(ApplicationEvent.INVOKE, onAppInvokeEvent);
		}

		private function onImportGenesisEvent(event:Event, withURL:String=null):void
		{
			if (!importGenesisPopup)
			{
				importGenesisPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ImportGenesisPopup) as ImportGenesisPopup;
				importGenesisPopup.url = withURL;
				importGenesisPopup.addEventListener(CloseEvent.CLOSE, onImportGenesisPopupClosed);
				importGenesisPopup.addEventListener(ImportGenesisPopup.EVENT_FORM_SUBMIT, onImportGenesisPopupSubmit);
				PopUpManager.centerPopUp(importGenesisPopup);
			}
		}

		private function onOpenGenesisCatalogBrowserEvent(event:Event):void
		{
			navigateToURL(new URLRequest("https://genesis.directory/apps"));
		}

		private function onAppInvokeEvent(event:ApplicationEvent):void
		{
			if (event.data.length)
			{
				if ((event.data[0] as String).toLowerCase().indexOf("://project/") != -1)
				{
					var arguments:Array = event.data[0].split("/");
					// test only if there is some value followed by 'project/'
					if (arguments[arguments.length - 1].toLowerCase() != "")
					{
						onImportGenesisEvent(null, event.data[0] as String);
					}
				}
			}
		}

		private function onImportGenesisPopupSubmit(event:Event):void
		{
			new ImportGenesisCatalog(importGenesisPopup.url, importGenesisPopup.destinationFolder);
		}

		private function onImportGenesisPopupClosed(event:CloseEvent):void
		{
			importGenesisPopup.removeEventListener(CloseEvent.CLOSE, onImportGenesisPopupClosed);
			importGenesisPopup.removeEventListener(ImportGenesisPopup.EVENT_FORM_SUBMIT, onImportGenesisPopupSubmit);
			importGenesisPopup = null;
		}
	}
}