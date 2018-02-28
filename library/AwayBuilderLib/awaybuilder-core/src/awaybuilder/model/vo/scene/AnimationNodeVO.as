package awaybuilder.model.vo.scene
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class AnimationNodeVO extends AssetVO
	{
		public var type:String;
		
		public var totalDuration:Number = 0;
		
		public var currentPosition:Number = 0;
		
		public var isPlaying:Boolean;
		
		// this will contain a list of SkeletonPosesVO for SkeletonAnimations
		// or a List of Geometry for VertexAnimations
		public var animationPoses:ArrayCollection = new ArrayCollection();
		public var frameDurations:ArrayCollection = new ArrayCollection();
				
		public function clone():AnimationNodeVO
		{
			var vo:AnimationNodeVO = new AnimationNodeVO();
			vo.fillFromAnimationNode( this );
			return vo;
		}
		
		public function fillFromAnimationNode( asset:AnimationNodeVO ):void
		{
			this.name = asset.name;
			this.totalDuration = asset.totalDuration;
			this.animationPoses = new ArrayCollection( asset.animationPoses.source.concat() );
			this.frameDurations = new ArrayCollection( asset.frameDurations.source.concat() );
			this.id = asset.id;
			this.type = asset.type;
		}
	}
}
