package actionScripts.ui.feathersWrapper.help
{

    import actionScripts.interfaces.IViewWithTitle;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.IContentWindow;

    import moonshine.plugin.help.view.about.AboutScreen;

    public class AboutScreenWrapper extends FeathersUIWrapper implements IViewWithTitle, IContentWindow
	{

        private static const LABEL:String = "About Moonshine";

        public function get title():String 		{	return LABEL;	}
		public function get label():String 		{	return LABEL;	}
		public function get longLabel():String 	{	return LABEL;	}
		public function save():void				{}
		public function isChanged():Boolean 	{	return false;	}
		public function isEmpty():Boolean		{	return false;	}

        public function AboutScreenWrapper(feathersUIControl:AboutScreen=null)
		{
			super(feathersUIControl);
		}

    }

}