////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2025. All rights reserved.
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
package moonshine.ui.renderers;

import actionScripts.valueObjects.FileWrapper;
import feathers.controls.BitmapImage;
import feathers.controls.Menu;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ITreeViewItemRenderer;
import feathers.core.IValidating;
import feathers.text.TextFormat;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;

class FileWrapperHierarchicalItemRenderer extends HierarchicalItemRenderer implements ITreeViewItemRenderer {
	public function new() {
		super();
		addEventListener(MouseEvent.RIGHT_CLICK, fileWrapperHierarchicalItemRenderer_rightClickHandler);
	}

	private var _location:Array<Int>;

	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return _location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		_location = value;
		return _location;
	}

	private var _treeViewOwner:TreeView;

	public var treeViewOwner(get, set):TreeView;

	private function get_treeViewOwner():TreeView {
		return _treeViewOwner;
	}

	private function set_treeViewOwner(value:TreeView):TreeView {
		_treeViewOwner = value;
		return _treeViewOwner;
	}

	public var nativeContextMenuFactory:#if flash(data:Dynamic) -> flash.ui.ContextMenu #else(data:Dynamic) -> Dynamic #end;

	public var feathersContextMenuFactory:(data:Dynamic) -> Menu;

	public var isActiveFileCallback:(FileWrapper) -> Bool;
	public var isSourceFolderCallback:(FileWrapper) -> Bool;

	private var _currentIsOpenIcon:DisplayObject = null;
	private var _currentIsSourceFolderIcon:DisplayObject = null;
	private var _currentIsLoadingIcon:DisplayObject = null;

	/**
		Optional icon to indicate that the file is the currently active editor.
	**/
	@:style
	public var isOpenIcon:DisplayObject = null;

	/**
		Optional icon to indicate that the folder is a source folder.
	**/
	@:style
	public var isSourceFolderIcon:DisplayObject = null;

	/**
		Optional icon to indicate that the folder contents are loading.
	**/
	@:style
	public var isLoadingIcon:MovieClip = null;

	private var _rootTextFormat:TextFormat;
	private var _deletingTextFormat:TextFormat;
	private var _hiddenTextFormat:TextFormat;
	private var _normalTextFormat:TextFormat;

	override private function set_textFormat(value:TextFormat):TextFormat {
		if (get_textFormat() == value) {
			return get_textFormat();
		}
		_rootTextFormat = null;
		_deletingTextFormat = null;
		_hiddenTextFormat = null;
		_normalTextFormat = null;
		super.set_textFormat(value);
		if (value != null) {
			_rootTextFormat = value.clone();
			_rootTextFormat.color = 0xffffcc;
			_hiddenTextFormat = value.clone();
			_hiddenTextFormat.color = 0xff4848;
			_normalTextFormat = value.clone();
			_normalTextFormat.color = 0xe0e0e0;
			_deletingTextFormat = value.clone();
			// #if (feathersui >= "1.4.0" && openfl >= "9.5.0")
			// _deletingTextFormat.strikethrough = true;
			// #end
		}
		return get_textFormat();
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var stylesInvalid = isInvalid(STYLES);

		if (dataInvalid) {
			populateContextMenu();
			updateIcons();
			updateToolTip();
		}

		if (dataInvalid || stylesInvalid) {
			updateTextFormat();
		}

		super.update();
	}

	private function updateTextFormat():Void {
		runWithInvalidationFlagsOnly(() -> {
			var fw:FileWrapper = Std.downcast(data, FileWrapper);
			if (fw == null) {
				textFormat = _normalTextFormat;
				return;
			}
			if (fw.isRoot) {
				textFormat = _rootTextFormat;
			} else if (fw.isDeleting) {
				textFormat = _deletingTextFormat;
			} else if (fw.isHidden) {
				textFormat = _hiddenTextFormat;
			} else {
				textFormat = _normalTextFormat;
			}
		});
	}

	override private function layoutChildren():Void {
		super.layoutChildren();

		if ((isOpenIcon is IValidating)) {
			(cast isOpenIcon : IValidating).validateNow();
		}

		if ((isSourceFolderIcon is IValidating)) {
			(cast isSourceFolderIcon : IValidating).validateNow();
		}

		if ((isLoadingIcon is IValidating)) {
			(cast isLoadingIcon : IValidating).validateNow();
		}

		if (isOpenIcon != null) {
			isOpenIcon.x = textField.x - 8;
			isOpenIcon.y = (actualHeight - isOpenIcon.height) / 2.0;
		}
		if (isSourceFolderIcon != null) {
			isSourceFolderIcon.width = isSourceFolderIcon.height = 14;
			isSourceFolderIcon.x = textField.x - (this.icon != null ? 44 : 29);
			isSourceFolderIcon.y = (actualHeight - isSourceFolderIcon.height) / 2.0;
		}
		if (isLoadingIcon != null) {
			isLoadingIcon.width = isLoadingIcon.height = 10;
			isLoadingIcon.x = textField.x - isLoadingIcon.width - 10;
			isLoadingIcon.y = (actualHeight - isLoadingIcon.height) / 2.0;
		}
	}

	private function updateToolTip():Void {
		var fw:FileWrapper = Std.downcast(data, FileWrapper);
		if (fw != null) {
			toolTip = fw.nativePath;
		} else {
			toolTip = null;
		}
	}

	private function updateIcons():Void {
		this.refreshIsOpenIcon();
		this.refreshIsSourceFolderIcon();
		this.refreshIsLoadingIcon();

		var fw:FileWrapper = Std.downcast(data, FileWrapper);
		if (fw != null) {
			if (isOpenIcon != null) {
				// Show lil' dot if we are the currently opened file
				var isActiveFile:Bool = false;
				if (isActiveFileCallback != null) {
					isActiveFile = isActiveFileCallback(fw);
				}
				isOpenIcon.visible = isActiveFile;
			}

			if (isSourceFolderIcon != null) {
				var isSourceFolder = fw.isSourceFolder;
				if (!isSourceFolder && isSourceFolderCallback != null) {
					isSourceFolder = isSourceFolderCallback(fw);
				}
				isSourceFolderIcon.visible = isSourceFolder;
			}

			if (isLoadingIcon != null) {
				if (fw.isWorking) {
					isLoadingIcon.visible = true;
					isLoadingIcon.play();
				} else {
					isLoadingIcon.visible = false;
					isLoadingIcon.stop();
				}
			}
		} else {
			if (isOpenIcon != null) {
				isOpenIcon.visible = false;
			}
			if (isSourceFolderIcon != null) {
				isSourceFolderIcon.visible = false;
			}
			if (isLoadingIcon != null) {
				isLoadingIcon.visible = false;
				isLoadingIcon.stop();
			}
		}
	}

	private function refreshIsOpenIcon():Void {
		var oldIcon = _currentIsOpenIcon;
		_currentIsOpenIcon = isOpenIcon;
		if (_currentIsOpenIcon == oldIcon) {
			return;
		}
		if (oldIcon != null) {
			removeChild(oldIcon);
		}
		if (_currentIsOpenIcon != null) {
			addChild(_currentIsOpenIcon);
		}
	}

	private function refreshIsSourceFolderIcon():Void {
		var oldIcon = _currentIsSourceFolderIcon;
		_currentIsSourceFolderIcon = isSourceFolderIcon;
		if (_currentIsSourceFolderIcon == oldIcon) {
			return;
		}
		if (oldIcon != null) {
			removeChild(oldIcon);
		}
		if (_currentIsSourceFolderIcon != null) {
			addChild(_currentIsSourceFolderIcon);
		}
	}

	private function refreshIsLoadingIcon():Void {
		var oldIcon = _currentIsLoadingIcon;
		_currentIsLoadingIcon = isLoadingIcon;
		if (_currentIsLoadingIcon == oldIcon) {
			return;
		}
		if (oldIcon != null) {
			removeChild(oldIcon);
		}
		if (_currentIsLoadingIcon != null) {
			addChild(_currentIsLoadingIcon);
		}
	}

	private function populateContextMenu():Void {
		contextMenu = nativeContextMenuFactory != null ? nativeContextMenuFactory(data) : null;
	}

	private function fileWrapperHierarchicalItemRenderer_rightClickHandler(event:MouseEvent):Void {
		if (nativeContextMenuFactory != null || feathersContextMenuFactory == null) {
			return;
		}

		event.preventDefault();

		var menu:Menu = feathersContextMenuFactory(data);
		menu.showAtPosition(stage.mouseX, stage.mouseY, this);
	}
}
