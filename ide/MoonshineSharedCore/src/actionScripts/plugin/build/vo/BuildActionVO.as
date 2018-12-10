package actionScripts.plugin.build.vo
{
    [Bindable]
    public class BuildActionVO
    {
        public var actionName:String;
        public var action:String;

        public function BuildActionVO(actionName:String, action:String)
        {
            this.actionName = actionName;
            this.action = action;
        }
    }
}
