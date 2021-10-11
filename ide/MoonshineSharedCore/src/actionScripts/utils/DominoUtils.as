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
	import mx.controls.Alert;
	import com.adobe.utils.StringUtil;
    
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

		public static function getXslFormatForRun(xml:String):String
		{
			xml=xml+"<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">\n";
			xml=xml+"<xsl:template match=\"@*|node()\">\n";
			xml=xml+"<xsl:copy>\n";
			xml=xml+"<xsl:apply-templates select=\"@*|node()\"/>\n";
			xml=xml+"</xsl:copy>\n";
			xml=xml+"</xsl:template>\n";
			xml=xml+"\n";
			xml=xml+"<xsl:template match=\"run\">\n";
			xml=xml+"<xsl:copy>\n";
			xml=xml+"<xsl:apply-templates select=\"@*|*\"/>\n";
			xml=xml+"</xsl:copy>\n";
			xml=xml+"</xsl:template>\n";
			xml=xml+"</xsl:stylesheet>\n";
			return xml;
		}

		public static function fixDominButton(xml:XML):String
		{
			//remove the first div from table cells
			
			var tableCells:XMLList=xml.descendants("tablecell");
			
			for each(var cell:XML in tableCells){
				
				if(cell.children()[0]!=null){
					var count:Number = 0;
					for each(var cellChildren:XML in cell.children()){
						if(cellChildren.name()=="div"){
							for each(var cellDivChildren:XML in cellChildren.children()){
								cell.appendChild(cellDivChildren);
							}
							delete cell.children()[count];
							
						}
						count++;
					}
				}
			}
			
			var totalXml:String=xml.toXMLString();
			//>([^<]*)</td>
			//(?=<button)|(?<=<\/button>)
			var splits:Array = totalXml.split("</button>");
			var result:String="";
			var rex:RegExp = /(\t|\n|\r)/gi;

			for each (var child:String in splits ) {
				
				if(child.indexOf("<button")>=0){
					var buttonChildString:String="";
					
					var splitsFormula:Array = child.split("</formula>");
					for each (var formula:String in splitsFormula ) {
						formula=StringUtil.trim(formula);
						if(formula.indexOf("<formula")>=0){
							buttonChildString=StringUtil.trim(buttonChildString+formula+"</formula>");
						}else{
							buttonChildString=StringUtil.trim(StringUtil.trim(buttonChildString)+ formula.replace(rex,''));
						}
					}
					//Alert.show("buttonChildString:"+buttonChildString);
					child=buttonChildString+"</button>";
				}
				result=result+child;
			}
			var result2:String="";
			if(result.indexOf("<button")>=0){
				var splitsButton:Array = result.split("<button");
				for each (var childButton:String in splitsButton ) {
					if(childButton.indexOf("</button>")>=0){
						var buttonChildString2:String="";
						var splitsFormula2:Array = childButton.split("<formula>");
						for each (var formula2:String in splitsFormula2 ) {
							
							formula2=StringUtil.trim(formula2);
							if(formula2.indexOf("</formula>")>=0){
								buttonChildString2=StringUtil.trim(buttonChildString2+"<formula>"+formula2);
							}else{
								if(formula2.indexOf("<font")>=0){
									var splitsFormula3:Array = formula2.split("<font");
									var splitsFormula4:Array=splitsFormula3[0].split(">");
									buttonChildString2=buttonChildString2+splitsFormula4[0]+">"+StringUtil.trim(splitsFormula4[1])+"<font"+splitsFormula3[1];
								}else if(formula2.indexOf("<code")>=0){
									var splitsFormula5:Array = formula2.split("<code");
									var splitsFormula6:Array=splitsFormula5[0].split(">");
									buttonChildString2=buttonChildString2+splitsFormula6[0]+">"+StringUtil.trim(splitsFormula6[1])+"<code"+splitsFormula5[1];	
								}else{
									buttonChildString2=StringUtil.trim(StringUtil.trim(buttonChildString2)+ formula2.replace(rex,''));
								}					
							}
						}
						childButton="<button "+buttonChildString2;
					}
					result2=result2+childButton;
				}
				result=result2;
			}

				
				if(result.indexOf("<font")>=0){
					var fontFont:Number = 0;
					var result3:String="";
					var splitsFont:Array = result.split("<font");
					for each (var childFont:String in splitsFont ) {
						if(childFont.indexOf(">")>=0){
							var fontString:String="";
							var splitsFont2:Array = childFont.split(">");
							var countFont:Number = 0;
						
							for each (var childFont2:String in splitsFont2 ) {
								if(countFont==1){
									childFont2=childFont2.substring(1);
									var maxLen:int=22;
									if(childFont2.length<maxLen){
										maxLen=childFont2.length;
									}
									
									for (var i:int=0; i<maxLen; i++) {
									  if(childFont2.substring(0,1)==" "){
										  childFont2=childFont2.substring(1);
									  }	
									}	
								}
								childFont2=childFont2+">";
								
								
								fontString=fontString+childFont2;
								countFont++;
							}
							
							fontString=fontString.substring(0,fontString.length-1);
							if(fontFont>0){
								childFont="<font"+fontString;
							}
							
						}
						fontFont++;
				
						result3=result3+childFont;
					}
					result=result3;

				}
			 var tabpattern:RegExp = /&amp;#tab;/g;
			 result = result.replace(tabpattern,"\t");
			
			
			return result;
		}

    }
}