package actionScripts.valueObjects;

class EnvironmentExecPaths {

    public static final GRADLE_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$GRADLE_HOME/bin/gradle" : "%GRADLE_HOME%\\bin\\gradle";
		public static final GRAILS_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$GRAILS_HOME/bin/grails" : "%GRAILS_HOME%\\bin\\grails";
		public static final HAXE_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$HAXE_HOME/haxe" : "%HAXE_HOME%\\haxe.exe";
		public static final HAXELIB_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$HAXE_HOME/haxelib" : "%HAXE_HOME%\\haxelib.exe";
		public static final NEKO_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$NEKO_HOME/neko" : "%NEKO_HOME%\\neko.exe";
		public static final JAVA_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$JAVA_HOME/bin/java" : "%JAVA_HOME%\\bin\\java.exe";

}