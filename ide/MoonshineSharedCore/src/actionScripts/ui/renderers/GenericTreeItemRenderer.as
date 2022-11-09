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
package actionScripts.ui.renderers
{
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.display.Sprite;
    import flash.events.Event;
    
    import mx.binding.utils.ChangeWatcher;
    import mx.controls.treeClasses.TreeItemRenderer;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.ToolTipEvent;

	import spark.components.Image;

	import spark.components.Label;
    
    import actionScripts.locator.IDEModel;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.FileWrapper;

	use namespace mx_internal;
	
	public class GenericTreeItemRenderer extends TreeItemRenderer
	{
		private var label2:Label;
		
		private var model:IDEModel;
		private var hitareaSprite:Sprite;
		private var sourceControlBackground:UIComponent;
		private var sourceControlText:Label;
		private var sourceControlSystem:Label;
		private var isTooltipListenerAdded:Boolean;
		private var isSourceFolderIcon:Image;

		public function GenericTreeItemRenderer()
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
			super.data = value;
			
			if (!isTooltipListenerAdded)
			{
				addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
				addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);
				isTooltipListenerAdded = true;
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			sourceControlBackground = new UIComponent();
			sourceControlBackground.mouseEnabled = false;
			sourceControlBackground.mouseChildren = false;
			sourceControlBackground.visible = false;
			sourceControlBackground.graphics.beginFill(0x484848, .9);
			sourceControlBackground.graphics.drawRect(0, -2, 30, 17);
			sourceControlBackground.graphics.endFill();
			sourceControlBackground.graphics.lineStyle(1, 0x0, .3);
			sourceControlBackground.graphics.moveTo(-1, -2);
			sourceControlBackground.graphics.lineTo(-1, 16);
			sourceControlBackground.graphics.lineStyle(1, 0xEEEEEE, .1);
			sourceControlBackground.graphics.moveTo(0, -2);
			sourceControlBackground.graphics.lineTo(0, 16);
			addChild(sourceControlBackground);
			
			// For drawing SVN/GIT/HG/CVS etc
			sourceControlSystem = new Label();
			sourceControlSystem.width = 30;
			sourceControlSystem.height = 16;
			sourceControlSystem.mouseEnabled = false;
			sourceControlSystem.mouseChildren = false;
			sourceControlSystem.styleName = 'uiText';
			sourceControlSystem.setStyle('fontSize', 10);
			sourceControlSystem.setStyle('color', 0xe0e0e0);
			sourceControlSystem.setStyle('textAlign', 'center');
			sourceControlSystem.setStyle('paddingTop', 3);
			sourceControlSystem.maxDisplayedLines = 1;
			sourceControlSystem.visible = false;
			addChild(sourceControlSystem);
			
			// For displaying source control status
			sourceControlText = new Label();
			sourceControlText.width = 20;
			sourceControlText.height = 16;
			sourceControlText.mouseEnabled = false;
			sourceControlText.mouseChildren = false;
			sourceControlText.styleName = 'uiText';
			sourceControlText.setStyle('fontSize', 9);
			sourceControlText.setStyle('color', 0xcdcdcd);
			sourceControlText.setStyle('textAlign', 'center');
			sourceControlText.setStyle('paddingTop', 3);
			sourceControlText.maxDisplayedLines = 1;
			sourceControlText.visible = false;
			addChild(sourceControlText);
			
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
				label2.setStyle('color', 0xe0e0e0);
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
			label2.x = label.x;
        	label2.y = label.y+5;
        	
        	label2.text = label.text;
        	
        	if (label) label.visible = false;
        	if (data)
			{
	        	// Update source control status
	        	sourceControlSystem.visible = false;
	        	sourceControlText.visible = false;
	        	sourceControlBackground.visible = false;

				if (data.isSourceFolder && !isSourceFolderIcon)
				{
					isSourceFolderIcon = new Image();
					isSourceFolderIcon.toolTip = "Source folder";
					isSourceFolderIcon.source = new ConstantsCoreVO.sourceFolderIcon;
					isSourceFolderIcon.width = isSourceFolderIcon.height = 14;
					isSourceFolderIcon.x = label2.x - (this.icon ? 44 : 28);
					addChild(isSourceFolderIcon);
				}
				else if (data.isSourceFolder && isSourceFolderIcon)
				{
					isSourceFolderIcon.visible = true;
				}
				else if (!data.isSourceFolder && isSourceFolderIcon)
				{
					isSourceFolderIcon.visible = false;
				}
	        	
	        	if (data.hasOwnProperty("sourceController") && data.sourceController)
	        	{
	        		if (data.isRoot)
	        		{
		        		// Show source control system name (SVN/CVS/HG/GIT)
		        		sourceControlSystem.text = FileWrapper(data).sourceController.systemNameShort; 
		        		
		        		sourceControlBackground.visible = true;
		        		sourceControlSystem.visible = true;
		        		
		        		sourceControlBackground.x = unscaledWidth-30;
		        		sourceControlSystem.x = sourceControlBackground.x;
		        		sourceControlSystem.y = label2.y;	
	        		}
	        		else
	        		{
	        			/*var st:String = data.sourceController.getStatus(data.nativePath);
		        		if (st)
		        		{*/
		        			sourceControlText.text = data.name;
		        			sourceControlBackground.visible = true;
		        			sourceControlText.visible = true;
		        			
		        			sourceControlBackground.x = unscaledWidth-20;
		        			sourceControlText.x = sourceControlBackground.x;
		        			sourceControlText.y = label2.y;
		        		//}	
	        		}
	        	}
			}
		} // updateDisplayList
	}
}