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
package actionScripts.debugAdapter.vo
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;
	import mx.collections.IHierarchicalData;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class ThreadsHierarchicalData extends EventDispatcher implements IHierarchicalData
	{
		public function ThreadsHierarchicalData()
		{
			super();
		}
		
		private var _threads:ArrayCollection = new ArrayCollection();
		private var _threadsToStackFrames:Dictionary = new Dictionary();
		
		public function removeAll():void
		{
			this._threadsToStackFrames = new Dictionary();
			this._threads.removeAll();
		}
		
		public function setThreads(threads:Array):void
		{
			this._threadsToStackFrames = new Dictionary();
			this.populateCollectionsForThreads(threads);
			this._threads.source = threads;
		}
		
		public function setStackFramesForThread(stackFrames:Array, thread:Object):void
		{
			var collection:ArrayCollection = ArrayCollection(this._threadsToStackFrames[thread]);
			collection.source = stackFrames;
		}
		
		private function populateCollectionsForThreads(threads:Array):void
		{
			var count:int = threads.length;
			for(var i:int = 0; i < count; i++)
			{
				var thread:Object = threads[i];
				var collection:ArrayCollection = this._threadsToStackFrames[thread] as ArrayCollection;
				if(!collection)
				{
					//everything starts out empty, but will be populated later
					this._threadsToStackFrames[thread] = new ArrayCollection();
				}
			}
		}
		
		public function canHaveChildren(node:Object):Boolean
		{
			return !("line" in node);
		}
		
		public function hasChildren(node:Object):Boolean
		{
			var thread:Object = !("line" in node) ? node : null;
			if(!thread)
			{
				return false;
			}
			return ArrayCollection(this._threadsToStackFrames[thread]).length > 0;
		}
		
		public function getChildren(node:Object):Object
		{
			var thread:Object = !("line" in node) ? node : null;
			if(!thread)
			{
				return null;
			}
			return this._threadsToStackFrames[thread];
		}
		
		public function getData(node:Object):Object
		{
			return node;
		}
		
		public function getRoot():Object
		{
			return this._threads;
		}
	}
}
