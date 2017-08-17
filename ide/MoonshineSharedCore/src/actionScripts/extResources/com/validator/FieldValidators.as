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
package actionScripts.extResources.com.validator
{
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.validators.EmailValidator;
	import mx.validators.NumberValidator;
	import mx.validators.RegExpValidator;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	import spark.components.DropDownList;
	
	public class FieldValidators
	{
		private var validatorArr		: Array;
		private var validatorErrorArr	: Array;
		
		private const FORM_ERROR_MSG	: String = " is Invalid/Empty.\nPlease correct so we can save your data.";
		private const REQUIRED_STRING	: String = "This field is required.";
		private const REQUIRED_COMBOBOX	: String = "This field is required.";
		private const VALUE_MISSMATCH	: String = "The value does not match.";
		private const INVALID_EMAIL		: String = "The given email is invalid.";
		private const NUMBER_ERROR_MSG	: String = "Only numbers are allowed.";
		private const CUSTOM_EXP_MSG	: String = "Improper value";
		
		//Constructor
		public function FieldValidators()
		{	
		}
		
		public function validate(	validationSourceArr:Array	):Boolean{
			
			var validatorFlag : Boolean = true;
			validatorArr = new Array();
            
			if ( !validationSourceArr ) return true;
        	for(var i:int=0;i<validationSourceArr.length;i++){
				
				var tmpReqString : String;
        		var currentItem:ValidatorType = validationSourceArr[i];
        		var tmpArr : Array;
    			var stringValidator:StringValidator = new StringValidator();
    			stringValidator.source = currentItem.field;
				tmpReqString = REQUIRED_STRING;
    			stringValidator.required = currentItem.isRequired;
    			stringValidator.property = "text";
    			
        		
        		if(currentItem.minLength!=-1){
					tmpReqString = stringValidator.tooShortError = "Required "+currentItem.minLength+" digits";
        			stringValidator.minLength = currentItem.minLength;
        		} else {
					//stringValidator.source.errorString = null;
				}
        		if(currentItem.maxLength!=-1){
        			stringValidator.maxLength = currentItem.maxLength;
					tmpReqString = stringValidator.tooLongError = "Should not exceed "+currentItem.maxLength+" digits";
        		} else {
					//stringValidator.source.errorString = null;
				}
        		validatorArr.push(stringValidator); 
        		tmpArr = [ stringValidator ];
        		
        		
        		//Combobox validation - whether a value of the combobox is been selected
        		if((currentItem.field) is DropDownList){
        			var numberValidator:NumberValidator = new NumberValidator();
        			numberValidator.source = currentItem.field as DisplayObject;
        			numberValidator.minValue = 1;
        			numberValidator.lowerThanMinError = REQUIRED_COMBOBOX;
        			numberValidator.required = currentItem.isRequired;
        			numberValidator.property = "selectedIndex";
        			validatorArr.push(numberValidator); 
        			tmpArr = [ stringValidator ];
        		}
        		
        		//Matching 2 fields
        		if(currentItem.fieldToMatch != null){
        			var regExp:RegExpValidator = new RegExpValidator();
        			regExp.expression = "^"+currentItem.fieldToMatch+"$";
        			regExp.source = currentItem.field;
        			regExp.property = "text";
        			regExp.required = currentItem.isRequired;
        			regExp.noMatchError = tmpReqString = VALUE_MISSMATCH;
        			validatorArr.push(regExp); 
        			tmpArr.push( stringValidator );
        		}
        		
        		//Email validation
        		if(currentItem.isEmail != false){
        			
					var eValidator : EmailValidator = new EmailValidator();
					eValidator.source = currentItem.field;
					eValidator.required = currentItem.isRequired;
					eValidator.property = "text";
					eValidator.invalidCharError = tmpReqString = INVALID_EMAIL;
					validatorArr.push( eValidator );
        			tmpArr = [ eValidator ];
        			
        		}
        		
        		//Number validation
        		if(currentItem.isNumber != false){
        			var numberExp:RegExpValidator = new RegExpValidator();
        			numberExp.expression = "[0-9]";
        			numberExp.source = currentItem.field;
        			numberExp.property = "text";
        			numberExp.required = currentItem.isRequired;
        			numberExp.noMatchError = tmpReqString = NUMBER_ERROR_MSG;
        			validatorArr.push(numberExp); 
        			tmpArr.push( stringValidator );
        		}
        		
        		//Custom expression/validation
        		if(currentItem.customExp != null){
        			var customExp:RegExpValidator = new RegExpValidator();
        			customExp.expression = currentItem.customExp;
        			customExp.source = currentItem.field;
        			customExp.property = "text";
        			customExp.required = currentItem.isRequired;
        			customExp.noMatchError = tmpReqString = CUSTOM_EXP_MSG;
        			validatorArr.push(customExp); 
        			tmpArr.push( stringValidator );
        		}
        		
        		validatorErrorArr = Validator.validateAll(tmpArr);
        		
	        	if(validatorFlag && validatorErrorArr.length != 0) {
					currentItem.field.errorString = tmpReqString;
	        		Alert.show(currentItem.fieldName + FORM_ERROR_MSG, "Error!");
					return false;
	        	} else {
					tmpArr[0].source.errorString = '';
				}
        		
        	}
        	
        	if(validatorFlag){
        		return true;
        	}else{
        		return false;
        	} 
		
		}

	}
}