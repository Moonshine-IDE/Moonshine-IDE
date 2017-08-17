package org.as3commons.asblocks.impl
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.IASParser;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IParserInfo;
import org.as3commons.asblocks.parser.api.ISourceCode;

[Event(name="complete",type="flash.events.Event")]

[Event(name="error",type="flash.events.Event")]

/**
 * Implementation of the <code>IParserInfo</code> for .as files.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ParserInfo extends EventDispatcher implements IParserInfo
{
	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected var parser:Object;
	
	//--------------------------------------------------------------------------
	//
	//  IParserInfo API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  sourceCode
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _sourceCode:ISourceCode;
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#sourceCode
	 */
	public function get sourceCode():ISourceCode
	{
		return _sourceCode;
	}
	
	//----------------------------------
	//  entry
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _entry:IClassPathEntry;
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#entry
	 */
	public function get entry():IClassPathEntry
	{
		return _entry;
	}
	
	//----------------------------------
	//  unit
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _unit:ICompilationUnit;
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#unit
	 */
	public function get unit():ICompilationUnit
	{
		return _unit;
	}
	
	//----------------------------------
	//  error
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _error:ASBlocksSyntaxError;
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#error
	 */
	public function get error():ASBlocksSyntaxError
	{
		return _error;
	}
	
	/**
	 * @private
	 */	
	public function set error(value:ASBlocksSyntaxError):void
	{
		_error = value;
	}
	
	//----------------------------------
	//  parseBlocks
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _parseBlocks:Boolean;
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#parseBlocks
	 */
	public function get parseBlocks():Boolean
	{
		return _parseBlocks;
	}
	
	/**
	 * @private
	 */	
	public function set parseBlocks(value:Boolean):void
	{
		_parseBlocks = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ParserInfo(parser:Object, 
							   sourceCode:ISourceCode, 
							   entry:IClassPathEntry, 
							   parseBlocks:Boolean)
	{
		super();
		
		this.parser = parser;
		_sourceCode = sourceCode;
		_entry = entry;
		this.parseBlocks = parseBlocks;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IParserInfo API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#parse()
	 */
	public function parse():void
	{
		var asparser:IASParser = IASParser(parser);
		
		try {
			_unit = asparser.parse(sourceCode, parseBlocks);
		}
		catch (e:ASBlocksSyntaxError)
		{
			error = e;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			return;
		}
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
}
}