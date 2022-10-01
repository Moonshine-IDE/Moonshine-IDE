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

import flash.events.ErrorEvent;
import flash.events.Event;

import mx.controls.Alert;

import air.update.events.DownloadErrorEvent;
import air.update.events.StatusUpdateEvent;
import air.update.events.UpdateEvent;

[Bindable] protected var downlaoding:Boolean = false;
[Bindable] protected var isUpdater:int = -1;

protected function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
{
	// Example of custom isNewerFunction function, it can be omitted if one doesn't want
	// to implement it's own version comparison logic. Be default it does simple string
	// comparison.
	return true;
}

protected function updater_errorHandler(event:ErrorEvent):void
{
	Alert.show(event.text);
}

protected function updater_initializedHandler(event:UpdateEvent):void
{
	// When NativeApplicationUpdater is initialized you can call checkNow function
	updater.checkNow();
}
 
protected function updater_updateStatusHandler(event:StatusUpdateEvent):void
{
	if (event.available)
	{
		// In case update is available prevent default behavior of checkNow() function 
		// and switch to the view that gives the user ability to decide if he wants to
		// install new version of the application.
		event.preventDefault();
		//currentState = "Update";
		isUpdater = 1;
	}
	else
	{
		//Alert.show("Your application is up to date!");
	}
}

protected function btnNo_clickHandler(event:Event):void
{
	isUpdater = 0;
}

protected function btnCancel_clickHandler(event:Event):void
{
	updater.cancelUpdate();
	isUpdater = 0;
}

protected function btnYes_clickHandler(event:Event):void
{
	 
	// In case user wants to download and install update display download progress bar
	// and invoke downloadUpdate() function.
	downlaoding = true;
	updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	updater.downloadUpdate();
}

private function updater_downloadCompleteHandler(event:UpdateEvent):void
{
	// When update is downloaded install it.
	updater.installUpdate();
}
 
private function updater_downloadErrorHandler(event:DownloadErrorEvent):void
{
	Alert.show("Error downloading update file, try again later.");
}