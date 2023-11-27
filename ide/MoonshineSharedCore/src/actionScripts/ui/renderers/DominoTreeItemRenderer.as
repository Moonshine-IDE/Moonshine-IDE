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
package actionScripts.ui.renderers
{
    import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.mx_internal;
	import mx.controls.Alert;
	import spark.components.Label;
    import view.domino.forms.imageClass.LoadImage;
    import spark.components.Image;
    import mx.core.ClassFactory;
	import mx.controls.Alert;
	import flash.display.Sprite;
	import mx.core.IFlexDisplayObject;
	import flash.display.DisplayObject;

    public class DominoTreeItemRenderer extends TreeItemRenderer {
        private var customIcon:Image;

        public function DominoTreeItemRenderer() {
            super();
        }

        override protected function createChildren():void {
            super.createChildren();

            // Create an Image instance for the custom icon
            customIcon = new Image();
            
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
             // Check if it's a leaf node and hide the default leaf icon
            if (data && data is XML && data.children().length() == 0) {
                setStyle("defaultLeafIcon", null); // Hide the default leaf icon
            }
            if (data && data is XML && data.children().length() == 0) {
                setStyle("defaultLeafIcon", null); // Hide the default leaf icon
            }
            // Check the 'iconType' attribute of the data and set the custom icon accordingly
            if (data && XML(data).@type) {
                var value:String=XML(data).@value.toString();
                switch (XML(data).@type.toString())
				{
					case "LotusScript":
                        if(value=="hasValue"){
                            customIcon.source=LoadImage.DOMINO_OBJECT_TREE_PAGE_FILL
                        }else{
                            customIcon.source=(LoadImage.DOMINO_OBJECT_TREE_PAGE);
                        }
						break;
					case "Formula":
                        if(value=="hasValue"){
                            customIcon.source=(LoadImage.DOMINO_OBJECT_TREE_RHOMBUS_FILL);
                        }else{
                            customIcon.source=(LoadImage.DOMINO_OBJECT_TREE_RHOMBUS);
                        }
						
					    break;
					case "JavaScript":
                        if(value=="hasValue"){
                             customIcon.source=(LoadImage.DOMINO_OBJECT_TREE_CIRCLE_FILL);
                        }else{
                            customIcon.source=(LoadImage.DOMINO_OBJECT_TREE_CIRCLE);
                        }
                       
						break;
                    default:
                        customIcon.source = null; // Clear the custom icon for default case
                        break;

				}
                customIcon.visible = true;
                if(XML(data).@type.toString()!=""){
                    this.icon.visible=false;
                }
                
                customIcon.width = customIcon.height = 14;
                customIcon.x = this.icon.x;
                //label.x - (this.icon ? 34 : 24);
                customIcon.y = (unscaledHeight - customIcon.height) / 2;
                addChild(customIcon);
            } else {
                customIcon.visible = false;
            }

            // Position the custom icon as needed
            // customIcon.x = 5; // Adjust the x-coordinate as necessary
            // customIcon.y = (unscaledHeight - customIcon.height) / 2; // Center the icon vertically
         
            //isSourceFolderIcon.visible = true;
        }
    }
}
