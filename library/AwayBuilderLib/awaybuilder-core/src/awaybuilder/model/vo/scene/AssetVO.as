package awaybuilder.model.vo.scene
{
	
	import com.adobe.utils.ArrayUtil;
	
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;

	
	[Bindable]
	public class AssetVO
	{
		
		public var id:String; // unique ID to compare objects
		
		public var name:String = "undefined";
		
		public var isDefault:Boolean = false;
		
		public var isNull:Boolean = false;
		
		public function equals( asset:AssetVO ):Boolean
		{
			return (asset.id == this.id); 
		}
		
		protected function updateCollection( collection:ArrayCollection, newCollection:ArrayCollection ):ArrayCollection
		{
			if( collection == newCollection ) return collection;
			if( !collection || !newCollection ) 
			{
				collection == newCollection;
				return collection;
			}
			if( ArrayUtil.arraysAreEqual(collection.source, newCollection.source ) ) return collection;
			return new ArrayCollection( newCollection.source.concat() );
		}
			
		public function toString():String
		{
			return "[asset " + getQualifiedClassName( this ).split("::")[1] + "("+name+")]"; 
		}
	}
}