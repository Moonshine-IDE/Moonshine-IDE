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
package no.doomsday.console.core.text.autocomplete 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public dynamic class AutocompleteDictionary
	{
		public var basepage:Object = new Object();
		private var stringContents:Vector.<String> = new Vector.<String>;
		private var stringContentsLowercase:Vector.<String> = new Vector.<String>;
		public function AutocompleteDictionary() 
		{
		}
		
		public function correctCase(str:String):String {
			var idx:int = stringContentsLowercase.indexOf(str.toLowerCase());
			if (idx == -1) throw new Error("No result");
			return stringContents[idx];
		}
		
		public function addToDictionary(str:String):void {
			stringContents.push(str);
			stringContentsLowercase.push(str.toLowerCase()); //TODO: This is a terrible way to solve the search problem. Must fix.
            var strParts:Array = str.split("");
            strParts.push(new String());
            insert(strParts, basepage);
        }
		public function contains(str:String):Boolean {
			return stringContentsLowercase.indexOf(str.toLowerCase(), 0) > -1;
		}

        private function insert(parts:Array, page:Object):void {
            if(parts[0] == undefined) {
                return;
            }
            var letter:String = parts[0];
            if(!page[letter]){
                page[letter] = new Object();
            }
            insert(parts.slice(1, parts.length), page[letter]);
        }
		public function getSuggestion(arr:Array):String {
            var suggestion:String = "";
            var len:uint = arr.length;
            var tmpDict:Object = basepage;

            if(len < 1) {
                return suggestion;
            }

            var letter:String;
            for(var i:uint; i < len; i++) {
                letter = arr[i];
                if(tmpDict[letter.toUpperCase()] && tmpDict[letter.toLowerCase()]) {
                    var upperTmpDict:Object = tmpDict[letter.toUpperCase()];
                    var lowerTmpDict:Object = tmpDict[letter.toLowerCase()];
                    tmpDict = mergeDictionaries(lowerTmpDict, upperTmpDict);
                }
                else if(tmpDict[letter.toUpperCase()]) {
                    tmpDict = tmpDict[letter.toUpperCase()];
                }
                else if(tmpDict[letter.toLowerCase()]){
                    tmpDict = tmpDict[letter.toLowerCase()];
                }
                else {
                    return suggestion;
                }
            }

            var loop:Boolean = true;
            while(loop) {
                loop = false;
                for(var l:String in tmpDict) {
                    if(shouldContinue(tmpDict)) {
                        suggestion += l;
                        tmpDict = tmpDict[l];
                        loop = true;
                        break;
                    }
                }
            }

            return suggestion;
        }

        private function mergeDictionaries(lowerCaseDict:Object, upperCaseDict:Object):Object {
            var tmpDict:Object = new Object();

            for(var j:String in lowerCaseDict) {
                tmpDict[j] = lowerCaseDict[j];
            }

            for(var k:String in upperCaseDict) {
                if(tmpDict[k] != undefined && upperCaseDict[k] != undefined) {
                    tmpDict[k] = mergeDictionaries(tmpDict[k], upperCaseDict[k]);
                }
                else {
                    tmpDict[k] = upperCaseDict[k];
                }
            }
            return tmpDict;
        }

        private function shouldContinue(tmpDict:Object):Boolean {
            var count:Number = 0;
            for(var k:String in tmpDict) {
                if(count > 0) {
                    return false;
                }
                count++;
            }
            return true;
        }
		
	}

}