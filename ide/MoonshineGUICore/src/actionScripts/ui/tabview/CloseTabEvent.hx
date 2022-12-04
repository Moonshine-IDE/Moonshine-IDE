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

package actionScripts.ui.tabview;

import openfl.display.DisplayObject;
import openfl.events.Event;

class CloseTabEvent extends Event {
	public static final EVENT_CLOSE_TAB:String = "closeTabEvent";
	public static final EVENT_CLOSE_ALL_TABS:String = "closeAllTabsEvent";
	public static final EVENT_CLOSE_ALL_OTHER_TABS:String = "closeAllOtherTabsEvent";
	public static final EVENT_TAB_CLOSED:String = "tabClosedEvent";
	public static final EVENT_ALL_TABS_CLOSED:String = "allTabsClosed";
	public static final EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT:String = "EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT";

	public var tab:DisplayObject;
	public var forceClose:Bool;
	public var isUserTriggered:Bool;

	public function new(type:String, targetEditor:DisplayObject, forceClose:Bool = false) {
		this.tab = targetEditor;
		this.forceClose = forceClose;

		super(type, false, false);
	}
}