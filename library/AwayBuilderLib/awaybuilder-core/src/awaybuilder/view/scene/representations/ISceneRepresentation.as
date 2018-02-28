package awaybuilder.view.scene.representations {
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	
	public interface ISceneRepresentation {
		function get representation():Mesh;
		function get sceneObject():ObjectContainer3D;

		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		function updateRepresentation():void;
	}
}
