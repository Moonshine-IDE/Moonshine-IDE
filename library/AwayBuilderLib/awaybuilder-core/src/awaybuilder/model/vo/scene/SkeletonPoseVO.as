package awaybuilder.model.vo.scene
{
	import flash.geom.Matrix3D;
	
	import mx.collections.ArrayCollection;

	public class SkeletonPoseVO extends AssetVO
	{
		public var jointTransforms:ArrayCollection = new ArrayCollection();
				
		public function clone():SkeletonPoseVO
		{
			var vo:SkeletonPoseVO = new SkeletonPoseVO();
			vo.fillFromSkeletonPose( this );
			return vo;
		}
		
		public function fillFromSkeletonPose( asset:SkeletonPoseVO ):void
		{
			this.name = asset.name;
			this.jointTransforms = new ArrayCollection( asset.jointTransforms.source.concat() );
		}
	}
}
