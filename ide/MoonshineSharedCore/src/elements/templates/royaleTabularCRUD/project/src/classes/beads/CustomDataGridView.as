package classes.beads
{
    import classes.beads.JewelDataGridRendererOwner;
    
    import org.apache.royale.core.IStrand;
    import org.apache.royale.jewel.beads.views.DataGridView;
    import org.apache.royale.jewel.supportClasses.datagrid.IDataGridColumnList;
    
	public class CustomDataGridView extends DataGridView 
	{
		public function CustomDataGridView()
		{
			super();
		}
		
		 override public function set strand(value:IStrand):void
		 {
		 	 super.strand = value;
		 	 
		 	 for (var i:int=0; i < columnLists.length; i++)
             {
                var list:IDataGridColumnList = columnLists[i] as IDataGridColumnList;
                
                var jewelDgOwner:JewelDataGridRendererOwner = list.getBeadByType(JewelDataGridRendererOwner) as JewelDataGridRendererOwner;
                if (jewelDgOwner == null)
                {
               		list.addBead(new JewelDataGridRendererOwner());
                }
             }
		 }
	}
}