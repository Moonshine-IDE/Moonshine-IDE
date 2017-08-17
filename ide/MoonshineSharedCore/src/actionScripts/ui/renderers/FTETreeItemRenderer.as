////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.renderers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Image;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.ToolTipEvent;
	import mx.validators.StringValidator;
	
	import spark.components.Label;
	import spark.components.TextInput;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugin.templating.TemplatingPlugin;
	import actionScripts.plugin.templating.event.RequestTemplatesEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.notifier.ErrorTipManager;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;

	use namespace mx_internal;
	
	public class FTETreeItemRenderer extends TreeItemRenderer
	{
		public static const OPEN:String = "Open";
		public static const OPEN_FILE_FOLDER:String = "Open File/Folder";
		public static const NEW:String = "New";
		public static const NEW_FOLDER:String = "New Folder";
		public static const RENAME:String = "Rename";
		public static const DELETE:String = "Delete";
		public static const DELETE_FILE_FOLDER:String = "Delete File/Folder";
		public static const REFRESH:String = "Refresh";
		public static const RUN_ANT_SCRIPT:String = "Run Ant Script";
		public static const SETTINGS:String = "Settings";
		public static const PROJECT_SETUP:String = "Project Setup";
		public static const CLOSE:String = "Close";
		public static const DELETE_PROJECT:String = "Delete Project";
		public static const UNTITLED_FOLDER:String = "untitled folder";
		
		private var label2:Label;
		private var editText:TextInput;
		
		private var model:IDEModel;
		private var isOpenIcon:Sprite;
		private var hitareaSprite:Sprite;
		private var sourceControlBackground:UIComponent;
		private var sourceControlText:Label;
		private var sourceControlSystem:Label;
		private var loadingIcon:Image;
		private var isTooltipListenerAdded:Boolean;
		private var newMenuItems:Array = [];
		private var inputValidator:StringValidator;
		private var isErrorTipShowing:Boolean;
		
		public function FTETreeItemRenderer()
		{
			super();
			model = IDEModel.getInstance();
			ChangeWatcher.watch(model, 'activeEditor', onActiveEditorChange);
			
			// stores *new* context menu item
			if (ConstantsCoreVO.IS_AIR)
			{
				for each (var fileTemplate:FileLocation in TemplatingPlugin.fileTemplates)
				{
					var lbl:String = TemplatingHelper.getTemplateLabel(fileTemplate);
					
					// TODO: Do MenuEvent and have data:* for this kind of thing
					var eventType:String = "eventNewFileFromTemplate"+lbl;
					var newMenu:Object = model.contextMenuCore.getContextMenuItem(lbl, null, Event.SELECT);
					newMenu.data = eventType;
					newMenuItems.push(newMenu);
				}
			}
			
			inputValidator = new StringValidator();
			inputValidator.property = "text";
			inputValidator.required = true;
			inputValidator.minLength = 100;
			inputValidator.enabled = false;
			
			ErrorTipManager.registerValidator(inputValidator);
		}
		
		private function onActiveEditorChange(event:Event):void
		{
			invalidateDisplayList();
		}
		
		public function startEdit(editValue:String=null):void
		{
			label2.visible = false;
			
			editText = new TextInput();
			editText.x = label2.x;
			editText.y = -2;
			editText.width = width - 34;
			editText.height = height+4;
			editText.styleName = 'uiText';
			editText.setStyle('fontSize', 12);
			editText.setStyle('focusAlpha', 0);
			editText.setStyle('color', 0xe0e0e0);
			editText.setStyle('paddingTop', 3);
			editText.setStyle('contentBackgroundAlpha', 0);
			editText.setStyle('focusedTextSelectionColor', 0x2f0727);
			
			editText.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			editText.addEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
			
			editText.text = editValue ? editValue : label2.text;
			
			addChild(editText);
			
			editText.setFocus();
			
			// Normally you don't want to change the file ending
			if (editText.text.indexOf(".") > -1) editText.selectRange(0, editText.text.indexOf("."));
			else editText.selectRange(0, editText.text.length);
			
			inputValidator.source = editText;
		}
		
		public function stopEdit():void
		{
			editDone();
		}
		
		public function cancelEdit():void
		{
			if (!editText) return;
			
			label2.visible = true;
			editText.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			editText.removeEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
			
			removeChild(editText);
			editText = null;
		}
		
		public function setErrorInEdit(errorValue:String):void
		{
			if (!editText) return;
			
			inputValidator.enabled = true;
			inputValidator.tooLongError = inputValidator.tooShortError = errorValue;
			inputValidator.validate();
		}
		
		protected function handleKeyDown(event:KeyboardEvent):void
		{
			if (event.charCode == Keyboard.ENTER)
			{
				editDone();
			}
			else if (event.charCode == Keyboard.ESCAPE)
			{
				editCancel();
			}
		}
		
		protected function handleFocusOut(event:Event):void
		{
			editDone();
		}
		
		protected function editDone():void
		{
			removeErrorTip();
			dispatchEvent( new TreeMenuItemEvent(TreeMenuItemEvent.EDIT_END, editText.text, FileWrapper(data)) );
			cancelEdit();
			
			data = data;
		}
		
		protected function editCancel():void
		{
			removeErrorTip();
			dispatchEvent( new TreeMenuItemEvent(TreeMenuItemEvent.EDIT_CANCEL, editText.text, FileWrapper(data)) );
			cancelEdit();
		}
		
		public function removeErrorTip():void
		{
			if (inputValidator.enabled) 
			{
				inputValidator.enabled = false;
				ErrorTipManager.removeErrorTip(inputValidator.source, true);
				ErrorTipManager.hideAllErrorTips();
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			var fw:FileWrapper = value as FileWrapper;
			if (fw)
			{
				contextMenu = model.contextMenuCore.getContextMenu();
				
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? OPEN : OPEN_FILE_FOLDER, redispatch, Event.SELECT));
				
				if (ConstantsCoreVO.IS_AIR)
				{
					var newMenu:Object = model.contextMenuCore.getContextMenuItem(NEW, populateTemplatingMenu, "DISPLAYING");
					
					var folder:Object = model.contextMenuCore.getContextMenuItem("Folder", redispatch, Event.SELECT);
					folder.data = NEW_FOLDER;
					model.contextMenuCore.subMenu(newMenu, folder);
					model.contextMenuCore.subMenu(newMenu, model.contextMenuCore.getContextMenuItem(null));
					model.contextMenuCore.subMenu(newMenu, newMenuItems, redispatch);
					model.contextMenuCore.addItem(contextMenu, newMenu);
				}
				
				if (fw.sourceController)
				{
					model.contextMenuCore.addItem(contextMenu, fw.sourceController.getTreeRightClickMenu(fw.file));
				}
				
				if (!fw.isRoot)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(RENAME, redispatch, Event.SELECT));
					
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
	   				//contextMenu.addItem(new ContextMenuItem(null, true));
	   				
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? DELETE : DELETE_FILE_FOLDER, redispatch, Event.SELECT));
	   				
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
	   				//contextMenu.addItem(new ContextMenuItem(null, true));
					
					if (fw.file.fileBridge.extension=="xml")
					{
						var str:String = fw.file.fileBridge.read().toString();
						if ((str.search("<project ")!=-1) || (str.search("<project>")!=-1))
							model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(RUN_ANT_SCRIPT, redispatch, Event.SELECT));
					}
				}
				
				if (fw.isRoot || ConstantsCoreVO.IS_AIR) model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(REFRESH, redispatch, Event.SELECT));
				
				if (fw.isRoot)
				{
					if (!isTooltipListenerAdded)
					{
						addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
						addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);
						isTooltipListenerAdded = true;
					}
					
					//contextMenu.addItem(new ContextMenuItem(null, true));
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? SETTINGS : PROJECT_SETUP, redispatch, Event.SELECT));
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(CLOSE, redispatch, Event.SELECT));
					if (ConstantsCoreVO.IS_AIR)
					{
						// for some reason separatorBefore is not working through Constructor in desktop hence this separate null entry addition 
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? DELETE : DELETE_PROJECT, redispatch, Event.SELECT));
					}
					else
					{
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? DELETE : DELETE_PROJECT, redispatch, Event.SELECT, true));
					}
				}
				
				if (fw.isWorking && !loadingIcon) 
				{
					loadingIcon = new Image();
					loadingIcon.source = new ConstantsCoreVO.loaderIcon;
					loadingIcon.width = loadingIcon.height = 10;
					loadingIcon.y = (this.height - loadingIcon.height)/2;
					loadingIcon.x = this.width - loadingIcon.width - 10;
					addChild(loadingIcon);
				}
				else if (!fw.isWorking && loadingIcon)
				{
					removeChild(loadingIcon);
					loadingIcon = null;
				}
				
				if (fw.isDeleting)
				{
					label2.setStyle("lineThrough", true);
				}
				else
				{
					label2.setStyle("lineThrough", false);
				}
			}
			
			isOpenIcon.visible = false;
		}
		
		private function populateTemplatingMenu(e:Event):void
		{
			model.contextMenuCore.subMenu(e.target);
			
			var event:RequestTemplatesEvent = new RequestTemplatesEvent();
			GlobalEventDispatcher.getInstance().dispatchEvent(event);
			
			for each (var file:FileLocation in event.fileTemplates)
			{
				var label:String = TemplatingHelper.getTemplateLabel(file);
				var item:Object = model.contextMenuCore.getContextMenuItem(label, redispatch, Event.SELECT);
				item.data = file;
				model.contextMenuCore.addItem(e.target, item);
			}
			
			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem("Folder", redispatch, Event.SELECT));
		}
		
		private function redispatch(event:Event):void
		{
			var type:String = (event.target is ContextMenuItem) ? event.target.caption : event.target.label;
			if (type == NEW) return;
			
			
			var e:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, 
															type, 
															FileWrapper(data));
			e.renderer = this;
			if (event.target.hasOwnProperty("data") && event.target.data)
			{
				e.menuLabel = NEW;
				e.extra = event.target.data;
			}
			
			dispatchEvent(e);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			isOpenIcon = new Sprite();
			isOpenIcon.mouseEnabled = false;
			isOpenIcon.mouseChildren = false;
			isOpenIcon.graphics.clear();
			isOpenIcon.graphics.beginFill(0xe15fd5);
			isOpenIcon.graphics.drawCircle(1, 7, 2);
			isOpenIcon.graphics.endFill();
			isOpenIcon.visible = false;
			var glow:GlowFilter = new GlowFilter(0xff00e4, .4, 6, 6, 2);
			isOpenIcon.filters = [glow];
			addChild(isOpenIcon);
			
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
        	if(data)
			{
        	// Show lil' dot if we are the currently opened file
	        	if (model.activeEditor is BasicTextEditor
	        		&& BasicTextEditor(model.activeEditor).currentFile)
	        	{
					if (data.nativePath
						&& data.nativePath == BasicTextEditor(model.activeEditor).currentFile.fileBridge.nativePath)
	        		{
	        			isOpenIcon.visible = true;
	        			isOpenIcon.x = label2.x-8;
	        		}
	        		else isOpenIcon.visible = false;
	        	}
	        	else isOpenIcon.visible = false;
	        	
	        	// Update source control status
	        	sourceControlSystem.visible = false;
	        	sourceControlText.visible = false;
	        	sourceControlBackground.visible = false;
	        	
	        	if (data.sourceController)
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