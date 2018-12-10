package actionScripts.plugin.java.javaproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;

	public class JavaProjectVO extends ProjectVO
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";

		public function JavaProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
		}
	}
}