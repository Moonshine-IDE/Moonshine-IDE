package awaybuilder.model.vo.scene
{
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ObjectVO extends AssetVO
	{
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public var scaleX:Number;
		public var scaleY:Number;
		public var scaleZ:Number;
		
		public var rotationX:Number;
		public var rotationY:Number;
		public var rotationZ:Number;
		
		public var pivotX:Number;
		public var pivotY:Number;
		public var pivotZ:Number;
		
		public var extras:ArrayCollection;
		
		public function clone():ObjectVO
		{
			throw new Error( "Abstract method");
		}
		
		public function fillFromObject( asset:ObjectVO ):void
		{
			this.x = asset.x;
			this.y = asset.y;
			this.z = asset.z;
			this.scaleX = asset.scaleX;
			this.scaleY = asset.scaleY;
			this.scaleZ = asset.scaleZ;
			this.rotationX = asset.rotationX;
			this.rotationY = asset.rotationY;
			this.rotationZ = asset.rotationZ;
			
			this.pivotX = asset.pivotX;
			this.pivotY = asset.pivotY;
			this.pivotZ = asset.pivotZ;
			
			if( asset.name )
			{
				this.name = asset.name;
			}
			
			var e:Array = new Array();
			for each( var extra:ExtraItemVO in asset.extras )
			{
				e.push(extra.clone());
			}
			this.extras = new ArrayCollection( e );
		}
		
	}
}
