
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

package org.as3commons.asblocks.api
{

/**
 * A script node aware of the <code>IField</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IField
 * @see org.as3commons.asblocks.api.Visibility
 */
public interface IFieldAware extends IContentBlock
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  fields
	//----------------------------------
	
	/**
	 * Returns all <code>IField</code> instances declared in the class content.
	 * 
	 * <p>This property will never return <code>null</code>, if fields are 
	 * not found, an empty Vector is returned.</p>
	 */
	function get fields():Vector.<IField>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates, appends and returns a new <code>IField</code> instance.
	 * 
	 * @param name The <code>String</code> name of the field.
	 * @param visibility The <code>Visibility</code> of the field.
	 * @param type The type of the field.
	 * @return A new <code>IField</code> instance appended to the class type.
	 */
	function newField(name:String, 
					  visibility:Visibility, 
					  type:String):IField;
	
	/**
	 * Returns an <code>IField</code> instance if found or <code>null</code> 
	 * if the type does not contain a field by name.
	 * 
	 * @return The <code>IField</code> instance by name or <code>null</code>.
	 */
	function getField(name:String):IField;
	
	/**
	 * Attemps to remove an <code>IField</code> instance by name.
	 * 
	 * @param name The <code>String</code> name of the field.
	 * @return An <code>IField</code> indicating whether a field by name was 
	 * found and removed (<code>IField</code>), or (<code>null</code>) if not.
	 */
	function removeField(name:String):IField;
}
}