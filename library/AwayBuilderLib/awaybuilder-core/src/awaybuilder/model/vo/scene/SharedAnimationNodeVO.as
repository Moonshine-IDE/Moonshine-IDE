package awaybuilder.model.vo.scene
{
	import awaybuilder.model.vo.scene.interfaces.IShared;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class SharedAnimationNodeVO extends AnimationNodeVO implements IShared
	{
		
		public function SharedAnimationNodeVO( animationNodeVO:AnimationNodeVO )
		{
			this.fillFromAnimationNode( animationNodeVO );
			this.id = animationNodeVO.id;
			this.linkedAsset = animationNodeVO;
			IEventDispatcher( this.linkedAsset ).addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, linkedAsset_propertyChangeHandler );
		}
		
		private function linkedAsset_propertyChangeHandler( event:PropertyChangeEvent ):void
		{
			this.fillFromAnimationNode( linkedAsset as AnimationNodeVO );
		}
		
		public var linkedAsset:AssetVO;
		
	}
}