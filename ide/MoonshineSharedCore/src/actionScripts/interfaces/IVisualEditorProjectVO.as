////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.interfaces
{
	import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;

    public interface IVisualEditorProjectVO
    {
		function get isVisualEditorProject():Boolean;
		function set isVisualEditorProject(value:Boolean):void;
		function get isPrimeFacesVisualEditorProject():Boolean;
		function set isPrimeFacesVisualEditorProject(value:Boolean):void;
		function get isPreviewRunning():Boolean;
		function set isPreviewRunning(value:Boolean):void;
		function get visualEditorSourceFolder():FileLocation;
		function set visualEditorSourceFolder(value:FileLocation):void;
		
		// all acceptable files list those can be opened in 
		// Moonshine editor (mainly generates for VisualEditor project)
		function get filesList():ArrayCollection;
		function set filesList(value:ArrayCollection):void;
    }
}
