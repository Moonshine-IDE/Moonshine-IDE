package awaybuilder.model.vo.scene
{
	import awaybuilder.model.vo.scene.interfaces.IShared;
	
	import flash.events.IEventDispatcher;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class SharedEffectVO extends EffectVO implements IShared
	{
		
		public function SharedEffectVO( effectVO:EffectVO )
		{
			this.fillFromEffectMethod( effectVO );
			this.id = effectVO.id;
			this.linkedAsset = effectVO;
			
			IEventDispatcher( this.linkedAsset ).addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, linkedAsset_propertyChangeHandler );
		}
		
		private function linkedAsset_propertyChangeHandler( event:PropertyChangeEvent ):void
		{
			this.fillFromEffectMethod( linkedAsset as EffectVO );
		}
		
		public var linkedAsset:AssetVO;
		
	}
}