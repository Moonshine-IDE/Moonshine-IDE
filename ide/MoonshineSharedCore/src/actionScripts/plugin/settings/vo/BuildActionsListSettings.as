package actionScripts.plugin.settings.vo
{
    import actionScripts.plugin.settings.renderers.BuildActionsListSettingRenderer;

    import mx.core.IVisualElement;

    public class BuildActionsListSettings extends StringSetting
    {
        private var rdr:BuildActionsListSettingRenderer;

        private var _buildActions:Array;

        public function BuildActionsListSettings(provider:Object, buildActions:Array, name:String, label:String)
        {
            super(provider, name, label, null);

            _buildActions = buildActions;
        }

        public function get buildActions():Array
        {
            return _buildActions;
        }

        override public function get renderer():IVisualElement
        {
            rdr = new BuildActionsListSettingRenderer();
            rdr.setting = this;
            rdr.enabled = isEditable;
            rdr.setMessage(message, messageType);
            return rdr;
        }
    }
}
