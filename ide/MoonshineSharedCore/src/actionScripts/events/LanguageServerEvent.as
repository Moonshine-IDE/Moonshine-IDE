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
package actionScripts.events
{
	import flash.events.Event;
	import actionScripts.valueObjects.ProjectVO;
	
	public class LanguageServerEvent extends Event
	{
		public static const EVENT_DIDOPEN:String = "newDidOpenEvent";
		public static const EVENT_DIDCLOSE:String = "newDidCloseEvent";
		public static const EVENT_DIDCHANGE:String = "newDidChangeEvent";
		public static const EVENT_WILLSAVE:String = "newWillSaveEvent";
		public static const EVENT_DIDSAVE:String = "newDidSaveEvent";
		public static const EVENT_COMPLETION:String = "newCompletionEvent";
		public static const EVENT_SIGNATURE_HELP:String = "newSignatureHelpEvent";
		public static const EVENT_HOVER:String = "newHover";
		public static const EVENT_DEFINITION_LINK:String = "newDefinitionLink";
		public static const EVENT_DOCUMENT_SYMBOLS:String = "newDocumentSymbols";
		public static const EVENT_WORKSPACE_SYMBOLS:String = "newWorkspaceSymbols";
		public static const EVENT_GO_TO_REFERENCES:String = "newGoToReferences";
		public static const EVENT_RENAME:String = "newRename";
		public static const EVENT_CODE_ACTION:String = "newCodeAction";
		public static const EVENT_GO_TO_DEFINITION:String = "newGoToDefinition";
		public static const EVENT_GO_TO_TYPE_DEFINITION:String = "newGoToTypeDefinition";
		public static const EVENT_GO_TO_IMPLEMENTATION:String = "newGoToImplementation";
		
		public var startLinePos:Number;
		public var endLinePos:Number;
		public var startLineNumber:Number;
		public var endLineNumber:Number;
		public var newText:String;
		public var textlen:Number;
		public var version:Number;
		public var uri:String;
		public var project:ProjectVO;
		
		public function LanguageServerEvent(type:String, uri:String = null,
			startLinePos:Number = 0,startLineNumber:Number = 0,
			endLinePos:Number = 0, endLineNumber:Number = 0,
			newText:String = null, version:Number=0, project:ProjectVO = null)
		{
			this.startLinePos = startLinePos;
			this.endLinePos = endLinePos;
			this.startLineNumber = startLineNumber;
			this.endLineNumber = endLineNumber;
			this.newText = newText;
			this.version = version;
			this.uri = uri;
			this.project = project;
			super(type, false, true);
		}
		
	}
}