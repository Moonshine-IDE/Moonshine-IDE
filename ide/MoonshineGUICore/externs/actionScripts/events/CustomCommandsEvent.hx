package actionScripts.events;

import actionScripts.interfaces.ICustomCommandRunProvider;
import actionScripts.plugin.build.vo.BuildActionVO;
import flash.events.Event;

class CustomCommandsEvent extends Event {

    public static final OPEN_CUSTOM_COMMANDS_ON_SDK:String = "openCustomCommandsInterfaceForSDKtype";
	public static final RUN_CUSTOM_COMMAND_ON_SDK:String = "runCustomCommandForSDKtype";

    public var commands:Array<String>;
    public var selectedCommand:BuildActionVO;
    public var executableNameToDisplay:String;
    public var origin:ICustomCommandRunProvider;

    public function new(type:String, executableNameToDisplay:String, commands:Array<String>, origin:ICustomCommandRunProvider, selectedCommand:BuildActionVO=null) {
        this.commands = commands;
        this.selectedCommand = selectedCommand;
        this.origin = origin;
        this.executableNameToDisplay = executableNameToDisplay;
        
        super(type, false, false);
    }

}