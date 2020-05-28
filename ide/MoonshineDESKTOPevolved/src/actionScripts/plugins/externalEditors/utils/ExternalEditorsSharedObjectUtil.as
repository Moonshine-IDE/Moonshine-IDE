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
package actionScripts.plugins.externalEditors.utils
{
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
	import actionScripts.utils.ObjectTranslator;
	import actionScripts.utils.SharedObjectConst;

	public class ExternalEditorsSharedObjectUtil
	{
		public static function getExternalEditorsFromSO():ArrayCollection
		{
			var tmpCollection:ArrayCollection;
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
			var editor:ExternalEditorVO;
			
			if (cookie.data.hasOwnProperty('savedExternalEditors'))
			{
				tmpCollection = new ArrayCollection();
				for each (var item:Object in cookie.data.savedExternalEditors)
				{
					editor = ObjectTranslator.objectToInstance(item, ExternalEditorVO) as ExternalEditorVO;
					tmpCollection.addItem(editor);
				}
			}
			
			// add sorting by type
			if (tmpCollection)
			{
				tmpCollection.sort = new Sort([new SortField("title")]);
				tmpCollection.refresh();
			}
			
			return tmpCollection;
		}
		
		public static function resetExternalEditorsInSO():void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
			delete cookie.data["savedExternalEditors"];
			cookie.flush();
		}
	}
}