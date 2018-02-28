package awaybuilder.model.vo.scene
{
	import awaybuilder.model.vo.scene.interfaces.IShared;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class SharedLightVO extends LightVO implements IShared
	{
		
		public function SharedLightVO( light:LightVO )
		{
			this.fillFromLight( light );
			this.id = light.id;
			this.linkedAsset = light;
			IEventDispatcher( this.linkedAsset ).addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, linkedAsset_propertyChangeHandler );
		}
		
		private function linkedAsset_propertyChangeHandler( event:PropertyChangeEvent ):void
		{
			this.fillFromLight( linkedAsset as LightVO );
		}
		
		public var linkedAsset:AssetVO;
		
	}
}