package classes.beads
{
    import org.apache.royale.core.IBead;
    import org.apache.royale.core.IDataGrid;
    import org.apache.royale.core.IStrand;
    import org.apache.royale.jewel.supportClasses.datagrid.IDataGridColumnList;
             
	public class JewelDataGridRendererOwner implements IBead
	{
		public var ownerView:IDataGrid;
		
		/**
		 *  @copy org.apache.royale.core.IBead#strand
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.0
		 */
		public function set strand(value:IStrand):void
		{	
            ownerView = (value as IDataGridColumnList).datagrid as IDataGrid;            
		}
	}
}