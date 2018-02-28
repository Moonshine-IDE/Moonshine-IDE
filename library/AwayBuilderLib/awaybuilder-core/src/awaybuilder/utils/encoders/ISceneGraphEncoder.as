package awaybuilder.utils.encoders
{
	import awaybuilder.model.DocumentModel;
	
	import flash.utils.ByteArray;

	public interface ISceneGraphEncoder
	{
		function encode(scenegraph : DocumentModel, output : ByteArray, useWebRestriction:Boolean = false) : Boolean;
		function dispose() : void;
	}
}