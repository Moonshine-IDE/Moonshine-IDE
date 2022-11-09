////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import mx.controls.Alert;
	import mx.events.ValidationResultEvent;
	import mx.validators.StringValidator;
	
	import spark.validators.NumberValidator;
	
	import actionScripts.extResources.com.validator.ValidatorType;
	
	public class SimpleValidator
	{
		public static function validate( fields:Array ) : Boolean
		{
			var vResultEvent : ValidationResultEvent;
			var tmpValidatorType : ValidatorType;
			for ( var i:int = 0; i < fields.length; i++ ) {
				
				tmpValidatorType = fields[ i ];
				
				tmpValidatorType.validator.source = tmpValidatorType.field;
				if ( tmpValidatorType.validator is StringValidator ) {
					tmpValidatorType.validator.minLength = ( tmpValidatorType.minLength != -1 ) ? tmpValidatorType.minLength : NaN;
					tmpValidatorType.validator.maxLength = ( tmpValidatorType.maxLength != -1 ) ? tmpValidatorType.maxLength : NaN;
				} else if ( tmpValidatorType.validator is NumberValidator ) {
					tmpValidatorType.validator.minValue = ( tmpValidatorType.minLength != -1 ) ? tmpValidatorType.minLength : NaN;
					tmpValidatorType.validator.maxValue = ( tmpValidatorType.maxLength != -1 ) ? tmpValidatorType.maxLength : NaN;
					tmpValidatorType.validator.domain = "int";
				}
				if ( tmpValidatorType.tooLongError ) tmpValidatorType.validator.tooLongError = tmpValidatorType.tooLongError;
				if ( tmpValidatorType.tooShortError ) tmpValidatorType.validator.tooShortError = tmpValidatorType.tooShortError;
				vResultEvent = tmpValidatorType.validator.validate();
				if ( vResultEvent.type == ValidationResultEvent.INVALID ) {
					Alert.show(tmpValidatorType.fieldName + " is Invalid/Empty.\nPlease correct so we can save your data.", "Error!");
					return false;
				}
			}
			
			// else
			return true;
		}
	}
}