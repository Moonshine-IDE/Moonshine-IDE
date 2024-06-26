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
package actionScripts.ui.renderers
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.ui.ContextMenuItem;
    
    import mx.binding.utils.ChangeWatcher;
    import mx.controls.treeClasses.TreeItemRenderer;
    import mx.core.mx_internal;
    import mx.events.ToolTipEvent;
    
    import spark.components.BusyIndicator;
    import spark.components.Image;
    import spark.components.Label;
    
    import actionScripts.events.TreeMenuItemEvent;
    import actionScripts.locator.IDEModel;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.VersionControlTypes;

	use namespace mx_internal;
	
	public class RepositoryTreeItemRenderer extends TreeItemRenderer
	{
		public static const REFRESH:String = "Refresh";
		public static const COLLAPSE_ALL:String = "Collapse All";
		
		private var label2:Label;
		
		private var model:IDEModel;
		private var hitareaSprite:Sprite;
		private var busyIndicator:BusyIndicator;
		private var repositoryIcon:Image;
		private var isTooltipListenerAdded:Boolean;

		public function RepositoryTreeItemRenderer()
		{
			super();
			model = IDEModel.getInstance();
			ChangeWatcher.watch(model, 'activeEditor', onActiveEditorChange);
		}
		
		private function onActiveEditorChange(event:Event):void
		{
			invalidateDisplayList();
		}
		
		override public function set data(value:Object):void
		{
			if (value)
			{
				super.data = value;
				
				contextMenu = model.contextMenuCore.getContextMenu();
				if (data.children)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(REFRESH, redispatch, Event.SELECT));
				}
				
				// collapse-all in all cases
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(COLLAPSE_ALL, redispatch, Event.SELECT));
				
				if (data.isUpdating && !busyIndicator) 
				{
					busyIndicator = new BusyIndicator();
					addChild(busyIndicator);
				}
				else if (!data.isUpdating && busyIndicator)
				{
					removeChild(busyIndicator);
					busyIndicator = null;
				}
				
				// repository icon
				if (repositoryIcon)
				{
					removeChild(repositoryIcon);
					repositoryIcon = null;
				}
				if ((data.isRoot || data.isDownloadable || data.type != VersionControlTypes.SVN) && !repositoryIcon)
				{
					repositoryIcon = new Image();
					repositoryIcon.source = new ConstantsCoreVO[data.type +"LabelIcon"];
					addChild(repositoryIcon);
				}
				
				if (!isTooltipListenerAdded)
				{
					addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
					addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);
					isTooltipListenerAdded = true;
				}
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			hitareaSprite = new Sprite();
			hitArea = hitareaSprite;
			addChild(hitareaSprite);
		}
		
		override mx_internal function createLabel(childIndex:int):void
	    {
	        super.createLabel(childIndex);
	        label.visible = false;
			
	        if (!label2)
			{	
				label2 = new Label();
				label2.mouseEnabled = false;
				label2.mouseChildren = false;
				label2.styleName = 'uiText';
				label2.setStyle('fontSize', 12);
				label2.maxDisplayedLines = 1;
				
				if (childIndex == -1) 
					addChild(label2);
				else 
					addChildAt(label2, childIndex);
			}
	    }
		
	    override mx_internal function removeLabel():void
	    {
	    	super.removeLabel();
	    	
	        if (label2 != null)
	        {
	            removeChild(label2);
	            label2 = null;
	        }
	    }
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    	{
        	super.updateDisplayList(unscaledWidth, unscaledHeight);
        	
        	hitareaSprite.graphics.clear();
        	hitareaSprite.graphics.beginFill(0x0, 0);
        	hitareaSprite.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        	hitareaSprite.graphics.endFill();
        	hitArea = hitareaSprite;
        	
        	// Draw our own FTE label
        	label2.width = label.width;
        	label2.height = label.height;
			label2.x = label.x + 4;
        	label2.y = label.y + 6
        	
        	label2.text = label.text;
        	
        	if (label) label.visible = false;
			if (busyIndicator)
			{
				busyIndicator.width = busyIndicator.height = 20;
				busyIndicator.x = unscaledWidth - 30;
				busyIndicator.y = 0;
			}
			if (repositoryIcon)
			{
				repositoryIcon.width = repositoryIcon.sourceWidth;
				repositoryIcon.height = repositoryIcon.sourceHeight;
				repositoryIcon.x = unscaledWidth - (data.type == VersionControlTypes.GIT ? 65 : 69);
				repositoryIcon.y = (unscaledHeight - repositoryIcon.height) / 2;
			}
		}
		
		private function redispatch(event:Event):void
		{
			var type:String = (event.target is ContextMenuItem) ? event.target.caption : event.target.label;
			var e:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, type, null);
			e.extra = data;
			
			dispatchEvent(e);
		}
	}
}