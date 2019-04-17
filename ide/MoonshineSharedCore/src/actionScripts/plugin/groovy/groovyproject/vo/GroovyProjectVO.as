package actionScripts.plugin.groovy.groovyproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.groovy.groovyproject.exporter.GroovyExporter;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.settings.vo.FileNameSetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import mx.collections.ArrayList;

	public class GroovyProjectVO extends ProjectVO
	{
		private static const TARGET_BYTECODE_VALUES:Array = ["1.4", "1.5", "1.6", "1.7", "1.8", "9", "10", "11", "12", "13"];

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var sourceFolder:FileLocation;
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		
		public var jarOutput:JAROutputVO;
		public var buildOptions:GroovyBuildOptionsVO;

		public function GroovyProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

			jarOutput = new JAROutputVO();
			buildOptions = new GroovyBuildOptionsVO();

            projectReference.hiddenPaths = new <FileLocation>[];
		}
		
		public function get outputPath():String
		{
			var tmpPath:String = this.folderLocation.fileBridge.getRelativePath(jarOutput.path.fileBridge.parent);
			if (!tmpPath) tmpPath = jarOutput.path.fileBridge.parent.fileBridge.nativePath;
			return tmpPath;
		}

		public function set outputPath(value:String):void
		{
			if (!value || value == "") return;

			var folder:FileLocation = this.folderLocation.fileBridge.resolvePath(value);
			if (!folder.fileBridge.exists) folder.fileBridge.createDirectory();
			var fileName:String = jarOutput.path.fileBridge.name;
			jarOutput.path = folder.resolvePath(fileName);
		}
		
		public function get outputFileName():String
		{
			var name:String = jarOutput.path.fileBridge.name;
			var index:int = name.lastIndexOf(".");
			if(index != -1)
			{
				name = name.substr(0, index);
			}
			return name;
		}

		public function set outputFileName(value:String):void
		{
			if (!value || value == "") return;
			
			jarOutput.path = new FileLocation(jarOutput.path.fileBridge.parent.fileBridge.nativePath + folderLocation.fileBridge.separator + value + ".jar");
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new StringSetting(buildOptions, "additional", 				"Additional compiler options"),
                            new DropDownListSetting(buildOptions, "targetBytecode",		"Target bytecode", new ArrayList(TARGET_BYTECODE_VALUES)),
                            new StringSetting(buildOptions, "temp",						"Compiler temp directory"),
                            new StringSetting(buildOptions, "encoding",					"Source file encoding"),
                            new PathSetting(buildOptions, "destdir",					"Generated class files destination", true, buildOptions.destdir),
                            new BooleanSetting(buildOptions, "stacktrace",				"Display stack trace of errors"),
                            new StringSetting(buildOptions, "scriptBaseClass",			"Script base class name"),
                            new BooleanSetting(buildOptions, "indy",					"Enable invokedynamic"),
                            new PathSetting(buildOptions, "configscript",				"Compiler configuration script", false, buildOptions.configscript),
                            new BooleanSetting(buildOptions, "parameters",				"Parameter reflection metdata."),
                            new BooleanSetting(buildOptions, "verbose",					"Verbose output"),
                        ])
                ),
                new SettingsWrapper("Paths",
					new <ISetting>[
						new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true)
					]
                ),
				new SettingsWrapper("JAR Output",
					new <ISetting>[
						new PathSetting(this, "outputPath", "Output Folder", true, outputPath),
						new FileNameSetting(this, "outputFileName", "Output File Name", ".jar")
					]
				)
			]);
			settings.sort(order);
			return settings;
		}

		private function order(a:SettingsWrapper, b:SettingsWrapper):int
		{ 
			if (a.name < b.name) { return -1; } 
			else if (a.name > b.name) { return 1; }
			return 0;
		}

		override public function saveSettings():void
		{
			GroovyExporter.export(this);
		}
	}
}