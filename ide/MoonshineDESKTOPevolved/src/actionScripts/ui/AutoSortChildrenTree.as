package actionScripts.ui
{
	import flash.events.Event;

	import mx.controls.Tree;

	public class AutoSortChildrenTree extends Tree
	{
		public var sortItemLabel:String;
		public function AutoSortChildrenTree()
		{
			super();
		}

		override public function expandItem(item:Object, open:Boolean,
											animate:Boolean = false,
											dispatchEvent:Boolean = false,
											cause:Event = null):void
		{
			super.expandItem(item, open, animate, dispatchEvent);

			if (sortItemLabel && item.children)
				item.children.sortOn(sortItemLabel, Array.CASEINSENSITIVE);
		}
	}
}
