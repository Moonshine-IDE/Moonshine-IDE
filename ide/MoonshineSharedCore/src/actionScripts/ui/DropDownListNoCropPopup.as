////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui
{
    import mx.events.ResizeEvent;

    import spark.components.DropDownList;
    import spark.components.PopUpAnchor;

    public class DropDownListNoCropPopup extends DropDownList
    {
        [SkinPart(popUpWidthMatchesAnchorWidth)]
        public var popUp:PopUpAnchor;

        public function DropDownListNoCropPopup()
        {
            super();
        }

        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            if (partName == "popUp")
            {
                instance.popUpWidthMatchesAnchorWidth = false;
                instance.addEventListener(ResizeEvent.RESIZE, onInstanceResized, false, 0, true);
            }
        }

        private function onInstanceResized(event:ResizeEvent):void
        {
            event.target.removeEventListener(ResizeEvent.RESIZE, onInstanceResized);
            if (!isNaN(event.target.popUp.width) && width > event.target.popUp.width)
                event.target.popUp.width = width;
        }
    }
}