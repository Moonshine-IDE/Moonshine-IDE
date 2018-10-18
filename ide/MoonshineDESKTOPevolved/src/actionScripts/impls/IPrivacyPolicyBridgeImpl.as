package actionScripts.impls
{
    import actionScripts.interfaces.IPrivacyPolicyBridge;
    import actionScripts.plugins.help.view.PrivacyPolicyScreen;

    import mx.core.IFlexDisplayObject;

    public class IPrivacyPolicyBridgeImpl implements IPrivacyPolicyBridge
    {
        public function getNewPrivacyPolicyScreen(closeListener:Function):IFlexDisplayObject
        {
            return new PrivacyPolicyScreen();
        }
    }
}
