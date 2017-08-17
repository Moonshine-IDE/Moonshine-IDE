package org.as3commons.asblocks.impl
{

import flash.events.IEventDispatcher;

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.parser.api.ISourceCode;

public interface IParserInfo extends IEventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  sourceCode
	//----------------------------------
	
	/**
	 * The source code.
	 */
	function get sourceCode():ISourceCode;
	
	//----------------------------------
	//  entry
	//----------------------------------
	
	/**
	 * The class path entry (base path).
	 */
	function get entry():IClassPathEntry;
	
	//----------------------------------
	//  unit
	//----------------------------------
	
	/**
	 * The parsed compilation unit.
	 */
	function get unit():ICompilationUnit;
	
	//----------------------------------
	//  error
	//----------------------------------
	
	/**
	 * The error thrown during parsing.
	 */
	function get error():ASBlocksSyntaxError;
	
	/**
	 * @private
	 */
	function set error(value:ASBlocksSyntaxError):void;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Parses the sourceCode with the appropriate parser.
	 */
	function parse():ICompilationUnit;
}
}