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
package org.apache.flex.packageflexsdk.interfaces
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import org.apache.flex.packageflexsdk.resource.ViewResourceConstants;

	public interface IMoonshineAppStoreHelper
	{
		function get flexVersionSelected():Object;
		function get flexJSVersionSelected():Object;
		function get airVersionSelected():Object;
		function get flashPlayerVersionSelected():Object;
		function get viewResourceConstants():ViewResourceConstants;
		function set moonshineAIRversion(value:String):void;
		function set moonshineFlexVersion(value:String):void;
		function set moonshineFlexJSVersion(value:String):void;
		function set progress(value:Number):void;
		function setFlexPath(value:String):void;
		function getFlexPath():File;
		function startInstallation():void;
		function showConsole(event:Event):void;
		function writeFileToDirectoryMASH(file:File, data:ByteArray):void;
		function copyOrDownloadMASH(url:String, handlerFunction:Function, dest:File = null, errorFunction:Function = null, nocache:Boolean = false):void;
		function downloadMASH(url:String, handlerFunction:Function, errorFunction:Function = null, nocache:Boolean = false):void;
		function unzipMASH(fileToUnzip:File, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void;
		function untarMASH(source:File, destination:File, unTarCompleteFunction:Function, unTarErrorFunction:Function):void;
		function logMASH(text:String, position:int = -1, isPublic:Boolean = true, skipLog:Boolean = false):void;
		function abortInstallationMASH(reason:String = ""):void;
		function updateActivityStepMASH(stepLabel:String, status:String):void;
	}
}