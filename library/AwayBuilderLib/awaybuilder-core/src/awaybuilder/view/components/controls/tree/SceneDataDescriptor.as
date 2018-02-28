package awaybuilder.view.components.controls.tree
{
	import away3d.tools.commands.Merge;
	
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.utils.DataMerger;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class SceneDataDescriptor extends GenericDataDescriptor
	{
		
		override public function getChildren(node:Object, model:Object = null):ICollectionView
		{
			if (node == null)
				return null;
			
			switch(true)
			{
				case( node is ContainerVO ):
					return ContainerVO( node ).children;
				case( node is LightPickerVO ):
					return LightPickerVO( node ).lights;
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
		
	}
	
}
