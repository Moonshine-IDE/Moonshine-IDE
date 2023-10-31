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
package actionScripts.languageServer
{
	import actionScripts.valueObjects.ProjectVO;
	import flash.events.IEventDispatcher;
	import actionScripts.ui.editor.BasicTextEditor;

	/**
	 * Dispatched when the language server is active.
	 * 
	 * @see #active
	 */
	[Event(name="init",type="flash.events.Event")]
	
	/**
	 * Dispatched when the language server is no longer active.
	 * 
	 * @see #active
	 */
	[Event(name="close",type="flash.events.Event")]

	public interface ILanguageServerManager extends IEventDispatcher
	{
		/**
		 * Indicates if the language server is active. If active, it will need
		 * to be closed before Moonshine can exit.
		 * 
		 * @see #event:init
		 * @see #event:close
		 */
		function get active():Boolean;

		/**
		 * The spawned process' ID. Currently implemented in Java-based language server processes only
		 */
		function get pid():int;

		/**
		 * The project associated with this language server.
		 */
		function get project():ProjectVO;

		/**
		 * The URI schemes associated with this language server.
		 */
		function get uriSchemes():Vector.<String>;

		/**
		 * The file extensions associated with this language server.
		 */
		function get fileExtensions():Vector.<String>;

		/**
		 * Creates a text editor for the specified URI.
		 */
		function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor;
	}
}