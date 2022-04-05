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
	import moonshine.lsp.TextDocumentEdit;
	import moonshine.lsp.WorkspaceEdit;
	import moonshine.lsp.RenameFile;
	import moonshine.lsp.CreateFile;
	import moonshine.lsp.DeleteFile;
	import haxe.IMap;
	import haxe.lang.Iterator;

	public function applyWorkspaceEdit(edit:WorkspaceEdit):void
	{
		var changes:IMap = edit.changes;
		if(changes)
		{
			var iterator:Object = changes.keys();
			while(iterator.hasNext())
			{
				var uri:String = iterator.next();
				var textEdits:Array = changes.get(uri) as Array;
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
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.utils.applyTextEditsToFile;
import moonshine.lsp.CreateFile;
import moonshine.lsp.DeleteFile;
import moonshine.lsp.RenameFile;
import moonshine.lsp.TextEdit;
import actionScripts.events.RefreshTreeEvent;

function applyTextEditsToURI(uri:String, textEdits:Array /* Array<TextEdit> */):void
{
	var file:FileLocation = new FileLocation(uri, true);
	applyTextEditsToFile(file, textEdits);
}

function handleRenameFile(renameFile:RenameFile):void
{
	var renameOldLocation:FileLocation = new FileLocation(renameFile.oldUri, true);
	var renameNewLocation:FileLocation = new FileLocation(renameFile.newUri, true);
	try
	{
		renameOldLocation.fileBridge.moveTo(renameNewLocation, true);
	}
	catch(error:Error)
	{
		trace("rename failed:", error)
	}
	GlobalEventDispatcher.getInstance().dispatchEvent(new RefreshTreeEvent(renameNewLocation.fileBridge.parent));

	var editors:ArrayCollection = IDEModel.getInstance().editors;
	var editorCount:int = editors.length;
	for(var i:int = 0; i < editorCount; i++)
	{
		var lspEditor:LanguageServerTextEditor = editors.getItemAt(i) as LanguageServerTextEditor;
		if(!lspEditor)
		{
			continue;
		}
		var editorFile:FileLocation = lspEditor.currentFile;
		if(!editorFile || editorFile.fileBridge.nativePath !== renameOldLocation.fileBridge.nativePath)
		{
			continue;
		}
		lspEditor.currentFile = renameNewLocation;
	}
}

function handleCreateFile(createFile:CreateFile):void
{
	var createLocation:FileLocation = new FileLocation(createFile.uri, true);
	createLocation.fileBridge.createFile();
	GlobalEventDispatcher.getInstance().dispatchEvent(new RefreshTreeEvent(createLocation.fileBridge.parent));
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
		GlobalEventDispatcher.getInstance().dispatchEvent(new RefreshTreeEvent(deleteLocation.fileBridge.parent));
	}
}