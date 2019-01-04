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
package actionScripts.utils
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.TextDocumentEdit;
	import actionScripts.valueObjects.TextEdit;
	import actionScripts.valueObjects.WorkspaceEdit;
	import actionScripts.valueObjects.RenameFile;
	import actionScripts.valueObjects.CreateFile;
	import actionScripts.valueObjects.DeleteFile;
	import actionScripts.locator.IDEModel;
	import mx.collections.ArrayCollection;

	public function applyWorkspaceEdit(edit:WorkspaceEdit):void
	{
		var changes:Object = edit.changes;
		if(changes)
		{
			for(var uri:String in changes)
			{
				var textEdits:Vector.<TextEdit> = changes[uri] as Vector.<TextEdit>;
				applyTextEditsToURI(uri, textEdits);
			}
		}
		var documentChanges:Array = edit.documentChanges;
		if(documentChanges)
		{
			var documentChangesCount:int = documentChanges.length;
			for(var i:int = 0; i < documentChangesCount; i++)
			{
				var documentChange:Object = documentChanges[i];
				if(documentChange is TextDocumentEdit)
				{
					var textDocumentEdit:TextDocumentEdit = TextDocumentEdit(documentChange);
					applyTextEditsToURI(
						textDocumentEdit.textDocument.uri,
						textDocumentEdit.edits);
				}
				else if("kind" in documentChange)
				{
					switch(documentChange.kind)
					{
						case RenameFile.KIND:
						{
							var renameFile:RenameFile = RenameFile(documentChange);
							handleRenameFile(renameFile);
							break;
						}
						case CreateFile.KIND:
						{
							var createFile:CreateFile = CreateFile(documentChange);
							handleCreateFile(createFile);
							break;
						}
						case DeleteFile.KIND:
						{
							var deleteFile:DeleteFile = DeleteFile(documentChange);
							handleDeleteFile(deleteFile);
							break;
						}
						default:
						{
							trace("applyWorkspaceEdit: Unknown document change kind " + documentChange.kind);
						}
					}
				}
				else
				{
					trace("applyWorkspaceEdit: Unknown document change " + documentChange);
				}
			}
		}
	}
}

import mx.collections.ArrayCollection;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.LanguageServerEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.utils.applyTextEditsToFile;
import actionScripts.valueObjects.CreateFile;
import actionScripts.valueObjects.DeleteFile;
import actionScripts.valueObjects.RenameFile;
import actionScripts.valueObjects.TextEdit;

function applyTextEditsToURI(uri:String, textEdits:Vector.<TextEdit>):void
{
	var file:FileLocation = new FileLocation(uri, true);
	applyTextEditsToFile(file, textEdits);
}

function handleRenameFile(renameFile:RenameFile):void
{
	var renameOldLocation:FileLocation = new FileLocation(renameFile.oldUri, true);
	var renameNewLocation:FileLocation = new FileLocation(renameFile.newUri, true);
	renameOldLocation.fileBridge.moveTo(renameNewLocation, true);

	var editors:ArrayCollection = IDEModel.getInstance().editors;
	var editorCount:int = editors.length;
	for(var i:int = 0; i < editorCount; i++)
	{
		var editor:LanguageServerTextEditor = editors.getItemAt(i) as LanguageServerTextEditor;
		if(!editor)
		{
			continue;
		}
		var editorFile:FileLocation = editor.currentFile;
		if(!editorFile || editorFile.fileBridge.nativePath !== renameOldLocation.fileBridge.nativePath)
		{
			continue;
		}
		editor.currentFile = renameNewLocation;
		GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDCLOSE,
			0, 0, 0, 0, null, 0, 0, renameOldLocation.fileBridge.url));
		GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
			0, 0, 0, 0, editor.getEditorComponent().dataProvider, 0, 0, renameNewLocation.fileBridge.url));
	}
}

function handleCreateFile(createFile:CreateFile):void
{
	var createLocation:FileLocation = new FileLocation(createFile.uri, true);
	createLocation.fileBridge.createFile();
}

function handleDeleteFile(deleteFile:DeleteFile):void
{
	var deleteLocation:FileLocation = new FileLocation(deleteFile.uri, true);
	if(deleteLocation.fileBridge.exists)
	{
		if(deleteLocation.fileBridge.isDirectory)
		{
			deleteLocation.fileBridge.deleteDirectory(true);
		}
		else
		{
			deleteLocation.fileBridge.deleteFile();
		}
	}
}