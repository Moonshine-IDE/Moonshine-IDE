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

package actionScripts.factory;

import actionScripts.impls.INativeMenuItemBridgeImp;
import actionScripts.interfaces.IAboutBridge;
import actionScripts.interfaces.IClipboardBridge;
import actionScripts.interfaces.IContextMenuBridge;
import actionScripts.interfaces.IFileBridge;
import actionScripts.interfaces.IFlexCoreBridge;
import actionScripts.interfaces.IProjectBridge;
import actionScripts.interfaces.ILanguageServerBridge;
import actionScripts.interfaces.IOSXBookmarkerBridge;
import actionScripts.interfaces.IVisualEditorBridge;

class BridgeFactory {
	public static function getFileInstance():IFileBridge {
		return getInstance("actionScripts.impls.IFileBridgeImp");
	}

	public static function getFileInstanceObject():Dynamic {
		return getInstance("actionScripts.impls.IFileBridgeImp");
	}

	public static function getContextMenuInstance():IContextMenuBridge {
		return getInstance("actionScripts.impls.IContextMenuBridgeImp");
	}

	public static function getClipboardInstance():IClipboardBridge {
		return getInstance("actionScripts.impls.IClipboardBridgeImp");
	}

	public static function getNativeMenuItemInstance():INativeMenuItemBridgeImp {
		return getInstance("actionScripts.impls.INativeMenuItemBridgeImp");
	}

	public static function getFlexCoreInstance():IFlexCoreBridge {
		return getInstance("actionScripts.impls.IFlexCoreBridgeImp");
	}

	public static function getOSXBookmarkerCoreInstance():IOSXBookmarkerBridge {
		return getInstance("actionScripts.impls.IOSXBookmarkerBridgeImp");
	}

	public static function getVisualEditorInstance():IVisualEditorBridge {
		return getInstance("actionScripts.impls.IVisualEditorProjectBridgeImpl");
	}

	public static function getAboutInstance():IAboutBridge {
		return getInstance("actionScripts.impls.IAboutBridgeImp");
	}

	public static function getProjectInstance():IProjectBridge {
		return getInstance("actionScripts.impls.IProjectBridgeImpl");
	}

	public static function getLanguageServerCoreInstance():ILanguageServerBridge {
		return getInstance("actionScripts.impls.ILanguageServerBridgeImp");
	}

	private static function getInstance<T>(name:String):T {
		return Type.createInstance(Type.resolveClass(name), []);
	}
}