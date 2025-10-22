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

package actionScripts.ui.renderers;

import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import feathers.controls.BitmapImage;
import feathers.controls.Menu;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ITreeViewItemRenderer;
import feathers.core.IValidating;
import feathers.text.TextFormat;
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

	public var nativeContextMenuFactory:#if flash (data:Dynamic)->flash.ui.ContextMenu #else (data:Dynamic)->Dynamic #end;

	public var feathersContextMenuFactory:(data:Dynamic)->Menu;

	private var model:IDEModel = IDEModel.getInstance();

	private var isOpenIcon:Sprite;
	private var isSourceFolderIcon:BitmapImage;
	private var isLoadingIcon:MovieClip;

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
		if (value != null)
		{
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

	override private function initialize():Void {
		super.initialize();
		
		if (isOpenIcon == null) {
			isOpenIcon = new Sprite();
			isOpenIcon.mouseEnabled = false;
			isOpenIcon.mouseChildren = false;
			isOpenIcon.graphics.clear();
			isOpenIcon.graphics.beginFill(0xe15fd5);
			isOpenIcon.graphics.drawCircle(2, 2, 2);
			isOpenIcon.graphics.endFill();
			isOpenIcon.visible = false;
			var glow:GlowFilter = new GlowFilter(0xff00e4, .4, 6, 6, 2);
			isOpenIcon.filters = [glow];
			addChild(isOpenIcon);
		}

		if (isSourceFolderIcon == null) {
			isSourceFolderIcon = new BitmapImage();
			isSourceFolderIcon.toolTip = "Source folder";
			isSourceFolderIcon.source = Type.createInstance(ConstantsCoreVO.sourceFolderIcon, []).bitmapData;
			isSourceFolderIcon.visible = false;
			addChild(isSourceFolderIcon);
		}

		if (isLoadingIcon == null) {
			isLoadingIcon = Type.createInstance(ConstantsCoreVO.loaderIcon, []);
			isLoadingIcon.stop();
			isLoadingIcon.visible = false;
			addChild(isLoadingIcon);
		}
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
			if (fw == null)
			{
				textFormat = _normalTextFormat;
				return;
			}
			if (fw.isRoot) {
				textFormat = _rootTextFormat;
			} else if (!ConstantsCoreVO.IS_AIR && fw.isDeleting) {
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

		if ((isOpenIcon is IValidating))
		{
			(cast isOpenIcon : IValidating).validateNow();
		}

		if ((isSourceFolderIcon is IValidating))
		{
			(cast isSourceFolderIcon : IValidating).validateNow();
		}

		if ((isLoadingIcon is IValidating))
		{
			(cast isLoadingIcon : IValidating).validateNow();
		}

		if (isOpenIcon != null) {
			isOpenIcon.x = textField.x-8;
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
		var fw:FileWrapper = Std.downcast(data, FileWrapper);
		if (fw != null)
		{
			// Show lil' dot if we are the currently opened file
			var isActiveFile:Bool = false;
			if ((model.activeEditor is BasicTextEditor))
			{
				var textEditor:BasicTextEditor = cast model.activeEditor;
				if (textEditor.currentFile != null)
				{
					if (fw.nativePath != null
						&& fw.nativePath == textEditor.currentFile.fileBridge.nativePath)
					{
						isActiveFile = true;
					}
				}
			}
			isOpenIcon.visible = isActiveFile;
			
			var isSourceFolder = fw.isSourceFolder;
			if (!isSourceFolder && fw.projectReference != null && fw.projectReference.sourceFolder != null)
			{
				isSourceFolder = fw.nativePath == fw.projectReference.sourceFolder.fileBridge.nativePath;	
			}
			isSourceFolderIcon.visible = isSourceFolder;

			if (fw.isWorking)
			{
				isLoadingIcon.visible = true;
				isLoadingIcon.play();
			}
			else
			{
				isLoadingIcon.visible = false;
				isLoadingIcon.stop();
			}
		}
		else
		{
			isOpenIcon.visible = false;
			isSourceFolderIcon.visible = false;
			isLoadingIcon.visible = false;
			isLoadingIcon.stop();
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