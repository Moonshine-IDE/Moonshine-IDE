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

package org.as3commons.mxmlblocks.parser.api
{

/**
 * The <strong>MXMLNodeKind</strong> enumeration of <strong>.mxml</strong> 
 * node kinds.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MXMLNodeKind
{
	public static const ATT:String = "att";
	
	public static const BODY:String = "body";
	
	public static const AS_DOC:String = "as-doc";
	
	public static const BINDING:String = "binding";
	
	public static const CDATA:String = "cdata";
	
	public static const COMPILATION_UNIT:String = "compilation-unit";
	
	public static const LOCAL_NAME:String = "local-name";
	
	public static const NAME:String = "name";
	
	public static const PROC_INST:String = "proc-inst";
	
	public static const STATE:String = "state";
	
	public static const TAG_LIST:String = "tag-list";
	
	public static const ATT_LIST:String = "att-list";
	
	public static const URI:String = "uri";
	
	public static const VALUE:String = "value";
	
	public static const XML_NS:String = "xml-ns";
}
}