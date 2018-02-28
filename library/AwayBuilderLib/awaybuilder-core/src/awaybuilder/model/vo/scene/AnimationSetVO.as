package awaybuilder.model.vo.scene
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class AnimationSetVO extends AssetVO
	{
		
		public var type:String;
		
		public var animations:ArrayCollection = new ArrayCollection(); //SharedAnimationNodeVO
		
		public var animators:ArrayCollection = new ArrayCollection();
		
		public function clone():AnimationSetVO
		{
			var vo:AnimationSetVO = new AnimationSetVO();
			vo.fillFromAnimationSet( this );
			return vo;
		}
		
		public function fillFromAnimationSet( asset:AnimationSetVO ):void
		{
			this.name = asset.name;
			this.type = asset.type;
			this.animations = new ArrayCollection( asset.animations.source.concat() );
			this.animators = new ArrayCollection( asset.animators.source.concat() );
		}
	}
}
