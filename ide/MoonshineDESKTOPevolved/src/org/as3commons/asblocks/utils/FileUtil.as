////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.utils
{

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.Capabilities;
import flash.utils.getDefinitionByName;

import org.as3commons.asblocks.api.ICompilationUnit;

/**
 * A utility class for dealing with files and their data.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class FileUtil
{
	/**
	 * The OS file separator.
	 */
	public static var separator:String = "/";
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Reads a File from the filesystem and returns the data as a String Vector.
	 * 
	 * <p><strong>Note:</strong> The method will replace all <strong>\r\n</strong> 
	 * characters with <strong>'\n'</strong> before it splits the data into lines.</p>
	 * 
	 * @param filePath A String indicating the path to the File to open and read.
	 * @return A String Vector of file lines split by the <strong>\n</strong> character.
	 * @throws Error Definition flash.filesystem.File not found, import AIR library
	 * @throws Error File does not exist
	 */
	public static function readLines(filePath:String):Vector.<String>
	{
		var data:String;
		
		try
		{
			data = readFile(filePath);
		}
		catch (e:Error)
		{
			throw e;
		}
		
		data = data.replace(/\r\n/g, "\n");
		
		return Vector.<String>(data.split("\n"));
	}
	
	public static function readFile(filePath:String):String
	{
		var fileClass:Class = getDefinitionByName("flash.filesystem.File") as Class;
		var fileStreamClass:Class = getDefinitionByName("flash.filesystem.FileStream") as Class;
		
		if (!fileClass)
		{
			throw new Error("Definition flash.filesystem.File not found, import AIR library");
		}
		
		var file:Object = new fileClass(filePath);
		if (!file.exists)
		{
			throw new Error("'" + filePath + "' does not exist");
		}
		
		var stream:Object = new fileStreamClass();
		stream.open(file, "read");
		
		var data:String = stream.readUTFBytes(stream.bytesAvailable);
		
		return data;
	}
	
	public static function normalizePath(path:String):String
	{
		if (path.indexOf("\\") != -1)
		{
			path = path.replace(/\\/g, "/");
		}
		return path;
	}
	
	public static function fileNameFor(unit:ICompilationUnit):String
	{
		var name:String;
		var packageName:String = unit.packageName;
		var typeName:String = unit.typeNode.name;
		if (packageName == null || packageName == "")
		{
			name = typeName;
		}
		else
		{
			name = packageName + "." + typeName;
		}
		return name.replace(/\./g, separator) + ".as";
	}
	
	public static function get isDesktop():Boolean
	{
		return Capabilities.playerType == "Desktop";
	}
	
	public static function createFile(file:File, forceIsDirectory:Boolean=false):void
	{
		if (!file.parent.exists)
		{
			FileUtil.createFile(file.parent, true);
		}
		
		if (!file.exists)
		{
			if (file.isDirectory || forceIsDirectory)
			{
				file.createDirectory();
			}
			else
			{
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeUTF("");
				fs.close();
			}
		}
	}
	
	public static function contains(dir:File, file:File):Boolean
	{
		if (file.nativePath.indexOf(dir.nativePath) == 0) return true;
		return false;
	}
}
}