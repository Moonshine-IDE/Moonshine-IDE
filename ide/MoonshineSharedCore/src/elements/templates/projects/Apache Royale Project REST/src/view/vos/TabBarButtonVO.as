package view.vos
{
    [Bindable]
    public class TabBarButtonVO
    {
        public var label:String;
        public var hash:String;
        public var icon:String;

        public function TabBarButtonVO(label:String, hash:String, icon:String = null)
        {
            this.label = label;
            this.hash = hash;
            this.icon = icon;
        }
    }
}