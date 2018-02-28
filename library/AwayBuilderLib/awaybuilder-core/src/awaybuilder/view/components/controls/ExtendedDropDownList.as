package awaybuilder.view.components.controls
{
	import awaybuilder.view.components.controls.events.ExtendedDropDownEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.primitives.BitmapImage;
	import spark.utils.LabelUtil;
	
	[Event(name="addNewItem", type="awaybuilder.view.components.controls.events.ExtendedDropDownEvent")]
	
	public class ExtendedDropDownList extends DropDownList
	{
		public function ExtendedDropDownList()
		{
			super();
		}
		
		[SkinPart(required="true")]
		public var addNewButton:Button;
		
		[SkinPart(required="false")]
		public var iconDisplay:BitmapImage;
		
		private var iconChanged:Boolean;
		
		private var _newItemLabel:String = "Add New";
		
		[Inspectable(category="String", defaultValue="Add New")]
		[Bindable]
		public function get newItemLabel():String
		{
			return _newItemLabel;
		}
		public function set newItemLabel(value:String):void
		{
			if (value == _newItemLabel)
				return 
				
			_newItemLabel = value;
		}
		
		override public function set selectedItem(value:*):void
		{
			super.selectedItem = value;
			updateIconDisplay();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == addNewButton)
			{
				addNewButton.addEventListener( MouseEvent.CLICK, addNewButton_clickHandler );
			}
			if (instance == iconDisplay)
			{
				iconChanged = true;
				invalidateProperties();
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (instance == addNewButton)
			{
				addNewButton.removeEventListener( MouseEvent.CLICK, addNewButton_clickHandler );
			}
		}
		
		private function addNewButton_clickHandler( event:MouseEvent ):void
		{
			dropDownController.closeDropDown(false);
			this.dispatchEvent( new ExtendedDropDownEvent( ExtendedDropDownEvent.ADD ) );
		}
		
		override protected function dataProvider_collectionChangeHandler(event:Event):void
		{       
			super.dataProvider_collectionChangeHandler(event);
			if (event is CollectionEvent)
			{
				iconChanged = true;
				invalidateProperties();         
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (iconChanged)
			{
				iconChanged = false;
				updateIconDisplay();
			}
		}
		private function updateIconDisplay(displayItem:* = undefined):void
		{
			if (iconDisplay)
			{
				if (displayItem == undefined)
					displayItem = selectedItem;
				if (displayItem != null && displayItem != undefined)
				{
					iconDisplay.source = itemToImage(displayItem, iconField, iconFunction);
				}
				else 
				{
					iconDisplay.source = null;
				}
					
			}   
		}
		override public function set dataProvider(value:IList):void
		{   
			if (dataProvider === value)
				return;
			iconChanged = true;
			super.dataProvider = value;
		}

		private var _iconField:String = "source";
		
		[Inspectable(category="Data", defaultValue="source")]
		public function get iconField():String
		{
			return _iconField;
		}
		public function set iconField(value:String):void
		{
			if (value == _iconField)
				return 
				
			_iconField = value;
			iconChanged = true;
			invalidateProperties();
		}
		
		private var _iconFunction:Function; 
		
		[Inspectable(category="Data")]
		public function get iconFunction():Function
		{
			return _iconFunction;
		}
		
		public function set iconFunction(value:Function):void
		{
			if (value == _iconFunction)
				return 
				
			_iconFunction = value;
			iconChanged = true;
			invalidateProperties(); 
		}
		
//		override public function set selectedItem(value:*):void
//		{
//			iconChanged = true;
//			super.selectedItem = value;
//		}
		
		override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
		{
			var retVal:Boolean = super.commitSelection(dispatchChangedEvents);
			updateIconDisplay();
			return retVal; 
		}
		
		public static function itemToImage(item:Object, labelField:String=null, labelFunction:Function=null):Object
		{
			if (labelFunction != null)
				return labelFunction(item);
			
			if (item is String)
				return String(item);
			
			if (item is Object)
			{
				try
				{
					if (item[labelField] != null)
						item = item[labelField];
				}
				catch(e:Error)
				{
				}
			}
			
			if (item is String)
				return String(item);
			
			return null;
		}
	}
}