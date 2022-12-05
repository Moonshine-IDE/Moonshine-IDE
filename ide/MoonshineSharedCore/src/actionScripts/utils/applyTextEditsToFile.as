////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import actionScripts.factory.FileLocation;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.changes.TextEditorChange;
	import moonshine.editor.text.utils.LspTextEditorUtil;
	import moonshine.editor.text.utils.TextEditorUtil;
	import moonshine.lsp.TextEdit;

	public function applyTextEditsToFile(file:FileLocation, textEdits:Array /* Array<TextEdit> */):void
	{
		var textEditor:TextEditor = findOpenTextEditor(file);
		if(textEditor !== null)
		{
			applyTextEditsToTextEditor(textEditor, textEdits);
			return;
		}

		var content:String = file.fileBridge.read() as String;
		var contentLines:Array = content.split("\n");
		
		var changes:Array = textEdits.map(function(textEdit:TextEdit, index:int, array:Array):TextEditorChange
		{
			return LspTextEditorUtil.lspTextEditToTextEditorChange(textEdit);
		});
		changes.forEach(function(textEditorChange:TextEditorChange, index:int, array:Array):void
		{
			contentLines = TextEditorUtil.applyTextChangeToLines(contentLines, textEditorChange);
		});

		content = contentLines.join("\n");

		file.fileBridge.save(content);
	}
}
