package actionScripts.valueObjects
{
    public class WorkspaceVO
    {
        public var label:String;
        public var paths:Array;

        public function WorkspaceVO(label:String, paths:Array)
        {
            this.label = label;
            this.paths = paths;
        }
    }
}
