package awaybuilder.view.components.controls.tree
{
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.utils.DataMerger;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.treeClasses.ITreeDataDescriptor;

	public class GenericDataDescriptor implements ITreeDataDescriptor
	{
		
		protected var ChildCollectionCache:Dictionary = new Dictionary(true);
		
		public function getChildren(node:Object, model:Object = null):ICollectionView
		{
			if (node == null)
				return null;
			
			switch(true)
			{
				case( node is ContainerVO ):
					return ContainerVO( node ).children;
				case( node is MaterialVO ):
					return MaterialVO( node ).effectMethods;
				case( node is LightPickerVO ):
					return LightPickerVO( node ).lights;
				case( node is LightVO ):
					return LightVO( node ).shadowMethods;
				case( node is AnimationSetVO ):
					var children:ArrayCollection = ChildCollectionCache[node];
					if( !children )
					{
						children = new ArrayCollection();
						ChildCollectionCache[node] = children;
					}
					var newChildren:ArrayCollection = new ArrayCollection();
					newChildren.addAll(AnimationSetVO( node ).animators);
					newChildren.addAll(AnimationSetVO( node ).animations);
					return DataMerger.syncArrays( children, newChildren, "id" );
			}
			return null;
		}
		
		public function hasChildren(node:Object, model:Object = null):Boolean
		{
			if (node == null) 
				return false;
			
			//This default impl can't optimize this call to getChildren
			//since we can't make any assumptions by type.  Custom impl's
			//can probably avoid this call and reduce the number of calls to 
			//getChildren if need be. 
			var children:ICollectionView = getChildren(node, model);
			try 
			{
				if (children.length > 0)
					return true;
			}
			catch(e:Error)
			{
			}
			return false;
		}
		
		public function isBranch(node:Object, model:Object = null):Boolean
		{
			if (node == null)
				return false;
			
			var branch:Boolean = false;
			
			if (node is XML)
			{
				var childList:XMLList = node.children();
				//accessing non-required e4x attributes is quirky
				//but we know we'll at least get an XMLList
				var branchFlag:XMLList = node.@isBranch;
				//check to see if a flag has been set
				if (branchFlag.length() == 1)
				{
					//check flag and return (this flag overrides termination status)
					if (branchFlag[0] == "true")
						branch = true;
				}
					//since no flags, we'll check to see if there are children
				else if (childList.length() != 0)
				{
					branch = true;
				}
			}
			else if (node is Object)
			{
				try
				{
					if (node.children != undefined)
					{
						branch = true;
					}
				}
				catch(e:Error)
				{
				}
			}
			return branch;
		}
		
		public function getData(node:Object, model:Object = null):Object
		{
			return Object(node);
		}
		
		public function addChildAt(parent:Object, newChild:Object, index:int, model:Object = null):Boolean
		{
			if (!parent)
			{
				try
				{
					if (index > model.length)
						index = model.length;
					if (model is IList)
						IList(model).addItemAt(newChild, index);
					else
					{
						var cursor:IViewCursor = model.createCursor();
						cursor.seek(CursorBookmark.FIRST, index);
						cursor.insert(newChild);
					}
					
					return true;
				}
				catch(e:Error)
				{
				}
			}
			else 
			{
				var children:ICollectionView = ICollectionView(getChildren(parent, model));
				if (!children)
				{
					if (parent is XML)
					{
						var temp:XMLList = new XMLList();
						XML(parent).appendChild(temp);
						children = new XMLListCollection(parent.children());
					}
					else if (parent is Object)
					{
						parent.children = new ArrayCollection();
						children = parent.children;
					}
				}
				try
				{
					if (index > children.length)
						index = children.length;
					if (children is IList)
						IList(children).addItemAt(newChild, index);
					else
					{
						cursor = children.createCursor();
						cursor.seek(CursorBookmark.FIRST, index);
						cursor.insert(newChild);
					}
					return true;
				}
				catch(e:Error)
				{
				}
			}
			return false;
		}
		
		public function removeChildAt(parent:Object, child:Object, index:int, model:Object = null):Boolean
		{
			//handle top level where there is no parent
			if (!parent)
			{
				try
				{
					if (index > model.length)
						index = model.length;
					if (model is IList)
						model.removeItemAt(index);
					else
					{
						var cursor:IViewCursor = model.createCursor();
						cursor.seek(CursorBookmark.FIRST, index);
						cursor.remove();
					}
					
					return true;
				}
				catch(e:Error)
				{
				}
			}
			else
			{
				var children:ICollectionView = ICollectionView(getChildren(parent, model));
				try
				{
					if (index > children.length)
						index = children.length;
					if (children is IList)
						IList(children).removeItemAt(index);
					else
					{
						cursor = children.createCursor();
						cursor.seek(CursorBookmark.FIRST, index);
						cursor.remove();
					}
					
					return true;
				}
				catch(e:Error)
				{
				}
			}
			return false;
		}
	}
	
}
