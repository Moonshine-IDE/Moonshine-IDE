package awaybuilder.controller.scene.events
{
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AnimatorVO;
	
	import flash.events.Event;

	public class AnimationEvent extends Event
	{
		
		public static const PAUSE:String = "animationPause";
		public static const PLAY:String = "animationPlay";
		public static const STOP:String = "animationStop";
		public static const SEEK:String = "animationSeek";
		
		public function AnimationEvent( type:String, animator:AnimatorVO, animation:AnimationNodeVO, value:Number=0 ) {
			super( type, false, false);
			this.value = value;
			this.animator = animator;
			this.animation = animation;
		}
		
		public var animator:AnimatorVO;
		public var animation:AnimationNodeVO;
		
		public var value:Number;
		
		override public function clone():Event
		{
			return new AnimationEvent(this.type, this.animator, this.animation, this.value );
		}
	}
}
