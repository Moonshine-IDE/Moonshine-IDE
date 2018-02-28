package awaybuilder.model.vo.scene
{

    import away3d.core.base.SubMesh;
    import away3d.entities.Mesh;
    import away3d.materials.MaterialBase;
    
    import awaybuilder.utils.AssetUtil;
    
    import mx.collections.ArrayCollection;

	[Bindable]
    public class MeshVO extends ContainerVO
    {
			
        public var castsShadows:Boolean;

        public var subMeshes:ArrayCollection;
		
		public var geometry:GeometryVO;
		
		public var animator:AnimatorVO;
		
		[Transient]
		public var jointsPerVertex:uint = 0;
		
		override public function clone():ObjectVO
        {
			var m:MeshVO = new MeshVO();
			m.fillFromMesh( this );
            return m;
        }
		
		public function fillFromMesh( asset:MeshVO ):void
		{
			this.fillFromContainer( asset );
			this.subMeshes = asset.subMeshes;
			this.castsShadows = asset.castsShadows;
			this.animator = asset.animator;
			this.geometry = asset.geometry;
		}
		
		
    }
}
