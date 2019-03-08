package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.utils.SerializeUtil;

    public class JavaMavenBuildOptions extends MavenBuildOptions
    {
        public function JavaMavenBuildOptions(defaultMavenBuildPath:String)
        {
            super(defaultMavenBuildPath);
        }

        override public function parse(build:XMLList):void
        {
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            commandLine = SerializeUtil.deserializeString(build.xsiNamespace::projectbuildaction);
        }
    }
}
