package awaybuilder.view.components.controls
{
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.view.components.controls.tree.ITreeItemRenderer;
	import awaybuilder.view.components.controls.tree.Tree;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	public class LightsTree extends Tree
	{
		public function LightsTree()
		{
			super();
		}
		
		override protected function renderer_dragEnterHandler(event:DragEvent):void
		{
			var dropArea:UIComponent = event.target as UIComponent;
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			if( !items ) return;
			var renderer:ITreeItemRenderer = dropArea.parent as ITreeItemRenderer;
			if( renderer.data == items[0] ) return;
			if( renderer.data is LightPickerVO )
			{
				if( items[0] is LightVO )
				{
					renderer.showDropIndicator = true;
					DragManager.acceptDragDrop(dropArea);
					_druggingOverItem = true;
				}
			}
			
		}
		
		override protected function renderer_dragOverHandler(event:DragEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
			var dropArea:UIComponent = event.target as UIComponent;
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			if( !items ) return;
			var renderer:ITreeItemRenderer = dropArea.parent as ITreeItemRenderer;
			if( renderer.data == items[0] ) return;
			if( renderer.data is LightPickerVO )
			{
				if( items[0] is LightVO )
				{
					renderer.showDropIndicator = true;
					DragManager.acceptDragDrop(dropArea);
					_druggingOverItem = true;
				}
			}
		}
		
	}
}