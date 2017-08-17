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
package actionScripts.plugins.svn.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.core.ClassFactory;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.List;
	import spark.layouts.VerticalLayout;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.view.HDividerSkin;
	import actionScripts.plugins.svn.commands.SVNFileWrapper;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.tabview.CloseTabEvent;

	public class CommitMessageEditor extends VBox implements IContentWindow, IFocusManagerComponent
	{
		protected var editor:TextEditor;
		protected var fileList:List;
		protected var fileListContainer:VBox;
		protected var buttonBar:ButtonBar;
		
		public var isSaved:Boolean;
		
		[Bindable]
		public var files:Vector.<SVNFileWrapper>;
		
		public function get selectedFiles():Vector.<SVNFileWrapper>
		{
			var files:Vector.<SVNFileWrapper> = new Vector.<SVNFileWrapper>();
			
			for each (var wrap:SVNFileWrapper in fileList.dataProvider)
			{
				if (!wrap.ignore)
				{
					files.push(wrap);
				}
			}
			
			return files;
		}
		
		public function get text():String
		{
			return editor.dataProvider;
		}

		public function set text(v:String):void
		{
			editor.dataProvider = v;
		}

		
		public function CommitMessageEditor()
		{
			super();
			percentHeight = 100;
			percentWidth = 100;
			setStyle('verticalGap', 0);
			//addEventListener(FlexEvent.CREATION_COMPLETE, createdHandler);

			editor = new TextEditor();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			//editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);

			fileListContainer = new VBox();
			fileListContainer.percentHeight = 100;
			fileListContainer.percentWidth = 100;
			fileListContainer.setStyle('backgroundColor', 0x444444);
			fileListContainer.setStyle('paddingTop', 5);
			fileListContainer.setStyle('gap', 0);

			fileList = new List();
			fileList.percentWidth = 100;
			fileList.percentHeight = 100;
			fileList.setStyle('borderVisible', false);
			fileList.setStyle('contentBackgroundColor', 0x444444);
			fileList.setStyle('rollOverColor', 0x393939);
			fileList.setStyle('selectionColor', 0x393939);
			fileList.itemRenderer = new ClassFactory(CommitItemRenderer);
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.gap = 0;
			vlayout.rowHeight = 16;
			fileList.layout = vlayout;
			
			buttonBar = new ButtonBar();
			
			text = "";
		}

		override public function setFocus():void
		{
			if (editor)
				editor.setFocus();
		}

		override protected function createChildren():void
		{
			addChild(editor);
			
			var c:Canvas = new Canvas();
			c.setStyle('borderSkin', HDividerSkin);
			c.setStyle('paddingBottom', 5);
			c.height = 2;
			c.percentWidth = 100;
			addChild(c);
			
			addChild(fileListContainer);
			
			fileListContainer.addChild(fileList);
			addChild(buttonBar);
			
			buttonBar.cancelButton.addEventListener(MouseEvent.CLICK, handleCancel);
			buttonBar.commitButton.addEventListener(MouseEvent.CLICK, handleCommit);
			
			// Facepalm?
			var ac:ArrayCollection = new ArrayCollection();
			for each (var wrap:SVNFileWrapper in files)
			{
				ac.addItem(wrap);
			}
			var sortField:SortField = new SortField("relativePath");
			var sort:Sort = new Sort();
			sort.fields = [sortField];
			
			ac.sort = sort;
			ac.refresh();
			
			fileList.dataProvider = ac;
			
			super.createChildren();
		}
		
		private function handleCancel(event:Event):void
		{
			isSaved = false;
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, this, true)
			);
		}
		
		private function handleCommit(event:Event):void
		{
			save();
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, this)
			)
		}
		
		override public function get label():String
		{
			return "Commit message";
		}
		
		public function get longLabel():String
		{
			return "Commit message";
		}
		
		public function save():void
		{
			isSaved = true;
		}
		
		public function isChanged():Boolean
		{
			return false;
		}
		
		public function isEmpty():Boolean
		{
			return text == "";
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (fileList.dataProvider)
			{
				var fullHeight:int = 16*fileList.dataProvider.length;
				fileListContainer.height = Math.min(height/1.5, fullHeight) + 5;
			}
		}
		
		
	}
}