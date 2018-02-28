package awaybuilder.model.vo.scene
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ContainerVO extends ObjectVO
	{
		
		public var children:ArrayCollection; // array of ContainerVO
		
		override public function clone():ObjectVO
		{
			var clone:ContainerVO = new ContainerVO()
			clone.fillFromContainer( this );
			return clone;
		}
		
		public function fillFromContainer( asset:ContainerVO ):void
		{
			this.fillFromObject( asset );
			
			this.children = updateCollection( this.children, asset.children );
		}
		
		
		
		
	}
}