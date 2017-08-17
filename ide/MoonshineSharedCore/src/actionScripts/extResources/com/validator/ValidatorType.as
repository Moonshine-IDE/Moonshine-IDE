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
/**
 * ValidatorType Component
 * 		field = Need to pass the field ID of different user controls (i.e. TextArea, ComboBox et)
 * 		isEmail = True/Talse - optional - whether email validation is required
 * 		isNumber = True/False - optional - whether number validation is required (i.e. only number data can be entered)
 * 		minLength = Integer value - for minimum character length validation (i.e. 4 digit of zip code)
 * 		maxLength = Integer value - for maximum character length validation (i.e. zip code can't be more than 7 digit)
 * 		fieldToMatch = String - optional - required to check current input string with 'fieldToMatch' string
 * 						(i.e. confirm password need to be checked with the password textbox.text OR any textbox with any string)
 * 		customExp = String - optional - if any custom expression need to be checked then pass the expression string with _
 * 
 */
package actionScripts.extResources.com.validator
{
	public class ValidatorType
	{
		public var validator		: *;
		public var tooLongError		: String;
		public var tooShortError	: String;
		
		private var _field:*;
		private var _isRequired:Boolean;
		private var _isEmail:Boolean;
		private var _isNumber:Boolean;
		private var _fieldToMatch:String;
		private var _minLength:int;
		private var _maxLength:int;
		private var _customExp:String;
		private var _fieldName:String;
		
		/**
		 * CONSTRUCTOR
		 */
		public function ValidatorType(val:*, field:*, fName:String, isRequired:Boolean=true, isEmail:Boolean =false, isNumber:Boolean=false, minLength:int=-1, maxLength:int=-1, tooLE:String=null, tooSE:String=null)
		{
			validator = val;
			tooLongError = tooLE;
			tooShortError = tooSE;
			_field = field;
			_isRequired = isRequired;
			_isEmail = isEmail;
			_isNumber = isNumber;
			_minLength = minLength;
			_maxLength = maxLength;
			_customExp = customExp;
			_fieldName = fName;
		}
		
		public function get field():*{
			return _field;
		}
		
		public function set field(value:*):void{
			_field = value;
		}
		
		public function get isRequired():Boolean{
			return _isRequired;
		}
		
		public function set isRequired(value:Boolean):void{
			_isRequired = value;
		}
		
		public function get isEmail():Boolean{
			return _isEmail;
		}
		
		public function set isEmail(value:Boolean):void{
			_isEmail = value;
		}
		
		public function get isNumber():Boolean{
			return _isNumber;
		}
		
		public function set isNumber(value:Boolean):void{
			_isNumber = value;
		}
		
		public function get fieldToMatch():String{
			return _fieldToMatch;
		}
		
		public function set fieldToMatch(value:String):void{
			_fieldToMatch = value;
		}
		
		public function get minLength():int{
			return _minLength;
		}
		
		public function set minLength(value:int):void{
			_minLength = value;
		}
		
		public function get maxLength():int{
			return _maxLength;
		}
		
		public function set maxLength(value:int):void{
			_maxLength = value;
		}
		
		public function get customExp():String{
			return _customExp;
		}
		
		public function set customExp(value:String):void{
			_customExp = value;
		}
		
		public function get fieldName():String{
			return _fieldName;
		}
		
		public function set fieldName(value:String):void{
			_fieldName = value;
		}

	}
	
}