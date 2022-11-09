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
package actionScripts.utils;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.help.HelpPlugin;
import mx.controls.Alert;
import mx.events.CloseEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class NoSDKNotifier extends EventDispatcher {
	public static final SDK_SAVED:String = "SDK_SAVED";
	public static final SDK_SAVE_CANCELLED:String = "SDK_SAVE_CANCELLED";

	private static var instance:NoSDKNotifier;
	private static var isShowing:Bool;

	public static function getInstance():NoSDKNotifier {
		if (instance == null)
			instance = new NoSDKNotifier();
		return instance;
	}

	private var isJavaCheckingRequires:Bool;

	public function new() {
		super();
	}

	public function notifyNoFlexSDK(isJavaCheckingRequires:Bool = true):Void {
		if (isShowing)
			return;

		var model:IDEModel = IDEModel.getInstance();
		var item:Dynamic = model.userSavedSDKs.getItemAt(0);
		if ((model.userSavedSDKs.length != 0) && (item != null) && (item.status == SDKUtils.BUNDLED)) {
			SDKUtils.setDefaultSDKByBundledSDK();
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, item));
			return;
		}

		Alert.noLabel = "Do it later";
		Alert.yesLabel = "Fix this now";
		Alert.buttonWidth = 110;

		Alert.show("Moonshine detected no default SDK set!", "No SDK Found", Alert.YES | Alert.NO, null, alertClosed);
		this.isJavaCheckingRequires = isJavaCheckingRequires;
	}

	private function alertClosed(event:CloseEvent):Void {
		Alert.buttonWidth = 65;
		Alert.noLabel = "No";
		Alert.yesLabel = "Yes";

		if (event.detail == Alert.YES) {
			GlobalEventDispatcher.getInstance()
				.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
		}

		if (isJavaCheckingRequires)
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(HelpPlugin.EVENT_ENSURE_JAVA_PATH));
		isShowing = false;
	}
}