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

	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;

	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	import spark.components.Alert;

	public class GenesisPlugin extends ConsoleBuildPluginBase
	{
		public static var NAMESPACE:String = "actionScripts.plugins.genesis::GenesisPlugin";

		override public function get name():String			{ return "Genesis"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Genesis support from Moonshine-IDE"; }
		
		private var importGenesisPopup:ImportGenesisPopup;

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent, false, 0, true);

			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent);
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onAppInvokeEvent);
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

		private function onAppInvokeEvent(event:InvokeEvent):void
		{
			if (event.arguments.length)
			{
				var arguments:Array = event.arguments[0].split("&");
				for each (var argument:String in arguments)
				{
					if (argument.toLowerCase().indexOf("gencaturl=") != -1)
					{
						var startIndex:int = argument.indexOf("=");
						var url:String = decodeURIComponent(argument.substr(startIndex + 1, argument.length));
						onImportGenesisEvent(null, url);
					}
				}
			}
		}

		private function onImportGenesisPopupSubmit(event:Event):void
		{
			var url:String = importGenesisPopup.url;
			new ImportGenesisCatalog(url);
		}

		private function onImportGenesisPopupClosed(event:CloseEvent):void
		{
			importGenesisPopup.removeEventListener(CloseEvent.CLOSE, onImportGenesisPopupClosed);
			importGenesisPopup.removeEventListener(ImportGenesisPopup.EVENT_FORM_SUBMIT, onImportGenesisPopupSubmit);
			importGenesisPopup = null;
		}
	}
}