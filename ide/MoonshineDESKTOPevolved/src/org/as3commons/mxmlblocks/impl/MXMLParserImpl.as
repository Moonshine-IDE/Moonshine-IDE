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

package org.as3commons.mxmlblocks.impl
{

import flash.events.IEventDispatcher;

import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTTypeBuilder;
import org.as3commons.asblocks.impl.ApplicationUnitNode;
import org.as3commons.asblocks.api.IParserInfo;
import org.as3commons.asblocks.impl.ParserInfo;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.parser.errors.UnExpectedTokenError;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.mxmlblocks.IMXMLParser;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;
import org.as3commons.mxmlblocks.parser.impl.MXMLParser;

/**
 * Implementation of the <code>IMXMLParser</code> API.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MXMLParserImpl implements IMXMLParser
{
	//--------------------------------------------------------------------------
	//
	//  IMXMLParser API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.IMXMLParser#parseAsync()
	 */
	public function parseAsync(sourceCode:ISourceCode, 
							   entry:IClassPathEntry):IParserInfo
	{
		var parserInfo:MXMLParserInfo = new MXMLParserInfo(this, sourceCode, entry);
		return parserInfo;
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.IMXMLParser#parse()
	 */
	public function parse(sourceCode:ISourceCode, 
						  entry:IClassPathEntry):ICompilationUnit
	{
		var parser:MXMLParser = ASTUtil.parseMXML(sourceCode);
		var ast:IParserNode;
		try
		{
			ast = parser.parseCompilationUnit();
		}
		catch (e:UnExpectedTokenError)
		{
			throw ASTUtil.constructSyntaxError(null, parser, e);
		}
		
		var sup:IParserNode = ast.getLastChild();
		var sname:IParserNode = sup.getKind(MXMLNodeKind.LOCAL_NAME);
		var superQualifiedName:String = sname.stringValue;
		
		var classPath:String = entry.filePath.replace(/\\/g, "/");
		var filePath:String = sourceCode.filePath.replace(/\\/g, "/");
		
		var qualifiedName:String = filePath.replace(classPath, "");
		if (qualifiedName.indexOf("/") == 0)
		{
			qualifiedName = qualifiedName.substring(1, qualifiedName.length);
		}
		qualifiedName = qualifiedName.replace(".mxml", "");
		qualifiedName = qualifiedName.split("/").join(".");
		
		var unit:ICompilationUnit = new ApplicationUnitNode(
			ASTTypeBuilder.newClassCompilationUnitAST(qualifiedName), ast);
		var pname:String = ASTTypeBuilder.packageNameFrom(qualifiedName);
		if (pname != null)
		{
			unit.packageName = pname;
		}
		unit.typeNode.name = ASTTypeBuilder.typeNameFrom(qualifiedName);
		IClassType(unit.typeNode).superClass = superQualifiedName;
		
		return unit;
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.IMXMLParser#parseString()
	 */
	public function parseString(source:String):ICompilationUnit
	{
		return parse(new SourceCode(source), null);
	}
}
}