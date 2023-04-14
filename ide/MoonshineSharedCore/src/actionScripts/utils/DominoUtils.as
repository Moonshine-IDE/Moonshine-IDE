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
    import mx.core.UIComponent;
	import mx.controls.Alert;
	import mx.utils.StringUtil;
	import actionScripts.locator.IDEModel;
	import actionScripts.factory.FileLocation;
	import mx.utils.Base64Encoder;
    import mx.utils.Base64Decoder;
    import flash.utils.ByteArray;

    public class DominoUtils
	{
		

        public static function getDominoParentContent(title:String,windowsTitle:String):XML
		{	   
			return getDominoMainContainer(title,windowsTitle);	
		}

        private static function getDominoMainContainer(title:String,windowsTitle:String):XML
		{
				var model:IDEModel = IDEModel.getInstance();
				var separator:String = model.fileCore.separator;
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
					var separatorIndex:int=windowsTitle.lastIndexOf(separator);
					if(separatorIndex>0){
						windowsTitle = windowsTitle.substring(separatorIndex + 1);
					}
					
					xml_str=xml_str+"<item name='$WindowTitle' sign='true'><formula>"+fixXmlSpecailCharacter(windowsTitle)+"</formula></item>"
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
			var tabpattern:RegExp = /&amp;#tab;/g;
			
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
			var newLinrex:RegExp = /(\n|\r)/gi;

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
						if(childButton.indexOf("<formula>")>=0){
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
						}else{
							buttonChildString2=childButton;
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
								if(childFont2.substring(0,1)!="<"){
									childFont2=childFont2.substring(1);
								}
							
								var maxLen:int=24;
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
			 
			 result = result.replace(tabpattern,"\t");
			
			// remove all new line from section
			if(result.indexOf("</sectiontitle>")>=0){
				var result4:String="";
				var splitsSection:Array = result.split("</sectiontitle>");
				for each (var childSection:String in splitsSection ) {
					if(childSection.indexOf("</section>")>=0){
						var sectionChildString2:String="";
						var splitsSection2:Array = childSection.split("</section>");
						var sectionCount:Number=0;
						for each (var childSection2:String in splitsSection2 ) {
							if(sectionCount==0){
								
								sectionChildString2=sectionChildString2+StringUtil.trim(childSection2)+"</section>";
							}else{
								sectionChildString2=sectionChildString2+childSection2;
							}
							sectionCount++;
						}
						childSection="</sectiontitle>"+childSection;
					}

					result4=result4+childSection;
				}
				result=result4;
			}

			//remove all  _moonshineSelected_

			if(result.indexOf("_moonshineSelected_")>=0){
				result=result.replace(/_moonshineSelected_/g,'')
			}

			
			result = result.replace(tabpattern,"\t");
			
			return result;
		}

		//fix </button< to </button><
		public static function fixNotCloseButton(totalXml:String):String 
		{	
			var pattern:RegExp = /<button[\s\S]*?<\/button>/g; 
			totalXml=totalXml.replace(pattern,removeNewLineFN);
	
			return totalXml;
		}

		private static function removeNewLineFN():String{
			var rex:RegExp = /(\t|\n|\r)/gi;
			
			var str:String=arguments[0].replace(rex, '');
			
			return str;
		}

		public static function fixNewTab(xml:XML):XML
		{
			var tabpattern:RegExp = /&amp;#tab;/g;
			var xmlstr:String = xml.toXMLString();
			xmlstr=xmlstr.replace(tabpattern,"\t");
			xml =new XML(xmlstr);
			return xml;
		}
		public static function dominoPageUpdateWithoutSave(newFileLocation:FileLocation,newFormName:String,souceFormName:String):void{
			var newDxlXMLStr:String =String(newFileLocation.fileBridge.read());
			newDxlXMLStr=newDxlXMLStr.replace("name=\""+souceFormName+"\"","name=\""+newFormName+"\"");
			newDxlXMLStr=newDxlXMLStr.replace("name='"+souceFormName+"'","name='"+newFormName+"'");
			newDxlXMLStr=newDxlXMLStr.replace("<text>"+souceFormName+"</text>","<text>"+newFormName+"</text>");
			newDxlXMLStr=newDxlXMLStr.replace("<formula>\""+souceFormName+"\"</formula>","<formula>\""+newFormName+"\"</formula>");
			
			
			newFileLocation.fileBridge.save(newDxlXMLStr);

		}
		public static function dominoWindowTitleUpdate(sourceXml:FileLocation,newFormName:String,souceFormName:String):void{
		
				
				var sourceFormXML:XML = new XML(sourceXml.fileBridge.read());
				var windowsTitleName:String= sourceFormXML.MainApplication.@windowsTitle;
				if(windowsTitleName!=null && windowsTitleName!="" && windowsTitleName.length>0){
					windowsTitleName=base64Decode(windowsTitleName);
					souceFormName="\""+souceFormName+"\"";
					
					if(windowsTitleName==souceFormName){
						windowsTitleName="\""+newFormName+"\"";
					}
					
				}else{
					windowsTitleName="@Text(\""+newFormName+"\")";
				}
				
				windowsTitleName=base64Encode(windowsTitleName);
				var mainApplicationList:XMLList=sourceFormXML..MainApplication;
				if(mainApplicationList.length()>0 && mainApplicationList.length()<2){
					sourceFormXML.MainApplication.@windowsTitle=windowsTitleName;

				} else if (mainApplicationList.length()>0&& mainApplicationList.length()>=2){
					mainApplicationList[0].@windowsTitle=windowsTitleName;
					delete mainApplicationList[1]
				}
				
				sourceXml.fileBridge.save(sourceFormXML.toXMLString());

		}

		public static function base64Encode(str:String, charset:String = "UTF-8"):String{
			if((str==null)){
				return "";
			}
			var base64:Base64Encoder = new Base64Encoder();
			base64.insertNewLines = false;
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(str, charset);
			base64.encodeBytes(byte);
			return base64.toString();
		}
		
		public static function base64Decode(str:String, charset:String = "UTF-8"):String{
			if((str==null)){
				return "";
			}
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(str);
			var byteArray:ByteArray = base64.toByteArray();
			return byteArray.readMultiByte(byteArray.length, charset);;
		}

		public static function getDominActionDxlTemplate():String
		{
			var  dominlDxl:String="<?xml version='1.0' encoding='utf-8'?> \n";
			dominlDxl=dominlDxl+"<!DOCTYPE database SYSTEM 'xmlschemas/domino_11_0_1.dtd'> \n";
			dominlDxl=dominlDxl+"<database  version='11.0' maintenanceversion='1.0'";
 			dominlDxl=dominlDxl+"replicaid='862585A6006C3CED'  increasemaxfields='true' compressdesign='true'";
 			dominlDxl=dominlDxl+"compressdata='true'> \n";
 			dominlDxl=dominlDxl+"<sharedactions hide='v3 v4strict' designerversion='8.5.3' maxid='32'> \n";
			dominlDxl=dominlDxl+"</sharedactions> \n";
			dominlDxl=dominlDxl+"</database> \n";
 
			return dominlDxl;

		}

		public static const AMPERSAND:String = "&amp;"
		public static const APOSTROPHE:String = "&apos;"
		public static const DBL_QUOTES:String = "&quot;"
		public static const GT:String = "&gt;"
		public static const LT:String = "&lt;"

		public static function fixXmlSpecailCharacter(text:String):String
		{
			var amppattern:RegExp = /&/g;
			text = text.replace(amppattern, AMPERSAND);

			var ltpattern:RegExp = /</g;
			text = text.replace(ltpattern, LT);
			var gtpattern:RegExp = />/g;
			text = text.replace(gtpattern, GT);

			var qtpattern:RegExp = /"/g;
			text = text.replace(qtpattern, DBL_QUOTES);


			var aposattern:RegExp = /'/g;
			text = text.replace(aposattern, APOSTROPHE);

			return text


		}

		/**
		<?xml version="1.0" encoding="UTF-8"?>
<database xmlns="http://www.lotus.com/dxl" showinopendialog="false">
   <agent allowremotedebugging="false" clientbackgroundthread="false" hide="web v3" name="DemoJavaAgent_20200901_07" publicaccess="false" restrictions="unrestricted" runaswebuser="false" storehighlights="false">
      <trigger type="scheduled">
         <schedule hours="0" minutes="5" runlocation="specific" runserver="CN=blazeds.testprominic.com/O=PNITEST" type="daily">
            <starttime>
               <datetime>T030000,00</datetime>
            </starttime>
         </schedule>
      </trigger>
      <documentset type="runonce" />
      <code event="action">
         <javaproject class="com.prominic.demo.DemoJavaAgent.class" codepath="" compiledebug="true" imported="true">
            <javaresource name="DemoJavaAgent.jar">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</javaresource>
         </javaproject>
      </code>
   </agent>
</database> */


		public static function generateDominoAgentDomDocument():XML
		{
			var xml_str:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
				xml_str=xml_str+"<database xmlns=\"http://www.lotus.com/dxl\" showinopendialog=\"false\">";
				xml_str=xml_str+"<agent></agent>";
				xml_str=xml_str+"</database>";

				var xml:XML=new XML(xml_str);

				return xml;
		}

    }
}