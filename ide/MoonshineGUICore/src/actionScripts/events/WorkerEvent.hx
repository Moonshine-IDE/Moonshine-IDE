package actionScripts.events;

class WorkerEvent {
	public static final SEARCH_IN_PROJECTS:String = "SEARCH_IN_PROJECTS";
	public static final TOTAL_FILE_COUNT:String = "TOTAL_FILE_COUNT";
	public static final TOTAL_FOUND_COUNT:String = "TOTAL_FOUND_COUNT";
	public static final FILE_PROCESSED_COUNT:String = "FILE_PROCESSED_COUNT";
	public static final FILTERED_FILE_COLLECTION:String = "FILTERED_FILE_COLLECTION";
	public static final PROCESS_ENDS:String = "PROCESS_ENDS";
	public static final REPLACE_FILE_WITH_VALUE:String = "REPLACE_FILE_WITH_VALUE";
	public static final GET_FILE_LIST:String = "GET_FILE_LIST";
	public static final SET_FILE_LIST:String = "SET_FILE_LIST";
	public static final SET_IS_MACOS:String = "SET_IS_MACOS"; // running standard code to determine macOS platform always returning true even in Windows
	public static final RUN_LIST_OF_NATIVEPROCESS:String = "RUN_LIST_OF_NATIVEPROCESS";
	public static final RUN_LIST_OF_NATIVEPROCESS_ENDED:String = "RUN_LIST_OF_NATIVEPROCESS_ENDED";
	public static final RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:String = "RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK";
	public static final RUN_NATIVEPROCESS_OUTPUT:String = "RUN_NATIVEPROCESS_OUTPUT";
	public static final CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:String = "CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT";
	public static final SEARCH_PROJECTS_IN_DIRECTORIES:String = "SEARCH_PROJECTS_IN_DIRECTORIES";
	public static final FOUND_PROJECTS_IN_DIRECTORIES:String = "FOUND_PROJECTS_IN_DIRECTORIES";
	public static final PROCESS_STDINPUT_WRITEUTF:String = "PROCESS_STDINPUT_WRITEUTF"; // can be use to write to stdInput for an already running process
}