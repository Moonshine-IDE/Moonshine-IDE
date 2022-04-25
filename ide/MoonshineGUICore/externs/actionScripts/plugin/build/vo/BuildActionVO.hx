package actionScripts.plugin.build.vo;

@:bind
class BuildActionVO {

    public var actionName:String;
    public var action:String;

    public function new(actionName:String, action:String)
    {
        this.actionName = actionName;
        this.action = action;
    }
    
}