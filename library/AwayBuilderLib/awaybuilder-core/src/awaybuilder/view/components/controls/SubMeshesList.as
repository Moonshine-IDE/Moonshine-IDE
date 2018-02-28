package awaybuilder.view.components.controls
{
	import awaybuilder.view.components.editors.renderers.SubmeshItemRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import spark.components.IItemRenderer;
	import spark.components.List;
	
	public class SubMeshesList extends List
	{
		public function SubMeshesList()
		{
			super();
		}
		
		private var _materials:ArrayCollection;
		
		public function get materials():ArrayCollection
		{
			return _materials;
		}
		
		public function set materials(value:ArrayCollection):void
		{
			_materials = value;
			var renderer:IItemRenderer;
			var n:int = dataGroup.numElements;
			for ( var i:int = 0; i < n; i++)
			{
				renderer = dataGroup.getElementAt(i) as IItemRenderer;
				if (renderer && renderer.data)
					updateRenderer(renderer, renderer.itemIndex, renderer.data);
			}
		}
		
		override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
		{
			if (renderer is SubmeshItemRenderer)
			{
				SubmeshItemRenderer(renderer).materials = materials; 
			}
			
			super.updateRenderer( renderer, itemIndex, data );
			
		}
	}
}