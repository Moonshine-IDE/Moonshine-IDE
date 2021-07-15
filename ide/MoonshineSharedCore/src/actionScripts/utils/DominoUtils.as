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
package actionScripts.utils
{
    import mx.core.UIComponent;
    
    public class DominoUtils
	{
        public static function getDominoParentContent(title:String,windowsTitle:String):XML
		{	   
			return getDominoMainContainer(title,windowsTitle);	
		}

        private static function getDominoMainContainer(title:String,windowsTitle:String):XML
		{
				var dat:Date = new Date();
				var xml_str:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
				xml_str=xml_str+"<note class='form' xmlns='http://www.lotus.com/dxl' version='9.0' maintenanceversion='1.4' replicaid='4825808B00336E81'>";
				xml_str=xml_str+"<!DOCTYPE note>";
				// xml_str=xml_str+"<noteinfo noteid='2116' unid='27C118EDE31483CB86256C6900644875' sequence='8'>";
				// xml_str=xml_str+"<created><datetime>"+dat+"</datetime></created> ";
				// xml_str=xml_str+"<modified><datetime>"+dat+"</datetime></modified> ";
				// xml_str=xml_str+"<revised dst=\"true\"><datetime>"+dat+"</datetime></revised>";
				// xml_str=xml_str+"<lastaccessed><datetime>"+dat+"</datetime></lastaccessed>";
				// xml_str=xml_str+"<lastaccessed><datetime>"+dat+"</datetime></lastaccessed>";
				// xml_str=xml_str+"<addedtofile><datetime>"+dat+"</datetime></addedtofile>";
				// xml_str=xml_str+"</noteinfo>"
				if(windowsTitle!=null  && windowsTitle!=""){
					xml_str=xml_str+"<item name='$WindowTitle' sign='true'><formula>"+windowsTitle+"</formula></item>"
				}
				xml_str=xml_str+"<item name='$Info' sign='true'><rawitemdata type='1'>hhgBAIAAAAAAgAAAAQABAP///wAQAAAA</rawitemdata></item>"
				xml_str=xml_str+"<item name='$Flags'><text/></item>"
				xml_str=xml_str+"<item name='$TITLE'><text>"+title+"</text></item>"
				xml_str=xml_str+"<item name='$Fields'><textlist></textlist></item>"
				xml_str=xml_str+"<item name='$Body' sign='true'> <richtext style='width:700px;height:700px;' class='flexHorizontalLayout flexHorizontalLayoutLeft flexHorizontalLayoutTop' direction='Horizontal' vdirection='Vertical'/></item>"
				
				xml_str=xml_str+"</note>";
			



				var xml:XML = new XML(xml_str);
				
			
			

			return xml;
		}

    }
}