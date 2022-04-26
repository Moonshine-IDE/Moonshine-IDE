package actionScripts.plugin.genericproj.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;

	public class GenericProjectVO extends ProjectVO
	{
		public function GenericProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);
		}
	}
}
