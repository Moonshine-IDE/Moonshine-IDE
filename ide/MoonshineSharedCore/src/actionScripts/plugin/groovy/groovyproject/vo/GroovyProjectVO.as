package actionScripts.plugin.groovy.groovyproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;

	public class GroovyProjectVO extends ProjectVO
	{
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var sourceFolder:FileLocation;

		public function GroovyProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
		}
	}
}