package actionScripts.ui.editor.text
{
	import org.aswing.Component;
	import org.aswing.plaf.basic.BasicListUI;
	import org.aswing.geom.IntRectangle;
	
	public class PopupUI extends BasicListUI
	{
		public function PopupUI()
		{
			super();
		}
		/*	
		override protected function paintCellFocus(cellComponent:Component):void
		{
		
		}
		*/ 
		public function resetIndex():void
		{
			paintFocusedIndex = -1;
		}
	}
}