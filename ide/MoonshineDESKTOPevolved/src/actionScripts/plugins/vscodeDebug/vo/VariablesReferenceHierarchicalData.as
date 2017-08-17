////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.vscodeDebug.vo
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;
	import mx.collections.IHierarchicalData;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class VariablesReferenceHierarchicalData extends EventDispatcher implements IHierarchicalData
	{
		public function VariablesReferenceHierarchicalData()
		{
			super();
		}
		
		private var _scopes:ArrayCollection = new ArrayCollection();
		private var _variablesReferenceToVariables:Dictionary = new Dictionary();
		
		public function removeAll():void
		{
			this._variablesReferenceToVariables = new Dictionary();
			this._scopes.removeAll();
		}
		
		public function setScopes(scopes:Array):void
		{
			this._variablesReferenceToVariables = new Dictionary();
			this.populateCollectionsForParentReferences(scopes);
			this._scopes.source = scopes;
		}
		
		public function setVariablesForScopeOrVar(variables:Array, parentScopeOrVar:BaseVariablesReference):void
		{
			this.populateCollectionsForParentReferences(variables);
			var collection:ArrayCollection = ArrayCollection(this._variablesReferenceToVariables[parentScopeOrVar]);
			collection.source = variables;
			
			//for some reason, this is necessary or the tree won't update. -JT
			collection.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REFRESH));
		}
		
		private function populateCollectionsForParentReferences(references:Array):void
		{
			var count:int = references.length;
			for(var i:int = 0; i < count; i++)
			{
				var scopeOrVar:BaseVariablesReference = BaseVariablesReference(references[i]);
				var variablesReference:Number = scopeOrVar.variablesReference;
				if(variablesReference !== -1)
				{
					var collection:ArrayCollection = this._variablesReferenceToVariables[scopeOrVar] as ArrayCollection;
					if(!collection)
					{
						//everything starts out empty, but will be populated later
						this._variablesReferenceToVariables[scopeOrVar] = new ArrayCollection();
					}
				}
			}
		}
		
		public function canHaveChildren(node:Object):Boolean
		{
			return node is BaseVariablesReference && BaseVariablesReference(node).variablesReference !== -1;
		}
		
		public function hasChildren(node:Object):Boolean
		{
			return this.canHaveChildren(node);
		}
		
		public function getChildren(node:Object):Object
		{
			var branch:BaseVariablesReference = node as BaseVariablesReference;
			if(!branch)
			{
				return null;
			}
			return this._variablesReferenceToVariables[branch];
		}
		
		public function getData(node:Object):Object
		{
			return node;
		}
		
		public function getRoot():Object
		{
			return this._scopes;
		}
	}
}
