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
package actionScripts.valueObjects
{
	/**
	 * Implementation of WorkspaceEdit interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#workspaceedit
	 */
	public class WorkspaceEdit
	{
		/**
		 * Holds changes to existing resources.
		 * 
		 * <p>The object key is the URI, and the value is an Array of TextEdit
		 * instnaces.</p>
		 */
		public var changes:Object;
		
		/**
		 * An array of TextDocumentEdits to express changes to n different
		 * text documents where each text document edit addresses a specific
		 * version of a text document. Or it can contain above TextDocumentEdits
		 * mixed with create, rename and delete file / folder operations.
		 */
		public var documentChanges:Array;

		public function WorkspaceEdit()
		{
			
		}

		public static function parse(original:Object):WorkspaceEdit
		{
			var workspaceEdit:WorkspaceEdit = new WorkspaceEdit;
			var jsonChanges:Object = original.changes;
			if(jsonChanges)
			{
				var changes:Object = {};
				for(var uri:String in jsonChanges)
				{
					//the key is the file path, the value is a list of TextEdits
					var resultChanges:Array = jsonChanges[uri];
					var resultChangesCount:int = resultChanges.length;
					var textEdits:Vector.<TextEdit> = new <TextEdit>[];
					for(var i:int = 0; i < resultChangesCount; i++)
					{
						var resultChange:Object = resultChanges[i];
						var textEdit:TextEdit = TextEdit.parse(resultChange);
						textEdits[i] = textEdit;
					}
					changes[uri] = textEdits;
				}
				workspaceEdit.changes = changes;
			}
			var jsonDocumentChanges:Array = original.documentChanges;
			if(jsonDocumentChanges)
			{
				var documentChanges:Array = [];
				var changesCount:int = jsonDocumentChanges.length;
				for(i = 0; i < changesCount; i++)
				{
					var documentChange:Object = jsonDocumentChanges[i];
					if("kind" in documentChange)
					{
						switch(documentChange.kind)
						{
							case RenameFile.KIND:
							{
								var renameFile:RenameFile = RenameFile.parse(documentChange);
								documentChanges.push(renameFile);
								break;
							}
							case CreateFile.KIND:
							{
								var createFile:CreateFile = CreateFile.parse(documentChange);
								documentChanges.push(createFile);
								break;
							}
							case DeleteFile.KIND:
							{
								var deleteFile:DeleteFile = DeleteFile.parse(documentChange);
								documentChanges.push(deleteFile);
								break;
							}
							default:
							{
								trace("parseWorkspaceEdit: Unknown document change:", documentChange.kind);
							}
						}
					}
					else
					{
						var textDocumentEdit:TextDocumentEdit = TextDocumentEdit.parse(documentChange);
						documentChanges.push(textDocumentEdit);
					}
				}
				workspaceEdit.documentChanges = documentChanges;
			}
			return workspaceEdit;
		}
	}
}