package awaybuilder.model.vo.scene.interfaces
{
	import awaybuilder.model.vo.scene.TextureVO;

	public interface ITextured
	{
		function get name():String;
		
		function set texture( value:TextureVO ):void;
		function get texture():TextureVO;
	}
}