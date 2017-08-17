////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
//
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	
	public class DataDescriptorForCustomTree extends DefaultDataDescriptor
	{
		/**
		 * CONSTRUCTOR
		 */
		public function DataDescriptorForCustomTree()
		{
			super();
		}
		
		/**
		 * Overriding childrens to return only items
		 * a folder/branch node
		 */
		override public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			var temp:ArrayCollection = super.getChildren(node, model) as ArrayCollection;
			var modifTemp:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < temp.length; i++)
			{
				if (temp[i].children != null)
				{
					modifTemp.addItem(temp[i]);
				}
			}
			
			// send filtered collection
			return modifTemp;
		}
	}
}