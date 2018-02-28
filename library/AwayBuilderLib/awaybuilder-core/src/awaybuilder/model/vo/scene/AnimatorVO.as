package awaybuilder.model.vo.scene
{
	
	[Bindable]
	public class AnimatorVO extends AssetVO
	{

		public var type:String;
		
		public var playbackSpeed:Number = 1;
		
		public var animationSet:AnimationSetVO;
		
		public var skeleton:SkeletonVO;
		
		[Transient]
		public var activeAnimationNode:AnimationNodeVO;
		
		public function clone():AnimatorVO
		{
			var vo:AnimatorVO = new AnimatorVO();
			vo.fillFromAnimator( this );
			return vo;
		}
		
		public function fillFromAnimator( asset:AnimatorVO ):void
		{
			this.name = asset.name;
			this.animationSet = asset.animationSet;
			this.skeleton = asset.skeleton;
			this.playbackSpeed = asset.playbackSpeed;
			this.type = asset.type;
		}
	}
}
