package org.as3commons.asblocks.impl
{

public class ASQName
{
	//----------------------------------
	//  packageName
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _packageName:String;
	
	/**
	 * doc
	 */
	public function get packageName():String
	{
		return _packageName;
	}
	
	/**
	 * @private
	 */	
	public function set packageName(value:String):void
	{
		_packageName = value;
	}
	
	//----------------------------------
	//  localName
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _localName:String;
	
	/**
	 * doc
	 */
	public function get localName():String
	{
		return _localName;
	}
	
	/**
	 * @private
	 */	
	public function set localName(value:String):void
	{
		_localName = value;
	}
	
	//----------------------------------
	//  qualifiedName
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get qualifiedName():String
	{
		if (isQualified)
		{
			return packageName + "." + localName;
		}
		return localName;
	}
	
	//----------------------------------
	//  isQualified
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get isQualified():Boolean
	{
		return packageName != null;
	}
	
	public function ASQName(qualifiedName:String = null)
	{
		if (!qualifiedName)
			return;
		
		var pos:int = qualifiedName.lastIndexOf(".");
		if (pos != -1)
		{
			_packageName = qualifiedName.substring(0, pos);
			_localName = qualifiedName.substring(pos + 1);
		}
		else
		{
			_localName = qualifiedName;
		}
	}
	
	//----------------------------------
	//  filePath
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _filePath:String;
	
	/**
	 * doc
	 */
	public function get filePath():String
	{
		return _filePath;
	}
	
	/**
	 * @private
	 */	
	public function set filePath(value:String):void
	{
		_filePath = value;
	}
	
	public function define(localName:String, packageName:String):void
	{
		_localName = localName;
		_packageName = packageName;
	}
	
	public function equals(obj:Object):Boolean
	{
		if (this === obj)
			return true;
		if (obj == null)
			return false;
		//if (getClass() != obj.getClass())
		//	return false;
		var other:ASQName = ASQName(obj);
		
		if (localName == null)
		{
			if (other.localName != null)
				return false;
		}
		else if (!localName == other.localName)
			return false;
		
		if (packageName == null)
		{
			if (other.packageName != null)
				return false;
		} 
		else if (!packageName == other.packageName)
			return false;
		
		return true;
	}
	
	public function toString():String
	{
		return qualifiedName;
	}
}
}