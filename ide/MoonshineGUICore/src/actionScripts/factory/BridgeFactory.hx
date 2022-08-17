package actionScripts.factory;

import actionScripts.impls.INativeMenuItemBridgeImp;
import actionScripts.interfaces.IAboutBridge;
import actionScripts.interfaces.IClipboardBridge;
import actionScripts.interfaces.IContextMenuBridge;
import actionScripts.interfaces.IFileBridge;
import actionScripts.interfaces.IFlexCoreBridge;
import actionScripts.interfaces.IGroovyBridge;
import actionScripts.interfaces.IHaxeBridge;
import actionScripts.interfaces.IJavaBridge;
import actionScripts.interfaces.ILanguageServerBridge;
import actionScripts.interfaces.IOSXBookmarkerBridge;
import actionScripts.interfaces.IOnDiskBridge;
import actionScripts.interfaces.IVisualEditorBridge;
import actionScripts.plugin.genericproj.interfaces.IGenericProjectBridge;

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

	public static function getJavaInstance():IJavaBridge {
		return getInstance("actionScripts.impls.IJavaBridgeImpl");
	}

	public static function getGroovyInstance():IGroovyBridge {
		return getInstance("actionScripts.impls.IGroovyBridgeImpl");
	}

	public static function getHaxeInstance():IHaxeBridge {
		return getInstance("actionScripts.impls.IHaxeBridgeImpl");
	}

	public static function getLanguageServerCoreInstance():ILanguageServerBridge {
		return getInstance("actionScripts.impls.ILanguageServerBridgeImp");
	}

	public static function getOnDiskInstance():IOnDiskBridge {
        return getInstance("actionScripts.impls.IOnDiskBridgeImpl");
	}

	public static function getGenericInstance():IGenericProjectBridge {
		return getInstance("actionScripts.impls.IGenericBridgeImpl");
	}

	private static function getInstance<T>(name:String):T {
		return Type.createInstance(Type.resolveClass(name), []);
	}
}