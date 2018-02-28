package awaybuilder.view.components.controls.tree
{
	import mx.core.UIComponent;
	
	import spark.components.IItemRenderer;
	
	public interface ITreeItemRenderer extends IItemRenderer
	{
		
		/**
		 * Level in the tree hierarchy. 0 for top level items, 1 for their children
		 * and so on.
		 */
		function get level():int;
		function set level(value:int):void;
		
		/**
		 * Vector of object parents starting from the top level item. 
		 * <code>null</code> for top level items. If not <code>null</code> then 
		 * <code>parents.length == level</code>.
		 */
		
		function get dropArea():UIComponent;
		function set dropArea(value:UIComponent):void;
		
		function get showDropIndicator():Boolean;
		function set showDropIndicator(value:Boolean):void; 
		
		function get parents():Vector.<Object>;
		function set parents(value:Vector.<Object>):void;
		
		function get isBranch():Boolean;
		function set isBranch(value:Boolean):void;
		
		function get isLeaf():Boolean;
		function set isLeaf(value:Boolean):void;
		
		function get hasChildren():Boolean;
		function set hasChildren(value:Boolean):void;
		
		function get isOpen():Boolean;
		function set isOpen(value:Boolean):void;
		
	}
}